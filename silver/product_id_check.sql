USE central_superstore;
GO


SELECT product_id, COUNT(*) AS occurrences
FROM bronze.staging_superstore
WHERE product_id = 'FUR-CH-10001146'
GROUP BY product_id;


SELECT product_id, product_name, category, sub_category
FROM bronze.staging_superstore
WHERE product_id = 'FUR-CH-10001146';
--different 2 products with the same id


SELECT product_id , COUNT(DISTINCT product_name)
FROM bronze.staging_superstore
GROUP BY product_id
HAVING COUNT(DISTINCT product_name) > 1;
--16 id have more than 1 product name


SELECT product_id , COUNT(DISTINCT category)
FROM bronze.staging_superstore
GROUP BY product_id
HAVING COUNT(DISTINCT category) > 1;
--each id have an unique category


SELECT product_id , COUNT(DISTINCT sub_category)
FROM bronze.staging_superstore
GROUP BY product_id
HAVING COUNT(DISTINCT sub_category) > 1;
--each id have an unique sub_category


SELECT product_id , product_name 
FROM bronze.staging_superstore
WHERE product_id IN (
    SELECT product_id
    FROM bronze.staging_superstore
    GROUP BY product_id
    HAVING COUNT(DISTINCT product_name) > 1
);
--the product_id is not unique so (DISTINCT) will not be the best to use 


SELECT kc.name AS constraint_name
FROM sys.key_constraints kc
JOIN sys.tables t
ON kc.parent_object_id = t.object_id
JOIN sys.schemas s
ON t.schema_id = s.schema_id
WHERE t.name = 'dim_product'
AND s.name = 'silver'
AND kc.type = 'PK';


SELECT fk.name AS foreign_key_name
FROM sys.foreign_keys fk
WHERE fk.parent_object_id = OBJECT_ID('silver.fact_sales')
AND fk.referenced_object_id = OBJECT_ID('silver.dim_product');
