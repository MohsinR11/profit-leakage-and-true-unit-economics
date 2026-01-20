CREATE SCHEMA analytics;

-- Build the base fact table

-- analytics.fact_unit_economics
CREATE TABLE analytics.fact_unit_economics AS
SELECT
    oi.order_id,
    oi.product_id,
    c.customer_unique_id,
    p.product_category_name,
    oi.item_revenue,
    oi.logistics_cost,
    pay.total_paid_amount,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date
FROM staging.order_items oi
JOIN staging.orders o
    ON oi.order_id = o.order_id
JOIN staging.payments pay
    ON oi.order_id = pay.order_id
JOIN staging.customers c
    ON o.customer_id = c.customer_id
LEFT JOIN staging.products p
    ON oi.product_id = p.product_id;

-- Row count
SELECT COUNT(*) FROM analytics.fact_unit_economics;

-- Revenue sanity
SELECT
    SUM(item_revenue) AS total_item_revenue,
    SUM(logistics_cost) AS total_logistics_cost
FROM analytics.fact_unit_economics;


-- Introduce payment gateway cost

-- Payment cost and contribution margin
CREATE TABLE analytics.fact_unit_economics_v2 AS
SELECT
    *,
    total_paid_amount * 0.02 AS payment_gateway_fee,
    item_revenue
        - logistics_cost
        - (total_paid_amount * 0.02) AS contribution_margin
FROM analytics.fact_unit_economics;


-- Identify profit leakage immediately

-- Loss-making items
SELECT
    product_category_name,
    COUNT(*) AS items_sold,
    SUM(contribution_margin) AS total_contribution
FROM analytics.fact_unit_economics_v2
GROUP BY product_category_name
ORDER BY total_contribution ASC;

-- Orders that should never have happened
SELECT
    order_id,
    SUM(contribution_margin) AS order_contribution
FROM analytics.fact_unit_economics_v2
GROUP BY order_id
HAVING SUM(contribution_margin) < 0
ORDER BY order_contribution;

-- Customer-level unit economics
SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS orders_count,
    SUM(contribution_margin) AS lifetime_contribution
FROM analytics.fact_unit_economics_v2
GROUP BY customer_unique_id
ORDER BY lifetime_contribution ASC;


-- Create modeled marketing spend table
CREATE TABLE analytics.marketing_spend_model (
    marketing_channel VARCHAR(50),
    monthly_spend NUMERIC
);

-- Insert values
INSERT INTO analytics.marketing_spend_model VALUES
('paid_search', 50000),
('paid_social', 30000),
('organic_search', 5000),
('referral', 3000),
('unknown', 2000);

-- Calculate CAC per converted lead
CREATE TABLE analytics.channel_cac AS
SELECT
    ms.marketing_channel,
    ms.monthly_spend,
    mc.converted_leads,
    ms.monthly_spend / NULLIF(mc.converted_leads, 0) AS cac_per_converted_lead
FROM analytics.marketing_spend_model ms
LEFT JOIN staging.marketing_conversions mc
ON ms.marketing_channel = mc.marketing_channel;

-- Compute total orders
CREATE TABLE analytics.total_orders AS
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM analytics.fact_unit_economics_v2;

-- Average CAC per order
CREATE TABLE analytics.cac_per_order AS
SELECT
    SUM(monthly_spend) / (SELECT total_orders FROM analytics.total_orders)
        AS avg_cac_per_order
FROM analytics.marketing_spend_model;


-- FINAL unit economics table
CREATE TABLE analytics.fact_unit_economics_final AS
SELECT
    f.*,
    cpo.avg_cac_per_order AS allocated_cac,
    contribution_margin - cpo.avg_cac_per_order AS net_profit
FROM analytics.fact_unit_economics_v2 f
CROSS JOIN analytics.cac_per_order cpo;

-- Final profit leakage analysis
-- Loss-making SKUs
SELECT
    product_category_name,
    COUNT(*) AS items_sold,
    SUM(net_profit) AS net_profit_total
FROM analytics.fact_unit_economics_final
GROUP BY product_category_name
ORDER BY net_profit_total ASC;

-- Customers destroying value
SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS orders,
    SUM(net_profit) AS lifetime_profit
FROM analytics.fact_unit_economics_final
GROUP BY customer_unique_id
ORDER BY lifetime_profit ASC;

-- Growth illusion detection
SELECT
    COUNT(*) AS loss_making_orders
FROM (
    SELECT
        order_id,
        SUM(net_profit) AS order_profit
    FROM analytics.fact_unit_economics_final
    GROUP BY order_id
    HAVING SUM(net_profit) < 0
) x;
