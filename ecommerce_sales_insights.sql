-- 📘 SQL Mini Project: E-Commerce Sales Insights.




-- 🎯 Project Objective:
-- Analyze customer orders and generate insights about sales, product performance, and customer behavior using SQL only.




DROP TABLE IF EXISTS customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);




SELECT * FROM customers;




DROP TABLE IF EXISTS orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    product VARCHAR(100),
    quantity INT,
    price_per_unit DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);




SELECT * FROM orders;




-- 🟢 BASIC LEVEL QUERIES.




-- 1	What is the total number of orders placed?


SELECT COUNT(order_id) AS total_Orders
FROM orders;


-- 2	What is the total revenue generated?


SELECT SUM(quantity*price_per_unit) AS total_revenue
FROM orders;


-- 3	List all customers from 'Delhi'.


SELECT name
FROM customers
WHERE city = 'Delhi';


-- 4	List all unique products sold.


SELECT DISTINCT product
FROM orders;


-- 5	Calculate the revenue for each order.


SELECT product , (quantity * price_per_unit) AS revenue 
FROM orders ;




-- 🟡 INTERMEDIATE LEVEL QUERIES.




-- 6	What is the total revenue per customer?


SELECT c.name , SUM(o.quantity * o.price_per_unit) AS total_revenue 
FROM customers c
INNER JOIN orders o 
ON c.customer_id = o.customer_id
GROUP BY c.name ;


-- 7	Find top 5 customers by total spending.


SELECT c.name , SUM(o.price_per_unit) AS total_spending
FROM customers c 
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.name 
ORDER BY total_spending DESC
LIMIT 5;


-- 8	Show monthly revenue trend.


SELECT DATE_TRUNC('month',order_date) AS month_ly,
       SUM(quantity * price_per_unit) AS monthly_revenue 
FROM orders
GROUP BY  DATE_TRUNC('month',order_date)
ORDER by month_ly;


-- 9	List the top 3 best-selling products by quantity.


SELECT product, SUM(quantity) AS total_qty
FROM orders
GROUP BY product
ORDER BY total_qty DESC
LIMIT 3;


-- 10	Show number of orders placed per city.


SELECT c.city , COUNT(o.order_id) AS Orders_placed
FROM customers c
JOIN orders o 
ON c.customer_id = o.customer_id
GROUP BY c.city;


-- 11	Show average order value per customer.


SELECT c.name , AVG(o.quantity * o.price_per_unit) AS order_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.name;


-- 12	List customers who never placed any order.


SELECT c.name , c.customer_id
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- 13	Revenue contribution by each product.


SELECT product , SUM(quantity * price_per_unit) AS Revenue 
FROM orders
GROUP BY product;


-- 14	City-wise revenue by product.


SELECT c.city , SUM(o.quantity * o.price_per_unit) AS Revenue , o.product
FROM orders o
JOIN customers c 
ON o.customer_id = c.customer_id
GROUP BY c.city , o.product;




-- 🔴 ADVANCED LEVEL QUERIES.




-- 15	Rank products by revenue in each city.


SELECT o.product , c.city , SUM(o.quantity * o.price_per_unit) AS Revenue, 
       RANK() OVER (
       PARTITION BY c.city
	   ORDER BY SUM(o.quantity * o.price_per_unit) DESC)AS rank_products
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.city , o.product;


-- 16	Find the product with the highest revenue in each month.


SELECT product,revenue,month
FROM (
    SELECT 
        product,
        DATE_TRUNC('month', order_date) AS month,
        SUM(quantity * price_per_unit) AS revenue,
        RANK() OVER (
            PARTITION BY DATE_TRUNC('month', order_date)
            ORDER BY SUM(quantity * price_per_unit) DESC
        ) AS rnk
    FROM 
        orders
    GROUP BY 
        DATE_TRUNC('month', order_date), product
) ranked
WHERE rnk = 1;


-- 17	Identify repeat customers (those who ordered more than once).


SELECT customer_id,
    COUNT(quantity) AS total_orders
FROM 
    orders
GROUP BY 
    customer_id
HAVING 
    COUNT(quantity) > 1;


-- 18	Use a CTE to calculate customer lifetime value.


WITH customer_revenue AS (
    SELECT 
        customer_id,
        SUM(quantity * price_per_unit) AS lifetime_value
    FROM 
        orders
    GROUP BY 
        customer_id
)

SELECT 
    cr.customer_id,
    c.name,
    cr.lifetime_value
FROM 
    customer_revenue cr
JOIN 
    customers c ON cr.customer_id = c.customer_id
ORDER BY 
    cr.lifetime_value DESC;


-- 19	Use a window function to calculate running revenue per customer.


SELECT 
    customer_id,
    order_date,
    quantity * price_per_unit AS revenue,
    SUM(quantity * price_per_unit) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS running_revenue
FROM 
    orders;


-- 20	What was the best sales day ever (highest single-day revenue)?


SELECT 
    order_date,
    SUM(quantity * price_per_unit) AS daily_revenue
FROM 
    orders
GROUP BY 
    order_date
ORDER BY 
    daily_revenue DESC
LIMIT 1;



















