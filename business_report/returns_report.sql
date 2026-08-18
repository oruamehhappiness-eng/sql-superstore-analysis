/*
===============================================================================
Returns Report
===============================================================================
Purpose:
    - Consolidates key return metrics and behaviors

Highlights:
    1. Identifies returned and non-returned orders.
    2. Aggregates return metrics at the order level.
    3. Calculates:
        - total orders
        - returned orders
        - not returned orders
        - return rate
        - returned sales
        - returned profit
        - returned quantity
    4. Provides customer, product, regional, and manager information
       for further return analysis.
===============================================================================
*/

WITH base_query AS
(
/*---------------------------------------------------------------------------
1) Base Query: Retrieve core columns from fact_sales and dimension tables
---------------------------------------------------------------------------*/

    SELECT
        f.[Order ID] AS order_id,
        f.[Order Date] AS order_date,

        f.[Customer Key] AS customer_key,
        c.[Customer ID] AS customer_id,
        c.[Customer Name] AS customer_name,

        f.[Product Key] AS product_key,
        p.[Product ID] AS product_id,
        p.[Product Name] AS product_name,
        p.Category AS category,
        p.[Sub-Category] AS sub_category,

        f.Region,
        f.[Regional Manager] AS regional_manager,

        f.Sales,
        f.Profit,
        f.Quantity,

        f.[Return_Status] AS return_status

    FROM gold.fact_sales f

    LEFT JOIN gold.dim_customers c
        ON f.[Customer Key] = c.[Customer Key]

    LEFT JOIN gold.dim_products p
        ON f.[Product Key] = p.[Product Key]

    WHERE f.[Order Date] IS NOT NULL
),

return_aggregation AS
(
/*---------------------------------------------------------------------------
2) Return Aggregation
---------------------------------------------------------------------------*/

    SELECT
        return_status,

        COUNT(DISTINCT order_id) AS total_orders,

        COUNT(DISTINCT customer_key) AS total_customers,

        COUNT(DISTINCT product_key) AS total_products,

        SUM(Sales) AS total_sales,

        SUM(Profit) AS total_profit,

        SUM(Quantity) AS total_quantity

    FROM base_query

    GROUP BY return_status
)

SELECT
    return_status,

    total_orders,

    total_customers,

    total_products,

    CAST(total_sales AS DECIMAL(18,2)) AS total_sales,

    CAST(total_profit AS DECIMAL(18,2)) AS total_profit,

    CAST(total_quantity AS INT) AS total_quantity,

    CAST(
        ROUND(
            total_profit * 100.0
            / NULLIF(total_sales, 0),
            2
        )
        AS DECIMAL(10,2)
    ) AS profit_margin

FROM return_aggregation

ORDER BY total_orders DESC;





/*
===============================================================================
Returns by Category
===============================================================================
Purpose:
    - Analyzes return performance across product categories.

Questions:
    1. Which product category has the highest return rate?
    2. Which product category has the most returned orders?

Highlights:
    1. Calculates total orders for each product category.
    2. Identifies the number of returned orders by category.
    3. Calculates the return rate for each category.
    4. Ranks product categories by the number of returned orders.
===============================================================================
*/

SELECT 
    p.Category,
    COUNT(DISTINCT f.[Order ID]) AS total_orders,
    COUNT(DISTINCT CASE 
        WHEN f.Return_Status = 'returned' 
        THEN f.[Order ID] 
    END) AS returned_orders,
    CONCAT(
        ROUND(
            COUNT(DISTINCT CASE 
                WHEN f.Return_Status = 'returned' 
                THEN f.[Order ID] 
            END) * 100.0 
            / COUNT(DISTINCT f.[Order ID]), 
            2
        ), 
        '%'
    ) AS return_rate
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.[Product Key] = p.[Product Key]
GROUP BY p.Category
ORDER BY returned_orders DESC;


/*
===============================================================================
Returns by Product
===============================================================================
Purpose:
    - Identifies products that are frequently returned.
    - Highlights products with unusually high return rates.

Questions:
    1. Which products have the highest number of returns?
    2. Which products have unusually high return rates?

Highlights:
    1. Calculates total orders for each product.
    2. Identifies the number of returned orders for each product.
    3. Calculates the return rate for each product.
    4. Ranks products based on their return rate.
    5. Helps identify products that may have quality, customer expectation,
       or fulfillment issues.
===============================================================================
*/

