/*******************************************************************************
* Script Name: 03_dim_product_structure.sql
* Description: Creates the shared.dim_product dimension table supporting SCD Type 2,
*              integrating core attributes, category hierarchies, models, and descriptions.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

-- 1. Ensure shared schema exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'shared')
BEGIN
    EXEC('CREATE SCHEMA shared');
END
GO

-- 2. Create shared.dim_product table
CREATE TABLE shared.dim_product (
    -- Keys
    product_sk           INT IDENTITY(1,1) PRIMARY KEY,   -- Surrogate Key (PK)
    product_id           INT NOT NULL,                    -- Source Natural Key[cite: 4]
    
    -- Product Core Attributes
    product_name         NVARCHAR(100) NOT NULL,          -- Product Name[cite: 4]
    product_number       NVARCHAR(25) NOT NULL,           -- Product Number[cite: 4]
    color                NVARCHAR(15) NULL,               -- Color[cite: 4]
    standard_cost        DECIMAL(19, 4) NOT NULL,         -- Standard Cost[cite: 4]
    list_price           DECIMAL(19, 4) NOT NULL,         -- List Price[cite: 4]
    size                 NVARCHAR(5) NULL,                -- Size[cite: 4]
    weight               DECIMAL(8, 2) NULL,              -- Weight[cite: 4]
    
    -- Category Hierarchy[cite: 4]
    product_category_id  INT NULL,                        -- Category ID[cite: 4]
    subcategory_name     NVARCHAR(50) NULL,               -- Subcategory Name[cite: 4]
    category_name        NVARCHAR(50) NULL,               -- Parent Category Name[cite: 4]
    
    -- Model & Description[cite: 4]
    product_model_id     INT NULL,                        -- Model ID[cite: 4]
    product_model_name   NVARCHAR(50) NULL,               -- Model Name[cite: 4]
    product_description  NVARCHAR(MAX) NULL,              -- Product Description[cite: 4]
    
    -- Lifecycle Dates
    sell_start_date      DATETIME2 NOT NULL,              -- Sell Start Date[cite: 4]
    sell_end_date        DATETIME2 NULL,                  -- Sell End Date[cite: 4]
    discontinued_date    DATETIME2 NULL,                  -- Discontinued Date[cite: 4]
    
    -- SCD Type 2 & Warehouse Metadata
    effective_start_date DATETIME2 NOT NULL DEFAULT GETDATE(),
    effective_end_date   DATETIME2 NULL,
    is_current           BIT NOT NULL DEFAULT 1
);
GO

-- 3. Create index on natural key
CREATE INDEX idx_dim_product_natural_key ON shared.dim_product(product_id);
GO