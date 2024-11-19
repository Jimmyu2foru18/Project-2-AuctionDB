USE auctionbase;

DELIMITER //

-- Complete an auction
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
    
    -- Create auction record
    INSERT INTO Auctions (
        ItemID, 
        WinningBidderID, 
        PaymentStatus
    ) VALUES (
        p_ItemID, 
        v_WinningBidderID, 
        'PENDING'
    );
    
    -- Log auction completion
    INSERT INTO SystemLogs (
        EventType, 
        EventDescription, 
        RelatedEntityID, 
        EntityType
    ) VALUES (
        'AUCTION_COMPLETED',
        CONCAT('Auction completed with winning bid: $', v_HighestBid),
        p_ItemID,
        'AUCTION'
    );
END//

-- Process payment for auction
CREATE PROCEDURE ProcessPayment(
    IN p_ItemID INT,
    IN p_ShippingOptionID INT
)
BEGIN
    DECLARE v_Amount DECIMAL(10,2);
    DECLARE v_ShippingCost DECIMAL(10,2);
    DECLARE v_WinningBidderID INT;
    
    -- Get auction details
    SELECT CurrentPrice, WinningBidderID 
    INTO v_Amount, v_WinningBidderID
    FROM Items i
    JOIN Auctions a ON i.ItemID = a.ItemID
    WHERE i.ItemID = p_ItemID;
    
    -- Get shipping cost
    SELECT Price INTO v_ShippingCost 
    FROM ShippingOptions 
    WHERE ShippingOptionID = p_ShippingOptionID;
    
    -- Update Auction with shipping selection and payment status
    UPDATE Auctions 
    SET PaymentStatus = 'COMPLETED',
        SelectedShippingOptionID = p_ShippingOptionID
    WHERE ItemID = p_ItemID;
    
    -- Log the payment
    INSERT INTO SystemLogs (
        EventType, 
        EventDescription, 
        RelatedEntityID, 
        EntityType,
        UserID
    ) VALUES (
        'PAYMENT_PROCESSED',
        CONCAT('Payment processed: $', v_Amount + v_ShippingCost),
        p_ItemID,
        'PAYMENT',
        v_WinningBidderID
    );
END//

-- Update shipping status
CREATE PROCEDURE UpdateShippingStatus(
    IN p_ItemID INT,
    IN p_TrackingInfo VARCHAR(200),
    IN p_Status VARCHAR(50)
)
BEGIN
    -- Update auction shipping info
    UPDATE Auctions
    SET TrackingInformation = p_TrackingInfo
    WHERE ItemID = p_ItemID;
    
    -- Update item shipping status
    UPDATE Items
    SET ShippingStatus = p_Status
    WHERE ItemID = p_ItemID;
    
    -- Log shipping update
    INSERT INTO SystemLogs (
        EventType, 
        EventDescription, 
        RelatedEntityID, 
        EntityType
    ) VALUES (
        'SHIPPING_UPDATE',
        CONCAT('Shipping status updated to: ', p_Status),
        p_ItemID,
        'SHIPPING'
    );
END//

-- Confirm delivery
CREATE PROCEDURE ConfirmDelivery(IN p_ItemID INT)
BEGIN
    UPDATE Auctions
    SET DeliveryConfirmed = TRUE
    WHERE ItemID = p_ItemID;
    
    UPDATE Items
    SET ShippingStatus = 'DELIVERED'
    WHERE ItemID = p_ItemID;
    
    -- Log delivery confirmation
    INSERT INTO SystemLogs (
        EventType, 
        EventDescription, 
        RelatedEntityID, 
        EntityType
    ) VALUES (
        'DELIVERY_CONFIRMED',
        'Delivery confirmed by buyer',
        p_ItemID,
        'SHIPPING'
    );
END//

-- Add seller review
CREATE PROCEDURE AddSellerReview(
    IN p_ItemID INT,
    IN p_BuyerID INT,
    IN p_Rating INT,
    IN p_Feedback TEXT
)
BEGIN
    DECLARE v_SellerID INT;
    
    -- Get seller ID
    SELECT SellerID INTO v_SellerID
    FROM Items
    WHERE ItemID = p_ItemID;
    
    -- Add review
    INSERT INTO SellerReviews (
        SellerID,
        BuyerID,
        ItemID,
        Rating,
        Feedback
    ) VALUES (
        v_SellerID,
        p_BuyerID,
        p_ItemID,
        p_Rating,
        p_Feedback
    );
    
    -- Log review
    INSERT INTO SystemLogs (
        EventType, 
        EventDescription, 
        RelatedEntityID, 
        EntityType,
        UserID
    ) VALUES (
        'SELLER_REVIEW',
        CONCAT('New seller review: ', p_Rating, ' stars'),
        p_ItemID,
        'REVIEW',
        p_BuyerID
    );
END//

DELIMITER ; 