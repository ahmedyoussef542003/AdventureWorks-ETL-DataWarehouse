USE AdventureWorks_Staging;
GO

-- التأكد من وجود الـ Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'cleaned_data')
BEGIN
    EXEC('CREATE SCHEMA cleaned_data;');
END
GO

-- 1. Cleaned Address
DROP TABLE IF EXISTS cleaned_data.Address;
CREATE TABLE cleaned_data.Address (
    AddressID INT NULL,
    AddressLine1 NVARCHAR(60) NULL,
    AddressLine2 NVARCHAR(60) NULL,
    City NVARCHAR(30) NULL,
    StateProvince NVARCHAR(50) NULL,
    CountryRegion NVARCHAR(50) NULL,
    PostalCode NVARCHAR(15) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    CleanedAt DATETIME DEFAULT GETDATE()
);

-- 2. Cleaned Customer
DROP TABLE IF EXISTS cleaned_data.Customer;
CREATE TABLE cleaned_data.Customer (
    CustomerID INT NULL,
    NameStyle BIT NULL,
    Title NVARCHAR(8) NULL,
    FirstName NVARCHAR(50) NULL,
    MiddleName NVARCHAR(50) NULL,
    LastName NVARCHAR(50) NULL,
    Suffix NVARCHAR(10) NULL,
    CompanyName NVARCHAR(128) NULL,
    SalesPerson NVARCHAR(256) NULL,
    EmailAddress NVARCHAR(50) NULL,
    Phone NVARCHAR(25) NULL,
    PasswordHash VARCHAR(128) NULL,
    PasswordSalt VARCHAR(10) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    CleanedAt DATETIME DEFAULT GETDATE()
);

-- 3. Cleaned CustomerAddress
DROP TABLE IF EXISTS cleaned_data.CustomerAddress;
CREATE TABLE cleaned_data.CustomerAddress (
    CustomerID INT NULL,
    AddressID INT NULL,
    AddressType NVARCHAR(50) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    CleanedAt DATETIME DEFAULT GETDATE()
);

-- 4. Cleaned Product
DROP TABLE IF EXISTS cleaned_data.Product;
CREATE TABLE cleaned_data.Product (
    ProductID INT NULL,
    Name NVARCHAR(50) NULL,
    ProductNumber NVARCHAR(25) NULL,
    Color NVARCHAR(15) NULL,
    StandardCost MONEY NULL,
    ListPrice MONEY NULL,
    Size NVARCHAR(5) NULL,
    Weight DECIMAL(8,2) NULL,
    ProductCategoryID INT NULL,
    ProductModelID INT NULL,
    SellStartDate DATETIME NULL,
    SellEndDate DATETIME NULL,
    DiscontinuedDate DATETIME NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    CleanedAt DATETIME DEFAULT GETDATE()
);

-- 5. Cleaned ProductCategory
DROP TABLE IF EXISTS cleaned_data.ProductCategory;
CREATE TABLE cleaned_data.ProductCategory (
    ProductCategoryID INT NULL,
    ParentProductCategoryID INT NULL,
    Name NVARCHAR(50) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    CleanedAt DATETIME DEFAULT GETDATE()
);

-- 6. Cleaned ProductDescription
DROP TABLE IF EXISTS cleaned_data.ProductDescription;
CREATE TABLE cleaned_data.ProductDescription (
    ProductDescriptionID INT NULL,
    Description NVARCHAR(400) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    CleanedAt DATETIME DEFAULT GETDATE()
);

-- 7. Cleaned ProductModel
DROP TABLE IF EXISTS cleaned_data.ProductModel;
CREATE TABLE cleaned_data.ProductModel (
    ProductModelID INT NULL,
    Name NVARCHAR(50) NULL,
    CatalogDescription XML NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    CleanedAt DATETIME DEFAULT GETDATE()
);

-- 8. Cleaned ProductModelProductDescription
DROP TABLE IF EXISTS cleaned_data.ProductModelProductDescription;
CREATE TABLE cleaned_data.ProductModelProductDescription (
    ProductModelID INT NULL,
    ProductDescriptionID INT NULL,
    Culture NVARCHAR(6) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    CleanedAt DATETIME DEFAULT GETDATE()
);

-- 9. Cleaned SalesOrderDetail
DROP TABLE IF EXISTS cleaned_data.SalesOrderDetail;
CREATE TABLE cleaned_data.SalesOrderDetail (
    SalesOrderID INT NULL,
    SalesOrderDetailID INT NULL,
    OrderQty SMALLINT NULL,
    ProductID INT NULL,
    UnitPrice DECIMAL(18,2) NULL,
    UnitPriceDiscount DECIMAL(18,2) NULL,
    LineTotal DECIMAL(38,6) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    CleanedAt DATETIME DEFAULT GETDATE()
);

-- 10. Cleaned SalesOrderHeader
DROP TABLE IF EXISTS cleaned_data.SalesOrderHeader;
CREATE TABLE cleaned_data.SalesOrderHeader (
    SalesOrderID INT NULL,
    RevisionNumber TINYINT NULL,
    OrderDate DATETIME NULL,
    DueDate DATETIME NULL,
    ShipDate DATETIME NULL,
    Status TINYINT NULL,
    OnlineOrderFlag BIT NULL,
    SalesOrderNumber NVARCHAR(25) NULL,
    PurchaseOrderNumber NVARCHAR(25) NULL,
    AccountNumber NVARCHAR(15) NULL,
    CustomerID INT NULL,
    ShipToAddressID INT NULL,
    BillToAddressID INT NULL,
    ShipMethod NVARCHAR(50) NULL,
    CreditCardApprovalCode VARCHAR(15) NULL,
    SubTotal MONEY NULL,
    TaxAmt MONEY NULL,
    Freight MONEY NULL,
    TotalDue MONEY NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    CleanedAt DATETIME DEFAULT GETDATE()
);
GO