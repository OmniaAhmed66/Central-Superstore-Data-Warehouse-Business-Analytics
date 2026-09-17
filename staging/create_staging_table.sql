USE central_superstore;
GO


IF OBJECT_ID('staging.staging_superstore', 'U') IS NOT NULL
    DROP TABLE staging.staging_superstore;
GO

CREATE TABLE staging.staging_superstore (
    row_id INT,
    order_id varchar(20),
    order_date DATE,
    ship_date DATE,
    ship_mode varchar(20),
    customer_id varchar(20),
    customer_name varchar(100),
    segment varchar(50),
    country varchar(50),
    city varchar(100),
    state varchar(50),
    postal_code varchar(20),
    region varchar(50),
    product_id varchar(20),
    category varchar(50),
    sub_category varchar(50),
    product_name varchar(200),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(3,2),
    profit DECIMAL(10,2)
);
