# AuctionBase System

## Overview
AuctionDB

## Features
- User registration (buyers and sellers)
- Item listing and categorization
- Bidding system with real-time validation
- Payment processing
- Shipping management
- Seller rating system
- Comprehensive activity tracking

## Database Structure

### Core Tables
- Users
- Items
- Categories
- Bids
- Auctions
- ShippingOptions
- SellerReviews

### Views
- ActiveAuctions
- UserRatings

## Core Constraints
1. No duplicate User IDs
2. All sellers/bidders must be registered users
3. Bidders must have valid credit cards
4. No duplicate Item IDs
5. All bids must reference valid items
6. No duplicate category assignments
7. Auction end time must be after start time
8. Current price matches highest bid
9. No self-bidding
10. No simultaneous bids
11. Bids must be within auction timeframe
12. No duplicate bid amounts
13. Accurate bid count tracking
14. Bids must be higher than previous bids
15. Bids must match current system time
16. System time can only move forward

## Utility Procedures
- AdvanceTime
- ResetDatabase
- CleanupExpiredAuctions
- GenerateAuctionStats
- CheckUserStatus

## Data Import
Use the provided Python script to import eBay data:
```
python
python import_ebay_data.py
```

## File Structure
```bash
Project2:AuctionDB/
├── 1_database_setup.sql
├── 2_create_tables.sql
├── 3_indexes_constraints.sql
├── 4_triggers.sql
├── 5_views.sql
├── 6_stored_procedures.sql
├── 7_initial_data.sql
├── 8_utility_procedures.sql
├── install_auctionbase.sql
└── verify_installation.sql
├── EERD.txt
└── constraints.txt
└── import_ebay_data.py
```
## Requirements
- MySQL 5.7 or higher
- Python 3.6+ (for data import)
- MySQL Connector/Python

## Notes
- Ensure proper permissions are set for database operations
- Run verification after installation
- Check system logs for operation tracking
- Regular maintenance recommended using utility procedures
