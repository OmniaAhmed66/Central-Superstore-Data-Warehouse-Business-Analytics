USE central_superstore;
GO

--basic sql queries
SELECT TOP 10 *
FROM silver.fact_sales;


SELECT DISTINCT segment
FROM silver.dim_customer;


SELECT sales 
FROM silver.fact_sales
WHERE sales > 500
ORDER BY sales DESC;


SELECT SUM(sales) AS total_sales
FROM silver.fact_sales;


SELECT AVG(sales) AS avg_sales
FROM silver.fact_sales;


SELECT COUNT(*) AS number_of_transactions
FROM silver.fact_sales;


SELECT MAX(sales) AS max_sales , MIN(sales) AS min_sales
FROM silver.fact_sales;


SELECT customer_id , SUM(sales)
FROM silver.fact_sales
GROUP BY customer_id
HAVING SUM(sales) > 2000;


--join

SELECT segment, SUM(sales) AS total_sales
FROM silver.fact_sales AS f
JOIN silver.dim_customer AS c
ON f.customer_id = c.customer_id
GROUP BY segment
ORDER BY total_sales DESC;


SELECT p.category , SUM(sales) AS total_sales
FROM silver.fact_sales AS f  
JOIN silver.dim_product as p  
ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_sales DESC;


SELECT l.state , SUM(profit) AS total_profit
FROM silver.fact_sales AS f
JOIN silver.dim_location AS l
ON f.location_id = l.location_id
GROUP BY l.state
ORDER BY total_profit DESC;


SELECT d.year , SUM(sales) AS total_sales
FROM silver.fact_sales AS f  
JOIN silver.dim_date as d   
ON f.order_date_id = d.date_id
GROUP BY d.year
ORDER BY total_sales DESC;


SELECT TOP 10 p.product_name , SUM(quantity) AS total_quantity
FROM silver.fact_sales AS f  
JOIN silver.dim_product as p   
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_quantity DESC;


SELECT  c.customer_id , ISNULL(SUM(f.sales), 0) AS total_sales
FROM silver.dim_customer AS c
LEFT JOIN silver.fact_sales AS f 
ON c.customer_id = f.customer_id
GROUP BY c.customer_id
ORDER BY total_sales DESC;


--subqueries
SELECT customer_id, SUM(sales) AS total_sales
FROM silver.fact_sales
GROUP BY customer_id
HAVING SUM(sales) > ( SELECT AVG(total_sales)
    FROM (
        SELECT customer_id, SUM(sales) AS total_sales
        FROM silver.fact_sales
        GROUP BY customer_id
    ) AS customer_totals
);


SELECT product_key , SUM(sales) AS total_sales
FROM silver.fact_sales 
GROUP BY product_key
HAVING SUM(sales) > ( SELECT AVG(total_sales)
    FROM (
        SELECT product_key , SUM(sales) AS total_sales
        FROM silver.fact_sales
        GROUP BY product_key
    ) AS product_totals
);


SELECT customer_id , total_sales
FROM(
    SELECT customer_id , SUM(sales) AS total_sales
    FROM silver.fact_sales
    GROUP BY customer_id
)AS customer_totals
WHERE total_sales > 2000;


--CTEs

WITH customer_sales AS(
    SELECT customer_id , SUM(sales) as total_sales , SUM(profit) AS total_profit 
    FROM silver.fact_sales
    GROUP BY customer_id
)
SELECT customer_id , total_sales , total_profit 
FROM customer_sales
WHERE total_sales > 2000;


with category_sales AS (
    SELECT p.category , SUM(sales) AS total_sales , SUM(profit) AS total_profit
    FROM silver.fact_sales AS f
    JOIN silver.dim_product AS p
    ON f.product_key = p.product_key
    GROUP BY p.category
)
SELECT category , total_sales , total_profit
FROM category_sales 
WHERE total_sales > (
    select AVG(total_sales)
    FROM category_sales
);


WITH sales_by_year AS(
    SELECT d.year , SUM(sales) AS total_sales , SUM(profit) AS total_profit
    FROM silver.fact_sales as f  
    JOIN silver.dim_date as d  
    on d.date_id = f.order_date_id
    GROUP BY d.year
)
SELECT year , total_sales , total_profit
FROM sales_by_year
ORDER BY year;


--case statements

SELECT order_id , profit ,
CASE
    WHEN profit < 0 THEN 'loss'
    WHEN profit = 0 THEN 'no profit'
    WHEN profit > 0 THEN 'profit'
    END AS profit_status
FROM silver.fact_sales;


WITH customer_sales AS(
    SELECT customer_id , SUM(sales) AS total_sales 
    FROM silver.fact_sales
    GROUP BY customer_id
)
SELECT customer_id , total_sales ,
CASE
    WHEN total_sales < 0.8 * (
        SELECT AVG(total_sales)
        FROM customer_sales
        )THEN 'low value'

    WHEN total_sales <= 1.2 * (
        SELECT AVG(total_sales)
        FROM customer_sales
    )THEN 'medium value'

    ELSE 'high value'
    END AS customer_status
FROM customer_sales;
