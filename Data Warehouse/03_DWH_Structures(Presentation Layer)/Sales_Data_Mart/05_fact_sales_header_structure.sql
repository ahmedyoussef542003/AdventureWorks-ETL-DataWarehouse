/*******************************************************************************
* Script Name: 05_fact_sales_header_structure.sql
* Description: Creates the 'sales_data_mart' schema and builds the fact_sales_header 
*              table linked to customer, address, ship method, and date dimensions,
*              capturing header-level financial measures and operational flags.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

-- 1. Ensure sales_data_mart schema exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'sales_data_mart')
BEGIN
    EXEC('CREATE SCHEMA sales_data_mart');
END
GO

-- 2. Create Sales Header Fact table with foreign keys
CREATE TABLE sales_data_mart.fact_sales_header (
    sales_header_sk        BIGINT IDENTITY(1,1) PRIMARY KEY,
    
    -- Degenerate Dimensions & Identifiers
    sales_order_id         INT NOT NULL,
    sales_order_number     NVARCHAR(25) NOT NULL,
    
    -- Dimension Foreign Keys (Full integration with shared dimensions)
    customer_sk            INT NOT NULL REFERENCES shared.dim_customer(customer_sk),
    ship_to_address_sk     INT NOT NULL REFERENCES shared.dim_address(address_sk),
    bill_to_address_sk     INT NOT NULL REFERENCES shared.dim_address(address_sk),
    ship_method_sk         INT NOT NULL REFERENCES shared.dim_ship_method(ship_method_sk),
    order_date_sk          INT NOT NULL REFERENCES shared.dim_date(date_sk),
    due_date_sk            INT NOT NULL REFERENCES shared.dim_date(date_sk),
    ship_date_sk           INT NOT NULL REFERENCES shared.dim_date(date_sk),
    
    -- Financial Measures (Header-level totals)
    sub_total              MONEY NOT NULL,
    tax_amt                MONEY NOT NULL,
    freight                MONEY NOT NULL,
    total_due              MONEY NOT NULL,
    
    -- Flags & Audit
    online_order_flag      BIT NOT NULL,
    order_status           TINYINT NOT NULL,
    etl_loaded_at          DATETIME2 NOT NULL DEFAULT GETDATE(),

    -- Ensure uniqueness for sales orders
    CONSTRAINT uq_fact_sales_header_order_id UNIQUE (sales_order_id)
);
GO

-- 3. Create indexes to accelerate analytical queries and joins
CREATE INDEX idx_fact_header_customer    ON sales_data_mart.fact_sales_header(customer_sk);
CREATE INDEX idx_fact_header_order_date  ON sales_data_mart.fact_sales_header(order_date_sk);
CREATE INDEX idx_fact_header_ship_method ON sales_data_mart.fact_sales_header(ship_method_sk);
CREATE INDEX idx_fact_header_ship_addr   ON sales_data_mart.fact_sales_header(ship_to_address_sk);
GO