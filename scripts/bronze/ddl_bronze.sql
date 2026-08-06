/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('bronze.ms_orderss', 'U') IS NOT NULL
	DROP TABLE bronze.ms_orderss;

CREATE TABLE bronze.ms_orderss (
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
[Profit] decimal (18,10)
);


IF OBJECT_ID('bronze.ms_peoplee', 'U') IS NOT NULL
	DROP TABLE bronze.ms_peoplee;

CREATE TABLE bronze.ms_peoplee (
[Regional Manager] NVARCHAR(50),	
[Region] NVARCHAR(50)
)
;


IF OBJECT_ID('bronze.ms_returnss', 'U') IS NOT NULL
	DROP TABLE bronze.ms_returnss;

CREATE TABLE bronze.ms_returnss (
[Order ID]	NVARCHAR(50),
[Returned] NVARCHAR(50)
)


