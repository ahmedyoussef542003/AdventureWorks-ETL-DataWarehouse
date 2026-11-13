/*******************************************************************************
* Script Name: 06_load_fact_sales_detail.sql
* Description: Creates and executes a Stored Procedure (sales_data_mart.sp_load_fact_sales_detail)
*              to load line-item sales details from staging, resolving product surrogate keys.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

CREATE OR ALTER PROCEDURE sales_data_mart.sp_load_fact_sales_detail
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO sales_data_mart.fact_sales_detail (
            sales_order_detail_id,
            sales_order_id,
            product_sk,
            order_qty,
            unit_price,
            unit_price_discount,
            line_total
        )
        SELECT 
            src.SalesOrderDetailID,
            src.SalesOrderID,
            
            -- Resolve product surrogate key (defaults to -1 if product not found)
            ISNULL(prod.product_sk, -1) AS product_sk,
            
            src.OrderQty,
            src.UnitPrice,
            src.UnitPriceDiscount,
            src.LineTotal
        FROM AdventureWorks_Staging.rawdata.Stg_SalesOrderDetail src
        -- Join with active product dimension (SCD Type 2 current record)
        LEFT JOIN shared.dim_product prod ON src.ProductID = prod.product_id AND prod.is_current = 1
        WHERE NOT EXISTS (
            SELECT 1 FROM sales_data_mart.fact_sales_detail target 
            WHERE target.sales_order_id = src.SalesOrderID 
              AND target.sales_order_detail_id = src.SalesOrderDetailID
        );

        PRINT 'SUCCESS: Sales Detail Fact loaded successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

-- Execute the procedure and preview data
EXEC sales_data_mart.sp_load_fact_sales_detail;
SELECT TOP 100 * FROM sales_data_mart.fact_sales_detail;