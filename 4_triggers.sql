USE auctionbase;

DELIMITER //

-- Prevent bidding on own items
CREATE TRIGGER prevent_self_bidding
BEFORE INSERT ON Bids
FOR EACH ROW
BEGIN
    DECLARE seller_id INT;
    SELECT SellerID INTO seller_id FROM Items WHERE ItemID = NEW.ItemID;
    
    IF seller_id = NEW.BidderID THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot bid on your own item';
    END IF;
END//

-- Validate bid amount
CREATE TRIGGER validate_bid_amount
BEFORE INSERT ON Bids
FOR EACH ROW
BEGIN
    DECLARE max_bid DECIMAL(10,2);
    DECLARE start_price DECIMAL(10,2);
    
    SELECT COALESCE(MAX(BidAmount), 0), StartingPrice 
    INTO max_bid, start_price
    FROM Bids b
    RIGHT JOIN Items i ON b.ItemID = i.ItemID
    WHERE i.ItemID = NEW.ItemID;
    
    IF NEW.BidAmount <= max_bid THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Bid must be higher than previous bids';
    ELSEIF NEW.BidAmount < start_price THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bid must be at least the starting price';
    END IF;
END//

-- Validate bid time
CREATE TRIGGER validate_bid_time
BEFORE INSERT ON Bids
FOR EACH ROW
BEGIN
    DECLARE item_start DATETIME;
    DECLARE item_end DATETIME;
    DECLARE current_sys_time DATETIME;
    
    SELECT StartTime, EndTime 
    INTO item_start, item_end 
    FROM Items 
    WHERE ItemID = NEW.ItemID;
    
    SELECT CurrentTime INTO current_sys_time FROM Time LIMIT 1;
    
    IF NEW.BidTime < item_start OR NEW.BidTime > item_end THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Bid time must be within auction period';
    ELSEIF NEW.BidTime != current_sys_time THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bid time must match current system time';
    END IF;
END//

-- Update bid count and current price
CREATE TRIGGER update_bid_count
AFTER INSERT ON Bids
FOR EACH ROW
BEGIN
    UPDATE Items 
    SET NumberOfBids = NumberOfBids + 1,
        CurrentPrice = NEW.BidAmount
    WHERE ItemID = NEW.ItemID;
    
    -- Log the bid
    INSERT INTO SystemLogs (EventType, EventDescription, RelatedEntityID, EntityType, UserID)
    VALUES ('NEW_BID', 
            CONCAT('New bid placed: $', NEW.BidAmount),
            NEW.ItemID,
            'BID',
            NEW.BidderID);
END//

-- Validate system time
CREATE TRIGGER validate_current_time
BEFORE UPDATE ON Time
FOR EACH ROW
BEGIN
    IF NEW.CurrentTime < OLD.CurrentTime THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'System time cannot move backward';
    END IF;
END//

-- Enforce shipping deadline
CREATE TRIGGER enforce_shipping_deadline
BEFORE UPDATE ON Auctions
FOR EACH ROW
BEGIN
    IF NEW.PaymentStatus = 'COMPLETED' 
    AND OLD.PaymentStatus != 'COMPLETED' THEN
        SET NEW.ShipByDate = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 2 DAY);
        
        -- Log payment completion
        INSERT INTO SystemLogs (EventType, EventDescription, RelatedEntityID, EntityType)
        VALUES ('PAYMENT_COMPLETED', 
                'Payment completed, shipping deadline set',
                NEW.ItemID,
                'AUCTION');
    END IF;
    
    IF NEW.TrackingInformation IS NOT NULL 
    AND OLD.TrackingInformation IS NULL THEN
        SET NEW.ActualShipDate = CURRENT_TIMESTAMP;
        
        IF NEW.ActualShipDate > NEW.ShipByDate THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Shipping deadline exceeded';
        END IF;
        
        -- Log shipment
        INSERT INTO SystemLogs (EventType, EventDescription, RelatedEntityID, EntityType)
        VALUES ('ITEM_SHIPPED', 
                CONCAT('Item shipped with tracking: ', NEW.TrackingInformation),
                NEW.ItemID,
                'AUCTION');
    END IF;
END//

-- Auto-close auction
CREATE TRIGGER close_auction
AFTER UPDATE ON Time
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE auction_id INT;
    DECLARE cur CURSOR FOR 
        SELECT ItemID 
        FROM Items 
        WHERE EndTime <= NEW.CurrentTime 
        AND ItemID NOT IN (SELECT ItemID FROM Auctions);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO auction_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Call procedure to complete auction
        CALL CompleteAuction(auction_id);
    END LOOP;
    
    CLOSE cur;
END//

DELIMITER ; 