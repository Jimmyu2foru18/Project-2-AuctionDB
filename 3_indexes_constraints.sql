USE auctionbase;

-- Indexes for performance optimization
CREATE INDEX idx_seller ON Items(SellerID);
CREATE INDEX idx_bidder ON Bids(BidderID);
CREATE INDEX idx_item ON Bids(ItemID);
CREATE INDEX idx_auction_end ON Items(EndTime);
CREATE INDEX idx_bid_time ON Bids(BidTime);
CREATE INDEX idx_item_price ON Items(CurrentPrice);
CREATE INDEX idx_category_name ON Categories(CategoryName);
CREATE INDEX idx_user_email ON Users(Email);
CREATE INDEX idx_payment_status ON Auctions(PaymentStatus);
CREATE INDEX idx_shipping_status ON Items(ShippingStatus);

-- Additional constraints for data integrity
ALTER TABLE Users
    ADD CONSTRAINT chk_phone_format 
    CHECK (PhoneNumber REGEXP '^[0-9-+()]{10,15}$');

ALTER TABLE CreditCard
    ADD CONSTRAINT chk_card_number 
    CHECK (CardNumber REGEXP '^[0-9]{13,19}$'),
    ADD CONSTRAINT chk_cvv 
    CHECK (CVVCode REGEXP '^[0-9]{3,4}$');

ALTER TABLE BankInfo
    ADD CONSTRAINT chk_routing 
    CHECK (RoutingNumber REGEXP '^[0-9]{9}$');

ALTER TABLE Items
    ADD CONSTRAINT chk_prices 
    CHECK (StartingPrice > 0 AND CurrentPrice >= StartingPrice);

ALTER TABLE Bids
    ADD CONSTRAINT chk_bid_amount 
    CHECK (BidAmount > 0);

ALTER TABLE ShippingOptions
    ADD CONSTRAINT chk_shipping_price 
    CHECK (Price >= 0),
    ADD CONSTRAINT chk_delivery_time 
    CHECK (EstimatedDeliveryTime > 0);

-- Ensure proper status values
ALTER TABLE Auctions
    ADD CONSTRAINT chk_payment_status 
    CHECK (PaymentStatus IN ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED'));

ALTER TABLE Items
    ADD CONSTRAINT chk_shipping_status 
    CHECK (ShippingStatus IN ('PENDING', 'SHIPPED', 'DELIVERED', 'RETURNED'));

-- Ensure user role consistency
ALTER TABLE Users
    ADD CONSTRAINT chk_user_role 
    CHECK (IsSeller = TRUE OR IsBuyer = TRUE);

-- Add foreign key constraints
ALTER TABLE BankInfo
    ADD CONSTRAINT fk_bank_user
    FOREIGN KEY (UserID) REFERENCES Users(UserID);

