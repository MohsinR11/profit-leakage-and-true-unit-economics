CREATE SCHEMA staging;

-- Create staging.orders
CREATE TABLE staging.orders AS
SELECT
    order_id,
    customer_id,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM raw.orders
WHERE order_status = 'delivered';

-- Validation
SELECT COUNT(*) FROM staging.orders;


-- Create staging.order_items
CREATE TABLE staging.order_items AS
SELECT
    oi.order_id,
    oi.product_id,
    oi.seller_id,
    oi.price AS item_revenue,
    oi.freight_value AS logistics_cost
FROM raw.order_items oi
JOIN staging.orders o
ON oi.order_id = o.order_id;

-- Validation
SELECT
    COUNT(*) AS item_rows,
    SUM(item_revenue) AS total_item_revenue
FROM staging.order_items;


-- Create staging.payments
CREATE TABLE staging.payments AS
SELECT
    order_id,
    SUM(payment_value) AS total_paid_amount
FROM raw.order_payments
GROUP BY order_id;

-- Validation
SELECT
    COUNT(*) AS orders_paid,
    SUM(total_paid_amount) AS total_cash_collected
FROM staging.payments;


-- Create staging.customers
CREATE TABLE staging.customers AS
SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_state
FROM raw.customers c;


-- Create staging.products
CREATE TABLE staging.products AS
SELECT
    product_id,
    product_category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM raw.products;


-- Create staging.marketing_channels
CREATE TABLE staging.marketing_channels AS
SELECT
    origin AS marketing_channel,
    COUNT(*) AS total_leads
FROM raw.marketing_qualified_leads
GROUP BY origin;


-- Create staging.marketing_conversions
CREATE TABLE staging.marketing_conversions AS
SELECT
    m.origin AS marketing_channel,
    COUNT(cd.mql_id) AS converted_leads
FROM raw.marketing_qualified_leads m
LEFT JOIN raw.closed_deals cd
ON m.mql_id = cd.mql_id
GROUP BY m.origin;


-- CHECKPOINT
SELECT COUNT(*) FROM staging.orders;
SELECT COUNT(*) FROM staging.order_items;
SELECT COUNT(*) FROM staging.payments;
SELECT COUNT(*) FROM staging.customers;
SELECT COUNT(*) FROM staging.products;
SELECT COUNT(*) FROM staging.marketing_channels;


