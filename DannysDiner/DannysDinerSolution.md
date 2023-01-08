### Question 1
````sql
-- 1. What is the total amount each customer spent at the restaurant?
SELECT
    s.customer_id,
    SUM(m.price) AS total_spent
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m ON s.product_id=m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
````
| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

---
### Question 2
````sql
-- 2. How many days has each customer visited the restaurant?
SELECT
    customer_id,
    COUNT(DISTINCT order_DATE) AS days_visted
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY customer_id;
````

| customer_id | days_visted |
| ----------- | ----------- |
| A           | 4           |
| B           | 6           |
| C           | 2           |
---

### Question 3
````sql
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
ORDER BY customer_id;
````

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---

### Question 4
````sql
-- 4. What is the most purchased item on the menu... 
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
````

| product_name | times_purchased |
| ------------ | --------------- |
| ramen        | 8               |

````sql
-- and how many times was it purchased by all customers? (I misread question as 'by each customer')
-- might as well keep the code
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
````

| customer_id | count |
| ----------- | ----- |
| A           | 3     |
| B           | 2     |
| C           | 3     |

---
