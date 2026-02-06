/*
===========================================================================================================
DDL Script: Create Gold Views
===========================================================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema)
    ready for Power BI.
    
    1. gold.dim_department
    2. gold.dim_student
    3. gold.dim_course
    4. gold.dim_time
    5. gold.fact_performance (Filters out bad data & adds calculation flags)
===========================================================================================================
*/
-------------------------------------------------------------------------------
-- 1. View: Gold Department
-------------------------------------------------------------------------------
IF OBJECT_ID('gold.dim_department', 'V') IS NOT NULL DROP VIEW gold.dim_department;
GO

CREATE VIEW gold.dim_department AS
SELECT
    dept_id                 AS [Department_ID],
    dept_name               AS [Department_Name],
    hod_name                AS [HOD_Name],
    total_intake_capacity   AS [Intake_Capacity]
FROM silver.dim_department;
GO

/*
===========================================================================================================
DDL Script: Update Gold Student View with CGPA & Percentage
===========================================================================================================
Script Purpose:
    Updates the gold.dim_student view to include academic performance metrics.
    
    Logic:
    1. CGPA = Sum(Grade Point * Credits) / Sum(Total Credits)
    2. Percentage = (CGPA - 0.75) * 10
===========================================================================================================
*/

IF OBJECT_ID('gold.dim_student', 'V') IS NOT NULL DROP VIEW gold.dim_student;
GO

CREATE VIEW gold.dim_student AS

-- 1. Calculate Aggregates per Student (CTE)
WITH Academic_Performance AS (
    SELECT 
        f.student_id,
        -- Weighted Sum: (Grade Point * Credits)
        SUM(f.grade_point * c.credits) AS total_weighted_points,
        -- Total Credits Attempted
        SUM(c.credits) AS total_credits
    FROM silver.fact_performance f
    JOIN silver.dim_course c ON f.course_id = c.course_id
    WHERE f.is_valid_data = 1 -- Only calculate based on valid data
    GROUP BY f.student_id
)

-- 2. Join Aggregates with Student Details
SELECT
    s.student_id            AS [Student_ID],
    s.full_name             AS [Student_Name],
    s.gender                AS [Gender],
    s.dept_id               AS [Department_ID],
    s.batch_year            AS [Batch],
    s.enrollment_year       AS [Enrollment_Year],
    s.graduation_year       AS [Graduation_Year],
    s.high_school_gpa       AS [High_School_GPA],
    s.commute_distance_km   AS [Commute_Distance_KM],
    
    -- NEW COLUMN: CGPA Calculation
    -- Handle division by zero using ISNULL/NULLIF logic
    CAST(
        CASE 
            WHEN perf.total_credits > 0 
            THEN perf.total_weighted_points / perf.total_credits 
            ELSE 0 
        END 
    AS DECIMAL(4,2))        AS [CGPA],

    -- NEW COLUMN: Percentage Calculation
    -- CGPA * 9.5
    CAST(
        CASE 
            WHEN perf.total_credits > 0 THEN (perf.total_weighted_points / perf.total_credits) * 9.5 
            ELSE 0 
        END AS DECIMAL(5,2)
    )                       AS [Percentage]

FROM silver.dim_student s
LEFT JOIN Academic_Performance perf ON s.student_id = perf.student_id;
GO

-------------------------------------------------------------------------------
-- 3. View: Gold Course
-------------------------------------------------------------------------------
IF OBJECT_ID('gold.dim_course', 'V') IS NOT NULL DROP VIEW gold.dim_course;
GO

CREATE VIEW gold.dim_course AS
SELECT
    course_id               AS [Course_ID],
    course_name             AS [Course_Name],
    credits                 AS [Credits],
    course_type             AS [Course_Type], -- Core, Elective, Lab
    dept_id                 AS [Department_ID] -- Foreign Key to Department
FROM silver.dim_course;
GO

-------------------------------------------------------------------------------
-- 4. View: Gold Time
-------------------------------------------------------------------------------
IF OBJECT_ID('gold.dim_time', 'V') IS NOT NULL DROP VIEW gold.dim_time;
GO

CREATE VIEW gold.dim_time AS
SELECT
    term_id                 AS [Term_ID],
    academic_year           AS [Academic_Year],
    start_year              AS [Start_Year],
    end_year                AS [End_Year],
    term_type               AS [Semester_Type], -- Odd/Even
    -- Enrichment: Create a sortable logic for semesters (e.g., 2021-Odd comes before 2021-Even)
    CAST(CONCAT(start_year, CASE WHEN term_type = 'Odd' THEN '01' ELSE '02' END) AS INT) AS [Term_Sort_Order]
FROM silver.dim_time;
GO

-------------------------------------------------------------------------------
-- 5. View: Gold Fact Performance
-------------------------------------------------------------------------------
IF OBJECT_ID('gold.fact_performance', 'V') IS NOT NULL DROP VIEW gold.fact_performance;
GO

CREATE VIEW gold.fact_performance AS
SELECT
    transaction_id          AS [Transaction_ID],
    student_id              AS [Student_ID],
    course_id               AS [Course_ID],
    term_id                 AS [Term_ID],
    
    -- Metrics
    internal_marks          AS [Internal_Marks],
    external_marks          AS [External_Marks],
    total_marks             AS [Total_Marks],
    grade_point             AS [Grade_Point],
    CASE 
        WHEN grade_point = 10 THEN 'O'
        WHEN grade_point = 9  THEN 'A+'
        WHEN grade_point = 8  THEN 'A'
        WHEN grade_point = 7  THEN 'B+'
        WHEN grade_point = 6  THEN 'B'
        WHEN grade_point = 5  THEN 'C'
        ELSE 'F' 
    END                     AS [Grade],
    result_status           AS [Result_Status],
    attendance_percentage   AS [Attendance_Percentage],
    
    -- Business Logic / Derived Metrics for Power BI
    CASE 
        WHEN result_status = 'Pass' THEN 1 
        ELSE 0 
    END                     AS [Is_Passed_Flag], -- Helps calculate Pass % easily
    
    CASE 
        WHEN result_status = 'Fail' THEN 1 
        ELSE 0 
    END                     AS [Is_Failed_Flag]

FROM silver.fact_performance
WHERE is_valid_data = 1; -- CRITICAL: Only expose valid data to the BI tool
GO
