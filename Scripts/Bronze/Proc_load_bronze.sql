/* 
=============================================================================================
Stored Procedure: Load Bronze Layer (Sourse->Bronze)
=============================================================================================
Script Purpose:
	This stored procedure loads data into the 'bronze' schema from external CSV files.
	It performs the following actions:
	- Truncate the bronze tables before loading data.
	- Uses the BULK INSERT' command to load data from csv Files to bronze tables.
	- QUALITY CHECK (CORRECT COLUMN, CORRECT COUNT OF ROW, NO DUPLICATE)

Parameters:
	None.
	This stored Procedure does not accept any parameters or return any values.

Usage Example:

	EXEC bronze.load_bronze;

===========================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME , @end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '==================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '==================================================';

		PRINT '--------------------------------------------------';
		PRINT 'Loading Dim_Department Tables';
		PRINT '--------------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating Tables: bronze.dim_department';
		TRUNCATE TABLE bronze.dim_department;
		PRINT '>> Inserting Data Into: bronze.dim_department';
		BULK INSERT bronze.dim_department
		FROM 'C:\Desktop\Data Stuffs\Final Year Project\Datasets\Dim_Department.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------';

		PRINT '--------------------------------------------------';
		PRINT 'Loading Dim_Course Tables';
		PRINT '--------------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating Tables: bronze.dim_course';
		TRUNCATE TABLE bronze.dim_course;
		PRINT '>> Inserting Data Into: bronze.dim_course';
		BULK INSERT bronze.dim_course
		FROM 'C:\Desktop\Data Stuffs\Final Year Project\Datasets\Dim_Course.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------';

		PRINT '--------------------------------------------------';
		PRINT 'Loading Dim_Student Tables';
		PRINT '--------------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating Tables: bronze.dim_student'
		TRUNCATE TABLE bronze.dim_student;
		PRINT '>> Inserting Data Into: bronze.dim_student';
		BULK INSERT bronze.dim_student
		FROM 'C:\Desktop\Data Stuffs\Final Year Project\Datasets\Dim_Student.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------';


		PRINT '--------------------------------------------------';
		PRINT 'Loading Dim_Time Tables';
		PRINT '--------------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating Tables: bronze.dim_time'
		TRUNCATE TABLE bronze.dim_time;
		PRINT '>> Inserting Data Into: bronze.dim_time';
		BULK INSERT bronze.dim_time
		FROM 'C:\Desktop\Data Stuffs\Final Year Project\Datasets\Dim_Time.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------';

		PRINT '--------------------------------------------------';
		PRINT 'Loading Fact_Performance Tables';
		PRINT '--------------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating Tables: bronze.fact_performance'
		TRUNCATE TABLE bronze.fact_performance;
		PRINT '>> Inserting Data Into: bronze.fact_performance';
		BULK INSERT bronze.fact_performance
		FROM 'C:\Desktop\Data Stuffs\Final Year Project\Datasets\Fact_Performance.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------';

		SET @batch_end_time = GETDATE();
		PRINT '=================================================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '-Total Load Duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + 'seconds';
		PRINT '=================================================================';
	END TRY
	BEGIN CATCH
		PRINT '=================================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=================================================================';
	END CATCH
END
