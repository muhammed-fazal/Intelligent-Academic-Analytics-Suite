/* ===========================================================================================================
DDL Script: Create Silver Tables
===========================================================================================================
Script Purpose:
Defines the schema for the Silver layer.
Changes from Bronze:
  - Adds Primary Keys.
  - Changes Credits from INT to DECIMAL (to handle 1.5 credits).
  - Adds Enriched columns (e.g., enrollment_year).
===========================================================================================================
*/

-- 1. Silver Department
IF OBJECT_ID('silver.dim_department', 'U') IS NOT NULL DROP TABLE silver.dim_department;
CREATE TABLE silver.dim_department(
    dept_id                 NVARCHAR(50) NOT NULL PRIMARY KEY,
    dept_name               NVARCHAR(100), -- Increased size for safety
    hod_name                NVARCHAR(100),
    total_intake_capacity   INT,
    inserted_date           DATETIME DEFAULT GETDATE()
);

-- 2. Silver Course
IF OBJECT_ID('silver.dim_course', 'U') IS NOT NULL DROP TABLE silver.dim_course;
CREATE TABLE silver.dim_course(
    course_id      NVARCHAR(50) NOT NULL PRIMARY KEY,
    course_name    NVARCHAR(100),
    credits        DECIMAL(3,1), -- FIXED: Changed from INT to DECIMAL to support 1.5 credits
    course_type    NVARCHAR(50),
    dept_id        NVARCHAR(50),
    inserted_date  DATETIME DEFAULT GETDATE()
);

-- 3. Silver Student
IF OBJECT_ID('silver.dim_student', 'U') IS NOT NULL DROP TABLE silver.dim_student;
CREATE TABLE silver.dim_student(
    student_id          NVARCHAR(50) NOT NULL PRIMARY KEY,
    full_name           NVARCHAR(100),
    gender              NVARCHAR(10),  -- Standardized to Male/Female
    dept_id             NVARCHAR(50),
    batch_year          NVARCHAR(50),
    enrollment_year     INT,           -- ENRICHMENT: Extracted from batch_year
    graduation_year     INT,           -- ENRICHMENT: Extracted from batch_year
    high_school_gpa     DECIMAL(4,2),
    commute_distance_km DECIMAL(10,2),
    inserted_date       DATETIME DEFAULT GETDATE()
);

-- 4. Silver Time
IF OBJECT_ID('silver.dim_time', 'U') IS NOT NULL DROP TABLE silver.dim_time;
CREATE TABLE silver.dim_time(
    term_id        NVARCHAR(50) NOT NULL PRIMARY KEY,
    academic_year  NVARCHAR(50),
    start_year     INT,            -- ENRICHMENT
    end_year       INT,            -- ENRICHMENT
    term_type      NVARCHAR(20),   -- Standardized (Odd/Even)
    inserted_date  DATETIME DEFAULT GETDATE()
);

-- 5. Silver Fact Performance
IF OBJECT_ID('silver.fact_performance', 'U') IS NOT NULL DROP TABLE silver.fact_performance;
CREATE TABLE silver.fact_performance(
    transaction_id         NVARCHAR(50) NOT NULL PRIMARY KEY,
    student_id             NVARCHAR(50),
    course_id              NVARCHAR(50),
    term_id                NVARCHAR(50),
    internal_marks         INT,
    external_marks         INT,
    total_marks            INT,
    grade_point            INT,
    result_status          NVARCHAR(20),
    attendance_percentage  INT,
    is_valid_data          BIT DEFAULT 1, -- DATA QUALITY FLAG
    inserted_date          DATETIME DEFAULT GETDATE()
);
