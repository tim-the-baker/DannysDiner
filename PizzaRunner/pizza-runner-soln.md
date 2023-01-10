# Solutions
Solutions are my own and are not guarenteed to be correct.
## A. Pizza Metrics
### Question A.1
How many pizzas were ordered?
````sql
SELECT
    COUNT(pizza_id)
FROM pizza_runner.customer_orders;
````
| count |
| ----- |
| 14    |
---

#### Question A.2
How many unique customer orders were made?
````sql
SELECT
    COUNT(DISTINCT order_id)
FROM pizza_runner.customer_orders;
````
| count |
| ----- |
| 10    |