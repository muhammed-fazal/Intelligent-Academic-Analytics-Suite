/* 
=============================================================================================
Stored Procedure: Load Silver Layer (bronze->silver)
=============================================================================================
Script Purpose:
	This stored procedure performs the ETL (Extract, Transform, Load) process to
	populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
	-Truncates silver tables
	-Insert transformed and cleaned data from bronze into Silver tables.
	-Performs data cleaning, standardization, and enrichment.
Parameters:
	None.
	This stored Procedure does not accept any parameters or return any values.

Usage Example:

	EXEC silver.load_silver;

===========================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
	DECLARE @start_time DATETIME , @end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '==================================================';
		PRINT 'Loading Silver Layer';
		PRINT '==================================================';

		PRINT '--------------------------------------------------';
		PRINT 'Loading Department Tables';
		PRINT '--------------------------------------------------';
		SET @start_time = GETDATE();
PRINT '>> Truncating Table: silver.dim_department';
TRUNCATE TABLE silver.dim_department;
PRINT '>> Inserting Data Into:silver.dim_department';
INSERT INTO silver.dim_department (dept_id, dept_name, hod_name, total_intake_capacity)
SELECT 
    TRIM(dept_id),                          -- Standardization: Remove whitespace
    TRIM(dept_name),                        -- Standardization: Remove whitespace
    CASE 
        WHEN hod_name IS NULL OR hod_name = '' THEN 'Unassigned' 
        ELSE TRIM(hod_name) 
    END,                                    -- Cleaning: Handle missing HOD names
    CAST(total_intake_capacity AS INT)
FROM bronze.dim_department;
	SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------';

        PRINT '--------------------------------------------------';
		PRINT 'Loading Course Tables';
		PRINT '--------------------------------------------------';
SET @start_time = GETDATE();
PRINT '>> Truncating Table: silver.dim_course';
TRUNCATE TABLE silver.dim_course;
PRINT '>> Inserting Data Into:silver.dim_course';
INSERT INTO silver.dim_course (course_id, course_name, credits, course_type, dept_id)
SELECT 
    TRIM(course_id),
    TRIM(course_name),
    CAST(credits AS DECIMAL(3,1)),          -- Standardization: Ensure correct decimal type
    UPPER(TRIM(course_type)),               -- Standardization: Standardize 'Core' to 'CORE'
    TRIM(dept_id)
FROM bronze.dim_course;

SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------';

        PRINT '--------------------------------------------------';
		PRINT 'Loading Student Tables';
		PRINT '--------------------------------------------------';
SET @start_time = GETDATE();
PRINT '>> Truncating Table: silver.dim_student';
TRUNCATE TABLE silver.dim_student;
PRINT '>> Inserting Data Into:silver.dim_student';
INSERT INTO silver.dim_student (
    student_id, full_name, gender, dept_id, batch_year, 
    enrollment_year, graduation_year, high_school_gpa, commute_distance_km
)
SELECT 
    TRIM(student_id),
    TRIM(full_name),
    -- Standardization: Ensure consistent Gender naming
    CASE 
        WHEN UPPER(gender) IN ('M', 'MALE') THEN 'Male'
        WHEN UPPER(gender) IN ('F', 'FEMALE') THEN 'Female'
        ELSE 'Unknown'
    END,
    TRIM(dept_id),
    batch_year,
    -- Enrichment: Split "2021-2025" into separate integers
    CAST(LEFT(batch_year, 4) AS INT) AS enrollment_year,
    CAST(RIGHT(batch_year, 4) AS INT) AS graduation_year,
    high_school_gpa,
    ABS(commute_distance_km) -- Cleaning: Ensure no negative distances
FROM bronze.dim_student;
SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------';

        PRINT '--------------------------------------------------';
		PRINT 'Loading Time Tables';
		PRINT '--------------------------------------------------';
SET @start_time = GETDATE();
PRINT '>> Truncating Table: silver.dim_time';
TRUNCATE TABLE silver.dim_time;
PRINT '>> Inserting Data Into:silver.dim_time';
INSERT INTO silver.dim_time (term_id, academic_year, start_year, end_year, term_type)
SELECT 
    TRIM(term_id),
    TRIM(academic_year),
    -- Enrichment: Split "2021-2022" into start and end years
    CAST(LEFT(academic_year, 4) AS INT),
    CAST(RIGHT(academic_year, 4) AS INT),
    TRIM(term_type)
FROM bronze.dim_time;

SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------';

        PRINT '--------------------------------------------------';
		PRINT 'Loading Performance Tables';
		PRINT '--------------------------------------------------';
SET @start_time = GETDATE();
PRINT '>> Truncating Table: silver.fact_performance';
TRUNCATE TABLE silver.fact_performance;
PRINT '>> Inserting Data Into:silver.fact_performance';
INSERT INTO silver.fact_performance (
    transaction_id, student_id, course_id, term_id, 
    internal_marks, external_marks, total_marks, 
    grade_point, result_status, attendance_percentage, is_valid_data
)
SELECT 
    TRIM(transaction_id),
    TRIM(student_id),
    TRIM(course_id),
    TRIM(term_id),
    internal_marks,
    external_marks,
    -- Enrichment / Cleaning: Recalculate Total to ensure data integrity
    (ISNULL(internal_marks, 0) + ISNULL(external_marks, 0)) AS total_marks, 
    grade_point,
    TRIM(result_status),
    attendance_percentage,
    -- Data Quality Check: Flag rows where logic is broken
    CASE 
        WHEN (internal_marks + external_marks) <> total_marks THEN 0 -- Invalid Calculation
        WHEN internal_marks < 0 OR external_marks < 0 THEN 0         -- Negative marks impossible
        ELSE 1 
    END AS is_valid_data
FROM bronze.fact_performance;

SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------';
		PRINT '=================================================================';
		PRINT 'Loading Silver Layer is Completed';
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
