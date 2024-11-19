USE auctionbase;

DELIMITER //

-- Advance system time
CREATE PROCEDURE AdvanceTime(IN minutes INT)
BEGIN
    DECLARE current_sys_time DATETIME;
    
    SELECT CurrentTime INTO current_sys_time FROM Time LIMIT 1;
    
    UPDATE Time 
    SET CurrentTime = DATE_ADD(current_sys_time, INTERVAL minutes MINUTE);
    
    -- Log time advancement
    INSERT INTO SystemLogs (EventType, EventDescription)
    VALUES ('TIME_ADVANCED', 
            CONCAT('System time advanced by ', minutes, ' minutes'));
END//

-- Reset database
CREATE PROCEDURE ResetDatabase()
BEGIN
    SET FOREIGN_KEY_CHECKS = 0;
    
    -- Truncate all tables in proper order
    TRUNCATE TABLE SystemLogs;
    TRUNCATE TABLE SellerReviews;
    TRUNCATE TABLE Bids;
    TRUNCATE TABLE Auctions;
    TRUNCATE TABLE ShippingOptions;
    TRUNCATE TABLE CategoryItems;
    TRUNCATE TABLE Items;
    TRUNCATE TABLE Categories;
    TRUNCATE TABLE CreditCard;
    TRUNCATE TABLE BankInfo;
    TRUNCATE TABLE Users;
    
    SET FOREIGN_KEY_CHECKS = 1;
    
    -- Reset system time
    UPDATE Time SET CurrentTime = NOW();
    
    -- Log database reset
    INSERT INTO SystemLogs (EventType, EventDescription)
    VALUES ('DATABASE_RESET', 'Database has been reset to initial state');
END//

-- Clean up expired auctions
CREATE PROCEDURE CleanupExpiredAuctions()
BEGIN
    DECLARE current_sys_time DATETIME;
    
    SELECT CurrentTime INTO current_sys_time FROM Time LIMIT 1;
    
    -- Close expired auctions that haven't been processed
    INSERT INTO Auctions (ItemID, PaymentStatus)
    SELECT ItemID, 'EXPIRED'
    FROM Items i
    WHERE EndTime < current_sys_time
    AND NOT EXISTS (
        SELECT 1 FROM Auctions a 
        WHERE a.ItemID = i.ItemID
    );
    
    -- Log cleanup
    INSERT INTO SystemLogs (EventType, EventDescription)
    VALUES ('AUCTION_CLEANUP', 'Expired auctions have been processed');
END//

-- Generate auction statistics
CREATE PROCEDURE GenerateAuctionStats()
BEGIN
    SELECT 
        COUNT(*) AS TotalAuctions,
        COUNT(CASE WHEN EndTime > CURRENT_TIMESTAMP THEN 1 END) AS ActiveAuctions,
        COUNT(CASE WHEN EndTime <= CURRENT_TIMESTAMP THEN 1 END) AS CompletedAuctions,
        AVG(CurrentPrice) AS AveragePrice,
        MAX(CurrentPrice) AS HighestPrice,
        AVG(NumberOfBids) AS AverageBidsPerItem
    FROM Items;
    
    SELECT 
        u.Username,
        COUNT(DISTINCT i.ItemID) AS ItemsListed,
        COUNT(DISTINCT a.ItemID) AS AuctionsWon,
        COALESCE(AVG(sr.Rating), 0) AS AverageRating
    FROM Users u
    LEFT JOIN Items i ON u.UserID = i.SellerID
    LEFT JOIN Auctions a ON u.UserID = a.WinningBidderID
    LEFT JOIN SellerReviews sr ON u.UserID = sr.SellerID
    GROUP BY u.UserID, u.Username;
END//

-- Check user status
CREATE PROCEDURE CheckUserStatus(IN p_UserID INT)
BEGIN
    -- Get user's auction activity
    SELECT 
        u.Username,
        u.Email,
        u.IsSeller,
        u.IsBuyer,
        COUNT(DISTINCT i.ItemID) AS ItemsSelling,
        COUNT(DISTINCT b.ItemID) AS ItemsBiddingOn,
        COUNT(DISTINCT a.ItemID) AS AuctionsWon,
        COALESCE(AVG(sr.Rating), 0) AS SellerRating
    FROM Users u
    LEFT JOIN Items i ON u.UserID = i.SellerID AND i.EndTime > CURRENT_TIMESTAMP
    LEFT JOIN Bids b ON u.UserID = b.BidderID
    LEFT JOIN Auctions a ON u.UserID = a.WinningBidderID
    LEFT JOIN SellerReviews sr ON u.UserID = sr.SellerID
    WHERE u.UserID = p_UserID
    GROUP BY u.UserID, u.Username, u.Email, u.IsSeller, u.IsBuyer;
END//

DELIMITER ; 