USE auctionbase;

-- Set initial system time
INSERT INTO Time (CurrentTime) VALUES (NOW());

-- Insert test users
INSERT INTO Users (UserID, Username, Email, Name, Address, PhoneNumber, IsSeller, IsBuyer, RegistrationDate) VALUES
(1, 'john_seller', 'john@email.com', 'John Smith', '123 Seller St', '555-0101', TRUE, FALSE, NOW()),

-- Insert bank information
INSERT INTO BankInfo (UserID, BankName, RoutingNumber, AccountNumber) VALUES
(1, 'First Bank', '123456789', '11111111'),

-- Insert credit card information
INSERT INTO CreditCard (UserID, CardNumber, ExpirationDate, CVVCode, CardholderName, BillingAddress) VALUES
(2, '1111111111111111', '2025-12-31', '123', 'Mary Johnson', '456 Buyer Ave'),


-- Insert categories
INSERT INTO Categories (CategoryID, CategoryName, CategoryDescription) VALUES
(1, 'Electronics', 'Electronic devices and accessories'),

-- Insert items
INSERT INTO Items (ItemID, ItemName, SellerID, Location, Country, Description, StartTime, EndTime, StartingPrice, CurrentPrice, NumberOfBids) VALUES
(1, 'Smartphone XYZ', 1, 'New York', 'USA', 'Brand new smartphone', NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), 299.99, 299.99, 0),


-- Insert category items
INSERT INTO CategoryItems (ItemID, CategoryID) VALUES
(1, 1), 


-- Insert shipping options
INSERT INTO ShippingOptions (ShippingOptionID, SellerID, ShippingMethod, Price, EstimatedDeliveryTime) VALUES
(1, 1, 'Standard Shipping', 9.99, 5),

-- Insert some initial bids
INSERT INTO Bids (BidID, ItemID, BidderID, BidAmount, BidTime) VALUES
(1, 1, 2, 309.99, NOW()),


-- Update current prices based on bids
UPDATE Items SET CurrentPrice = 319.99, NumberOfBids = 2 WHERE ItemID = 1;


-- Insert completed auctions
INSERT INTO Auctions (ItemID, WinningBidderID, SelectedShippingOptionID, PaymentStatus, TrackingInformation, DeliveryConfirmed) VALUES
(1, 5, 2, 'COMPLETED', 'TRACK123456', TRUE),


-- Insert seller reviews
INSERT INTO SellerReviews (ReviewID, SellerID, BuyerID, ItemID, Rating, Feedback, ReviewDate) VALUES
(1, 1, 5, 1, 5, 'Great seller, fast shipping!', NOW()),


-- Insert some system logs
INSERT INTO SystemLogs (EventType, EventDescription, RelatedEntityID, EntityType, UserID) VALUES
('NEW_BID', 'New bid placed: $319.99', 1, 'BID', 5),

