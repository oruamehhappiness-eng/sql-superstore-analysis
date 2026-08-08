/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY [Customer ID]) AS [Customer Key], --Surrogate Key
    [Customer ID],
    [Customer Name],
    [Segment]
FROM
(
    SELECT DISTINCT
        [Customer ID],
        [Customer Name],
        [Segment]
    FROM silver.ms_orderss
) c;

GO

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS

SELECT
    ROW_NUMBER() OVER (ORDER BY [Product ID]) AS [Product Key], --Surrogate Key
    [Product ID],
    [Product Name],
    [Category],
    [Sub-Category]
FROM (
    SELECT
        [Product ID],
        [Product Name],
        [Category],
        [Sub-Category],
        ROW_NUMBER() OVER (
            PARTITION BY [Product ID]
            ORDER BY [Product ID]
        ) AS rn
    FROM silver.ms_orderss
) p
WHERE rn = 1;
GO

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    -- Keys / Identifiers
    o.[Row ID],
    o.[Order ID],
    c.[Customer Key],
    pr.[Product Key],

    -- Dates / Order Details
    o.[Order Date],
    o.[Ship Date],
    o.[Ship Mode],

    -- Location
    o.[Country],
    o.[State],
    o.[City],
    o.[Region],

    -- Measures
    o.[Sales],
    o.[Quantity],
    o.[Discount],
    o.[Profit],

    -- Regional Management
    p.[Regional Manager],
    
    CASE
        WHEN r.[Order ID] IS NULL THEN 'Not Returned'
        ELSE 'Returned'
    END AS Return_Status

FROM silver.ms_orderss o

LEFT JOIN gold.dim_customers c
    ON o.[Customer ID] = c.[Customer ID]

LEFT JOIN gold.dim_products pr
    ON o.[Product ID] = pr.[Product ID]

LEFT JOIN silver.ms_peoplee p
    ON o.Region = p.Region

LEFT JOIN silver.ms_returnss r
    ON o.[Order ID] = r.[Order ID];

GO
