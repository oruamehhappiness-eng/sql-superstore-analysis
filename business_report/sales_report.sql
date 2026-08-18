/*
===============================================================================
Sales Report
===============================================================================
Purpose:
    - Consolidates key sales transaction metrics and performance

Highlights:
    1. Gathers essential order, customer, product, and transaction details.
    2. Calculates sales-level metrics:
        - sales
        - profit
        - profit margin
        - quantity
        - discount
    3. Calculates operational metrics:
        - shipping duration
        - return status
    4. Provides information for analyzing sales performance,
       profitability, shipping, and returns.
===============================================================================
*/

WITH base_query AS
(
/*---------------------------------------------------------------------------
1) Base Query: Retrieve core columns from fact_sales
---------------------------------------------------------------------------*/

    SELECT
        f.[Order ID] AS order_id,
        f.[Order Date] AS order_date,
        f.[Ship Date] AS ship_date,
          -- Shipping duration
    DATEDIFF(
        DAY,
        f.[Order Date],
        f.[Ship Date]
    ) AS shipping_days,

        f.[Ship Mode] AS ship_mode,

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
        f.Discount,
        f.[Return_Status] AS return_status

    FROM gold.fact_sales f

    LEFT JOIN gold.dim_customers c
        ON f.[Customer Key] = c.[Customer Key]

    LEFT JOIN gold.dim_products p
        ON f.[Product Key] = p.[Product Key]

    WHERE f.[Order Date] IS NOT NULL
)

SELECT
    order_id,
    order_date,
    ship_date,
    shipping_days,
    ship_mode,

    customer_key,
    customer_id,
    customer_name,

    product_key,
    product_id,
    product_name,
    category,
    sub_category,

    Region,
    regional_manager,

    CAST(Sales AS DECIMAL(18,2)) AS sales,

    CAST(Profit AS DECIMAL(18,2)) AS profit,

    CAST(
        ROUND(
            Profit * 100.0 / NULLIF(Sales, 0),
            2
        )
        AS DECIMAL(10,2)
    ) AS profit_margin,

    CAST(Quantity AS INT) AS quantity,

    CAST(
        ROUND(Discount * 100, 2)
        AS DECIMAL(10,2)
    ) AS discount,

    return_status


FROM base_query;
