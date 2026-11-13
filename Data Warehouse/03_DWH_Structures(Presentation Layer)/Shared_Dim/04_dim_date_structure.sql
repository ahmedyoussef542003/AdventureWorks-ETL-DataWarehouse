/*******************************************************************************
* Script Name: 04_dim_date_structure.sql
* Description: Creates the shared.dim_date dimension table with smart surrogate keys (YYYYMMDD) 
*              and inserts a default 'Unknown' (-1) record for unassigned or future dates.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

-- 1. Create Dim Date table in the shared schema
CREATE TABLE shared.dim_date (
    date_sk              INT PRIMARY KEY,               -- Smart Key: YYYYMMDD
    full_date            DATE NOT NULL UNIQUE,
    day_number_of_week   TINYINT NOT NULL,
    day_name             NVARCHAR(15) NOT NULL,
    day_number_of_month  TINYINT NOT NULL,
    day_number_of_year   SMALLINT NOT NULL,
    week_number_of_year  TINYINT NOT NULL,
    month_name           NVARCHAR(15) NOT NULL,
    month_number         TINYINT NOT NULL,
    quarter_number       TINYINT NOT NULL,
    quarter_name         CHAR(2) NOT NULL,
    year_number          SMALLINT NOT NULL,
    year_month           CHAR(7) NOT NULL,
    is_weekend           BIT NOT NULL
);
GO

-- 2. Insert default unknown record for missing/null dates (Data Warehouse Best Practice)
INSERT INTO shared.dim_date (
    date_sk, full_date, day_number_of_week, day_name, day_number_of_month,
    day_number_of_year, week_number_of_year, month_name, month_number,
    quarter_number, quarter_name, year_number, year_month, is_weekend
)
VALUES (
    -1, '1900-01-01', 1, 'Unknown', 1, 1, 1, 'Unknown', 0, 0, 'NA', 1900, '1900-00', 0
);
GO