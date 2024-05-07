-- Write SQL queries to answer these questions using the data you have loaded into your database/data warehouse:
-- 1. Retrieve total sales revenue, number of units sold, and average price per unit for each item type for the first quarter of 2017.
SELECT 
  Item_Type,
  round(sum(Total_Revenue),2) as Total_Revenue,
  sum(Units_Sold)             as Units_Sold,
  round(sum(Total_Revenue)/sum(Units_Sold),2) as Avg_Price_Unit
FROM `my-wiki-data-bq.dbt_jbrugos.tech_task` 
where Order_Date between '2017-01-01' and '2017-03-31'
group by Item_Type
;
-- 2. Identify the top 3 item types by sales revenue for each region in the last quarter.
With a as (
SELECT 
  Region,
  Item_Type,
  EXTRACT(YEAR FROM Order_Date) as Year,
  EXTRACT(QUARTER FROM Order_Date) as Quarter,
  round(sum(Total_Revenue)) as revenue
FROM `my-wiki-data-bq.dbt_jbrugos.tech_task` 
group by Region, Item_Type, Year, Quarter
), b as (
SELECT 
  Region,
  Year,
  Item_Type,
  sum(revenue) as revenue
from a
where Quarter = 4 
group by Region, Year, Item_Type
order by  Region, Year, revenue desc
), c as (
SELECT 
  *,
    row_number() over (partition by Region, Year order by Region, Year, revenue desc) as row_n

from b
order by Region, Year, revenue desc
)
SELECT * from c where row_n<=3
;
-- 3. Calculate the year-over-year growth in sales revenue for each item type.
With A as (
SELECT 
  Region,
  Item_Type,
  EXTRACT(YEAR FROM Order_Date) as Year,
  round(sum(Total_Revenue)) as revenue
FROM `my-wiki-data-bq.dbt_jbrugos.tech_task` 
GROUP BY Region, Item_Type, Year
)
SELECT 
 *,
 LAG (revenue) OVER (ORDER BY Region, Item_Type, Year ) AS Prev_Revenue,
 round(100*(revenue /  LAG (revenue) OVER (ORDER BY Region, Item_Type, Year )-1 ),1) AS Growth_pct

from A
Order by Region, Item_Type, Year desc
;
