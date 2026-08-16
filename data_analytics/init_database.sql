/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
	
WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'SuperstoreDWHAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'SuperstoreDWHAnalytics')
BEGIN
    ALTER DATABASE SuperstoreDWHAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SuperstoreDWHAnalytics;
END;
GO

-- Create the 'SuperstoreDWHAnalytics' database
CREATE DATABASE SuperstoreDWHAnalytics;
GO

USE SuperstoreDWHAnalytics;
GO

-- Create Schemas

CREATE SCHEMA gold;
GO

CREATE TABLE gold.dim_customers(
	[Customer Key] INT,
	[Customer ID] NVARCHAR(50),
	[Customer Name] NVARCHAR(50),
	[Segment] NVARCHAR(50)
	
);
GO


CREATE TABLE gold.dim_products(
	[Product Key] INT ,
	[Product ID] NVARCHAR(50) ,
	[Product Name] NVARCHAR(150),
	[Category] NVARCHAR(50),
	[Sub-Category] NVARCHAR(50),

);
GO


CREATE TABLE gold.fact_sales(
    [Row ID] INT,
    [Order ID] NVARCHAR(50),
    [Customer Key] INT,
    [Product Key]INT,
    [Order Date] NVARCHAR(50),
    [Ship Date] NVARCHAR(50),
    [Ship Mode] NVARCHAR(50),
    [Country] NVARCHAR(50),
    [State] NVARCHAR(50),
    [City] NVARCHAR(50),
    [Region] NVARCHAR(50),
    [Sales] DECIMAL (18,10),
    [Quantity] INT,
    [Discount] DECIMAL (18,10),
    [Profit] DECIMAL (18,10),
    [Regional Manager] NVARCHAR(50),
    [Return_Status] NVARCHAR(50)
);
GO

TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM 'C:\Users\PC\Documents\SQL Server Management Studio 22\superstore analytics\dim_customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

BULK INSERT gold.dim_products
FROM 'C:\Users\PC\Documents\SQL Server Management Studio 22\superstore analytics\dim_products.csv'
WITH (
	FORMAT = 'CSV',
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);

TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM 'C:\Users\PC\Documents\SQL Server Management Studio 22\superstore analytics\fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO
