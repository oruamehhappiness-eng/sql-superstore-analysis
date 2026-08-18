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
