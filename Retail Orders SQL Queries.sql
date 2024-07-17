
create table df_orders(
[order_id] int primary key,
[order_date] date,
[ship_mode] varchar(20),
[segment] varchar(20),
[country] varchar(20),
[city] varchar(20),
[state] varchar(20),
[postal_code] varchar(20),
[region] varchar(20),
[category] varchar(20),
[sub_category] varchar(20),
[product_id] varchar(50),
[quantity] int,
[discount] decimal(7,2),
[sale_price] decimal(7,2),
[total_profit] decimal(7,2))

Select * from df_orders

-- Find Top 10 highest revenue generating products
Select top 10 product_id,SUM(sale_price) as sales
from df_orders
Group by product_id
Order By sales desc

-- Find Top 5 highest selling products in each region
With CTE as(
			Select region,product_id,SUM(sale_price) as Sales
			From df_orders
			Group by region,product_id) 
Select * from(

			Select *,
			ROW_NUMBER() Over(partition by region order by sales desc) as rn
			from CTE) A
Where rn <= 5

--Find month over month comparison for 2022 and 2023 sales
With CTE as(
			Select YEAR(order_date) as order_year,MONTH(order_date) as order_month,
			SUM(sale_price) as sales
			from df_orders
			group by YEAR(order_date),MONTH(order_date)
--Order by YEAR(order_date),MONTH(order_date)
)
Select order_month,
Sum(CASE When order_year = 2022 then sales else 0 end) as sales_2022,
Sum(CASE when order_year = 2023 then sales else 0 end) as sales_2023
from CTE
Group by order_month
Order by order_month

-- For each category which month had highest sales
With CTE as(
			Select category,FORMAT(order_date,'yyyyMM') as order_year_month, sum(sale_price) as sales
			From df_orders
			Group by category,FORMAT(order_date,'yyyyMM')
)
	Select * from(
	Select *,
	ROW_NUMBER() Over(partition by category order by sales DESC) as rn
	from CTE) A
	where rn =1

-- Which sub category had highest growth by profit in 2023 compare to 2022
With CTE as(
			Select sub_category,YEAR(order_date) as order_year,
			SUM(sale_price) as sales
			from df_orders
			group by sub_category,YEAR(order_date)
--Order by YEAR(order_date),MONTH(order_date)
),
CTE2 As (
Select sub_category,
Sum(CASE When order_year = 2022 then sales else 0 end) as sales_2022,
Sum(CASE when order_year = 2023 then sales else 0 end) as sales_2023
from CTE
Group by sub_category)

Select top 1 * ,
(sales_2023-sales_2022)*100/sales_2022
from CTE2
order by (sales_2023-sales_2022)*100/sales_2022 DESC

