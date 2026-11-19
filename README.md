#  AdventureWorksLT Enterprise Data Warehouse & Defensive ETL Pipeline

##  Project Overview

This repository contains an end-to-end **Data Engineering & Business Intelligence solution** built on top of the **AdventureWorksLT2022** transactional database. It demonstrates industry best practices in **Defensive ETL**, **Data Quality Assurance**, **Slowly Changing Dimensions (SCD Type 2)**, and **Kimball Dimensional Modeling (Star Schema)** using T-SQL and Microsoft SQL Server.

The architecture decouples raw data ingestion from analytical presentation through a multi-layered Medallion-inspired warehouse approach (`Staging` $\rightarrow$ `Cleaned Data` $\rightarrow$ `Presentation / Data Marts`).

---

##  System Architecture & Data Flow

```text
+-----------------------+       +-------------------------+       +--------------------------+       +------------------------------+
|  Source OLTP Database |       |   01. Staging Layer     |       |  02. Cleaning & ETL      |       |  03. Presentation Layer (DW) |
| (AdventureWorksLT2022)| ----> |  (rawdata Schema)       | ----> |  (cleaned_data Schema)   | ----> |  (shared & sales_data_mart)  |
|   10 Normalized       |       |  Full Refresh Truncate  |       |  Data Quality Filtering  |       |  Kimball Star Schema         |
|   Source Tables       |       |  & Load + Audit Logs    |       |  & Business KPIs         |       |  SCD Type 2 & Surrogate Keys |
+-----------------------+       +-------------------------+       +--------------------------+       +------------------------------+
```

### Architectural Layers:

1. **Staging Layer (`AdventureWorks_Staging.rawdata`):**
   * Exact replica of the 10 source tables (`SalesLT`) with ingestion audit timestamps (`LoadedAt`).
   * Implements a **Full Refresh** strategy (`TRUNCATE` + `INSERT`) wrapped in `TRY...CATCH` error handling.

2. **Data Cleaning & Transformation Layer (`AdventureWorks_Staging.cleaned_data`):**
   * Enforces **Defensive ETL** rules: filters out invalid/negative quantities, prices, discounts, and broken foreign key references.
   * Standardizes text fields (`LTRIM`, `RTRIM`, `LOWER`) and replaces `NULL` values with meaningful business defaults (`'N/A'`, `0`).
   * Derives operational business metrics such as shipping delay indicators (`IsDelayed` and `DelayDays`).

3. **Presentation Layer (`adventureworks_dw_presentation`):**
   * Designed following **Ralph Kimball’s Dimensional Modeling** principles.
   * Separated into `shared` (Conformed Dimensions) and `sales_data_mart` (Header & Detail Fact Tables).
   * Implements **Surrogate Keys (`_sk`)**, **Unknown Member Handling (`-1`)**, and **SCD Type 2** historical tracking.

---

## 📂 Repository Structure

```text
AdventureWorkProject/
│
├── Staging/
│   ├── 00_staging_tables_structure.sql          # DDL scripts to create the 10 raw staging tables
│   └── 01_load_staging_rawdata.sql              # SP (rawdata.sp_Load_All_StagingTables) for Full Refresh extraction
│
├── 02_Cleaning_ETL/
│   ├── 01_clean_and_transform_staging_data.sql  # Master SP (cleaned_data.sp_Run_Full_ETL_Pipeline) for cleaning & business rules
│   └── 02_cleaned_data_schema.sql               # DDL scripts for the cleaned_data schema & destination tables
│
├── Data Warehouse/
│   └── 03_DWH_Structures(Presentation Layer)/
│       │
│       ├── Shared_Dim/
│       │   ├── 01_dim_customer_structure.sql        # DDL for shared.dim_customer (SCD Type 2)
│       │   ├── 01_load_dim_customer.sql             # SP (etl.sp_load_dim_customer_scd2)
│       │   ├── 02_dim_address_structure.sql         # DDL for shared.dim_address (SCD Type 2 + Geo Hierarchy)
│       │   ├── 02_load_dim_address.sql              # SP (etl.sp_load_dim_address_scd2)
│       │   ├── 03_dim_product_structure.sql         # DDL for shared.dim_product (SCD Type 2 + Category Hierarchy)
│       │   ├── 03_load_dim_product.sql              # SP (etl.sp_load_dim_product_scd2)
│       │   ├── 04_dim_date_structure.sql            # DDL for shared.dim_date (Smart Key YYYYMMDD + Default -1)
│       │   ├── 04_load_dim_date.sql                 # Recursive CTE SP (etl.sp_load_dim_date)
│       │   ├── 07_ship_method_lookup_structure.sql  # DDL for shared.dim_ship_method (+ Default -1)
│       │   └── 07_load_dim_ship_method.sql          # SP (etl.sp_load_dim_ship_method)
│       │
│       └── Sales_Data_Mart/
│           ├── 05_fact_sales_header_structure.sql   # DDL for sales_data_mart.fact_sales_header
│           ├── 05_load_fact_sales_header.sql        # SP (sales_data_mart.sp_load_fact_sales_header)
│           ├── 06_fact_sales_detail_structure.sql   # DDL for sales_data_mart.fact_sales_detail
│           └── 06_load_fact_sales_detail.sql        # SP (sales_data_mart.sp_load_fact_sales_detail)
│
└── README.md                                        # Project documentation
```

