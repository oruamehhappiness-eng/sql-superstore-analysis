

/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

-- Analyse sales performance over time

-- Using Quick Date Functions
SELECT 
Year([order date]) as order_year,
MONTH([order date]) as order_month,
SUM([sales]) as total_sales,
COUNT(DISTINCT [customer key]) as total_customer, --are we gaining customers
SUM([quantity]) as total_quantity
FROM gold.fact_sales
GROUP BY month([order date]),Year([order date])  
ORDER BY month([order date]),Year([order date]) 

-- Using DATETRUNC()
SELECT 
DATETRUNC(month, [Order Date]) as order_date,
SUM([sales]) as total_sales,
COUNT(distinct [customer key]) as total_customer, --are we gaining customers
SUM([quantity]) as total_quantity
FROM gold.fact_sales
GROUP BY datetrunc(month, [Order Date])  
ORDER BY datetrunc(month, [Order Date]) 

-- Using FORMAT() to change the date format

SELECT 
FORMAT([Order Date], 'yyyy-MMM') as order_date,
SUM([sales]) as total_sales,
COUNT(distinct [customer key]) as total_customer, --are we gaining customers
SUM([quantity]) as total_quantity
FROM gold.fact_sales
GROUP BY format([Order Date], 'yyyy-MMM') 
ORDER BY format([Order Date], 'yyyy-MMM')


/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month 
-- and the running total of sales over time

SELECT
order_Date,
total_sales,
SUM(total_sales) OVER ( order by order_date) as running_total_Sales,
AVG(total_sales) OVER ( order by order_date) as moving_avg_Sales
FROM
(
  SELECT 
  DATETRUNC(month, [Order Date]) as order_date,
  SUM([sales]) as total_sales
  FROM gold.fact_sales
  GROUP BY datetrunc(month, [Order Date])  
 )t


/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

--PERFORMANCE ANALYSIS: Comparing current value to a target value.
/*Analyze the yearly performance of products by comparing each product's sales to both
  its average sales performance and the previous year's sales.*/

WITH yearly_product_sales AS (
SELECTED
YEAR(f.[Order Date])  as order_year,
p.[Product Name] as product_name,
SUM(f.Sales) as current_sales
  
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.[Product Key] = p.[Product Key]

GROUP BY
YEAR ( f.[Order Date]),
p.[Product Name]
)

SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) as diff_avg,
CASE WHEN current_sales - AVG(current_sales) over(PARTITION BY product_name) > 0 THEN 'Above Avg'
	 WHEN current_sales - AVG(current_sales) over(PARTITION BY product_name) < 0 THEN 'Below Avg'
	 ELSE 'Avg'
END avg_change,

--YOY ANALYSIS
LAG (current_sales) OVER (PARTITION BY product_name order by order_year) py_sales,
current_sales - LAG (current_sales) OVER (PARTITION BY product_name order by order_year) as diff_py,
CASE WHEN current_sales - LAG(current_sales) over(PARTITION BY product_name order by order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) over(PARTITION BY product_name order by order_year) < 0 THEN 'Decrease'
	 ELSE 'No Change'
END py_change

FROM yearly_product_sales

ORDER BY
product_name,
order_year;






