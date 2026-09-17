USE central_superstore;
GO

--views

DROP VIEW IF EXISTS gold.view_customer_performance;
GO

CREATE VIEW gold.view_customer_performance AS
SELECT customer_id , SUM(sales) AS total_sales , SUM(profit) AS total_profit
FROM silver.fact_sales
GROUP BY customer_id;
GO

SELECT *
FROM gold.view_customer_performance
ORDER BY total_profit DESC;
GO

DROP VIEW IF EXISTS gold.view_category_performance;
GO

CREATE VIEW gold.view_category_performance AS
SELECT p.category , SUM(sales) AS total_sales , SUM(profit) AS total_profit , SUM(quantity) AS total_quantity
FROM silver.fact_sales AS f  
JOIN silver.dim_product as p
ON p.product_key = f.product_key
GROUP BY p.category;
GO

SELECT *
FROM gold.view_category_performance
ORDER BY total_profit DESC;
GO


--stored procedures
DROP PROCEDURE IF EXISTS gold.customer_kpi;
GO

CREATE PROCEDURE gold.customer_kpi 
@customer_id varchar(20) AS
BEGIN
SELECT customer_id, SUM(sales) AS total_sales, SUM(profit) AS total_profit
FROM silver.fact_sales
WHERE customer_id = @customer_id
GROUP BY customer_id
END;
GO

SELECT DISTINCT customer_id
FROM silver.fact_sales;

EXEC gold.customer_kpi @customer_id = 'LF-17185' ;
GO

DROP PROCEDURE IF EXISTS gold.category_kpi;
GO

CREATE PROCEDURE gold.category_kpi
@category varchar(50) AS
BEGIN 
SELECT p.category , SUM(sales) AS total_sales, SUM(profit) AS total_profit
FROM silver.fact_sales as f  
JOIN silver.dim_product as p   
ON f.product_key = p.product_key
WHERE p.category = @category
GROUP BY p.category
END;
GO

SELECT DISTINCT category
FROM silver.dim_product;

EXEC gold.category_kpi @category = 'Technology';
GO



DROP PROCEDURE IF EXISTS gold.customer_kpi_dashboard;
GO

CREATE PROCEDURE gold.customer_kpi_dashboard
@customer_id varchar(20) AS
BEGIN
    WITH all_customers AS (
        SELECT customer_id, 
               SUM(sales) AS total_sales, 
               SUM(profit) AS total_profit
        FROM silver.fact_sales
        GROUP BY customer_id
    )
    SELECT 
        customer_id,
        total_sales,
        total_profit,
        ROUND((SELECT AVG(total_profit) FROM all_customers), 2) AS avg_profit_all_customers,
        CASE
            WHEN total_profit < 0 THEN 'loss making'
            WHEN total_profit > (SELECT AVG(total_profit) FROM all_customers) * 1.2 THEN 'high value'
            WHEN total_profit < (SELECT AVG(total_profit) FROM all_customers) * 0.8 THEN 'low value'
            ELSE 'medium value'
        END AS customer_status,
        RANK() OVER (ORDER BY total_profit DESC) AS profit_rank
    FROM all_customers
    WHERE customer_id = @customer_id;
END;
GO

EXEC gold.customer_kpi_dashboard @customer_id = 'LF-17185';
GO
