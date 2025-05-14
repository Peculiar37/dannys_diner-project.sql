-- Create and use the database
CREATE DATABASE IF NOT EXISTS dannys_diner;
USE dannys_diner;

-- Drop tables if they exist to avoid conflicts
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS members;

-- Create the sales table
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INT
);

-- Insert data into sales
INSERT INTO sales (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);
show tables ;



-- Insert data into menu
INSERT INTO menu (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);
  

-- Create the members table
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

-- Insert data into members
INSERT INTO members (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
show tables ;

-- queries
-- join tables

CREATE TABLE sales_summary AS
SELECT
  s.customer_id,
  s.order_date,
  s.product_id,
  m.product_name,
  m.price,
  mem.join_date
FROM sales s
JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mem ON s.customer_id = mem.customer_id;


select *
from sales_summary;

-- total amount each customer spent at the restaurant
select customer_id, sum(price)
from sales_summary 
group by customer_id
order by 1;

-- number of days each customer visited the restaurant
select *,
row_number () over (
partition by order_date) as time_of_visit
from sales_summary;

with duplicate_cte as
(select *,
row_number () over (
partition by order_date) as time_of_visit
from sales_summary)
select *
from duplicate_cte 
where time_of_visit = 1
;


SELECT
  customer_id,
  COUNT(DISTINCT order_date) AS visit_days
FROM sales
GROUP BY customer_id;

-- first item from the menu purchased by each customer
select *
from sales_summary;

select *,
row_number () over (
partition by customer_id order by order_date asc) as rn
from sales_summary;

select customer_id, product_id, order_date
from (
select *,
row_number () over (
partition by customer_id order by order_date asc) as rn
from sales_summary) as first_item_bought
where rn = 1
;


-- the most purchased item on the menu and how many times was it purchased by all customers?

select 
product_name,
     count(distinct order_date) as number_of_purchases
from sales_summary
group by product_name;


-- the most popular item for each customer?
select 
customer_id, 
     count(distinct product_id,product_name) as popular_item
from sales_summary
group by customer_id ;


-- Which item was purchased first by the customer after they became a member?
select *
from sales_summary;

select *,
row_number () over (
partition by customer_id order by order_date ) as rn
from sales_summary;

select customer_id, product_id, order_date, join_date
from (
select *,
row_number () over (
partition by customer_id order by order_date) as rn
from sales_summary
where order_date >= join_date
) ranked
where rn = 1
;

-- -- Which item was purchased just before the customer became a member?

select *,
row_number () over (
partition by customer_id order by order_date ) as rn
from sales_summary;

select customer_id, product_id, order_date, join_date
from (
select *,
row_number () over (
partition by customer_id order by order_date) as rn
from sales_summary
where order_date <= join_date
) ranked
where rn = 1
;



-- What is the total items and amount spent for each member before they became a member?
select *
from sales_summary;

select customer_id,
     count(*) as total_sales,
sum(price) as total_amount 
from sales_summary
where order_date < join_date
group by customer_id
;

-- -- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select *
from sales_summary;

-- assumin the price is in $
select customer_id,
sum(
      case
                when product_id = 1 then price *2 *10
                           else price *10
end
) as total_points
from sales_summary
group by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select customer_id,
sum(
         case
             when order_date <= join_date then price *2 *10
               else price *10
end
) as total_points

from sales_summary
where order_date <= '2021-01-31'
      and customer_id in ('A', 'B')
group by customer_id;

select *
from sales_summary;



