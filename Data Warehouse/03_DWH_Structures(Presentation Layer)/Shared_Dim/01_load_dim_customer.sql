/*******************************************************************************
* Script Name: 01_load_dim_customer.sql
* Description: Creates and executes a Stored Procedure (etl.sp_load_dim_customer_scd2)
*              to manage SCD Type 2 changes for customer profiles, expiring outdated 
*              records and inserting newly updated or inserted customer rows.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

CREATE OR ALTER PROCEDURE etl.sp_load_dim_customer_scd2
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        ------------------------------------------------------------------------
        -- STEP 1: Expire old records if critical customer attributes changed
        ------------------------------------------------------------------------
        UPDATE target
        SET target.is_current = 0,
            target.effective_end_date = GETDATE()
        FROM shared.dim_customer target
        INNER JOIN AdventureWorks_Staging.cleaned_data.Customer src
            ON target.customer_id = src.CustomerID
        WHERE target.is_current = 1
          AND (
                ISNULL(target.first_name, '') <> ISNULL(src.FirstName, '')
             OR ISNULL(target.last_name, '') <> ISNULL(src.LastName, '')
             OR ISNULL(target.email_address, '') <> ISNULL(src.EmailAddress, '')
             OR ISNULL(target.phone, '') <> ISNULL(src.Phone, '')
             OR ISNULL(target.company_name, '') <> ISNULL(src.CompanyName, '')
          );

        ------------------------------------------------------------------------
        -- STEP 2: Insert brand new customers or updated version records
        ------------------------------------------------------------------------
        INSERT INTO shared.dim_customer (
            customer_id,
            title,
            first_name,
            middle_name,
            last_name,
            company_name,
            sales_person,
            email_address,
            phone,
            effective_start_date,
            effective_end_date,
            is_current
        )
        SELECT 
            src.CustomerID,
            src.Title,
            src.FirstName,
            src.MiddleName,
            src.LastName,
            src.CompanyName,
            src.SalesPerson,
            src.EmailAddress,
            src.Phone,
            GETDATE() AS effective_start_date,
            NULL AS effective_end_date,
            1 AS is_current
        FROM AdventureWorks_Staging.cleaned_data.Customer src
        WHERE NOT EXISTS (
            SELECT 1 FROM shared.dim_customer target 
            WHERE target.customer_id = src.CustomerID 
              AND target.is_current = 1
        );

        PRINT 'SUCCESS: Customer Dimension (SCD Type 2) loaded successfully from Staging.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

-- Execute the procedure
EXEC etl.sp_load_dim_customer_scd2;