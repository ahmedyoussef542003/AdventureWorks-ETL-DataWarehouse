/*******************************************************************************
* Script Name: 05_load_fact_sales_header.sql
* Description: Creates and executes a Stored Procedure (sales_data_mart.sp_load_fact_sales_header)
*              to load the sales header fact table by resolving surrogate keys from 
*              customer, address, ship method, and date dimensions, defaulting missing keys to -1.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

CREATE OR ALTER PROCEDURE sales_data_mart.sp_load_fact_sales_header
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO sales_data_mart.fact_sales_header (
            sales_order_id,
            sales_order_number,
            customer_sk,
            ship_to_address_sk,
            bill_to_address_sk,
            ship_method_sk,
            order_date_sk,
            due_date_sk,
            ship_date_sk,
            sub_total,
            tax_amt,
            freight,
            total_due,
            online_order_flag,
            order_status
        )
        SELECT 
            src.SalesOrderID,
            src.SalesOrderNumber,
            
            -- Resolve dimension surrogate keys with default -1 fallback
            ISNULL(cust.customer_sk, -1) AS customer_sk,
            ISNULL(addr_ship.address_sk, -1) AS ship_to_address_sk,
            ISNULL(addr_bill.address_sk, -1) AS bill_to_address_sk,
            ISNULL(ship.ship_method_sk, -1) AS ship_method_sk,
            
            -- Resolve date surrogate keys from dim_date
            ISNULL(d_order.date_sk, -1) AS order_date_sk,
            ISNULL(d_due.date_sk, -1)   AS due_date_sk,
            ISNULL(d_ship.date_sk, -1)  AS ship_date_sk,
            
            src.SubTotal,
            src.TaxAmt,
            src.Freight,
            src.TotalDue,
            src.OnlineOrderFlag,
            src.Status
        FROM AdventureWorks_Staging.rawdata.Stg_SalesOrderHeader src
        LEFT JOIN shared.dim_customer cust ON src.CustomerID = cust.customer_id AND cust.is_current = 1
        LEFT JOIN shared.dim_address addr_ship ON src.ShipToAddressID = addr_ship.address_id AND addr_ship.is_current = 1
        LEFT JOIN shared.dim_address addr_bill ON src.BillToAddressID = addr_bill.address_id AND addr_bill.is_current = 1
        LEFT JOIN shared.dim_ship_method ship ON LTRIM(RTRIM(src.ShipMethod)) = ship.ship_method_name
        
        -- Join staging dates with dim_date to get date_sk
        LEFT JOIN shared.dim_date d_order ON d_order.full_date = CAST(src.OrderDate AS DATE)
        LEFT JOIN shared.dim_date d_due   ON d_due.full_date = CAST(src.DueDate AS DATE)
        LEFT JOIN shared.dim_date d_ship  ON d_ship.full_date = CAST(src.ShipDate AS DATE)
        
        WHERE NOT EXISTS (
            SELECT 1 FROM sales_data_mart.fact_sales_header target 
            WHERE target.sales_order_id = src.SalesOrderID
        );

        PRINT 'SUCCESS: Sales Header Fact loaded successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

-- Execute the procedure and preview data
EXEC sales_data_mart.sp_load_fact_sales_header;
SELECT TOP 100 * FROM sales_data_mart.fact_sales_header;