SELECT 
    p.[Product Name],
    COUNT(DISTINCT f.[Order ID]) AS total_orders,
    COUNT(DISTINCT CASE 
        WHEN f.Return_Status = 'returned' 
        THEN f.[Order ID] 
    END) AS returned_orders,
    ROUND(
        COUNT(DISTINCT CASE 
            WHEN f.Return_Status = 'returned' 
            THEN f.[Order ID] 
        END) * 100.0 
        / COUNT(DISTINCT f.[Order ID]), 
        2
    ) AS return_rate
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.[Product Key] = p.[Product Key]
GROUP BY 
    p.[Product Name]
ORDER BY 
    return_rate DESC;




/*
===============================================================================
Returns by Region
===============================================================================
Purpose:
    - Analyzes return performance across different geographical regions.

Questions:
    1. Which region has the highest return rate?
    2. Which region has the lowest return rate?

Highlights:
    1. Calculates total orders for each region.
    2. Identifies the number of returned orders for each region.
    3. Calculates the return rate for each region.
    4. Ranks regions based on their return rate.
    5. Helps identify geographical areas with unusually high or low
       return activity.
===============================================================================
*/

SELECT
    Region,
    COUNT(DISTINCT [Order ID]) AS total_orders,
    COUNT(DISTINCT CASE 
        WHEN Return_Status = 'returned' 
        THEN [Order ID] 
    END) AS returned_orders,
    ROUND(
        COUNT(DISTINCT CASE 
            WHEN Return_Status = 'returned' 
            THEN [Order ID] 
        END) * 100.0 
        / COUNT(DISTINCT [Order ID]), 
        2
    ) AS return_rate
FROM gold.fact_sales
GROUP BY 
    Region
ORDER BY 
    return_rate DESC;



/*
===============================================================================
Returns by Customer
===============================================================================
Purpose:
    - Identifies customers with repeated returned orders.
    - Analyzes customer-level return behavior.

Questions:
    1. Which customers have the most returned orders?
    2. What percentage of their orders are returned?

Highlights:
    1. Calculates total orders for each customer.
    2. Identifies the number of returned orders for each customer.
    3. Calculates the return rate for each customer.
    4. Ranks customers based on their return rate.
    5. Helps identify customers with unusually high or repeated returns.
===============================================================================
*/

SELECT 
    c.[Customer Name],
    COUNT(DISTINCT f.[Order ID]) AS total_orders,
    COUNT(DISTINCT CASE 
        WHEN f.Return_Status = 'returned' 
        THEN f.[Order ID] 
    END) AS returned_orders,
    ROUND(
        COUNT(DISTINCT CASE 
            WHEN f.Return_Status = 'returned' 
            THEN f.[Order ID] 
        END) * 100.0 
        / COUNT(DISTINCT f.[Order ID]), 
        2
    ) AS return_rate
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.[Customer Key] = c.[Customer Key]
GROUP BY 
    c.[Customer Name]
ORDER BY 
    return_rate DESC;


/*
===============================================================================
Returns Over Time
===============================================================================
Purpose:
    - Analyzes return trends over time.
    - Tracks changes in return activity and the financial impact of returns.

Highlights:
    1. Aggregates return metrics at the monthly level.
    2. Calculates:
        - total orders
        - returned orders
        - return rate
        - total sales
        - returned sales
        - sales return rate
    3. Helps identify periods with unusually high return activity.
    4. Helps evaluate the financial impact of returns on sales over time.
    5. Supports the analysis of trends and changes in customer return behavior.
===============================================================================
*/

WITH returns_over_time AS 
(
    SELECT 
        DATETRUNC(MONTH, f.[Order Date]) AS order_month,

        COUNT(DISTINCT f.[Order ID]) AS total_orders,

        COUNT(DISTINCT CASE 
            WHEN f.Return_Status = 'returned' 
            THEN f.[Order ID] 
        END) AS returned_orders,

        SUM(f.[Sales]) AS total_sales,

        SUM(CASE 
            WHEN f.Return_Status = 'returned' 
            THEN f.[Sales] 
            ELSE 0 
        END) AS returned_sales

    FROM gold.fact_sales f

    GROUP BY 
        DATETRUNC(MONTH, f.[Order Date]) 
)

SELECT 
    order_month,
    total_orders,
    returned_orders,

    CAST(
        ROUND(
            returned_orders * 100.0 / total_orders,
            2
        )
        AS DECIMAL(18,2)
    ) AS return_rate,

    CAST(
        ROUND(total_sales, 2)
        AS DECIMAL(18,2)
    ) AS total_sales,

    CAST(
        ROUND(returned_sales, 2)
        AS DECIMAL(18,2)
    ) AS returned_sales,

    CAST(
        ROUND(
            returned_sales * 100.0 / total_sales,
            2
        )
        AS DECIMAL(18,2)
    ) AS sales_return_rate

FROM returns_over_time

ORDER BY 
    order_month;
