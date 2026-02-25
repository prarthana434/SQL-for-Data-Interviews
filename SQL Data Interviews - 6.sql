-- month over month return rate

with r1 as (
select date_format(order_date, '%Y-%m') as year_month,
case when return_date is not null then 1 else 0 end as return_flag
from returns
group by year_month, return_flag
), r2 as (
select year_month,
sum(return_flag) as returns
from r1 
group by year_month
order by year_month
)
select year_month,
returns,
lag(returns,1) over(order by year_month) as last_month_returns
ifnull((returns / lag(returns,1) over(order by year_month)),0) * 100 as return rate
from r2 

-- most common action per user

with a1 as (
select user_id, action_type, count(action_type) as action_cnt from users
group by user_id, action_type
order by user_id, action_cnt desc
)
select *, 
row_number() over(partition by user order by action_cnt desc) as rw
from a1 
where row_number() over(partition by user order by action_cnt desc) = 1

-- 2 day moving average for orders per users

select user_id, order_date, sum(revenue) as revenue,
avg(revenue) over(partition by user_id order by order_date rows between 1 preceding and current row) as 2_day_moving_avg
from users
group by user_id, order_date
order by user_id, order_date

-- pair of users from same country

select u1.country, (u1.user_id, u2.user_id) as user_pair from users u1
inner join users u2 on 
u2.country = u1.country
and u2.user_id < u1.user_id
group by 1,2
order by u1.country 

-- top product by revenue per month

select order_month, product_id, sales from (
select extract(month from order_date) as order_month, product_id,
sum(revenue) as sales,
row_number() over(partition by extract(month from order_date) order by sum(revenue) desc) as rn 
from sales
)
where rn = 1  