---

## ⭐ Data Warehouse Dimensional Model (Star Schema)

### 1. Conformed Dimensions (`shared` schema)

| Dimension Table | SCD Type | Key Strategy | Description |
| :--- | :---: | :--- | :--- |
| **`shared.dim_customer`** | **Type 2** | `customer_sk` (Identity) | Tracks customer contact, company, and sales rep history (`effective_start_date`, `effective_end_date`, `is_current`). |
| **`shared.dim_address`** | **Type 2** | `address_sk` (Identity) | Denormalized geographical hierarchy (`CountryRegion` $\rightarrow$ `StateProvince` $\rightarrow$ `City`) linked to customers. |
| **`shared.dim_product`** | **Type 2** | `product_sk` (Identity) | Tracks `ListPrice` and `StandardCost` changes over time. Flattens Category, Subcategory, Model, and English Description. |
| **`shared.dim_date`** | **Static** | `date_sk` (`YYYYMMDD`) | Pre-populated calendar table (2000–2030) with fiscal/calendar attributes, weekend flags, and `-1` Unknown record. |
| **`shared.dim_ship_method`** | **Type 1** | `ship_method_sk` (Identity) | Lookup dimension for shipping carriers with `-1` Unknown member handling. |

### 2. Fact Tables (`sales_data_mart` schema)

To avoid fan-out traps and preserve accurate grain separation (Header vs. Line-Item), the sales mart is modeled into two distinct fact tables:

* **`sales_data_mart.fact_sales_header`** *(Grain: One row per Sales Order)*
  * **Foreign Keys:** `customer_sk`, `ship_to_address_sk`, `bill_to_address_sk`, `ship_method_sk`, `order_date_sk`, `due_date_sk`, `ship_date_sk`.
  * **Measures:** `sub_total`, `tax_amt`, `freight`, `total_due` (Header-level additive/allocated financial metrics).

* **`sales_data_mart.fact_sales_detail`** *(Grain: One row per Order Line Item)*
  * **Foreign Keys:** `product_sk` + Degenerate Dimensions (`sales_order_id`, `sales_order_detail_id`).
  * **Measures:** `order_qty`, `unit_price`, `unit_price_discount`, `line_total`.

---

##  Key Data Engineering Best Practices Applied

* **Defensive ETL & Data Quality Rules:**
  * Rejects orphan records (`CustomerID <= 0`, `ProductID <= 0`) and logical anomalies (`ShipDate < OrderDate`, `OrderQty <= 0`, `UnitPrice < 0`, or invalid discount percentages outside `[0, 1]`).
* **Referential Integrity via Unknown Members (`-1`):**
  * Missing or unshipped dates (e.g., `ShipDate IS NULL`) and unmatched dimension lookups safely resolve to `-1` (`Unknown`) instead of failing inserts or dropping fact records.
* **Slowly Changing Dimensions (SCD Type 2):**
  * Automatically expires active rows (`is_current = 0`, sets `effective_end_date`) and inserts new active versions whenever tracked attributes (such as product prices, customer contacts, or addresses) change.
* **Performance Optimization:**
  * Strategic non-clustered indexes created on all Natural Keys in dimension tables and Foreign Keys in fact tables to accelerate `JOIN` and `LOOKUP` operations.
* **Idempotency & Error Handling:**
  * All DDL scripts use `DROP TABLE IF EXISTS` / `IF NOT EXISTS` checks, and all ETL Stored Procedures are wrapped in `BEGIN TRY ... BEGIN CATCH` blocks for safe re-execution.

---

##  How to Execute the Pipeline

Run the SQL scripts in your SQL Server Management Studio (SSMS) in the exact hierarchical order below:

1. **Initialize Databases:** Create `AdventureWorks_Staging` and `adventureworks_dw_presentation` (along with `rawdata`, `cleaned_data`, `etl`, `shared`, and `sales_data_mart` schemas).
2. **Build & Load Staging (`Staging/`):**
   * Execute `00_staging_tables_structure.sql`
   * Execute `01_load_staging_rawdata.sql`
3. **Build & Run Cleaning ETL (`02_Cleaning_ETL/`):**
   * Execute `02_cleaned_data_schema.sql`
   * Execute `01_clean_and_transform_staging_data.sql`
4. **Create & Populate Conformed Dimensions (`Shared_Dim/`):**
   * Execute `*_structure.sql` scripts first (`01`, `02`, `03`, `04`, `07`).
   * Execute `*_load_*.sql` procedures (`01`, `02`, `03`, `04`, `07`) to populate dimension records.
5. **Create & Populate Fact Tables (`Sales_Data_Mart/`):**
   * Execute `05_fact_sales_header_structure.sql` & `06_fact_sales_detail_structure.sql`.
   * Execute `05_load_fact_sales_header.sql` & `06_load_fact_sales_detail.sql` last.

---

##  Author

**Ahmed Youssef**  
*Data Engineer / BI Developer*
