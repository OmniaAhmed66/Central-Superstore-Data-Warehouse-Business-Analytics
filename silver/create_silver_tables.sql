USE central_superstore;
GO


--drop fact table first because it has foreign keys to the dimensions
IF OBJECT_ID('silver.fact_sales', 'U') IS NOT NULL
    DROP TABLE silver.fact_sales;
GO

IF OBJECT_ID('silver.dim_customer', 'U') IS NOT NULL
    DROP TABLE silver.dim_customer;
GO

IF OBJECT_ID('silver.dim_product', 'U') IS NOT NULL
    DROP TABLE silver.dim_product;
GO

IF OBJECT_ID('silver.dim_location', 'U') IS NOT NULL
    DROP TABLE silver.dim_location;
GO

IF OBJECT_ID('silver.dim_date', 'U') IS NOT NULL
    DROP TABLE silver.dim_date;
GO

IF OBJECT_ID('silver.dim_ship_mode', 'U') IS NOT NULL
    DROP TABLE silver.dim_ship_mode;
GO


CREATE TABLE silver.dim_customer (
    customer_id varchar(20) PRIMARY KEY,
    customer_name varchar(100) NOT NULL,
    segment varchar(50)
);


CREATE TABLE silver.dim_product (
    product_key INT IDENTITY(1,1) PRIMARY KEY,
    product_id varchar(20),
    product_name varchar(200) NOT NULL,
    category varchar(50),
    sub_category varchar(50),
    CONSTRAINT UQ_dim_product_product_id_name
        UNIQUE (product_id, product_name)
);


CREATE TABLE silver.dim_location (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    country varchar(50),
    region varchar(50),
    state varchar(50),
    city varchar(100),
    postal_code varchar(20)
);


CREATE TABLE silver.dim_date (
    date_id INT IDENTITY(1,1) PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    year INT,
    quarter INT CHECK(quarter BETWEEN 1 AND 4),
    month_name varchar(20)
);


CREATE TABLE silver.dim_ship_mode (
    ship_mode_id INT IDENTITY(1,1) PRIMARY KEY,
    ship_mode varchar(20) NOT NULL
);


CREATE TABLE silver.fact_sales (
    order_line_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id varchar(20),
    customer_id varchar(20),
    product_key INT,
    location_id INT,
    order_date_id INT,
    ship_date_id INT,
    ship_mode_id INT,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(3,2),
    profit DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES silver.dim_customer(customer_id),
    FOREIGN KEY (product_key) REFERENCES silver.dim_product(product_key),
    FOREIGN KEY (location_id) REFERENCES silver.dim_location(location_id),
    FOREIGN KEY (order_date_id) REFERENCES silver.dim_date(date_id),
    FOREIGN KEY (ship_date_id) REFERENCES silver.dim_date(date_id),
    FOREIGN KEY (ship_mode_id) REFERENCES silver.dim_ship_mode(ship_mode_id)
);
