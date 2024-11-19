USE auctionbase;

-- Active Auctions View
CREATE VIEW ActiveAuctions AS
SELECT 
    i.ItemID,
    i.ItemName,
    i.CurrentPrice,
    i.NumberOfBids,
    i.EndTime,
    u.Username AS SellerName,
    TIMESTAMPDIFF(HOUR, CURRENT_TIMESTAMP, i.EndTime) AS HoursRemaining,
    GROUP_CONCAT(c.CategoryName) AS Categories
FROM Items i
JOIN Users u ON i.SellerID = u.UserID
LEFT JOIN CategoryItems ci ON i.ItemID = ci.ItemID
LEFT JOIN Categories c ON ci.CategoryID = c.CategoryID
WHERE i.EndTime > CURRENT_TIMESTAMP
AND i.ItemID NOT IN (SELECT ItemID FROM Auctions WHERE PaymentStatus = 'COMPLETED')
GROUP BY i.ItemID, i.ItemName, i.CurrentPrice, i.NumberOfBids, i.EndTime, u.Username;

-- User Ratings View
CREATE VIEW UserRatings AS
SELECT 
    sr.SellerID,
    u.Username,
    COUNT(*) AS TotalReviews,
    ROUND(AVG(sr.Rating), 2) AS AverageRating,
    COUNT(CASE WHEN sr.Rating = 5 THEN 1 END) AS FiveStarReviews,
    COUNT(CASE WHEN sr.Rating = 1 THEN 1 END) AS OneStarReviews,
    MAX(sr.ReviewDate) AS LastReviewDate
FROM SellerReviews sr
JOIN Users u ON sr.SellerID = u.UserID
GROUP BY sr.SellerID, u.Username;

-- Auction History View
CREATE VIEW AuctionHistory AS
SELECT 
    i.ItemID,
    i.ItemName,
    i.StartTime,
    i.EndTime,
    i.StartingPrice,
    i.CurrentPrice AS FinalPrice,
    i.NumberOfBids,
    s.Username AS SellerName,
    b.Username AS WinnerName,
    a.PaymentStatus,
    a.ShippingStatus,
    so.ShippingMethod,
    so.Price AS ShippingCost,
    a.TrackingInformation,
    a.DeliveryConfirmed
FROM Items i
LEFT JOIN Auctions a ON i.ItemID = a.ItemID
LEFT JOIN Users s ON i.SellerID = s.UserID
LEFT JOIN Users b ON a.WinningBidderID = b.UserID
LEFT JOIN ShippingOptions so ON a.SelectedShippingOptionID = so.ShippingOptionID
WHERE i.EndTime < CURRENT_TIMESTAMP;

-- Recent Activity View
CREATE VIEW RecentActivity AS
SELECT 
    'BID' AS ActivityType,
    b.BidTime AS ActivityTime,
    i.ItemID,
    i.ItemName,
    u.Username,
    b.BidAmount AS Amount,
    NULL AS Status
FROM Bids b
JOIN Items i ON b.ItemID = i.ItemID
JOIN Users u ON b.BidderID = u.UserID
UNION ALL
SELECT 
    'PAYMENT' AS ActivityType,
    l.CreatedAt AS ActivityTime,
    l.RelatedEntityID AS ItemID,
    i.ItemName,
    u.Username,
    i.CurrentPrice AS Amount,
    a.PaymentStatus AS Status
FROM SystemLogs l
JOIN Items i ON l.RelatedEntityID = i.ItemID
JOIN Auctions a ON i.ItemID = a.ItemID
JOIN Users u ON a.WinningBidderID = u.UserID
WHERE l.EventType = 'PAYMENT_PROCESSED'
UNION ALL
SELECT 
    'SHIPPING' AS ActivityType,
    l.CreatedAt AS ActivityTime,
    l.RelatedEntityID AS ItemID,
    i.ItemName,
    u.Username,
    NULL AS Amount,
    i.ShippingStatus AS Status
FROM SystemLogs l
JOIN Items i ON l.RelatedEntityID = i.ItemID
JOIN Users u ON i.SellerID = u.UserID
WHERE l.EventType = 'ITEM_SHIPPED'
ORDER BY ActivityTime DESC
LIMIT 100;

-- User Activity Summary View
CREATE VIEW UserActivitySummary AS
SELECT 
    u.UserID,
    u.Username,
    COUNT(DISTINCT i.ItemID) AS ItemsSold,
    COUNT(DISTINCT b.ItemID) AS ItemsBidOn,
    COUNT(DISTINCT CASE WHEN a.WinningBidderID = u.UserID THEN a.ItemID END) AS AuctionsWon,
    COALESCE(AVG(sr.Rating), 0) AS SellerRating
FROM Users u
LEFT JOIN Items i ON u.UserID = i.SellerID
LEFT JOIN Bids b ON u.UserID = b.BidderID
LEFT JOIN Auctions a ON u.UserID = a.WinningBidderID
LEFT JOIN SellerReviews sr ON u.UserID = sr.SellerID
GROUP BY u.UserID, u.Username;

-- Shipping Status View
CREATE VIEW ShippingStatusView AS
SELECT 
    i.ItemID,
    i.ItemName,
    s.Username AS SellerName,
    b.Username AS BuyerName,
    a.PaymentStatus,
    i.ShippingStatus,
    so.ShippingMethod,
    a.ShipByDate,
    a.ActualShipDate,
    a.TrackingInformation,
    CASE 
        WHEN a.ActualShipDate > a.ShipByDate THEN 'LATE'
        WHEN a.ActualShipDate IS NULL AND CURRENT_TIMESTAMP > a.ShipByDate THEN 'OVERDUE'
        ELSE 'ON_TIME'
    END AS ShippingTimeStatus
FROM Items i
JOIN Auctions a ON i.ItemID = a.ItemID
JOIN Users s ON i.SellerID = s.UserID
JOIN Users b ON a.WinningBidderID = b.UserID
JOIN ShippingOptions so ON a.SelectedShippingOptionID = so.ShippingOptionID
WHERE a.PaymentStatus = 'COMPLETED';

