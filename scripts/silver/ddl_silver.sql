/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('silver.ms_orderss', 'U') IS NOT NULL
	DROP TABLE silver.ms_orderss;

GO
  
CREATE TABLE silver.ms_orderss (
[Row ID]	INT,
[Order ID] NVARCHAR(50),	
[Order Date]	NVARCHAR(50),
[Ship Date]	NVARCHAR(50),
[Ship Mode]  NVARCHAR(50),
[Customer ID]	NVARCHAR(50),
[Customer Name]	NVARCHAR(50),
[Segment]	NVARCHAR(50),
[Country]	NVARCHAR(50),
[City]	NVARCHAR(50),
[State]	NVARCHAR(50),
[Postal Code] NVARCHAR(50),
[Region]	NVARCHAR(50),
[Product ID]	NVARCHAR(50),
[Category] NVARCHAR(50),	
[Sub-Category] NVARCHAR(50),
[Product Name]	NVARCHAR(150),
[Sales]    decimal (18,10),
[Quantity] decimal (18,10),	
[Discount] FLOAT,
[Profit] decimal (18,10),
Dwh_create_date DATETIME2 DEFAULT GETDATE()
);

GO
  
IF OBJECT_ID('silver.ms_peoplee', 'U') IS NOT NULL
	DROP TABLE silver.ms_peoplee;

GO

CREATE TABLE silver.ms_peoplee (
[Regional Manager] NVARCHAR(50),	
[Region] NVARCHAR(50),
Dwh_create_date DATETIME2 DEFAULT GETDATE()
);

GO
  
IF OBJECT_ID('silver.ms_returnss', 'U') IS NOT NULL
	DROP TABLE silver.ms_returnss;

GO
  
CREATE TABLE silver.ms_returnss (
[Returned]	NVARCHAR(50),
[Order ID] NVARCHAR(50),
Dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
