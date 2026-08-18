/*
===============================================================================
                    DATA ANALYTICS TECHNIQUES
===============================================================================

TABLE OF CONTENTS

1. Change Over Time Analysis
   - Monthly Sales Performance
   - Customer Growth Over Time
   - Quantity Trends
   - Date Functions: YEAR(), MONTH(), DATETRUNC(), FORMAT()

2. Cumulative Analysis
   - Running Total of Sales
   - Moving Average of Sales
   - Window Functions: SUM() OVER(), AVG() OVER()

3. Performance Analysis
   - Year-over-Year (YoY) Analysis
   - Previous Year Comparison
   - Average Performance Comparison
   - Above/Below Average Classification
   - Increase/Decrease Analysis
   - Window Functions: LAG(), AVG() OVER(), CASE

4. Data Segmentation Analysis
   - Product Segmentation by Sales Range
   - Customer Segmentation by Spending Behavior
   - VIP, Regular, and New Customer Segments
   - CASE, DATEDIFF(), GROUP BY, CTEs

5. Part-to-Whole Analysis
   - Category Sales Contribution
   - Overall Sales Comparison
   - Percentage of Total Sales
   - Window Functions: SUM() OVER()

===============================================================================
*/

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

/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group products and customers into meaningful segments based on
      business-defined ranges and behavioral characteristics.
    - To understand the distribution of products across different sales ranges.
    - To segment customers based on spending behavior and customer lifespan.
    - To identify customer groups such as VIP, Regular, and New customers.
    - To support targeted business decisions and customer-focused strategies.

Analysis Covered:
    1. Product Segmentation
        - Groups products into sales ranges.
        - Counts the number of products within each range.

    2. Customer Segmentation
        - Groups customers based on spending and relationship lifespan.
        - Identifies VIP, Regular, and New customers.
        - Counts the number of customers in each segment.

SQL Techniques Used:
    - CASE: Creates business-defined segmentation categories.
    - SUM(): Calculates total customer spending.
    - MIN() / MAX(): Identifies first and last customer orders.
    - DATEDIFF(): Calculates customer lifespan.
    - GROUP BY: Aggregates entities within each segment.
    - Common Table Expressions (CTEs): Organizes intermediate calculations.
===============================================================================
*/

-- Segment products into sales ranges and
-- count how many products fall into each segment

WITH product_segment AS(
SELECT
P.[Product Key] as product_key,
P.[Product Name],
F.Sales,
CASE WHEN f.Sales < 100 THEN 'Below 100'
     WHEN f.Sales BETWEEN 100 AND 500 THEN '100-500'
	 WHEN f.Sales BETWEEN 500 AND 1000 THEN '500-1000'
     ELSE 'Above 1000'
END cost_range
	 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.[Product Key] = p.[Product Key])

SELECT
cost_range,
COUNT(product_key) AS total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products


/*Group customers into three segments based on their spending behavior:
-VIP: atleast 12 months of history and spending more than 5000
-Regular: atleast 12 months of history but spending 5,000 or less
-New: lifespan less than 12 months
And find the total number of customers by each group*/

WITH customer_spending AS(
SELECT 
c.[Customer Key] AS customer_key,
SUM( f.Sales) as total_spending,
MIN( f.[Order Date] ) as first_order,
MAX( f.[Order Date] ) as last_order,
DATEDIFF(month, MIN( f.[Order Date] ) , MAX( f.[Order Date] ) ) AS lifespan


FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.[Customer Key] = c.[Customer Key]
GROUP BY 
c.[Customer Key]
  )

SELECT
customer_segment,
COUNT(customer_key) AS total_customers
FROM(
   SELECT
   customer_key,
   total_spending,
   lifespan,
   CASE WHEN lifespan >= 12 and total_spending > 5000 then 'VIP'
		WHEN lifespan >= 12 and total_spending <= 5000 then 'Regular'
		ELSE 'New'
	END customer_segment
   from customer_spending
   )  AS segmented_customers
   
   GROUP BY customer_segment
   ORDER BY total_customers DESC


/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To evaluate how individual categories contribute to overall business
      performance.
    - To identify which product categories have the greatest impact on total
      sales.
    - To compare category-level sales against overall sales.

Analysis Covered:
    1. Calculates total sales for each product category.
    2. Calculates overall sales across all categories.
    3. Determines each category's percentage contribution to total sales.
    4. Ranks categories based on their total sales contribution.

SQL Techniques Used:
    - SUM(): Calculates total sales.
    - SUM() OVER(): Calculates the overall sales total.
    - CAST(): Converts values to a compatible data type for percentage
      calculations.
    - ROUND(): Rounds percentage results.
    - CONCAT(): Formats the percentage with a '%' symbol.
    - GROUP BY: Aggregates sales by product category.
    - Common Table Expression (CTE): Organizes the category-level calculation.
===============================================================================
*/

--Which categories contribute the most to overall sales
  
WITH category_sales AS(
SELECT
P.Category as category,
SUM( F.Sales) Total_Sales

FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.[Product Key] = p.[Product Key]

GROUP BY 
p.Category
)
  SELECT 
  category,
  total_sales,
  SUM(total_sales) OVER() overall_sales,
  CONCAT(ROUND((CAST(total_sales AS  FLOAT)/sum(total_sales ) OVER ()) * 100, 2), '%') AS percentage_of_total
  FROM category_Sales
  ORDER BY total_sales DESC




