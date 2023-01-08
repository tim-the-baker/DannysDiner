-- This file contains my personal solutions to the Danny's Diner problem of the 8-week SQL challenge.
-- See here for more info: https://8weeksqlchallenge.com/case-study-1/
-- First copy the provided SQL scheme code. Questions and my solutions follow.
CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

/* -----------------------------------
   Case Study Questions and Solutions
   -----------------------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
	s.customer_id,
    SUM(m.price) AS total_spent
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m ON s.product_id=m.product_id
GROUP BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT
	customer_id,
    COUNT(DISTINCT order_DATE) AS days_visted
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH rank_by_date AS(
  SELECT
  	s.customer_id,
  	m.product_name,
  	DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS date_rank
  FROM dannys_diner.sales AS s
  LEFT JOIN dannys_diner.menu AS m ON s.product_id=m.product_id
)
  
SELECT DISTINCT
	customer_id,
    product_name
FROM rank_by_date
WHERE date_rank=1
ORDER BY customer_id

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
WITH ranked_prod_count AS (
    SELECT
		product_id,
  		COUNT(product_id) AS times_purchased,
      	DENSE_RANK() OVER (ORDER BY COUNT(product_id) DESC) AS prod_rank
  	FROM dannys_diner.sales AS s
  	GROUP BY product_id
)


SELECT
	m.product_name,
    r.times_purchased
FROM dannys_diner.menu AS m
LEFT JOIN ranked_prod_count AS r ON m.product_id=r.product_id
WHERE prod_rank=1;

-- I misread question as asking how many times did 'each' customer purchase the most purchased
-- item. here is code for that unasked question.
WITH ranked_prod_count AS (
    SELECT
		product_id,
  		COUNT(product_id) AS times_purchased,
      	DENSE_RANK() OVER (ORDER BY COUNT(product_id) DESC) AS prod_rank
  	FROM dannys_diner.sales AS s
  	GROUP BY product_id
)
SELECT
	s.customer_id,
    COUNT(s.product_id)
FROM dannys_diner.sales AS s
LEFT JOIN ranked_prod_count AS r ON s.product_id=r.product_id
WHERE prod_rank=1
GROUP BY s.customer_id
ORDER BY s.customer_id;



-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

