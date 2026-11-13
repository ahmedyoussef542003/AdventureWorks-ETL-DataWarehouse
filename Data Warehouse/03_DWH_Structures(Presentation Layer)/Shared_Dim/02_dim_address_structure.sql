/*******************************************************************************
* Script Name: 02_dim_address_structure.sql
* Description: Creates the shared.dim_address dimension table supporting 
*              SCD Type 2 tracking, storing customer addresses with full geographic hierarchy.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

-- Create the Dim Address table under the shared schema
CREATE TABLE shared.dim_address (
    -- Keys
    address_sk           INT IDENTITY(1,1) PRIMARY KEY,   -- Surrogate Key (PK)
    address_id           INT NOT NULL,                    -- Source Natural Key (AddressID)
    customer_id          INT NULL,                        -- Customer ID linked from mapping
    
    -- Address Attributes & Hierarchy
    address_line_1       NVARCHAR(60) NOT NULL,           -- Address Line 1
    address_line_2       NVARCHAR(60) NULL,               -- Address Line 2
    city                 NVARCHAR(30) NOT NULL,           -- City (Lowest geographical level)
    state_province       NVARCHAR(50) NOT NULL,           -- State / Province (Middle level)
    country_region       NVARCHAR(50) NOT NULL,           -- Country / Region (Highest level)
    postal_code          NVARCHAR(15) NOT NULL,           -- Postal Code
    address_type         NVARCHAR(50) NULL,               -- Address Type (Billing, Shipping, etc.)
    
    -- SCD Type 2 Metadata (Slowly Changing Dimension)
    effective_start_date DATETIME2 NOT NULL DEFAULT GETDATE(),
    effective_end_date   DATETIME2 NULL,
    is_current           BIT NOT NULL DEFAULT 1
);
GO

-- Create indexes to optimize lookups and Fact Table joins
CREATE INDEX idx_dim_address_natural_key ON shared.dim_address(address_id);
CREATE INDEX idx_dim_address_customer ON shared.dim_address(customer_id);
GO