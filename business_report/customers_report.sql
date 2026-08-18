/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - Consolidates key customer metrics and purchasing behavior

Highlights:
    1. Gathers essential customer and transaction details.
    2. Segments customers into VIP, Regular, and New.
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total profit
        - profit margin
        - total quantity purchased
        - total products purchased
        - average discount
        - returned orders
        - lifespan
    4. Calculates customer KPIs:
        - recency
        - average order value
        - average monthly spend
        - return rate
===============================================================================
*/

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

WITH base_query AS
(
    SELECT
        f.[Order ID],
        f.[Product Key],
        f.[Order Date],
        f.Sales,
        f.Profit,
        f.Quantity,
       
        f.[Return_Status],

        c.[Customer Key],
        c.[Customer ID],
        c.[Customer Name]

    FROM gold.fact_sales f

    LEFT JOIN gold.dim_customers c
        ON f.[Customer Key] = c.[Customer Key]

    WHERE f.[Order Date] IS NOT NULL
),

customer_aggregation AS
(
    SELECT
        [Customer Key],
        [Customer ID],
        [Customer Name],

        COUNT(DISTINCT [Order ID]) AS total_orders,

        SUM(Sales) AS total_sales,

        SUM(Profit) AS total_profit,

        SUM(Quantity) AS total_quantity,

        COUNT(DISTINCT [Product Key]) AS total_products,

        
        COUNT(DISTINCT CASE
            WHEN [Return_Status] = 'Returned'
            THEN [Order ID]
        END) AS returned_orders,

        MAX([Order Date]) AS last_order_date,

        DATEDIFF(
            MONTH,
            MIN([Order Date]),
            MAX([Order Date])
        ) AS lifespan

    FROM base_query

    GROUP BY
        [Customer Key],
        [Customer ID],
        [Customer Name]
)

SELECT
    [Customer Key],
    [Customer ID],
    [Customer Name],

    CASE
        WHEN lifespan >= 12 AND total_sales > 5000
            THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000
            THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    last_order_date,

    DATEDIFF(
        MONTH,
        last_order_date,
        GETDATE()
    ) AS recency,

    total_orders,

    CAST(total_sales AS DECIMAL(18,2)) AS total_sales,

    CAST(total_profit AS DECIMAL(18,2)) AS total_profit,

    CAST(
        ROUND(
            total_profit * 100.0 / NULLIF(total_sales, 0),
            2
        )
        AS DECIMAL(10,2)
    ) AS profit_margin,

    CAST(total_quantity AS INT) AS total_quantity,

    total_products,


    returned_orders,

    CAST(
        ROUND(
            returned_orders * 100.0 / NULLIF(total_orders, 0),
            2
        )
        AS DECIMAL(10,2)
    ) AS return_rate,

    lifespan,

    CAST(
        ROUND(
            total_sales / NULLIF(total_orders, 0),
            2
        )
        AS DECIMAL(18,2)
    ) AS avg_order_value,

    CAST(
        ROUND(
            CASE
                WHEN lifespan = 0
                    THEN total_sales
                ELSE total_sales / lifespan
            END,
            2
        )
        AS DECIMAL(18,2)
    ) AS avg_monthly_spend

FROM customer_aggregation;
GO
