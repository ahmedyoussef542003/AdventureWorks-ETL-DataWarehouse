/*******************************************************************************
* Script Name: 03_load_dim_product.sql
* Description: Creates and executes a Stored Procedure (etl.sp_load_dim_product_scd2)
*              to manage SCD Type 2 tracking for products based on cost and price changes,
*              integrating product categories, models, and descriptions.
* Author: Ahmed Youssef
*******************************************************************************/

USE adventureworks_dw_presentation;
GO

CREATE OR ALTER PROCEDURE etl.sp_load_dim_product_scd2
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        ------------------------------------------------------------------------
        -- STEP 1: Expire old records if list price or standard cost changes
        ------------------------------------------------------------------------
        UPDATE target
        SET target.is_current = 0,
            target.effective_end_date = GETDATE()
        FROM shared.dim_product target
        INNER JOIN AdventureWorks_Staging.cleaned_data.Product src
            ON target.product_id = src.ProductID
        WHERE target.is_current = 1
          AND (
                target.list_price <> src.ListPrice
             OR target.standard_cost <> src.StandardCost
          );

        ------------------------------------------------------------------------
        -- STEP 2: Insert brand new products or newly updated active versions
        ------------------------------------------------------------------------
        INSERT INTO shared.dim_product (
            product_id,
            product_name,
            product_number,
            color,
            standard_cost,
            list_price,
            size,
            weight,
            product_category_id,
            subcategory_name,
            category_name,
            product_model_id,
            product_model_name,
            product_description,
            sell_start_date,
            sell_end_date,
            discontinued_date,
            effective_start_date,
            effective_end_date,
            is_current
        )
        SELECT 
            src.ProductID,
            src.Name AS product_name,
            src.ProductNumber,
            ISNULL(src.Color, 'N/A') AS color,
            src.StandardCost,
            src.ListPrice,
            ISNULL(src.Size, 'N/A') AS size,
            ISNULL(src.Weight, 0) AS weight,
            
            -- Category Hierarchy
            cat.ProductCategoryID AS product_category_id,
            cat.Name AS subcategory_name,         
            parent_cat.Name AS category_name,     
            
            -- Model & Description Joins
            pm.ProductModelID,
            pm.Name AS product_model_name,
            pd.Description AS product_description,
            
            -- Lifecycle Dates
            src.SellStartDate,
            src.SellEndDate,
            src.DiscontinuedDate,
            
            -- SCD Type 2 Metadata
            GETDATE() AS effective_start_date,
            NULL AS effective_end_date,
            1 AS is_current

        FROM AdventureWorks_Staging.cleaned_data.Product src
        LEFT JOIN AdventureWorks_Staging.cleaned_data.ProductCategory cat 
            ON src.ProductCategoryID = cat.ProductCategoryID
        LEFT JOIN AdventureWorks_Staging.cleaned_data.ProductCategory parent_cat 
            ON cat.ParentProductCategoryID = parent_cat.ProductCategoryID
        LEFT JOIN AdventureWorks_Staging.cleaned_data.ProductModel pm 
            ON src.ProductModelID = pm.ProductModelID
        LEFT JOIN AdventureWorks_Staging.cleaned_data.ProductModelProductDescription pmpd 
            ON pm.ProductModelID = pmpd.ProductModelID 
            AND pmpd.Culture = N'en'
        LEFT JOIN AdventureWorks_Staging.cleaned_data.ProductDescription pd 
            ON pmpd.ProductDescriptionID = pd.ProductDescriptionID
        -- Insert condition: Brand new product OR expired old version due to cost/price update
        WHERE NOT EXISTS (
            SELECT 1 FROM shared.dim_product target 
            WHERE target.product_id = src.ProductID AND target.is_current = 1
        );

        PRINT 'SUCCESS: Product Dimension (SCD Type 2) loaded successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

-- Execute the procedure
EXEC etl.sp_load_dim_product_scd2;