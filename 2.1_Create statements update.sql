-- Create table for User
CREATE TABLE User (
    user_id INT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    address TEXT,
    phone_number VARCHAR(15),
    user_type ENUM('buyer', 'seller', 'both') NOT NULL
);

-- Create table for Item
CREATE TABLE Item (
    item_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    seller_id INT,
    FOREIGN KEY (seller_id) REFERENCES User(user_id)
);

-- Create table for Category
CREATE TABLE Category (
    category_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT
);

-- Create table for Auction
CREATE TABLE Auction (
    auction_id INT PRIMARY KEY,
    item_id INT,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    starting_price DECIMAL(10, 2) NOT NULL,
    number_of_bids INT DEFAULT 0,
    last_price DECIMAL(10, 2) DEFAULT NULL,
    FOREIGN KEY (item_id) REFERENCES Item(item_id)
);

-- Create table for Bid
CREATE TABLE Bid (
    bid_id INT PRIMARY KEY,
    auction_id INT,
    buyer_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    timestamp DATETIME NOT NULL,
    FOREIGN KEY (auction_id) REFERENCES Auction(auction_id),
    FOREIGN KEY (buyer_id) REFERENCES User(user_id)
);

-- Create table for Review
CREATE TABLE Review (
    review_id INT PRIMARY KEY,
    buyer_id INT,
    seller_id INT,
    rating TINYINT CHECK (rating BETWEEN 1 AND 5),
    feedback TEXT,
    FOREIGN KEY (buyer_id) REFERENCES User(user_id),
    FOREIGN KEY (seller_id) REFERENCES User(user_id)
);

-- Create table for ShippingOption
CREATE TABLE ShippingOption (
    option_id INT PRIMARY KEY,
    seller_id INT,
    price DECIMAL(10, 2) NOT NULL,
    estimated_time VARCHAR(255),
    type ENUM('pickup', 'delivery') NOT NULL,
    FOREIGN KEY (seller_id) REFERENCES User(user_id)
);

-- Create table for BankInformation
CREATE TABLE BankInformation (
    bank_id INT PRIMARY KEY,
    seller_id INT,
    bank_name VARCHAR(255) NOT NULL,
    routing_number VARCHAR(50) NOT NULL,
    account_number VARCHAR(50) NOT NULL,
    FOREIGN KEY (seller_id) REFERENCES User(user_id)
);

-- Create table for Payment
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY,
    buyer_id INT,
    auction_id INT,
    card_number VARCHAR(16) NOT NULL,
    expiration_date DATE NOT NULL,
    ccv CHAR(3) NOT NULL,
    name_on_card VARCHAR(255) NOT NULL,
    billing_address TEXT NOT NULL,
    shipping_option_id INT,
    status ENUM('paid', 'unpaid') NOT NULL,
    FOREIGN KEY (buyer_id) REFERENCES User(user_id),
    FOREIGN KEY (auction_id) REFERENCES Auction(auction_id),
    FOREIGN KEY (shipping_option_id) REFERENCES ShippingOption(option_id)
);

-- Create table for Shipment
CREATE TABLE Shipment (
    shipment_id INT PRIMARY KEY,
    auction_id INT,
    tracking_number VARCHAR(255),
    status ENUM('shipped', 'delivered', 'pending') NOT NULL,
    confirmation BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (auction_id) REFERENCES Auction(auction_id)
);
