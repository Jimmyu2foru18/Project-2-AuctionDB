-- Verify tables
SELECT 'Users' as Table_Name, COUNT(*) as Row_Count FROM Users
UNION ALL
SELECT 'Items', COUNT(*) FROM Items
UNION ALL
SELECT 'Bids', COUNT(*) FROM Bids
UNION ALL
SELECT 'Auctions', COUNT(*) FROM Auctions;

-- Verify triggers
SHOW TRIGGERS;

-- Verify procedures
SHOW PROCEDURE STATUS WHERE Db = 'auctionbase';

-- Verify views
SHOW FULL TABLES WHERE Table_type = 'VIEW'; 