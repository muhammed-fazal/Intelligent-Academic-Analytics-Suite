/* 
==========================================================================================================
DDL Script: Create Bronze Tables
==========================================================================================================
Script Purpose:
This script create tables in the 'bronze' schema dropping existing tables
if they already exists.
Run this script to re-define the DDL structure of 'bronze' Tables
==========================================================================================================
*/

IF OBJECT_ID('bronze.dim_department' , 'U') IS NOT NULL
	DROP TABLE bronze.dim_department;
CREATE TABLE bronze.dim_department(
	dept_id					NVARCHAR(50),
	dept_name				NVARCHAR(50),
	hod_name				NVARCHAR(50),
	total_intake_capacity	INT
);

IF OBJECT_ID('bronze.dim_course' , 'U') IS NOT NULL
	DROP TABLE bronze.dim_course;
CREATE TABLE bronze.dim_course(
	course_id	  NVARCHAR(50),
	course_name	NVARCHAR(50),
	credits		  INT,
	course_type	NVARCHAR(50),
	dept_id		  NVARCHAR(50)
);

IF OBJECT_ID('bronze.dim_student' , 'U') IS NOT NULL
	DROP TABLE bronze.dim_student;
CREATE TABLE bronze.dim_student(
	student_id				NVARCHAR(50),
	full_name				  NVARCHAR(50),
	gender					  NVARCHAR(50),
	dept_id					  NVARCHAR(50),
	batch_year				NVARCHAR(50),
	high_school_gpa		DECIMAL(3,2),
	commute_distance_km		DECIMAL(10,2), 
	create_date				    DATE
);

IF OBJECT_ID('bronze.dim_time' , 'U') IS NOT NULL
	DROP TABLE bronze.dim_time;
CREATE TABLE bronze.dim_time(
	term_id			  NVARCHAR(50),
	academic_year	NVARCHAR(50),
	term_type		  NVARCHAR(50)
);

IF OBJECT_ID('bronze.fact_performance' , 'U') IS NOT NULL
	DROP TABLE bronze.fact_performance;
CREATE TABLE bronze.fact_performance(
	transaction_id		NVARCHAR(50),
	student_id				NVARCHAR(50),
	course_id				  NVARCHAR(50),
	term_id					  NVARCHAR(50),
	internal_marks		INT,
	external_marks		INT,
	total_marks				INT,
	grade_point				INT,
	result_status			NVARCHAR(50),
	attendance_percentage	INT
);
