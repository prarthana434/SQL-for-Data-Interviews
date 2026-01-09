DROP TABLE IF EXISTS dbo.orders;

CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    amount INT
);

INSERT INTO orders (order_id, customer_id, order_date, amount) VALUES
(13, 202, '2024-03-10', 100),
(14, 203, '2024-03-10', 200),
(15, 204, '2024-03-10', 300),
(16, 202, '2024-07-07', 450),
(17, 203, '2024-07-07', 450),
(18, 204, '2024-07-07', 150),
(19, 205, '2024-01-10', 400),
(20, 205, '2024-02-10', 400),
(21, 205, '2024-03-10', 350),
(22, 205, '2024-04-10', 350);

select * from orders;

-- customers who placed orders in the last 90 days

select 
customer_id, 
order_date , 
datediff(day, order_date, getdate()) as days_diff 
from orders
where datediff(day, order_date, getdate()) between 0 and 90

-- customers who placed an order in all the months of 2024

select customer_id from dbo.orders
where year(order_date) = 2024
group by customer_id
having count(distinct month(order_date)) = 12

-- customers to placed the same order amount more than once

select customer_id, amount as amt from (
select customer_id,
amount
from orders
) a
group by customer_id, amount
having count(amount) > 1
order by customer_id, amount

-- get orders above the average amount on the same day

select customer_id from (
select customer_id, order_date, sum(amount) as amt,
avg(amount) over(partition by order_date order by order_date) as avg_amt_day
from orders
group by customer_id, order_date, amount
) a 
where amt > avg_amt_day