create database pizza_sales;

use pizza_sales;

CREATE TABLE order_details(
	order_details INT PRIMARY KEY,
    order_id INT,
    pizza_id TEXT,
    quantity INT
);
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE orders(
order_id INT PRIMARY KEY,
date TEXT,
time TEXT
);
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE VIEW pizza_details AS
SELECT p.pizza_id,p.pizza_type_id,pt.name,pt.category,p.size,p.price,pt.ingredients
FROM pizzas p 
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id;

ALTER TABLE orders
MODIFY date DATE;

-- total revenue
SELECT ROUND(SUM(od.quantity*pd.price), 2) AS total_revenue
FROM order_details od
LEFT JOIN pizza_details pd
ON pd.pizza_id = od.pizza_id;

-- total no. of pizzas sold
SELECT SUM(quantity)
FROM order_details;

-- average order value
SELECT ROUND(SUM(od.quantity*pd.price)/COUNT(DISTINCT(od.order_id)),2) AS avg_order_value
FROM order_details od
LEFT JOIN pizza_details pd
ON pd.pizza_id = od.pizza_id;

-- average number of pizza per order
SELECT ROUND(SUM(od.quantity)/COUNT(DISTINCT(od.order_id)),2)
FROM order_details od
LEFT JOIN pizza_details pd
ON pd.pizza_id = od.pizza_id;

-- total revue and no of orders per catergory
SELECT pd.category, SUM(od.quantity*pd.price) AS total_revenue, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
LEFT JOIN pizza_details pd
ON pd.pizza_id = od.pizza_id
GROUP BY pd.category 
ORDER BY total_revenue DESC
;

-- total revue and no of orders per size
SELECT pd.size, SUM(od.quantity*pd.price) AS total_revenue, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
LEFT JOIN pizza_details pd
ON pd.pizza_id = od.pizza_id
GROUP BY pd.size
;

-- hourly, daily and monthly trend in orders and revenue of pizza
SELECT 
	CASE
		WHEN HOUR(o.time) BETWEEN 9 AND 12 THEN "Late Morning"
        WHEN HOUR(o.time) BETWEEN 12 AND 15 THEN "Lunch"
        WHEN HOUR(o.time) BETWEEN 15 AND 18 THEN "Mid Afternoon"
        WHEN HOUR(o.time) BETWEEN 18 AND 21 THEN "Dinner"
        WHEN HOUR(o.time) BETWEEN 21 AND 23 THEN "Late Night"
        ELSE 'Others'
        END AS meal_time, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN orders o
ON o.order_id = od.order_id
GROUP BY meal_time
ORDER BY total_orders DESC;

-- weekdays
SELECT DAYNAME(o.date) AS day_name , COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN orders o
ON o.order_id = od.order_id
GROUP BY day_name
ORDER BY total_orders DESC;

-- monthly trend
SELECT MONTHNAME(o.date) AS month_name, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN orders o
ON o.order_id = od.order_id
GROUP BY month_name
ORDER BY total_orders DESC;

-- most ordered pizza
SELECT pd.name, COUNT(od.order_id) AS count_pizzas
FROM order_details od
JOIN pizza_details pd
ON pd.pizza_id=od.pizza_id
GROUP BY name
order by count_pizzas DESC
LIMIT 1
;

-- top5 pizzas by revenue
SELECT pd.name, ROUND(SUM(od.quantity*pd.price), 2) AS total_revenue
FROM order_details od
JOIN pizza_details pd
ON pd.pizza_id=od.pizza_id
GROUP BY name 
ORDER BY total_revenue DESC
LIMIT 5 ;

