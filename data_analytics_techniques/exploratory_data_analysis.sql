/* 
===============================================================================
                    DATABASE EXPLORATION & ANALYSIS
===============================================================================

TABLE OF CONTENTS

1. Database Exploration
   - Explore All Tables
   - Explore All Columns
   - INFORMATION_SCHEMA.TABLES
   - INFORMATION_SCHEMA.COLUMNS

2. Dimensions Exploration
   - Explore Customer Countries
   - Explore Product Categories
   - Explore Product Sub-Categories
   - Explore Products
   - DISTINCT
   - ORDER BY

3. Date Range Exploration
   - First Order Date
   - Last Order Date
   - Order Date Range
   - MIN()
   - MAX()
   - DATEDIFF()

4. Measures Exploration
   - Total Sales
   - Total Items Sold
   - Average Sales
   - Total Orders
   - Total Products
   - Total Customers
   - Customers Who Have Placed Orders
   - COUNT()
   - COUNT(DISTINCT)
   - SUM()
   - AVG()
   - UNION ALL

5. Magnitude Analysis
   - Total Customers by Country
   - Total Products by Category
   - Average Sales by Category
   - Total Profit by Category
   - Total Profit by Customer
   - Quantity Sold by Region
   - SUM()
   - COUNT()
   - AVG()
   - GROUP BY
   - ORDER BY

6. Ranking Analysis
   - Top 5 Products by Profit
   - Top 10 Customers by Revenue
   - Bottom 5 Products by Profit
   - Customers with Fewest Orders
   - TOP
   - ROW_NUMBER()
   - GROUP BY
   - ORDER BY

===============================================================================
*/
/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

--DATABASE EXPLORATION
--EXPLORE ALL OBJECTS IN THE DATABASE
SELECT * FROM INFORMATION_SCHEMA.TABLES

--EXPLORE ALL COLUMNS IN THE DATABASE
SELECT * FROM INFORMATION_SCHEMA. COLUMNS


/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

--DIMENSIONS EXPLORATION
--EXPLORE ALL COUNTRIES CUSTOMERS COME FROM
SELECT DISTINCT [country] from gold.fact_sales

--EXPLORE ALL CATEGORY ' THE MAJOR DIVISIONS'
SELECT DISTINCT 
[Category], 
[Sub-Category],
[Product Name]
FROM gold.dim_products
ORDER BY 1,2,3

/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- To determine the first and last order date and the total duration in months
SELECT 
MIN([Order Date]) [First Order Date],
MAX([Order Date]) [Last Order Date],
DATEDIFF (Year,MIN([Order Date]),MAX([Order Date])) [Order Range Years]
FROM gold.fact_sales;


/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- To find the total sales
SELECT SUM(Sales) [total sales] from gold.fact_sales

-- To find how many items are sold
SELECT SUM (Quantity) [total items] from gold.fact_sales

-- To find the average sales
SELECT AVG(Sales) [average sales] from gold.fact_sales

-- To find the total number of orders
SELECT COUNT([Order ID]) [total orders] from gold.fact_sales
SELECT COUNT(DISTINCT[Order ID]) [total orders] from gold.fact_sales

-- To find the total number of products
SELECT COUNT([Product Name]) [total products] from gold.dim_products
SELECT COUNT(DISTINCT[product key]) [total products] from gold.dim_products

-- To find the total number of customers
SELECT COUNT([customer key]) [total customers] from gold.dim_customers

-- To find the total number of customers that has placed an order
SELECT COUNT(DISTINCT[customer key]) [total customers] from gold.fact_sales

