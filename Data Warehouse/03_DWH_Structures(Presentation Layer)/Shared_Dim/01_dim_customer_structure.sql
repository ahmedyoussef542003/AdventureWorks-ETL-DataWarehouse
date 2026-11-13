/*******************************************************************************
* Script Name: 01_dim_customer_structure.sql
* Description: Creates the shared.dim_customer dimension table supporting 
*              Slowly Changing Dimension Type 2 (SCD2) tracking for customer profiles.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

-- 1. Create Dim Customer table in the shared schema
CREATE TABLE shared.dim_customer (
    -- Keys
    customer_sk          INT IDENTITY(1,1) PRIMARY KEY,   -- Surrogate Key (PK)
    customer_id          INT NOT NULL,                    -- Source Natural Key (CustomerID)
    
    -- Customer Attributes
    title                NVARCHAR(8) NULL,                -- Title (Mr., Ms., etc.)
    first_name           NVARCHAR(50) NOT NULL,           -- First Name
    middle_name          NVARCHAR(50) NULL,               -- Middle Name
    last_name            NVARCHAR(50) NOT NULL,           -- Last Name
    company_name         NVARCHAR(128) NULL,              -- Company Name
    sales_person         NVARCHAR(256) NULL,              -- Sales Person
    email_address        NVARCHAR(50) NULL,               -- Email Address
    phone                NVARCHAR(25) NULL,               -- Phone Number
    
    -- SCD Type 2 Metadata
    effective_start_date DATETIME2 NOT NULL DEFAULT GETDATE(),
    effective_end_date   DATETIME2 NULL,
    is_current           BIT NOT NULL DEFAULT 1
);
GO

-- 2. Create index to accelerate lookups and joins on Natural Key
CREATE INDEX idx_dim_customer_natural_key ON shared.dim_customer(customer_id);
GO