-- Namastekart, an e-commerce company, has observed a notable surge in return orders recently. 
-- They suspect that a specific group of customers may be responsible for a significant portion of these returns. 
-- To address this issue, their initial goal is to identify customers who have returned more than 50% of their orders. 
-- This way, they can proactively reach out to these customers to gather feedback. 
-- Write an SQL to find list of customers along with their return percent (Round to 2 decimal places), 
-- display the output in ascending order of customer name.

SELECT 
customer_name,
ROUND(SUM(CASE WHEN return_flag = 'return' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS return_percent
FROM (
SELECT 
o.order_id,
o.customer_name,
CASE WHEN r.return_date IS NOT NULL THEN 'return'
ELSE 'not return'
END AS return_flag
FROM orders o
LEFT JOIN returns r
ON o.order_id = r.order_id
) a
GROUP BY customer_name
HAVING 
SUM(CASE WHEN return_flag = 'return' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) > 0.5
ORDER BY customer_name;

-- You are given a products table where a new row is inserted every time the price of a product changes. 
-- Additionally, there is a transaction table containing details such as order_date and product_id for each order. 
-- Write an SQL query to calculate the total sales value for each product, 
-- considering the cost of the product at the time of the order date, display the output in ascending order of the product_id.

SELECT 
product_id,
SUM(price) AS total_sales
FROM (
SELECT 
o.order_id,
o.product_id,
p.price,
ROW_NUMBER() OVER (PARTITION BY o.order_id ORDER BY p.price_date DESC) AS rn
FROM orders o
JOIN products p
ON p.product_id = o.product_id
AND p.price_date <= o.order_date
) t
WHERE rn = 1
GROUP BY product_id
ORDER BY product_id;

-- You’re working for a large financial institution that provides various types of loans to customers. 
-- Your task is to analyze loan repayment data to assess credit risk and improve risk management strategies. 
-- Write an SQL to create 2 flags for each loan as per below rules. Display loan id, loan amount , due date and the 2 flags.
-- 1- fully_paid_flag: 1 if the loan was fully repaid irrespective of payment date else it should be 0. 
-- 2- on_time_flag : 1 if the loan was fully repaid on or before due date else 0.

with master_table as (
select l.loan_id, l.customer_id, l.loan_amount, l.due_date, 
p.payment_id, p.payment_date, p.amount_paid 
from loans l 
left join payments p on 
p.loan_id = l.loan_id
)
select loan_id, sum(loan_amount) as loan_amount, due_date
case when sum(loan_amount) = sum(due_date) then '1' else '0' end as fully_paid_flag,
case when payment_date <= due_date then '1' else '0' end as on_time_flag 
from master_table
group by loan_id, due_date, payment_date