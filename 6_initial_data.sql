USE auctionbase;

-- Set initial system time
INSERT INTO Time (CurrentTime) VALUES (NOW());

-- Insert test users
INSERT INTO Users (UserID, Username, Email, Name, Address, PhoneNumber, IsSeller, IsBuyer, RegistrationDate) VALUES
(1, 'john_seller', 'john@email.com', 'John Smith', '123 Seller St', '555-0101', TRUE, FALSE, NOW()),
(2, 'mary_buyer', 'mary@email.com', 'Mary Johnson', '456 Buyer Ave', '555-0102', FALSE, TRUE, NOW()),
(3, 'bob_both', 'bob@email.com', 'Bob Wilson', '789 Both Rd', '555-0103', TRUE, TRUE, NOW()),
(4, 'alice_seller', 'alice@email.com', 'Alice Brown', '321 Seller Ln', '555-0104', TRUE, FALSE, NOW()),
(5, 'david_buyer', 'david@email.com', 'David Lee', '654 Buyer Blvd', '555-0105', FALSE, TRUE, NOW());

-- Insert bank information
INSERT INTO BankInfo (UserID, BankName, RoutingNumber, AccountNumber) VALUES
(1, 'First Bank', '123456789', '11111111'),
(3, 'Second Bank', '987654321', '22222222'),
(4, 'Third Bank', '456789123', '33333333');

-- Insert credit card information
INSERT INTO CreditCard (UserID, CardNumber, ExpirationDate, CVVCode, CardholderName, BillingAddress) VALUES
(2, '4111111111111111', '2025-12-31', '123', 'Mary Johnson', '456 Buyer Ave'),
(3, '5555555555554444', '2024-12-31', '456', 'Bob Wilson', '789 Both Rd'),
(5, '4012888888881881', '2026-12-31', '789', 'David Lee', '654 Buyer Blvd');

-- Insert categories
INSERT INTO Categories (CategoryID, CategoryName, CategoryDescription) VALUES
(1, 'Electronics', 'Electronic devices and accessories'),
(2, 'Books', 'Books and publications'),
(3, 'Clothing', 'Apparel and accessories'),
(4, 'Home & Garden', 'Home improvement and garden items'),
(5, 'Sports', 'Sporting goods and equipment');

-- Insert items
INSERT INTO Items (ItemID, ItemName, SellerID, Location, Country, Description, StartTime, EndTime, StartingPrice, CurrentPrice, NumberOfBids) VALUES
(1, 'Smartphone XYZ', 1, 'New York', 'USA', 'Brand new smartphone', NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), 299.99, 299.99, 0),
(2, 'Classic Novel Collection', 4, 'London', 'UK', 'Set of 10 classic novels', NOW(), DATE_ADD(NOW(), INTERVAL 5 DAY), 49.99, 49.99, 0),
(3, 'Tennis Racket Pro', 3, 'Paris', 'France', 'Professional tennis racket', NOW(), DATE_ADD(NOW(), INTERVAL 3 DAY), 89.99, 89.99, 0),
(4, 'Garden Tool Set', 1, 'Berlin', 'Germany', 'Complete garden tool set', NOW(), DATE_ADD(NOW(), INTERVAL 10 DAY), 149.99, 149.99, 0),
(5, 'Designer Watch', 4, 'Milan', 'Italy', 'Luxury designer watch', NOW(), DATE_ADD(NOW(), INTERVAL 6 DAY), 999.99, 999.99, 0);

-- Insert category items
INSERT INTO CategoryItems (ItemID, CategoryID) VALUES
(1, 1),  -- Smartphone in Electronics
(2, 2),  -- Books in Books
(3, 5),  -- Tennis Racket in Sports
(4, 4),  -- Garden Tool Set in Home & Garden
(5, 1);  -- Watch in Electronics

-- Insert shipping options
INSERT INTO ShippingOptions (ShippingOptionID, SellerID, ShippingMethod, Price, EstimatedDeliveryTime) VALUES
(1, 1, 'Standard Shipping', 9.99, 5),
(2, 1, 'Express Shipping', 19.99, 2),
(3, 3, 'Standard Shipping', 8.99, 5),
(4, 3, 'Express Shipping', 24.99, 2),
(5, 4, 'Standard Shipping', 7.99, 5),
(6, 4, 'Express Shipping', 22.99, 2);

-- Insert some initial bids
INSERT INTO Bids (BidID, ItemID, BidderID, BidAmount, BidTime) VALUES
(1, 1, 2, 309.99, NOW()),
(2, 1, 5, 319.99, NOW()),
(3, 2, 3, 54.99, NOW()),
(4, 3, 2, 94.99, NOW()),
(5, 5, 5, 1049.99, NOW());

-- Update current prices based on bids
UPDATE Items SET CurrentPrice = 319.99, NumberOfBids = 2 WHERE ItemID = 1;
UPDATE Items SET CurrentPrice = 54.99, NumberOfBids = 1 WHERE ItemID = 2;
UPDATE Items SET CurrentPrice = 94.99, NumberOfBids = 1 WHERE ItemID = 3;
UPDATE Items SET CurrentPrice = 1049.99, NumberOfBids = 1 WHERE ItemID = 5;

-- Insert completed auctions
INSERT INTO Auctions (ItemID, WinningBidderID, SelectedShippingOptionID, PaymentStatus, TrackingInformation, DeliveryConfirmed) VALUES
(1, 5, 2, 'COMPLETED', 'TRACK123456', TRUE),
(2, 3, 5, 'PENDING', NULL, FALSE);

-- Insert seller reviews
INSERT INTO SellerReviews (ReviewID, SellerID, BuyerID, ItemID, Rating, Feedback, ReviewDate) VALUES
(1, 1, 5, 1, 5, 'Great seller, fast shipping!', NOW()),
(2, 4, 3, 2, 4, 'Good experience overall', NOW());

-- Insert some system logs
INSERT INTO SystemLogs (EventType, EventDescription, RelatedEntityID, EntityType, UserID) VALUES
('NEW_BID', 'New bid placed: $319.99', 1, 'BID', 5),
('PAYMENT_COMPLETED', 'Payment processed for item', 1, 'PAYMENT', 5),
('SHIPPING_UPDATE', 'Item shipped with tracking: TRACK123456', 1, 'SHIPPING', 1);
