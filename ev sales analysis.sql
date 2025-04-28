create database ev;
select count(*) from ev_sales_india;
rename table ev_sales_india to ev_sales;
select * from ev_sales;
-- Year wise Ev sales in india 
SELECT 
    year, SUM(EV_Sales_Quantity) AS total_sales
FROM
    ev_sales
GROUP BY year
ORDER BY year desc
LIMIT 10;

-- Top 3 states with highest sales each year 
SELECT * 
FROM(
   SELECT year, state, sum(Ev_Sales_Quantity) as Total_sales,
   rank() over (partition by year order by sum(EV_Sales_Quantity) desc) as ranked_states
   FROM ev_sales
   GROUP BY year, state
)as ranked_states 
WHERE ranked_states<=3;

-- 3 wheelers dominate Ev sales in top states  
SELECT 
    State, EV_Sales_Quantity AS Total_sales, Vehicle_Category
FROM
    ev_sales
WHERE
    EV_Sales_Quantity > 1
ORDER BY EV_Sales_Quantity DESC
LIMIT 10;

select * from ev_sales;

-- State wise 4-Wheelers sales 
SELECT 
    State, Vehicle_Category, SUM(EV_Sales_Quantity) AS total_sales
FROM
    ev_sales
WHERE
    Vehicle_Category = '4-Wheelers'
GROUP BY State , Vehicle_Category
ORDER BY total_sales DESC;

-- Most Popular Vehicle Type Sales by State 
SELECT *
 FROM 
     (SELECT State,Vehicle_Type,sum(EV_Sales_Quantity) as total_sales,rank() over(partition by State ORDER BY
     sum(EV_Sales_Quantity)Desc) 
     as type_rank 
    FROM ev_sales 
GROUP BY State,Vehicle_Type)ranked_types
     WHERE type_rank = 1;
 
-- Quater Wise EV Sales By Vehicle Class 
SELECT 
    Year,
    CASE 
        WHEN Month_Name IN ('January', 'February', 'March') THEN 'Q1'
        WHEN Month_Name IN ('April', 'May', 'June') THEN 'Q2'
        WHEN Month_Name IN ('July', 'August', 'September') THEN 'Q3'
        ELSE 'Q4'
    END AS Quarter,
    Vehicle_Class,
    SUM(ev_sales_quantity) AS total_sales
FROM ev_sales
GROUP BY Year, Quarter, Vehicle_Class;

-- Highest Selling Month for each year 
SELECT *
FROM (
    SELECT 
        Year,
        Month_Name,
        SUM(ev_sales_quantity) AS total_sales,
        RANK() OVER (PARTITION BY Year ORDER BY SUM(ev_sales_quantity) DESC) AS month_rank
    FROM ev_sales
    GROUP BY Year, Month_Name
) ranked_months
WHERE month_rank = 1;

-- Year Over Year Growth By Vehicle Category 
WITH category_year_sales AS (
    SELECT 
        Vehicle_Category,
        Year,
        SUM(ev_sales_quantity) AS total_sales
    FROM ev_sales
    GROUP BY Vehicle_Category, Year
)
SELECT 
    Vehicle_Category,
    Year,
    total_sales,
    LAG(total_sales) OVER (PARTITION BY Vehicle_Category ORDER BY Year) AS previous_year_sales,
    ROUND(((total_sales - LAG(total_sales) OVER (PARTITION BY Vehicle_Category ORDER BY Year)) * 100.0) /
    NULLIF(LAG(total_sales) OVER (PARTITION BY Vehicle_Category ORDER BY Year), 0), 2) AS yoy_growth_percent
FROM category_year_sales;