USE AdventureWorks_Staging;
GO

-- 1. حذف الجدول القديم لو موجود عشان يضمن إنشاء الأعمدة الجديدة صح
IF OBJECT_ID('cleaned_data.SalesOrderHeader', 'U') IS NOT NULL DROP TABLE cleaned_data.SalesOrderHeader;
IF OBJECT_ID('cleaned_data.SalesOrderDetail', 'U') IS NOT NULL DROP TABLE cleaned_data.SalesOrderDetail;
GO

CREATE OR ALTER PROCEDURE cleaned_data.sp_Run_Full_ETL_Pipeline
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        PRINT 'Starting Full ETL and Data Cleaning Pipeline for all 10 tables...';

        ---------------------------------------------------------
        -- 1. جدول العملاء Stg_Customer
        ---------------------------------------------------------
        IF OBJECT_ID('cleaned_data.Customer', 'U') IS NOT NULL DROP TABLE cleaned_data.Customer;
        SELECT 
            CustomerID, NameStyle, ISNULL(Title, 'N/A') AS Title, FirstName, 
            ISNULL(MiddleName, '') AS MiddleName, LastName, ISNULL(Suffix, '') AS Suffix, 
            ISNULL(CompanyName, 'N/A') AS CompanyName, ISNULL(SalesPerson, 'N/A') AS SalesPerson, 
            ISNULL(EmailAddress, 'N/A') AS EmailAddress, ISNULL(Phone, 'N/A') AS Phone, 
            PasswordHash, PasswordSalt, rowguid, ModifiedDate, GETDATE() AS CleanedAt
        INTO cleaned_data.Customer
        FROM rawdata.Stg_Customer;

        ---------------------------------------------------------
        -- 2. جدول العناوين Stg_Address
        ---------------------------------------------------------
        IF OBJECT_ID('cleaned_data.Address', 'U') IS NOT NULL DROP TABLE cleaned_data.Address;
        SELECT 
            AddressID, AddressLine1, ISNULL(AddressLine2, '') AS AddressLine2, 
            City, StateProvince, CountryRegion, PostalCode, rowguid, ModifiedDate, GETDATE() AS CleanedAt
        INTO cleaned_data.Address
        FROM rawdata.Stg_Address;

        ---------------------------------------------------------
        -- 3. جدول ربط العملاء بالعناوين Stg_CustomerAddress
        ---------------------------------------------------------
        IF OBJECT_ID('cleaned_data.CustomerAddress', 'U') IS NOT NULL DROP TABLE cleaned_data.CustomerAddress;
        SELECT CustomerID, AddressID, AddressType, rowguid, ModifiedDate, GETDATE() AS CleanedAt
        INTO cleaned_data.CustomerAddress
        FROM rawdata.Stg_CustomerAddress
        WHERE CustomerID IS NOT NULL AND CustomerID > 0 
          AND AddressID IS NOT NULL AND AddressID > 0;

        ---------------------------------------------------------
        -- 4. جدول المنتجات Stg_Product
        ---------------------------------------------------------
        IF OBJECT_ID('cleaned_data.Product', 'U') IS NOT NULL DROP TABLE cleaned_data.Product;
        SELECT 
            ProductID, LTRIM(RTRIM(Name)) AS Name, ProductNumber, ISNULL(Color, 'N/A') AS Color, 
            StandardCost, ListPrice, ISNULL(Size, 'N/A') AS Size, ISNULL(Weight, 0) AS Weight, 
            ISNULL(ProductCategoryID, 0) AS ProductCategoryID, ISNULL(ProductModelID, 0) AS ProductModelID, 
            SellStartDate, SellEndDate, DiscontinuedDate, rowguid, ModifiedDate, GETDATE() AS CleanedAt
        INTO cleaned_data.Product
        FROM rawdata.Stg_Product
        WHERE ListPrice >= 0 AND StandardCost >= 0;

        ---------------------------------------------------------
        -- 5. جدول التصنيفات Stg_ProductCategory
        ---------------------------------------------------------
        IF OBJECT_ID('cleaned_data.ProductCategory', 'U') IS NOT NULL DROP TABLE cleaned_data.ProductCategory;
        SELECT ProductCategoryID, ParentProductCategoryID, LTRIM(RTRIM(Name)) AS Name, rowguid, ModifiedDate, GETDATE() AS CleanedAt
        INTO cleaned_data.ProductCategory
        FROM rawdata.Stg_ProductCategory;

        ---------------------------------------------------------
        -- 6. جدول أوصاف المنتجات Stg_ProductDescription
        ---------------------------------------------------------
        IF OBJECT_ID('cleaned_data.ProductDescription', 'U') IS NOT NULL DROP TABLE cleaned_data.ProductDescription;
        SELECT ProductDescriptionID, LTRIM(RTRIM(Description)) AS Description, rowguid, ModifiedDate, GETDATE() AS CleanedAt
        INTO cleaned_data.ProductDescription
        FROM rawdata.Stg_ProductDescription;

        ---------------------------------------------------------
        -- 7. جدول موديلات المنتجات Stg_ProductModel
        ---------------------------------------------------------
        IF OBJECT_ID('cleaned_data.ProductModel', 'U') IS NOT NULL DROP TABLE cleaned_data.ProductModel;
        SELECT ProductModelID, LTRIM(RTRIM(Name)) AS Name, CatalogDescription, rowguid, ModifiedDate, GETDATE() AS CleanedAt
        INTO cleaned_data.ProductModel
        FROM rawdata.Stg_ProductModel;

        ---------------------------------------------------------
        -- 8. جدول ربط الموديلات بالوصف Stg_ProductModelProductDescription
        ---------------------------------------------------------
        IF OBJECT_ID('cleaned_data.ProductModelProductDescription', 'U') IS NOT NULL DROP TABLE cleaned_data.ProductModelProductDescription;
        SELECT ProductModelID, ProductDescriptionID, LOWER(LTRIM(RTRIM(Culture))) AS Culture, rowguid, ModifiedDate, GETDATE() AS CleanedAt
        INTO cleaned_data.ProductModelProductDescription
        FROM rawdata.Stg_ProductModelProductDescription
        WHERE ProductModelID IS NOT NULL AND ProductModelID > 0
          AND ProductDescriptionID IS NOT NULL AND ProductDescriptionID > 0;


        ---------------------------------------------------------
        -- 9 & 10. إنشاء وتعبئة جداول المبيعات (SalesOrderHeader & SalesOrderDetail)
        ---------------------------------------------------------
        CREATE TABLE cleaned_data.SalesOrderHeader (
            SalesOrderID INT PRIMARY KEY,
            RevisionNumber TINYINT,
            OrderDate DATETIME,
            DueDate DATETIME,
            ShipDate DATETIME,
            Status TINYINT,
            OnlineOrderFlag BIT,
            SalesOrderNumber NVARCHAR(25),
            PurchaseOrderNumber NVARCHAR(25),
            AccountNumber NVARCHAR(15),
            CustomerID INT,
            ShipToAddressID INT,
            BillToAddressID INT,
            ShipMethod NVARCHAR(50),
            CreditCardApprovalCode VARCHAR(15),
            SubTotal MONEY,
            TaxAmt MONEY,
            Freight MONEY,
            TotalDue MONEY,
            IsDelayed BIT,
            DelayDays INT,
            rowguid UNIQUEIDENTIFIER,
            ModifiedDate DATETIME,
            CleanedAt DATETIME
        );

        CREATE TABLE cleaned_data.SalesOrderDetail (
            SalesOrderID INT,
            SalesOrderDetailID INT PRIMARY KEY,
            OrderQty SMALLINT,
            ProductID INT,
            UnitPrice DECIMAL(18,2),
            UnitPriceDiscount DECIMAL(18,2),
            LineTotal DECIMAL(38,6),
            rowguid UNIQUEIDENTIFIER,
            ModifiedDate DATETIME,
            CleanedAt DATETIME
        );

        -- تعبئة SalesOrderHeader
        INSERT INTO cleaned_data.SalesOrderHeader (
            SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, 
            OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber, AccountNumber, 
            CustomerID, ShipToAddressID, BillToAddressID, ShipMethod, CreditCardApprovalCode, 
            SubTotal, TaxAmt, Freight, TotalDue, IsDelayed, DelayDays, rowguid, ModifiedDate, CleanedAt
        )
        SELECT 
            SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate,
            ISNULL(Status, 1) AS Status,
            OnlineOrderFlag,
            LTRIM(RTRIM(SalesOrderNumber)) AS SalesOrderNumber,
            ISNULL(LTRIM(RTRIM(PurchaseOrderNumber)), 'N/A') AS PurchaseOrderNumber,
            AccountNumber, CustomerID, ShipToAddressID, BillToAddressID, ShipMethod,
            ISNULL(CreditCardApprovalCode, 'N/A') AS CreditCardApprovalCode,
            SubTotal, TaxAmt, Freight, TotalDue,
            CASE WHEN ShipDate IS NOT NULL AND ShipDate > DueDate THEN 1 ELSE 0 END AS IsDelayed,
            CASE WHEN ShipDate IS NOT NULL AND ShipDate > DueDate THEN DATEDIFF(day, DueDate, ShipDate) ELSE 0 END AS DelayDays,
            rowguid, ModifiedDate, GETDATE() AS CleanedAt
        FROM rawdata.Stg_SalesOrderHeader
        WHERE CustomerID IS NOT NULL AND CustomerID > 0
          AND (ShipDate IS NULL OR ShipDate >= OrderDate)
          AND TotalDue >= 0;

        -- تعبئة SalesOrderDetail
        INSERT INTO cleaned_data.SalesOrderDetail (
            SalesOrderID, SalesOrderDetailID, OrderQty, ProductID, 
            UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate, CleanedAt
        )
        SELECT 
            SalesOrderID, SalesOrderDetailID, OrderQty, ProductID, 
            UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate, GETDATE() AS CleanedAt
        FROM rawdata.Stg_SalesOrderDetail
        WHERE SalesOrderID IS NOT NULL AND SalesOrderID > 0
          AND ProductID IS NOT NULL AND ProductID > 0   
          AND OrderQty > 0
          AND UnitPrice >= 0
          AND UnitPriceDiscount >= 0 AND UnitPriceDiscount <= 1;

        PRINT 'SUCCESS: All 10 tables ETL Pipeline and Data Cleaning executed successfully!';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR in ETL Pipeline: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- تشغيل الـ Pipeline بالكامل الآن:
EXEC cleaned_data.sp_Run_Full_ETL_Pipeline;