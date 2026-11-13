/*******************************************************************************
* Script Name: 06_fact_sales_detail_structure.sql
* Description: Creates the fact_sales_detail table inside the sales_data_mart schema 
*              at the line-item grain, linking products and tracking item-level measures.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

-- 1. Create Sales Detail Fact table at grain of order line-item
CREATE TABLE sales_data_mart.fact_sales_detail (
    sales_detail_sk        BIGINT IDENTITY(1,1) PRIMARY KEY,
    
    -- Degenerate Dimensions & Identifiers
    sales_order_detail_id  INT NOT NULL,
    sales_order_id         INT NOT NULL, -- For header correlation and tracing
    
    -- Dimension Foreign Key
    product_sk             INT NOT NULL REFERENCES shared.dim_product(product_sk),
    
    -- Line Item Measures
    order_qty              SMALLINT NOT NULL,
    unit_price             MONEY NOT NULL,
    unit_price_discount    MONEY NOT NULL,
    line_total             NUMERIC(38,6) NOT NULL,
    
    -- Audit
    etl_loaded_at          DATETIME2 NOT NULL DEFAULT GETDATE(),

    -- Ensure no duplicate line items per sales order
    CONSTRAINT uq_fact_sales_detail_id UNIQUE (sales_order_id, sales_order_detail_id)
);
GO

-- 2. Create indexes to speed up joins with product and header
CREATE INDEX idx_fact_detail_product   ON sales_data_mart.fact_sales_detail(product_sk);
CREATE INDEX idx_fact_detail_order_id  ON sales_data_mart.fact_sales_detail(sales_order_id);
GO