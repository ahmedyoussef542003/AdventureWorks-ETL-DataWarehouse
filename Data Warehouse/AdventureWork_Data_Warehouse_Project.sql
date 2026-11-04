USE AdventureWorks_Staging;
GO

CREATE OR ALTER PROCEDURE rawdata.sp_Load_All_StagingTables
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. تفريغ الجداول أولاً لضمان عدم تكرار البيانات (Full Refresh)
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

        -- 2. نقل البيانات من المصدر AdventureWorksLT2022 إلى جداول الـ Staging (باستخدام SalesLT الصح)

        -- Address
        INSERT INTO rawdata.Stg_Address 
        SELECT AddressID, AddressLine1, AddressLine2, City, StateProvince, CountryRegion, PostalCode, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.Address;

        -- Customer
        INSERT INTO rawdata.Stg_Customer 
        SELECT CustomerID, NameStyle, Title, FirstName, MiddleName, LastName, Suffix, CompanyName, SalesPerson, EmailAddress, Phone, PasswordHash, PasswordSalt, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.Customer;

        -- CustomerAddress
        INSERT INTO rawdata.Stg_CustomerAddress 
        SELECT CustomerID, AddressID, AddressType, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.CustomerAddress;

        -- Product
        INSERT INTO rawdata.Stg_Product 
        SELECT ProductID, Name, ProductNumber, Color, StandardCost, ListPrice, Size, Weight, ProductCategoryID, ProductModelID, SellStartDate, SellEndDate, DiscontinuedDate, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.Product;

        -- ProductCategory
        INSERT INTO rawdata.Stg_ProductCategory 
        SELECT ProductCategoryID, ParentProductCategoryID, Name, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.ProductCategory;

        -- ProductDescription
        INSERT INTO rawdata.Stg_ProductDescription 
        SELECT ProductDescriptionID, Description, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.ProductDescription;

        -- ProductModel
        INSERT INTO rawdata.Stg_ProductModel 
        SELECT ProductModelID, Name, CatalogDescription, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.ProductModel;

        -- ProductModelProductDescription
        INSERT INTO rawdata.Stg_ProductModelProductDescription 
        SELECT ProductModelID, ProductDescriptionID, Culture, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.ProductModelProductDescription;

        -- SalesOrderDetail
        INSERT INTO rawdata.Stg_SalesOrderDetail 
        SELECT SalesOrderID, SalesOrderDetailID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.SalesOrderDetail;

        -- SalesOrderHeader
        INSERT INTO rawdata.Stg_SalesOrderHeader 
        SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, ShipToAddressID, BillToAddressID, ShipMethod, CreditCardApprovalCode, SubTotal, TaxAmt, Freight, TotalDue, rowguid, ModifiedDate, GETDATE()
        FROM AdventureWorksLT2022.SalesLT.SalesOrderHeader;

        PRINT 'All Staging tables loaded successfully!';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH
END;
GO

EXEC rawdata.sp_Load_All_StagingTables;