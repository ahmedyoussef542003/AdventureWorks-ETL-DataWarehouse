/*******************************************************************************
* Script Name: 07_ship_method_lookup_structure.sql
* Description: Creates the shared.dim_ship_method dimension table and inserts 
*              a default 'Unknown' (-1) record for data warehouse best practices.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

-- 1. Create Ship Method Dimension table under shared schema
CREATE TABLE shared.dim_ship_method (
    ship_method_sk   INT IDENTITY(1,1) PRIMARY KEY,
    ship_method_name NVARCHAR(50) NOT NULL UNIQUE,
    created_at       DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- 2. Insert default unknown record (Data Warehouse Best Practice)
SET IDENTITY_INSERT shared.dim_ship_method ON;
INSERT INTO shared.dim_ship_method (ship_method_sk, ship_method_name)
VALUES (-1, N'Unknown');
SET IDENTITY_INSERT shared.dim_ship_method OFF;
GO