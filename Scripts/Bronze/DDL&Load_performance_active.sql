/* ===========================================================================================================
1. BRONZE LAYER: Create and Load fact_active
===========================================================================================================
*/

-- Create the Bronze Table
IF OBJECT_ID('bronze.fact_active', 'U') IS NOT NULL
	DROP TABLE bronze.fact_active;
GO

CREATE TABLE bronze.fact_active(
	transaction_id		    NVARCHAR(50),
	student_id				NVARCHAR(50),
	course_id				NVARCHAR(50),
	term_id					NVARCHAR(50),
	internal_marks		    NVARCHAR(50), -- Kept as NVARCHAR to handle bad raw data gracefully
	external_marks		    NVARCHAR(50),
	total_marks				NVARCHAR(50),
	grade_point				NVARCHAR(50),
	result_status			NVARCHAR(50),
	attendance_percentage	NVARCHAR(50)
);
GO

-- Load the Data (Update the file path to match your local machine)
BULK INSERT bronze.fact_active
FROM 'C:\Desktop\Data Stuffs\Final Year Project\Datasets\Fact_Active.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,          -- Skips the CSV header row
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

PRINT 'Bronze Fact Active Load Complete!';