/*To generate report that shows all key metrics of the business*/
SELECT 'total sales' as measure_name, sum(sales) as measure_value from gold.fact_sales
UNION ALL
SELECT '[total items]' as measure_name, sum(Quantity) as measure_value from gold.fact_sales
UNION ALL
SELECT '[average sales]' as measure_name, avg(sales) as measure_value from gold.fact_sales
UNION ALL
SELECT '[total number of orders]' as measure_name,  COUNT(DISTINCT[Order ID]) as measure_value from gold.fact_sales
UNION ALL
SELECT '[total number of products]' as measure_name,  COUNT([Product Name]) as measure_value from gold.dim_products
UNION ALL
SELECT '[total number of customers]' as measure_name,  COUNT([customer key]) as measure_value from gold.dim_customers
UNION ALL
SELECT '[total nr.of customers that has placed an order]' as measure_name,  COUNT(DISTINCT[customer key]) as measure_value from gold.dim_customers


/*
===============================================================================
Magnitude Analysis
===============================================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
===============================================================================
*/

--Find total customers by countries
	SELECT
	f.[country],
	count(c.[Customer Key]) as total_customers
	FROM gold.dim_customers c
	left join gold.fact_sales f
	on c.[Customer Key] = f.[Customer Key]
	group by f.[Country]

-- To find total products by category
	SELECT 
	[category],
	count([Product Key]) as total_products
	from gold.dim_products
	group by [Category]

-- To get the average sales in each category?
	SELECT
	p.[category],
	avg(f.[sales]) as average_sales
	FROM gold.dim_products p
	left join gold.fact_sales f
	on p.[product Key] = f.[Product Key]
	group by p.[category]

-- To get the total profit generated by each category?
    SELECT
	p.[Category],
	SUM(f.[Profit]) as total_profit
	FROM  gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.[product Key] = f.[Product Key]
	GROUP BY P.[Category]
	ORDER BY sum(f.[Profit]) DESC

-- To find total revenue generated by each customer
	SELECT
	c.[Customer Name],
	c.[customer id],
	SUM(f.[Profit]) as total_profit
	FROM gold.dim_customers c
	LEFT JOIN gold.fact_sales f
	on c.[Customer Key] = f.[Customer Key]
	GROUP BY  
	c.[Customer Name],
	c.[customer id]
	ORDER BY total_profit DESC
		

-- To get the distribution of sold items across regions?
	SELECT
	f.[Region],
	SUM(F.[Quantity]) sold_item
	FROM gold.fact_sales f	
	GROUP BY f.[Region]
	ORDER BY sold_item DESC


/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- To get the 5 products that generate the highest revenue
	SELECT TOP 5
	p.[Product Name],
	SUM(f.[Profit]) as total_profit
	FROM  gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.[product Key] = f.[Product Key]
	GROUP BY P.[Product Name]
	ORDER BY sum(f.[Profit]) DESC
-- USING WINDOW FUNCTION
	SELECT*
	FROM(
	SELECT
	p.[Product Name],
	SUM(f.[Profit]) as total_profit,
	ROW_NUMBER() OVER (ORDER BY sum(f.[Profit]) desc) as rank_products
	FROM  gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.[product Key] = f.[Product Key]
	GROUP BY P.[Product Name])t
	where rank_products <=5
		
--  To get the top 10 customers who have generated the highest 
	SELECT TOP 10
    c.[Customer Key],
    c.[Customer Name],
    SUM(f.[Sales]) AS total_revenue
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
    ON c.[Customer Key] = f.[Customer Key]
    GROUP BY 
    c.[Customer Key],
    c.[Customer Name]
    ORDER BY total_revenue DESC;

-- To get the 5 worst performing products in terms of sales
	SELECT TOP 5
	p.[Product Name],
	SUM(f.[Profit]) as total_profit
	FROM  gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.[product Key] = f.[Product Key]
	GROUP BY P.[Product Name]
	ORDER BY SUM(f.[Profit]) 

-- To get the 3 customers with the fewest orders placed
	SELECT top 3
	c.[Customer Name],
	c.[customer key],
	COUNT(f.[order id]) as total_orders
	FROM gold.fact_sales f
	LEFT join gold.dim_customers c
	ON c.[Customer Key] = f.[Customer Key]
	GROUP BY 
	c.[Customer Name],
	c.[customer key]
	ORDER BY total_orders DESC












