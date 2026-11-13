/*******************************************************************************
* Script Name: 04_load_dim_date.sql
* Description: Creates and executes a Stored Procedure (etl.sp_load_dim_date) 
*              using recursive CTEs to populate the date dimension across a specified timeframe.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

CREATE OR ALTER PROCEDURE etl.sp_load_dim_date
    @StartDate DATE = '2000-01-01',
    @EndDate   DATE = '2030-12-31'
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        WITH DateCTE AS (
            SELECT @StartDate AS CurrentDate
            UNION ALL
            SELECT DATEADD(DAY, 1, CurrentDate)
            FROM DateCTE
            WHERE CurrentDate < @EndDate
        )
        INSERT INTO shared.dim_date (
            date_sk,
            full_date,
            day_number_of_week,
            day_name,
            day_number_of_month,
            day_number_of_year,
            week_number_of_year,
            month_name,
            month_number,
            quarter_number,
            quarter_name,
            year_number,
            year_month,
            is_weekend
        )
        SELECT 
            CAST(CONVERT(VARCHAR(8), CurrentDate, 112) AS INT) AS date_sk,
            CurrentDate AS full_date,
            DATEPART(WEEKDAY, CurrentDate) AS day_number_of_week,
            DATENAME(WEEKDAY, CurrentDate) AS day_name,
            DATEPART(DAY, CurrentDate) AS day_number_of_month,
            DATEPART(DAYOFYEAR, CurrentDate) AS day_number_of_year,
            DATEPART(WEEK, CurrentDate) AS week_number_of_year,
            DATENAME(MONTH, CurrentDate) AS month_name,
            DATEPART(MONTH, CurrentDate) AS month_number,
            DATEPART(QUARTER, CurrentDate) AS quarter_number,
            'Q' + CAST(DATEPART(QUARTER, CurrentDate) AS CHAR(1)) AS quarter_name,
            DATEPART(YEAR, CurrentDate) AS year_number,
            CONVERT(CHAR(7), CurrentDate, 120) AS year_month,
            CASE WHEN DATEPART(WEEKDAY, CurrentDate) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend
        FROM DateCTE
        WHERE NOT EXISTS (
            SELECT 1 FROM shared.dim_date d WHERE d.full_date = DateCTE.CurrentDate
        )
        OPTION (MAXRECURSION 0);

        PRINT 'SUCCESS: Date Dimension loaded successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

-- Execute the procedure to generate dates from 2000 to 2030
EXEC etl.sp_load_dim_date @StartDate = '2000-01-01', @EndDate = '2030-12-31';