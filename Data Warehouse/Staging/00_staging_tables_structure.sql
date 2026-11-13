/*******************************************************************************
* Script Name: 01_create_staging_rawdata_tables.sql
* Description: Creates the 10 raw staging tables under the 'rawdata' schema 
*              to store the extracted data directly from the AdventureWorksLT source.
* Author: Ahmed Youssef
*******************************************************************************/

USE AdventureWorks_Staging;
GO

------------------------------------------------------------------------
-- 1. Staging Address Table
------------------------------------------------------------------------
DROP TABLE IF EXISTS rawdata.Stg_Address;
CREATE TABLE rawdata.Stg_Address (
    AddressID INT NULL,
    AddressLine1 NVARCHAR(60) NULL,
    AddressLine2 NVARCHAR(60) NULL,
    City NVARCHAR(30) NULL,
    StateProvince NVARCHAR(50) NULL,
    CountryRegion NVARCHAR(50) NULL,
    PostalCode NVARCHAR(15) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    LoadedAt DATETIME DEFAULT GETDATE()
);

------------------------------------------------------------------------
-- 2. Staging Customer Table
------------------------------------------------------------------------
DROP TABLE IF EXISTS rawdata.Stg_Customer;
CREATE TABLE rawdata.Stg_Customer (
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
    LoadedAt DATETIME DEFAULT GETDATE()
);

------------------------------------------------------------------------
-- 3. Staging CustomerAddress Table
------------------------------------------------------------------------
DROP TABLE IF EXISTS rawdata.Stg_CustomerAddress;
CREATE TABLE rawdata.Stg_CustomerAddress (
    CustomerID INT NULL,
    AddressID INT NULL,
    AddressType NVARCHAR(50) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    LoadedAt DATETIME DEFAULT GETDATE()
);

------------------------------------------------------------------------
-- 4. Staging Product Table
------------------------------------------------------------------------
DROP TABLE IF EXISTS rawdata.Stg_Product;
CREATE TABLE rawdata.Stg_Product (
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
    LoadedAt DATETIME DEFAULT GETDATE()
);

------------------------------------------------------------------------
-- 5. Staging ProductCategory Table
------------------------------------------------------------------------
DROP TABLE IF EXISTS rawdata.Stg_ProductCategory;
CREATE TABLE rawdata.Stg_ProductCategory (
    ProductCategoryID INT NULL,
    ParentProductCategoryID INT NULL,
    Name NVARCHAR(50) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    LoadedAt DATETIME DEFAULT GETDATE()
);

------------------------------------------------------------------------
-- 6. Staging ProductDescription Table
------------------------------------------------------------------------
DROP TABLE IF EXISTS rawdata.Stg_ProductDescription;
CREATE TABLE rawdata.Stg_ProductDescription (
    ProductDescriptionID INT NULL,
    Description NVARCHAR(400) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    LoadedAt DATETIME DEFAULT GETDATE()
);

------------------------------------------------------------------------
-- 7. Staging ProductModel Table
------------------------------------------------------------------------
DROP TABLE IF EXISTS rawdata.Stg_ProductModel;
CREATE TABLE rawdata.Stg_ProductModel (
    ProductModelID INT NULL,
    Name NVARCHAR(50) NULL,
    CatalogDescription XML NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    LoadedAt DATETIME DEFAULT GETDATE()
);

------------------------------------------------------------------------
-- 8. Staging ProductModelProductDescription Table
------------------------------------------------------------------------
DROP TABLE IF EXISTS rawdata.Stg_ProductModelProductDescription;
CREATE TABLE rawdata.Stg_ProductModelProductDescription (
    ProductModelID INT NULL,
    ProductDescriptionID INT NULL,
    Culture NVARCHAR(6) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    LoadedAt DATETIME DEFAULT GETDATE()
);

------------------------------------------------------------------------
-- 9. Staging SalesOrderDetail Table
------------------------------------------------------------------------
DROP TABLE IF EXISTS rawdata.Stg_SalesOrderDetail;
CREATE TABLE rawdata.Stg_SalesOrderDetail (
    SalesOrderID INT NULL,
    SalesOrderDetailID INT NULL,
    OrderQty SMALLINT NULL,
    ProductID INT NULL,
    UnitPrice DECIMAL(18,2) NULL,
    UnitPriceDiscount DECIMAL(18,2) NULL,
    LineTotal DECIMAL(38,6) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL,
    LoadedAt DATETIME DEFAULT GETDATE()
);

------------------------------------------------------------------------
-- 10. Staging SalesOrderHeader Table
------------------------------------------------------------------------
DROP TABLE IF EXISTS rawdata.Stg_SalesOrderHeader;
CREATE TABLE rawdata.Stg_SalesOrderHeader (
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
    LoadedAt DATETIME DEFAULT GETDATE()
);
GO