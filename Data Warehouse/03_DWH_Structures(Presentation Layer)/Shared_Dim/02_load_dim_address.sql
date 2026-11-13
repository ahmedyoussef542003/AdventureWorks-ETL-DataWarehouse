/*******************************************************************************
* Script Name: 02_load_dim_address.sql
* Description: Creates and executes a Stored Procedure (etl.sp_load_dim_address_scd2)
*              to manage Slowly Changing Dimension Type 2 (SCD2) for the address dimension,
*              expiring old changed records and inserting new active records.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

CREATE OR ALTER PROCEDURE etl.sp_load_dim_address_scd2
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        ------------------------------------------------------------------------
        -- STEP 1: Expire old records if any address attributes or types changed
        ------------------------------------------------------------------------
        UPDATE target
        SET target.is_current = 0,
            target.effective_end_date = GETDATE()
        FROM shared.dim_address target
        INNER JOIN AdventureWorks_Staging.cleaned_data.Address src_addr
            ON target.address_id = src_addr.AddressID
        LEFT JOIN AdventureWorks_Staging.rawdata.Stg_CustomerAddress src_ca
            ON src_addr.AddressID = src_ca.AddressID AND target.customer_id = src_ca.CustomerID
        WHERE target.is_current = 1
          AND (
                target.address_line_1 <> src_addr.AddressLine1
             OR target.city <> src_addr.City
             OR target.state_province <> src_addr.StateProvince
             OR target.country_region <> src_addr.CountryRegion
             OR target.postal_code <> src_addr.PostalCode
             OR ISNULL(target.address_type, '') <> ISNULL(src_ca.AddressType, '')
          );

        ------------------------------------------------------------------------
        -- STEP 2: Insert brand new addresses or updated versions
        ------------------------------------------------------------------------
        INSERT INTO shared.dim_address (
            address_id,
            customer_id,
            address_line_1,
            address_line_2,
            city,
            state_province,
            country_region,
            postal_code,
            address_type,
            effective_start_date,
            effective_end_date,
            is_current
        )
        SELECT 
            addr.AddressID,
            ca.CustomerID,
            addr.AddressLine1,
            addr.AddressLine2,
            addr.City,
            addr.StateProvince,
            addr.CountryRegion,
            addr.PostalCode,
            ISNULL(ca.AddressType, 'Default') AS address_type,
            GETDATE() AS effective_start_date,
            NULL AS effective_end_date,
            1 AS is_current
        FROM AdventureWorks_Staging.cleaned_data.Address addr
        LEFT JOIN AdventureWorks_Staging.rawdata.Stg_CustomerAddress ca
            ON addr.AddressID = ca.AddressID
        -- Prevent duplicates by verifying no active record currently exists for this combination
        WHERE NOT EXISTS (
            SELECT 1 FROM shared.dim_address target 
            WHERE target.address_id = addr.AddressID 
              AND (target.customer_id = ca.CustomerID OR (target.customer_id IS NULL AND ca.CustomerID IS NULL))
              AND target.is_current = 1
        );

        PRINT 'SUCCESS: Address Dimension (SCD Type 2) loaded successfully from Staging.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

-- Execute the procedure
EXEC etl.sp_load_dim_address_scd2;