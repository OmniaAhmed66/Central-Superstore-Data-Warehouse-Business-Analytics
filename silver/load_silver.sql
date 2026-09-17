USE central_superstore;
GO


DELETE FROM silver.fact_sales;
DELETE FROM silver.dim_customer;
DELETE FROM silver.dim_product;
DELETE FROM silver.dim_location;
DELETE FROM silver.dim_date;
DELETE FROM silver.dim_ship_mode;


--load customer dimension
INSERT INTO silver.dim_customer (
    customer_id,
    customer_name,
    segment
)
SELECT DISTINCT customer_id , customer_name ,segment
FROM bronze.staging_superstore;


--load product dimension
INSERT INTO silver.dim_product (
    product_id,
    product_name,
    category,
    sub_category
)
SELECT DISTINCT product_id , product_name , category , sub_category
FROM bronze.staging_superstore;


--load location dimension
INSERT INTO silver.dim_location (
    country,
    region,
    state,
    city,
    postal_code
)
SELECT DISTINCT
    country,
    region,
    state,
    city,
    postal_code
FROM bronze.staging_superstore;


--load ship mode dimension
INSERT INTO silver.dim_ship_mode (
    ship_mode
)
SELECT DISTINCT ship_mode
FROM bronze.staging_superstore;


--load date dimension
INSERT INTO silver.dim_date (
    full_date,
    day,
    month,
    year,
    quarter,
    month_name
)
SELECT
    full_date,
    DAY(full_date),
    MONTH(full_date),
    YEAR(full_date),
    DATEPART(QUARTER, full_date),
    DATENAME(MONTH, full_date)
FROM (
    SELECT order_date AS full_date
    FROM bronze.staging_superstore

    UNION

    SELECT ship_date AS full_date
    FROM bronze.staging_superstore
) AS dates;


--load fact table
INSERT INTO silver.fact_sales (
    order_id,
    customer_id,
    product_key,
    location_id,
    order_date_id,
    ship_date_id,
    ship_mode_id,
    sales,
    quantity,
    discount,
    profit
)
SELECT
    s.order_id,
    s.customer_id,
    p.product_key,
    l.location_id,
    od.date_id,
    sd.date_id,
    sm.ship_mode_id,
    s.sales,
    s.quantity,
    s.discount,
    s.profit
FROM bronze.staging_superstore AS s

JOIN silver.dim_customer AS c
ON s.customer_id = c.customer_id

JOIN silver.dim_product AS p
ON s.product_id = p.product_id
AND s.product_name = p.product_name

JOIN silver.dim_location AS l
ON s.country = l.country
AND s.region = l.region
AND s.state = l.state
AND s.city = l.city
AND s.postal_code = l.postal_code

JOIN silver.dim_date AS od
ON s.order_date = od.full_date

JOIN silver.dim_date AS sd
ON s.ship_date = sd.full_date

JOIN silver.dim_ship_mode AS sm
ON s.ship_mode = sm.ship_mode;


