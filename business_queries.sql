-- Q1 — Top 5 customers by revenue 
SELECT 
	customers.name AS customer_name, 
	customers.email, 
	COUNT(orders.customer_id) AS order_count, 
	SUM(orders.total_amount) AS total_revenue 
FROM customers 
LEFT JOIN orders
	ON customers.id = orders.customer_id
WHERE status = 'completed'
GROUP BY 
	customer_name, 
	customers.email
ORDER BY total_revenue DESC
LIMIT 5;

-- Q2 — Monthly revenue
SELECT 
	TO_CHAR(order_date, 'YYYY-MM') AS month, 
	COUNT(id) AS order_count, 
	SUM(total_amount) AS total_revenue, 
	ROUND(AVG(total_amount),2) AS avg_order_value
FROM orders
WHERE status = 'completed'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;

-- Q3 — Revenue breakdown by country
SELECT 
	shipping_country AS country, 
	SUM(total_amount) AS total_revenue, 
	ROUND(SUM(total_amount) / (SELECT SUM(total_amount) FROM orders WHERE status = 'completed') * 100,2) AS pct_of_total
FROM orders
WHERE status = 'completed'
GROUP BY country;

-- Q4 — Top 10 best-selling products
SELECT 
	products.name AS product_name, 
	categories.name AS category, 
	SUM(order_items.quantity) AS units_sold, 
	SUM(order_items.unit_price * order_items.quantity) AS total_revenue
FROM order_items
JOIN products
	ON order_items.product_id = products.id
JOIN categories
	ON categories.id = products.category_id
GROUP BY product_name, category
ORDER BY total_revenue DESC

-- Q5 — Cancellation rate by month
SELECT 
	DATE_TRUNC('month', order_date) AS month,
	COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE status IN ('cancelled', 'refunded')) AS cancelled_refunded,
    ROUND((COUNT(*) FILTER (WHERE status IN ('cancelled', 'refunded'))::NUMERIC / COUNT(*)) * 100,2) AS cancellation_rate
FROM orders
GROUP BYmonth;

-- Q6 — Premium vs non-premium customers
SELECT
    CASE
        WHEN customers.is_premium = 'true' THEN 'premium'
        ELSE 'non-premium'
    END AS segment,
    COUNT(DISTINCT customers.id) AS customer_count,
    COUNT(orders.id) AS order_count,
    SUM(orders.total_amount) AS total_revenue,
    ROUND(AVG(orders.total_amount),2) AS avg_order_value
FROM customers 
JOIN orders 
    ON customers.id = orders .customer_id
GROUP BY customers.is_premium
ORDER BY segment;

-- Q7 — Products never ordered
SELECT 
	name AS product_name, price, stock_quantity AS stock, category_id AS category
FROM products
LEFT JOIN order_items  
   ON products.id = order_items.product_id
WHERE order_items.id IS NULL;

-- Q8 — Average basket by category
SELECT
    categories.name AS category,
    SUM(order_items.quantity) AS items_sold,
    SUM(order_items.quantity * order_items.unit_price) AS total_revenue,
    ROUND(AVG(order_items.unit_price),2) AS avg_selling_price
FROM order_items 
LEFT JOIN products  
    ON order_items.product_id = products.id
LEFT JOIN categories 
    ON products.category_id = categories.id
GROUP BY categories.name;

-- Q9 — New customer signups per month
WITH monthly_signups AS (
    SELECT
        DATE_TRUNC('month', signup_date) AS month,
        COUNT(signup_date) AS new_customers
    FROM customers
    GROUP BY DATE_TRUNC('month', signup_date)
)
SELECT
    month,
    new_customers,
    SUM(new_customers) OVER (ORDER BY month) AS cumulative_customers
FROM monthly_signups
ORDER BY month;

-- Q10 — Customers inactive for 3+ months

WITH customer_last_orders AS (
    SELECT
        orders.customer_id,
        customers.name,
        customers.email,
        MAX(orders.order_date) AS last_order_date
    FROM customers  
    JOIN orders ON customers.id = orders.customer_id
    GROUP BY orders.customer_id, customers.name, customers.email
)
SELECT
    name,
    email,
    last_order_date,
    ('2024-06-30'::DATE - last_order_date) AS days_since
FROM customer_last_orders
WHERE last_order_date < '2024-04-01'
ORDER BY last_order_date ASC;


