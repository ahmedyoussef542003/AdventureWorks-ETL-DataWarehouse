/*******************************************************************************
* Script Name: 07_load_dim_ship_method.sql
* Description: Creates and executes a Stored Procedure (etl.sp_load_dim_ship_method)
*              to extract unique shipping methods from staging and load them into 
*              the shared.dim_ship_method dimension table.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

CREATE OR ALTER PROCEDURE etl.sp_load_dim_ship_method
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Insert distinct ship methods from staging header into dimension table
        INSERT INTO shared.dim_ship_method (ship_method_name)
        SELECT DISTINCT 
            LTRIM(RTRIM(src.ShipMethod))
        FROM AdventureWorks_Staging.rawdata.Stg_SalesOrderHeader src
        WHERE src.ShipMethod IS NOT NULL
          AND LTRIM(RTRIM(src.ShipMethod)) <> ''
          AND NOT EXISTS (
              SELECT 1 
              FROM shared.dim_ship_method target
              WHERE target.ship_method_name = LTRIM(RTRIM(src.ShipMethod))
          );

        PRINT 'SUCCESS: Ship Method Dimension loaded successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

-- Execute the procedure
EXEC etl.sp_load_dim_ship_method;