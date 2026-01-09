CREATE TABLE fare_table (
    from_city varchar(50),
    to_city varchar(50),
    fare INT
);

INSERT INTO fare_table (from_city, to_city, fare) VALUES
('Hyderabad', 'Chennai', 1200),
('Hyderabad', 'Chennai', 1300),
('Chennai', 'Hyderabad', 1250),
('Hyderabad', 'Bangalore', 900),
('Bangalore', 'Hyderabad', 950),
('Hyderabad', 'Delhi', 2500),
('Hyderabad', 'Delhi', 2700),
('Delhi', 'Hyderabad', 2600),
('Mumbai', 'Delhi', 1500),
('Delhi', 'Mumbai', 1550),
('Mumbai', 'Chennai', 1800),
('Chennai', 'Mumbai', 1750);



CREATE TABLE product_price (
    product_id varchar(50),
    price DECIMAL(10,2),
    price_date DATE
);

INSERT INTO product_price (product_id, price, price_date) VALUES
('P1', 100.00, '2024-01-01'),
('P1', 120.00, '2024-02-01'),
('P1', 130.00, '2024-03-01'),
('P2', 200.00, '2024-01-01'),
('P2', 210.00, '2024-02-01'),
('P2', 190.00, '2024-03-01'),
('P3', 300.00, '2024-01-01'),
('P3', 280.00, '2024-02-01'),
('P3', 260.00, '2024-03-01'),
('P4', 400.00, '2024-01-01'),
('P4', 400.00, '2024-02-01'),
('P4', 420.00, '2024-03-01');

-- select * from dbo.fare_table;
-- minimum two way price
SELECT
GREATEST(from_city, to_city) AS to_city,
LEAST(from_city, to_city) AS from_city,
MIN(fare) AS first_fare
FROM dbo.fare_table
GROUP BY
GREATEST(from_city, to_city),
LEAST(from_city, to_city)

-- products whose price has always increased
select * from dbo.product_price

with p1 as (
select product_id, price_date, price, 
lag(price,1) over(partition by product_id order by price_date asc) as prev_price
from product_price
), p2 as (
select *,
case when 
price > prev_price then 'increased'
when price < prev_price then 'decreased'
when price = prev_price then 'no change'
when prev_price is null then null 
end as 
price_status
from p1
)
select product_id 
from p2
where price_status is not null 
and price_status <> 'no change'
group by product_id
having count(distinct price_status) = 1
and max(price_status) = 'increased'

