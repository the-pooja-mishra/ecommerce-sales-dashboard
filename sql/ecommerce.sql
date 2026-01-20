CREATE DATABASE ecommerce;

USE ecommerce;

CREATE TABLE customers (customer_id INT PRIMARY KEY,
customer_name VARCHAR(100),
gender VARCHAR(10),
age INT,
city VARCHAR(50),
signup_date DATE);

CREATE TABLE products (product_id INT PRIMARY KEY,
product_name VARCHAR(100),
category VARCHAR(50),
price DECIMAL(10,2));

CREATE TABLE orders (order_id INT PRIMARY KEY,
customer_id INT,
order_date DATE,
payment_method VARCHAR(30),
order_status VARCHAR(20),
FOREIGN KEY (customer_id) REFERENCES customers(customer_id));

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    discount DECIMAL(5,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id));
    

SELECT * FROM customers;
SELECT count(*) FROM order_items;
SELECT * FROM order_items LIMIT 5;
DESCRIBE order_items;
SELECT * FROM orders;
SELECT * FROM products;

SELECT COUNT(*) AS bad_orders
FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS bad_items
FROM order_items oi LEFT JOIN orders o ON oi.order_id= o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS bad_products
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- HANDLE CANCELLED ORDERS
-- Create Clean Orders View

CREATE OR REPLACE VIEW clean_orders AS
SELECT * 
FROM orders
WHERE order_status = 'Delivered';

-- Verify 
SELECT order_status, COUNT(*)
FROM orders
GROUP BY order_status;

SELECT COUNT(*) FROM clean_orders;

-- HANDLE NULLS & DATA STANDARDIZATION
-- Discount NULLs

SET SQL_SAFE_UPDATES = 0;

UPDATE order_items
SET discount = 0
WHERE discount IS NULL;

SET SQL_SAFE_UPDATES = 1;

-- Quantity Validation

SELECT *
FROM order_items
WHERE quantity <= 0;

SELECT COUNT(*) AS invalid_quantity
FROM order_items
WHERE quantity <= 0;

SELECT COUNT(*) AS null_quantity
FROM order_items
WHERE quantity IS NULL;

-- Standardize Text Fields

SET SQL_SAFE_UPDATES = 0;

UPDATE orders
SET payment_method = UPPER(payment_method);

SET SQL_SAFE_UPDATES = 1;

----- CREATE SALES FACT TABLE (ANALYSIS READY)
-- This table combines:Customer, Product, Order, Revenue

-- Create Sales Fact View

CREATE OR REPLACE VIEW sales_fact AS
SELECT o.order_id,
    o.order_date,
    o.customer_id,
    oi.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    p.price,
    oi.discount,
    (p.price * oi.quantity) * (1 - oi.discount / 100) AS revenue
FROM clean_orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- Validate Sales Fact
SELECT COUNT(*) FROM sales_fact;
SELECT * FROM sales_fact LIMIT 5;


-- ADD TIME FEATURES (FOR DASHBOARDS)
-- Power BI and SQL analysis need time attributes.

-- Enriched Sales View

SELECT VERSION();
SELECT YEAR(order_date)
FROM sales_fact
LIMIT 5;

SELECT MONTH(order_date)
FROM sales_fact
LIMIT 5;

SELECT DATE_FORMAT(order_date, '%Y-%m')
FROM sales_fact
LIMIT 5;

DROP TABLE IF EXISTS sales_fact_enriched;

CREATE TABLE sales_fact_enriched AS
SELECT
    order_id,
    order_date,
    customer_id,
    product_id,
    product_name,
    category,
    quantity,
    price,
    discount,
    revenue,
    YEAR(order_date)  AS order_year,
    MONTH(order_date) AS order_month,
    DATE_FORMAT(order_date, '%Y-%m') AS year_month_label
FROM sales_fact;

-- Validate Sales Fact
SELECT COUNT(*) FROM sales_fact_enriched;
SELECT * FROM sales_fact_enriched LIMIT 5;

-- STEP 3: EXPLORATORY DATA ANALYSIS (EDA)

-- 3.1 Overall Business Health (Top KPIs)
-- Total Revenue

SELECT ROUND(SUM(revenue),2) As total_revenue
FROM sales_fact_enriched;

-- Total Orders
SELECT COUNT(distinct order_id) AS total_orders
FROM sales_fact_enriched;

-- Total Customers
SELECT COUNT(distinct customer_id) AS total_customers
FROM sales_fact_enriched;

-- Average Order Value (AOV)
SELECT ROUND(SUM(revenue)/ count(DISTINCT order_id),2) AS avg_order_value
FROM sales_fact_enriched;

-- 3.2 Time-Based Analysis (Sales Trend)
-- Monthly Revenue Trend

SELECT year_month_label, ROUND(SUM(revenue), 2) AS monthly_revenue
FROM sales_fact_enriched
GROUP BY year_month_label
ORDER BY year_month_label;

-- Monthly Order Volume

SELECT year_month_label, count(Distinct order_id) AS monthly_orders
FROM sales_fact_enriched
GROUP BY year_month_label
ORDER BY year_month_label;

-- 3.3 Product & Category Performance
-- Revenue by Category

SELECT
    category,
    ROUND(SUM(revenue), 2) AS category_revenue
FROM sales_fact_enriched
GROUP BY category
ORDER BY category_revenue DESC;

-- Units Sold by Category
SELECT category, SUM(quantity) AS units_sold
FROM sales_fact_enriched
GROUP BY category
ORDER BY units_sold DESC;

-- Top 10 Products by Revenue
SELECT product_name, ROUND(SUM(revenue), 2) AS product_revenue
FROM sales_fact_enriched
GROUP BY product_name
ORDER BY product_revenue DESC
LIMIT 10;

-- 3.4 Customer Analysis (Basic)
-- Top 10 Customers by Revenue
SELECT customer_id, ROUND(SUM(revenue), 2) AS customer_revenue
FROM sales_fact_enriched
GROUP BY customer_id
ORDER BY customer_revenue DESC
LIMIT 10;

-- Revenue Distribution per Customer
SELECT customer_id, COUNT(DISTINCT order_id) AS order_count, ROUND(SUM(revenue), 2) AS total_revenue
FROM sales_fact_enriched
GROUP BY customer_id
ORDER BY total_revenue DESC;

-- 3.5 Discount Impact Analysis (Important for Business)
-- Revenue by Discount Level
SELECT discount, ROUND(sum(revenue),2) AS revenue
FROM sales_fact_enriched
GROUP BY discount
ORDER BY discount;

-- Average Revenue per Order by Discount
SELECT discount, ROUND(SUM(revenue)/ count(DISTINCT order_id),2) AS avg_order_value
FROM sales_fact_enriched
GROUP BY discount
ORDER BY discount;

SELECT *
FROM sales_fact_enriched;




