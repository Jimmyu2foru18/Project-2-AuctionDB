-- Create all tables for AuctionBase
USE auctionbase;

-- System Time 
CREATE TABLE Time (
    CurrentTime DATETIME NOT NULL
);

-- Users table
CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(200),
    PhoneNumber VARCHAR(20),
    IsSeller BOOLEAN DEFAULT FALSE,
    IsBuyer BOOLEAN DEFAULT FALSE,
    RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    LastLoginDate DATETIME
);

-- Bank Information
CREATE TABLE BankInfo (
    UserID INT PRIMARY KEY,
    BankName VARCHAR(100) NOT NULL,
    RoutingNumber VARCHAR(50) NOT NULL,
    AccountNumber VARCHAR(50) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Credit Card Information
CREATE TABLE CreditCard (
    UserID INT PRIMARY KEY,
    CardNumber VARCHAR(20) NOT NULL,
    ExpirationDate DATE NOT NULL,
    CVVCode VARCHAR(4) NOT NULL,
    CardholderName VARCHAR(100) NOT NULL,
    BillingAddress VARCHAR(200) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT valid_expiration CHECK (ExpirationDate > CURRENT_DATE)
);

-- Categories
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) UNIQUE NOT NULL,
    CategoryDescription TEXT
);

-- Items
CREATE TABLE Items (
    ItemID INT PRIMARY KEY,
    ItemName VARCHAR(255) NOT NULL,
    SellerID INT NOT NULL,
    Location VARCHAR(255),
    Country VARCHAR(100),
    Description TEXT,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    StartingPrice DECIMAL(10,2) NOT NULL,
    CurrentPrice DECIMAL(10,2) NOT NULL,
    NumberOfBids INT DEFAULT 0,
    ShippingStatus VARCHAR(50),
    PaymentStatus VARCHAR(50),
    FOREIGN KEY (SellerID) REFERENCES Users(UserID),
    CHECK (EndTime > StartTime)
);

-- Category Items Junction
CREATE TABLE CategoryItems (
    ItemID INT,
    CategoryID INT,
    PRIMARY KEY (ItemID, CategoryID),
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Shipping Options
CREATE TABLE ShippingOptions (
    ShippingOptionID INT PRIMARY KEY,
    SellerID INT NOT NULL,
    ShippingMethod VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    EstimatedDeliveryTime INT,
    FOREIGN KEY (SellerID) REFERENCES Users(UserID)
);

-- Bids
CREATE TABLE Bids (
    BidID INT PRIMARY KEY,
    ItemID INT NOT NULL,
    BidderID INT NOT NULL,
    BidAmount DECIMAL(10,2) NOT NULL,
    BidTime DATETIME NOT NULL,
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
    FOREIGN KEY (BidderID) REFERENCES Users(UserID),
    UNIQUE (ItemID, BidAmount),
    UNIQUE (ItemID, BidTime),
    CONSTRAINT chk_bid_time CHECK (BidTime = (SELECT CurrentTime FROM Time LIMIT 1))
);

-- Auctions
CREATE TABLE Auctions (
    ItemID INT PRIMARY KEY,
    WinningBidderID INT,
    SelectedShippingOptionID INT,
    PaymentStatus VARCHAR(50),
    TrackingInformation VARCHAR(200),
    DeliveryConfirmed BOOLEAN DEFAULT FALSE,
    ShipByDate DATETIME,
    ActualShipDate DATETIME,
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
    FOREIGN KEY (WinningBidderID) REFERENCES Users(UserID),
    FOREIGN KEY (SelectedShippingOptionID) REFERENCES ShippingOptions(ShippingOptionID)
);

-- Seller Reviews
CREATE TABLE SellerReviews (
    ReviewID INT PRIMARY KEY,
    SellerID INT NOT NULL,
    BuyerID INT NOT NULL,
    ItemID INT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Feedback TEXT,
    ReviewDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SellerID) REFERENCES Users(UserID),
    FOREIGN KEY (BuyerID) REFERENCES Users(UserID),
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
    CONSTRAINT unique_buyer_review UNIQUE (SellerID, BuyerID, ItemID)
);

-- System Logs
CREATE TABLE SystemLogs (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    EventType VARCHAR(50) NOT NULL,
    EventDescription TEXT,
    RelatedEntityID INT,
    EntityType VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UserID INT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);