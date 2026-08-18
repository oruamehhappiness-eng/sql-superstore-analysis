/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - Consolidates key product metrics and performance

Highlights:
    1. Gathers essential product and transaction details.
    2. Segments products into High-Performer, Mid-Range, and Low-Performer.
    3. Aggregates product-level metrics:
        - total orders
        - total sales
        - total quantity
        - total customers
        - average selling price
        - returned orders
        - return rate
        - lifespan
    4. Calculates valuable KPIs:
        - recency
        - average order revenue
        - average monthly revenue
===============================================================================
*/

WITH base_query AS
(
/*---------------------------------------------------------------------------
1) Base Query: Retrieve core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/

    SELECT
        f.[Order ID] AS order_id,
        f.[Customer Key] AS customer_key,
        f.[Order Date] AS order_date,
        f.Sales,
        f.Quantity,
        f.[Return_Status],

        p.[Product Key] AS product_key,
        p.[Product ID] AS product_id,
        p.[Product Name] AS product_name,
        p.Category AS category,
        p.[Sub-Category] AS sub_category

    FROM gold.fact_sales f

    LEFT JOIN gold.dim_products p
        ON f.[Product Key] = p.[Product Key]
),

product_aggregations AS
(
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarize key metrics at product level
---------------------------------------------------------------------------*/

    SELECT
        product_key,
        product_name,
        category,
        sub_category,

        DATEDIFF(
            MONTH,
            MIN(order_date),
            MAX(order_date)
        ) AS lifespan,

        MAX(order_date) AS last_order,

        COUNT(DISTINCT order_id) AS total_orders,

        COUNT(DISTINCT customer_key) AS total_customers,

        SUM(Sales) AS total_sales,

        SUM(Quantity) AS total_quantity,

        COUNT(DISTINCT CASE
            WHEN [Return_Status] = 'Returned'
            THEN order_id
        END) AS returned_orders,

        ROUND(
            AVG(
                CAST(Sales AS FLOAT)
                / NULLIF(Quantity, 0)
            ),
            1
        ) AS avg_selling_price

    FROM base_query

    GROUP BY
        product_key,
        product_name,
        category,
        sub_category
)

SELECT
    product_key,
    product_name,
    category,
    sub_category,

    last_order,

    DATEDIFF(
        MONTH,
        last_order,
        GETDATE()
    ) AS recency_in_months,

    CASE
        WHEN total_sales > 50000
            THEN 'High-Performer'

        WHEN total_sales >= 10000
            THEN 'Mid-Range'

        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan,

    total_orders,

    CAST(total_sales AS DECIMAL(18,2)) AS total_sales,

    CAST(total_quantity AS INT) AS total_quantity,

    total_customers,

    CAST(
        avg_selling_price AS DECIMAL(18,2)
    ) AS avg_selling_price,

    returned_orders,

    CAST(
        ROUND(
            returned_orders * 100.0
            / NULLIF(total_orders, 0),
            2
        )
        AS DECIMAL(10,2)
    ) AS return_rate,

    -- Compute average order revenue (AOR)
    CAST(
        CASE
            WHEN total_orders = 0
                THEN 0
            ELSE total_sales / total_orders
        END
        AS DECIMAL(18,2)
    ) AS avg_order_revenue,

    -- Compute average monthly revenue
    CAST(
        CASE
            WHEN lifespan = 0
                THEN total_sales
            ELSE total_sales / lifespan
        END
        AS DECIMAL(18,2)
    ) AS avg_monthly_revenue

FROM product_aggregations;
