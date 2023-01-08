### Question 1
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

### Question 4
````sql
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
````

| product_name | times_purchased |
| ------------ | --------------- |
| ramen        | 8               |

````sql
-- I misread problem and thought it asked how many times 'each' customer purchased the item. The following is the solution for that unasked question.
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
### Question 5
````sql
-- 5. Which item was the most popular for each customer?
WITH customer_favs AS (
    SELECT
        customer_id,
        product_id,
        COUNT(product_id) AS prod_count,
        DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) as prod_rank
    FROM dannys_diner.sales
    GROUP BY customer_id, product_id
    ORDER BY customer_id
)

SELECT
    f.customer_id,
    m.product_name,
    f.prod_count AS times_purchased
FROM customer_favs AS f
LEFT JOIN dannys_diner.menu AS m on f.product_id=m.product_id
WHERE f.prod_rank=1
ORDER BY customer_id;
````

| customer_id | product_name | times_purchased |
| ----------- | ------------ | --------------- |
| A           | ramen        | 3               |
| B           | sushi        | 2               |
| B           | curry        | 2               |
| B           | ramen        | 2               |
| C           | ramen        | 3               |

---
### Question 6

````sql
-- 6. Which item was purchased first by the customer after they became a member?
WITH ordered_orders AS (
    SELECT 
        s.customer_id,
        s.product_id,
        DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS prod_rank
    FROM dannys_diner.sales AS s
    LEFT JOIN dannys_diner.members AS m ON s.customer_id=m.customer_id
    WHERE s.order_date >= m.join_date
)

SELECT
    o.customer_id,
    m.product_name
FROM ordered_orders AS o
LEFT JOIN dannys_diner.menu AS m ON o.product_id=m.product_id
WHERE o.prod_rank=1
ORDER BY o.customer_id;
````

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| B           | sushi        |
---

### Question 7
````sql
-- 7. Which item was purchased just before the customer became a member?
WITH ordered_orders AS (
    SELECT
        s.customer_id,
        s.product_id,
        DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS prod_rank
    FROM dannys_diner.sales AS s
    LEFT JOIN dannys_diner.members as m ON s.customer_id=m.customer_id
    WHERE s.order_date < m.join_date
)

SELECT
    o.customer_id,
    m.product_name
FROM ordered_orders AS o
LEFT JOIN dannys_diner.menu AS m ON o.product_id=m.product_id
WHERE o.prod_rank=1
ORDER BY o.customer_id;
````

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | sushi        |

---

## Question 8
````sql
-- 8. What is the total items and amount spent for each member before they became a member?
WITH pre_mem_info AS (
    SELECT
        s.customer_id,
        s.product_id,
        COUNT(s.product_id) AS product_count
    FROM dannys_diner.sales AS s
    LEFT JOIN dannys_diner.members AS m ON s.customer_id=m.customer_id
    WHERE s.order_date < m.join_date
    GROUP BY s.customer_id, s.product_id
)

SELECT
    p.customer_id,
    SUM(p.product_count) AS items_purchased,
    SUM(p.product_count*m.price) AS amount_spent
FROM pre_mem_info AS p
LEFT JOIN dannys_diner.menu AS m on p.product_id=m.product_id
GROUP BY p.customer_id
ORDER BY customer_id;
````

| customer_id | items_purchased | amount_spent |
| ----------- | --------------- | ------------ |
| A           | 2               | 25           |
| B           | 3               | 40           |
---

### Question 9
````sql
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH prod_points AS (
    SELECT
        product_id,
        CASE product_id WHEN 1 THEN 20*price
                        ELSE 10*price END AS points
    FROM dannys_diner.menu 
)

SELECT
    s.customer_id,
    SUM(p.points)
FROM dannys_diner.sales AS s
LEFT JOIN prod_points AS p ON s.product_id=p.product_id
GROUP BY customer_id
ORDER BY customer_id;
````
| customer_id | sum |
| ----------- | --- |
| A           | 860 |
| B           | 940 |
| C           | 360 |
---

### Question 10
````sql
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH sale_mults AS (
    SELECT
        s.customer_id,
        s.product_id,
        CASE WHEN (s.order_date >= m.join_date AND s.order_date < join_date+7) THEN 2
             WHEN s.product_id=1 THEN 2
             ELSE 1 END AS point_mult
    FROM dannys_diner.sales AS s
    INNER JOIN dannys_diner.members AS m on s.customer_id=m.customer_id
    WHERE s.order_date >= '2021-01-01' AND s.order_date <= '2021-01-31'
)

SELECT
    s.customer_id,
    SUM(10*m.price*s.point_mult) AS points
FROM sale_mults AS s
LEFT JOIN dannys_diner.menu AS m on s.product_id=m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
````
| customer_id | points |
| ----------- | ------ |
| A           | 1370   |
| B           | 820    |

