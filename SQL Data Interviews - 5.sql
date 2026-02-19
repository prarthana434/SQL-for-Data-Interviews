-- Find users active for 3+ consecutive days.

WITH distinct_logins AS (
    SELECT DISTINCT user_id, activity_date
    FROM user_activity
),
ranked_logins AS (
    SELECT 
        user_id, 
        activity_date,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY activity_date) as rn
    FROM distinct_logins
),
islands AS (
    SELECT 
        user_id,
        activity_date,
        date(activity_date, '-' || (rn - 1) || ' days') as anchor_date
    FROM ranked_logins
)
SELECT user_id, COUNT(*) as streak_length
FROM islands
GROUP BY user_id, anchor_date
HAVING COUNT(*) >= 3;

-- Month-over-month revenue growth rate.

with r1 as (
SELECT CAST(strftime('%m', order_date) AS INTEGER) as order_month,
sum(amount) as amt
from orders
group by order_month
order by order_month
  ), r2 as (
select order_month, amt,
lag(amt,1) over(order by order_month) as last_amt
from r1
    )
    select *, (amt - last_amt) * 100 / last_amt as gr from r2

-- User with highest friend request acceptance rate (min 2 sent).

SELECT sender_id, 
count(distinct receiver_id) as requests_sent,
sum(case when status = 'accepted' then 1 else 0 end) accepted,
(100 * sum(case when status = 'accepted' then 1 else 0 end)) / count(distinct receiver_id) as rate
from friend_requests
group by sender_id
having count(distinct receiver_id) > 1
order by rate desc
limit 1

-- Average days between orders per user.

select user_id,
coalesce(avg(julianday(order_date) - julianday(prev_date)),0) AS days_diff
from (
SELECT user_id, 
order_date,
lag(order_date,1) over(partition by user_id order by order_date) as prev_date
from orders
group by user_id, order_date
  ) a 
group by user_id

-- Users with orders but no friend requests sent.

SELECT distinct user_id from orders 
where user_id not in (
  select distinct receiver_id from friend_requests
  ) 

-- Find the first order date and amount for each user.

select user_id, order_date, amount
from (
SELECT *, 
row_number() over(partition by user_id order by order_date) as rn
from orders
  ) a 
where rn = 1 

-- Find users whose average order amount exceeds the overall average.

select user_id from (
SELECT
user_id,
round(avg(amount),2) as user_avg,
round(avg(amount) over(),2) as over_all_avg
from orders
group by user_id
) a 
where user_avg > over_all_avg

-- Rank users by total spend within each country.

SELECT o.user_id, 
u.country, 
round(sum(o.amount),2) as amount,
dense_rank() over(partition by u.country order by sum(o.amount) desc) as drnk
from orders o 
inner join users u on 
u.user_id = o.user_id
group by u.country, o.user_id

-- Find the percentage of total revenue each product contributes.

WITH product_totals AS (
    SELECT
        product_id,
        SUM(amount) AS prod_amt
    FROM orders
    GROUP BY product_id
)
SELECT
    product_id,
    ROUND(prod_amt, 2) AS prod_amt,
    ROUND(SUM(prod_amt) OVER (), 2) AS total_sales,
    ROUND(prod_amt * 100.0 / SUM(prod_amt) OVER (), 2) AS percentage_of_revenue
FROM product_totals;

-- Users with 2nd purchase within 30 days

with u1 as (
select 
user_id,
order_date,
row_number() over(partition by user_id order by order_date) as rnk
from orders
), u2 as (
select distinct user_id,
max(case when rnk = 1 then order_date end) as first_order_date,
max(case when rnk = 2 then order_date end) as second_order_date 
from u1
group by user_id
)
select *, julianday(second_order_date) - julianday(first_order_date) as days_diff
from u2
where julianday(second_order_date) - julianday(first_order_date) <= 30 and second_order_date is not null

-- Calculate a 2-order moving average of revenue per order.

select 
order_id, 
order_date, 
amount, 
round(avg(amount) over(order by order_date, order_id rows between 1 preceding and current row),2) moving_average
from orders