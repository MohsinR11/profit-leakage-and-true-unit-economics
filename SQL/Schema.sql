CREATE SCHEMA raw;
SHOW SERVER_ENCODING;

-- Create raw.orders table
CREATE TABLE raw.orders (
    order_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- Load CSV into raw.orders
COPY raw.orders
FROM 'D:/Projects/End-to-end projects/Profit Leakage & True Unit Economics/Data/Raw/olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER;

-- Row count
SELECT COUNT(*) FROM raw.orders;

-- Status distribution
SELECT order_status, COUNT(*)
FROM raw.orders
GROUP BY order_status;


-- Create raw.order_items table
CREATE TABLE raw.order_items (
    order_id VARCHAR(32),
    order_item_id INTEGER,
    product_id VARCHAR(32),
    seller_id VARCHAR(32),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

-- Load CSV into raw.order_items
COPY raw.order_items
FROM 'D:/Projects/End-to-end projects/Profit Leakage & True Unit Economics/Data/Raw/olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER;

-- Row count
SELECT COUNT(*) FROM raw.order_items;

-- Orders with multiple items
SELECT COUNT(DISTINCT order_id) AS unique_orders,
       COUNT(*) AS total_items
FROM raw.order_items;

-- Price sanity check
SELECT MIN(price), MAX(price)
FROM raw.order_items;


-- Create raw.order_payments table
CREATE TABLE raw.order_payments (
    order_id VARCHAR(32),
    payment_sequential INTEGER,
    payment_type VARCHAR(20),
    payment_installments INTEGER,
    payment_value NUMERIC(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- Load CSV into raw.order_payments
COPY raw.order_payments
FROM 'D:/Projects/End-to-end projects/Profit Leakage & True Unit Economics/Data/Raw/olist_order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;

-- Row count
SELECT COUNT(*) FROM raw.order_payments;

-- Orders with multiple payments
SELECT
    COUNT(DISTINCT order_id) AS orders,
    COUNT(*) AS payment_rows
FROM raw.order_payments;

-- Payment type distribution
SELECT payment_type, COUNT(*)
FROM raw.order_payments
GROUP BY payment_type;

-- Revenue reconciliation sanity check
SELECT
    SUM(oi.price) AS item_revenue,
    SUM(op.payment_value) AS paid_amount
FROM raw.order_items oi
JOIN raw.order_payments op
ON oi.order_id = op.order_id;


-- Create raw.products table
CREATE TABLE raw.products (
    product_id VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(50),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

-- Load CSV into raw.products
COPY raw.products
FROM 'D:/Projects/End-to-end projects/Profit Leakage & True Unit Economics/Data/Raw/olist_products_dataset.csv'
DELIMITER ','
CSV HEADER;

-- Row count
SELECT COUNT(*) FROM raw.products;

-- Missing category check
SELECT COUNT(*) 
FROM raw.products
WHERE product_category_name IS NULL;

-- Physical dimension sanity
SELECT
    MIN(product_weight_g),
    MAX(product_weight_g)
FROM raw.products;


-- Create raw.customers table
CREATE TABLE raw.customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(50),
    customer_state VARCHAR(5)
);

-- Load CSV into raw.customers
COPY raw.customers
FROM 'D:/Projects/End-to-end projects/Profit Leakage & True Unit Economics/Data/Raw/olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;

-- Row count
SELECT COUNT(*) FROM raw.customers;

-- Customer vs unique customer reality check
SELECT
    COUNT(DISTINCT customer_id) AS customer_ids,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM raw.customers;

-- Repeat customer distribution
SELECT
    customer_unique_id,
    COUNT(*) AS orders_count
FROM raw.customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY orders_count DESC
LIMIT 10;


-- Create raw.marketing_qualified_leads table
CREATE TABLE raw.marketing_qualified_leads (
    mql_id VARCHAR(32) PRIMARY KEY,
    first_contact_date DATE,
    landing_page_id VARCHAR(50),
    origin VARCHAR(50)
);

-- Load CSV into raw.marketing_qualified_leads
COPY raw.marketing_qualified_leads
FROM 'D:/Projects/End-to-end projects/Profit Leakage & True Unit Economics/Data/Raw/olist_marketing_qualified_leads_dataset.csv'
DELIMITER ','
CSV HEADER;

-- Row count
SELECT COUNT(*) FROM raw.marketing_qualified_leads;

-- Channel distribution
SELECT origin, COUNT(*)
FROM raw.marketing_qualified_leads
GROUP BY origin
ORDER BY COUNT(*) DESC;


-- Create raw.closed_deals table
DROP TABLE raw.closed_deals;

CREATE TABLE raw.closed_deals (
    mql_id VARCHAR(32) PRIMARY KEY,
    seller_id VARCHAR(32),
    sdr_id VARCHAR(32),
    sr_id VARCHAR(32),
    won_date DATE,
    business_segment VARCHAR(50),
    lead_type VARCHAR(50),
    lead_behaviour_profile VARCHAR(50),
    has_company BOOLEAN,
    has_gtin BOOLEAN,
    average_stock VARCHAR(50),
    business_type VARCHAR(50),
    declared_product_catalog_size NUMERIC,
    declared_monthly_revenue VARCHAR(50)
);

-- Load CSV into raw.closed_deals
COPY raw.closed_deals
FROM 'D:/Projects/End-to-end projects/Profit Leakage & True Unit Economics/Data/Raw/olist_closed_deals_dataset.csv'
DELIMITER ','
CSV HEADER;

-- Row count
SELECT COUNT(*) FROM raw.closed_deals;

-- Conversion by business segment
SELECT business_segment, COUNT(*)
FROM raw.closed_deals
GROUP BY business_segment
ORDER BY COUNT(*) DESC;