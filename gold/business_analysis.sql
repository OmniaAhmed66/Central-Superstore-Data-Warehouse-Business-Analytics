USE central_superstore;
GO


--profitability analysis
--which category is the most profitable and which category is making a loss?
SELECT p.category , SUM(profit) AS total_profit , SUM(sales) AS total_sales
FROM silver.fact_sales AS f   
JOIN silver.dim_product as p 
ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_profit DESC;
--technology has the highest profit while furniture is making loss


--how does discount level affect profit and sales?
SELECT discount , AVG(profit) AS avg_profit , AVG(sales) AS avg_sales , COUNT(*) AS number_of_orders,
       AVG(quantity) AS avg_quantity
FROM silver.fact_sales 
GROUP BY discount
ORDER BY avg_profit DESC;
--the result here was very interesting for me because discount 10% has a higher profit than no discount (0%)
--but the difference in the number of order is huge
--it does not make sense to me so i decided to check it
--but overall profit generally decreases as discount increases but the relationship is not linear
SELECT *
FROM silver.fact_sales
WHERE discount = 0.10
ORDER BY profit DESC;
--after i checked it everything became clear 
--discount 10% has an outlier (sales = 3059.98)
--and that's why the profit was high even though the quantity was low


--summary:
--furniture is the only category that making loss (-2871.10)
--technology is the most profitable category (33697.60)
--profit generally decreases as discount increases
--and any discount of 30% or higher making a loss 
--recommendation: 
--the company should review discounts for furniture specifically
--and avoid discounts of 30% or more on any category since this consistently makes losses



--customer behavior analysis
--which customer segment generates the highest sales and profit?
SELECT  c.segment , SUM(sales) AS total_sales , AVG(sales) AS avg_sales, SUM(profit) AS total_profit 
, AVG(profit) AS avg_profit , COUNT(DISTINCT f.order_id) AS number_of_orders
FROM silver.fact_sales AS f  
JOIN silver.dim_customer AS c
ON f.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY total_profit DESC;
--corporate has the highest total profit and average sales 
--consumer has the highest total sales and number of orders but but very low average profit 
-- home office has the highest average profit

--how many customers are one time buyers and how many are repeat customers?
WITH customer_orders AS (
    SELECT  c.customer_id, COUNT(DISTINCT order_id) AS number_of_orders
    FROM silver.fact_sales AS f
    JOIN silver.dim_customer AS c
    ON f.customer_id = c.customer_id
    GROUP BY c.customer_id
)
SELECT 
    CASE
        WHEN number_of_orders = 1 THEN 'one time'
        ELSE 'repeat'
    END AS purchase_frequency,
    COUNT(*) AS number_of_customers
FROM customer_orders
GROUP BY 
    CASE
        WHEN number_of_orders = 1 THEN 'one time'
        ELSE 'repeat'
    END;
-- repeat customers are more common than one time customers.
-- this indicates that a good number of customers make more than one purchase.

--do customers with high sales also have high profitability?
WITH customer_behavior AS (
    SELECT customer_id, SUM(sales) AS total_sales, SUM(profit) AS total_profit, 
    COUNT(DISTINCT order_id) AS number_of_orders
    FROM silver.fact_sales
    GROUP BY customer_id
)
SELECT customer_id, total_sales, total_profit,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank,
    RANK() OVER (ORDER BY total_profit DESC) AS profit_rank
FROM customer_behavior
ORDER BY total_sales DESC;
-- BM-11140 has the 3rd highest sales but a very low profit rank (626)
-- SB-20290 and AA-10315 also have high sales but very low profit ranks
-- this shows that high sales do not always mean high profitability
-- the company should review these customers to understand what is causing the low profit


--summary:
-- corporate has the highest total profit 
--while consumer has the highest total sales and number of orders
-- repeat customers are more common than one time customers
-- some customers have high sales but very low or negative profit

--recommendation: 
--the company should encourage one time customers to make repeat purchases
-- and review high sales customers with low or negative profit 
--to understand what is reducing their profitability



--sales trends analysis

--are sales and profit increasing or decreasing over the years?
SELECT d.year , SUM(sales) AS total_sales , SUM(profit) AS total_profit , 
COUNT(DISTINCT f.order_id) AS number_of_orders
FROM silver.fact_sales AS f
JOIN silver.dim_date AS d
ON f.order_date_id = d.date_id
GROUP BY d.year
ORDER BY d.year; 
--2015 had the highest sales and highest profit 
--2016 had almost the same sales but a lower profit
--the number of orders increased over the years



--are there specific quarters with higher sales and profit?
SELECT d.quarter , SUM(sales) AS total_sales , SUM(profit) AS total_profit ,
COUNT(DISTINCT f.order_id) AS number_of_orders
FROM silver.fact_sales AS f   
JOIN silver.dim_date AS d   
ON f.order_date_id = d.date_id
GROUP BY d.quarter
ORDER BY total_sales DESC;
--quarter 4 has the highest sales and profit and number of orders
--quarter 1 has the lowest sales and profit and number of orders
--sales and profit are much higher in quarter 4 than in the other quarters




--top 10 products 
SELECT TOP 10 p.product_name , SUM(sales) AS total_sales , SUM(profit) AS total_profit ,
SUM(quantity) AS total_quantity
FROM silver.fact_sales AS f
JOIN silver.dim_product AS p
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_sales DESC;
--the highest product in sales and profit sold in a small quantity (only 5)
--high sales do not always mean high profit
--some products with high sales are making losses


--summary:
--performance is not consistent across the year quarter 4 has the highest sales and profit while quarter 1 is the weakest
--2016 shows sales can stay the same while profit drops
--and even the best selling products can end up being the least profitable ones

--recommendation:
--the company should focus more on quarter 4 since it consistently performs best across sales and profit and orders
--and investigate why profit dropped in 2016 despite similar sales to 2015
--and review the top selling products with low or negative profit to understand what is causing that