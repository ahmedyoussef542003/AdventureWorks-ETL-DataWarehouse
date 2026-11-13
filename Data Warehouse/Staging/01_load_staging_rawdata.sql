/*******************************************************************************
* Script Name: 01_load_staging_rawdata.sql
* Description: Creates and executes a Stored Procedure (rawdata.sp_Load_All_StagingTables)
*              to perform a Full Refresh ETL load. It truncates all 10 staging tables 
*              and extracts fresh raw data from the AdventureWorksLT2022 source database.
* Author: Ahmed Youssef
*******************************************************************************/

USE AdventureWorks_Staging;
GO

CREATE OR ALTER PROCEDURE rawdata.sp_Load_All_StagingTables
AS
BEGIN
    -- Prevent row count messages from returning for better performance
    SET NOCOUNT ON;

    BEGIN TRY
        ------------------------------------------------------------------------
        -- STEP 1: Truncate all staging tables to ensure a clean Full Refresh
        ------------------------------------------------------------------------
        TRUNCATE TABLE rawdata.Stg_Address;
        TRUNCATE TABLE rawdata.Stg_Customer;
        TRUNCATE TABLE rawdata.Stg_CustomerAddress;
        TRUNCATE TABLE rawdata.Stg_Product;
        TRUNCATE TABLE rawdata.Stg_ProductCategory;
        TRUNCATE TABLE rawdata.Stg_ProductDescription;
        TRUNCATE TABLE rawdata.Stg_ProductModel;
        TRUNCATE TABLE rawdata.Stg_ProductModelProductDescription;
        TRUNCATE TABLE rawdata.Stg_SalesOrderDetail;
        TRUNCATE TABLE rawdata.Stg_SalesOrderHeader;

        ------------------------------------------------------------------------
        -- STEP 2: Extract and Load data from source database (AdventureWorksLT2022)
        ------------------------------------------------------------------------

        -- 1. Load Address data
        INSERT INTO rawdata.Stg_Address 
        SELECT AddressID, AddressLine1, AddressLine2, City, StateProvince, CountryRegion, PostalCode, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.Address;

        -- 2. Load Customer data
        INSERT INTO rawdata.Stg_Customer 
        SELECT CustomerID, NameStyle, Title, FirstName, MiddleName, LastName, Suffix, CompanyName, SalesPerson, EmailAddress, Phone, PasswordHash, PasswordSalt, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.Customer;

        -- 3. Load CustomerAddress mapping data
        INSERT INTO rawdata.Stg_CustomerAddress 
        SELECT CustomerID, AddressID, AddressType, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.CustomerAddress;

        -- 4. Load Product catalog data
        INSERT INTO rawdata.Stg_Product 
        SELECT ProductID, Name, ProductNumber, Color, StandardCost, ListPrice, Size, Weight, ProductCategoryID, ProductModelID, SellStartDate, SellEndDate, DiscontinuedDate, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.Product;

        -- 5. Load ProductCategory hierarchy data
        INSERT INTO rawdata.Stg_ProductCategory 
        SELECT ProductCategoryID, ParentProductCategoryID, Name, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.ProductCategory;

        -- 6. Load ProductDescription data
        INSERT INTO rawdata.Stg_ProductDescription 
        SELECT ProductDescriptionID, Description, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.ProductDescription;

        -- 7. Load ProductModel data
        INSERT INTO rawdata.Stg_ProductModel 
        SELECT ProductModelID, Name, CatalogDescription, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.ProductModel;

        -- 8. Load ProductModel and ProductDescription bridge data
        INSERT INTO rawdata.Stg_ProductModelProductDescription 
        SELECT ProductModelID, ProductDescriptionID, Culture, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.ProductModelProductDescription;

        -- 9. Load SalesOrderDetail transaction items
        INSERT INTO rawdata.Stg_SalesOrderDetail 
        SELECT SalesOrderID, SalesOrderDetailID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.SalesOrderDetail;

        -- 10. Load SalesOrderHeader transaction headers
        INSERT INTO rawdata.Stg_SalesOrderHeader 
        SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, ShipToAddressID, BillToAddressID, ShipMethod, CreditCardApprovalCode, SubTotal, TaxAmt, Freight, TotalDue, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.SalesOrderHeader;

        PRINT 'SUCCESS: All Staging tables loaded successfully!';
    END TRY
    BEGIN CATCH
        -- Capture and raise any error encountered during execution
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- Execute the Stored Procedure to run the Staging ETL load
EXEC rawdata.sp_Load_All_StagingTables;