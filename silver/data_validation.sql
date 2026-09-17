USE central_superstore;
GO


--check staging data
SELECT TOP 10 *
FROM bronze.staging_superstore;


SELECT COUNT(*) AS staging_rows
FROM bronze.staging_superstore;


--check dimension row counts
SELECT COUNT(*) AS customer_count
FROM silver.dim_customer;


SELECT COUNT(*) AS product_count
FROM silver.dim_product;


SELECT COUNT(*) AS location_count
FROM silver.dim_location;


SELECT COUNT(*) AS date_count
FROM silver.dim_date;


SELECT COUNT(*) AS ship_mode_count
FROM silver.dim_ship_mode;


SELECT COUNT(*) AS fact_count
FROM silver.fact_sales;


--check product mapping
SELECT s.product_id , s.product_name , p.product_key
FROM bronze.staging_superstore AS s
JOIN silver.dim_product AS p
ON s.product_id = p.product_id
AND s.product_name = p.product_name;


--check for missing customers in fact table
SELECT COUNT(*) AS missing_customers
FROM silver.fact_sales AS f
LEFT JOIN silver.dim_customer AS c
ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


--check for missing products in fact table
SELECT COUNT(*) AS missing_products
FROM silver.fact_sales AS f
LEFT JOIN silver.dim_product AS p
ON f.product_key = p.product_key
WHERE p.product_key IS NULL;


--check for missing locations in fact table
SELECT COUNT(*) AS missing_locations
FROM silver.fact_sales AS f
LEFT JOIN silver.dim_location AS l
ON f.location_id = l.location_id
WHERE l.location_id IS NULL;


--check for missing order dates
SELECT COUNT(*) AS missing_order_dates
FROM silver.fact_sales AS f
LEFT JOIN silver.dim_date AS d
ON f.order_date_id = d.date_id
WHERE d.date_id IS NULL;


--check for missing ship dates
SELECT COUNT(*) AS missing_ship_dates
FROM silver.fact_sales AS f
LEFT JOIN silver.dim_date AS d
ON f.ship_date_id = d.date_id
WHERE d.date_id IS NULL;


--check for missing ship modes
SELECT COUNT(*) AS missing_ship_modes
FROM silver.fact_sales AS f
LEFT JOIN silver.dim_ship_mode AS s
ON f.ship_mode_id = s.ship_mode_id
WHERE s.ship_mode_id IS NULL;
