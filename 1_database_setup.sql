-- Create and use database

CREATE DATABASE IF NOT EXISTS auctionbase;
USE auctionbase;

-- Enable strict mode for better data integrity
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'; 