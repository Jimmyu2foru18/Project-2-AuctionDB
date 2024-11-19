DELIMITER //

-- Auction Completion Procedure
CREATE PROCEDURE CompleteAuction(IN p_ItemID INT)
BEGIN
    DECLARE v_WinningBidderID INT;
    DECLARE v_HighestBid DECIMAL(10,2);
    
    -- Get winning bid info
    SELECT BidderID, BidAmount INTO v_WinningBidderID, v_HighestBid
    FROM Bids 
    WHERE ItemID = p_ItemID 
    ORDER BY BidAmount DESC 
    LIMIT 1;
    
    -- Update Auctions table
    INSERT INTO Auctions (ItemID, WinningBidderID, PaymentStatus)
    VALUES (p_ItemID, v_WinningBidderID, 'PENDING_PAYMENT');
    
    -- Log the event
    INSERT INTO SystemLogs (EventType, EventDescription, RelatedEntityID, EntityType)
    VALUES ('AUCTION_COMPLETED', 
            CONCAT('Auction completed with winning bid: $', v_HighestBid),
            p_ItemID, 
            'ITEM');
END//

-- Payment Processing Procedure
CREATE PROCEDURE ProcessPayment(IN p_ItemID INT, IN p_ShippingOptionID INT)
BEGIN
    DECLARE v_Amount DECIMAL(10,2);
    DECLARE v_ShippingCost DECIMAL(10,2);
    
    -- Get bid amount and shipping cost
    SELECT CurrentPrice INTO v_Amount FROM Items WHERE ItemID = p_ItemID;
    SELECT Price INTO v_ShippingCost FROM ShippingOptions WHERE ShippingOptionID = p_ShippingOptionID;
    
    -- Update Auction with shipping selection and payment status
    UPDATE Auctions 
    SET PaymentStatus = 'COMPLETED',
        SelectedShippingOptionID = p_ShippingOptionID
    WHERE ItemID = p_ItemID;
    
    -- Log the payment
    INSERT INTO SystemLogs (EventType, EventDescription, RelatedEntityID, EntityType)
    VALUES ('PAYMENT_PROCESSED', 
            CONCAT('Payment processed: $', v_Amount + v_ShippingCost),
            p_ItemID,
            'PAYMENT');
END//

-- Update Shipping Status Procedure
CREATE PROCEDURE UpdateShippingStatus(
    IN p_ItemID INT,
    IN p_TrackingInfo VARCHAR(200),
    IN p_Status VARCHAR(50)
)
BEGIN
    UPDATE Auctions
    SET TrackingInformation = p_TrackingInfo,
        ShippingStatus = p_Status
    WHERE ItemID = p_ItemID;
    
    -- Log shipping update
    INSERT INTO SystemLogs (EventType, EventDescription, RelatedEntityID, EntityType)
    VALUES ('SHIPPING_UPDATE', 
            CONCAT('Shipping status updated to: ', p_Status),
            p_ItemID,
            'SHIPPING');
END//

DELIMITER ; 