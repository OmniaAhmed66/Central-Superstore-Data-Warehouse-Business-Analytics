USE central_superstore;
GO

--before optimization
--customer_id is used in filters and joins across the project

DROP INDEX IF EXISTS idx_fact_sales_customer_id
ON silver.fact_sales;
GO

SELECT customer_id , SUM(sales) AS total_sales , SUM(profit) AS total_profit
FROM silver.fact_sales
WHERE customer_id = 'LF-17185'
GROUP BY customer_id;



CREATE INDEX idx_fact_sales_customer_id
ON silver.fact_sales(customer_id);
GO


--after optimization

SELECT customer_id , SUM(sales) AS total_sales , SUM(profit) AS total_profit
FROM silver.fact_sales
WHERE customer_id = 'LF-17185'
GROUP BY customer_id;


--result
--before optimization sql server used a clustered index scan
--and read all 2323 rows from fact_sales

--after creating the index on customer_id sql server used an index seek and read only 7 matching rows
--this shows that the index helps queries that filter by customer_id
