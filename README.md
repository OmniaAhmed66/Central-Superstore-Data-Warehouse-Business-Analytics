# Central Superstore Data Warehouse & Business Analytics

A SQL Server data warehouse project built on the Central Superstore dataset, organized using the **Staging / Bronze / Silver / Gold** architecture. This is Mini-Project 2: Advanced SQL Data Warehouse & Business Analytics, done as part of my Data Analysis training with DEPI.

## Architecture

```
staging/  temporary raw loading area from the source csv
bronze/   raw data stored inside the warehouse with incremental loading
silver/   cleaned, modeled data (star schema: fact + dimensions)
gold/     business-ready layer (views, stored procedures, KPI queries, insights)
```

### Setup
- `00_setup.sql` – creates the database and the four schemas: `staging`, `bronze`, `silver`, and `gold`

### Staging layer
- `staging/create_staging_table.sql` – creates the raw staging table (matches the csv columns 1:1)
- `staging/load_staging.sql` – truncates staging and bulk inserts the raw `Central_Superstore.csv` file, no transformation applied

### Bronze layer
- `bronze/create_bronze_table.sql` – creates the raw bronze table and adds `bronze_id` as a surrogate key
- `bronze/load_bronze.sql` – incrementally loads only rows that are not already in bronze; the bronze layer is not truncated

### Silver layer
- `silver/create_silver_tables.sql` – the star schema: `dim_customer`, `dim_product`, `dim_location`, `dim_date`, `dim_ship_mode`, `fact_sales`, with primary/foreign keys defined
- `silver/load_silver.sql` – loads the dimensions and the fact table from the bronze layer
- `silver/data_validation.sql` – row count checks and checks for missing keys between the fact table and each dimension
- `silver/product_id_check.sql` – investigation into a data quality issue found during modeling (`product_id` is not actually unique in the source data — 16 ids map to more than one product name), and why `(product_id, product_name)` was used as the unique key on `dim_product` instead of `product_id` alone
- `silver/optimization.sql` – adding an index on `fact_sales(customer_id)` since it's used in filters/joins across the project, with a before/after comparison of the execution plan

### Gold layer
- `gold/queries.sql` – basic queries, joins, subqueries, CTEs, and CASE statements against the star schema
- `gold/views_and_procedures.sql` – `view_customer_performance`, `view_category_performance`, and stored procedures (`customer_kpi`, `category_kpi`, `customer_kpi_dashboard`) for KPI reporting
- `gold/business_analysis.sql` – the final business analysis: profitability by category, effect of discount on profit, customer segment behavior, one-time vs repeat customers, sales trends by year/quarter, and top products, each with the insight written as a comment under the query

## Dataset
`Central_Superstore.csv` — order-level retail transactions (customer, product, location, dates, sales, quantity, discount, profit).

## Tools
SQL Server, T-SQL
