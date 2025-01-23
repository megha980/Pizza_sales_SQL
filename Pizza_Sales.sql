
/* Basic:
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.


Intermediate:
Join the necessary tables to find the total quantity of each pizza category ordered.
Determine the distribution of orders by hour of the day.
find the category-wise distribution of pizzas.
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue.

Advanced:
Calculate the percentage contribution of each pizza type to total revenue.
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/


select *
from pizzas;

select *
from pizza_types;

select *
from orders;

select *
from order_details;

-- 1. Retrieve the total number of orders placed.

select count(*) as total_order_placed
from orders;

-- 2. Calculate the total revenue generated from pizza sales.
select round(sum(p.price*od.quantity),2)as total_sales
from order_details od
join pizzas p on p.pizza_id = od.pizza_id;
-- 3.Identify the highest-priced pizza.

select top 1 name,price
from pizzas p
join pizza_types as pd on pd.pizza_type_id = p.pizza_type_id
order by price desc;
-- 4. Identify the most common pizza size ordered.

select p.size, count(order_details_id)
from pizzas p
join order_details od on p.pizza_id= od.pizza_id
group by p.size;

-- 5 List the top 5 most ordered pizza types along with their quantities.
select top 5 pt.name, sum(od.quantity) as total_qty_ordered
from pizzas p
join order_details as od on p.pizza_id = od.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.name
order by total_qty_ordered desc;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
select category, sum(quantity) as TQ
from pizzas p
join order_details as od on p.pizza_id = od.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by category
order by TQ desc;

-- 7. Determine the distribution of orders by hour of the day.

select Datepart(Hour,time) as hour, count(order_id) as order_count
from orders
group by Datepart(Hour,time)
order by order_count desc;
-- 8 find the category-wise distribution of pizzas.

select category, count(name) as TC
from pizza_types
group by category
;

select *
from orders;

select *
from order_details;
-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
with average_n as (select date, sum(quantity) as sum_qty
from orders as o
join order_details od on o.order_id = od.order_id
group by date
)
select avg(sum_qty) as average_ordered_per_day
from average_n;

-- 10. Determine the top 3 most ordered pizza types based on revenue.

select top 3 name, sum(price*quantity) as total_price
from pizzas as p
join pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
join order_details od on od.pizza_id= p.pizza_id
group by name
order by total_price desc;
-- 11. Calculate the percentage contribution of each pizza type to total revenue.

select category, (sum(price*quantity) / (select sum(p.price*od.quantity)as total_sales
from order_details od
join pizzas p on p.pizza_id = od.pizza_id)*100) as total_revenue
from pizzas as p
join pizza_types as pt on p.pizza_type_id = pt.pizza_type_id
join order_details od on od.pizza_id= p.pizza_id
group by category
order by total_revenue desc;

-- 12. Analyze the cumulative revenue generated over time.
select date, sum(revenue) over(order by date) as cum_sum
from
(select date, sum(quantity * price) as revenue
from pizzas p
join order_details as od on p.pizza_id = od.pizza_id
join orders o on o.order_id = od.order_id
group by date) as sales;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category


WITH most AS (
    SELECT 
        category, 
        name,
        SUM(price * quantity) AS revenue
    FROM pizzas AS p
    JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
    JOIN order_details AS od ON od.pizza_id = p.pizza_id
    GROUP BY category, name
)
SELECT 
    category, 
    name, 
    revenue, 
    rank_no
FROM (
    SELECT 
        category, 
        name, 
        revenue, 
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_no
    FROM most
) AS ranked
WHERE rank_no <= 3;


