/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
        BEGIN TRY
            SET @batch_start_time = GETDATE();
            PRINT '================================================';
            PRINT 'Loading Silver Layer';
            PRINT '================================================';

                
                     -- Loading silver.ms_orderss
                    SET @start_time = GETDATE();

                    PRINT '>> Truncating Table: silver.ms_orderss';
                    TRUNCATE TABLE silver.ms_orderss;
                    PRINT '>> Inserting Data Into: silver.ms_orderss';
                    WITH Duplicates AS
                    (
                        SELECT *,
                         ROW_NUMBER() OVER (PARTITION BY
               
                        [Order ID],
                        [Order Date],
                        [Ship Date],
                        [Ship Mode],
                        [Customer ID],
                        [Customer Name],
                        [Segment],
                        [Country],
                        [City],
                        [State],
                        [Postal Code],
                        [Region],
                        [Product ID],
                        [Category],
                        [Sub-Category],
                        [Product Name],
                        [Sales],
                        [Quantity],
                        [Discount],
                        [Profit]
                                   ORDER BY [Row ID]
                               ) AS rn
                        FROM bronze.ms_orderss
                    )

                    INSERT INTO silver.ms_orderss
                    (
                        [Row ID],
                        [Order ID],
                        [Order Date],
                        [Ship Date],
                        [Ship Mode],
                        [Customer ID],
                        [Customer Name],
                        [Segment],
                        [Country],
                        [City],
                        [State],
                        [Postal Code],
                        [Region],
                        [Product ID],
                        [Category],
                        [Sub-Category],
                        [Product Name],
                        [Sales],
                        [Quantity],
                        [Discount],
                        [Profit]
                    )

                    SELECT
                        [Row ID],
                        [Order ID],
                        [Order Date],
                        [Ship Date],
                        [Ship Mode],
                        [Customer ID],
                        [Customer Name],
                        [Segment],
                        [Country],
                        [City],
                        [State],
                        [Postal Code],
                        [Region],
                        [Product ID],
                        [Category],
                        [Sub-Category],
                        [Product Name],
                        [Sales],
                        [Quantity],
                        [Discount],
                        [Profit]
                    FROM Duplicates
                    WHERE rn = 1;
                    SET @end_time = GETDATE();
                    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
                    PRINT '>> -------------';


                -- Loading silver.ms_peoplee
                    SET @start_time = GETDATE();
                    PRINT '>> Truncating Table: silver.ms_peoplee';
                    TRUNCATE TABLE silver.ms_peoplee;
                    PRINT '>> Inserting Data Into: silver.ms_peoplee';
                     INSERT INTO silver.ms_peoplee(
                        [Regional Manager],
                       [Region])

                       SELECT  
                       [Regional Manager],
                       [Region]
                       FROM bronze.ms_peoplee

                       SET @end_time = GETDATE();
                    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
                    PRINT '>> -------------';

                      -- Loading silver.ms_returnss
                    SET @start_time = GETDATE();
                    PRINT '>> Truncating Table: silver.ms_returnss';
                    TRUNCATE TABLE silver.ms_returnss;
                    PRINT '>> Inserting Data Into: silver.ms_returnss';
                    INSERT INTO silver.ms_returnss (
                       [Returned],
                       [Order ID]) 

                       SELECT  
                       [Returned],
                       [Order ID] 
                       FROM bronze.ms_returnss
                       SET @end_time = GETDATE();
       	            SET @end_time = GETDATE();
		            PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
                    PRINT '>> -------------';

		            SET @batch_end_time = GETDATE();
		            PRINT '=========================================='
		            PRINT 'Loading Silver Layer is Completed';
                    PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		            PRINT '=========================================='
		
	END TRY
	        BEGIN CATCH
		        PRINT '=========================================='
		        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		        PRINT 'Error Message' + ERROR_MESSAGE();
		        PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		        PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		        PRINT '=========================================='
	        END CATCH
END
