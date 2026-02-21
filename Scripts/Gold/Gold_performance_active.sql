/*
===========================================================================================================
DDL Script: Create Gold Active Fact View
===========================================================================================================
Script Purpose:
    Creates the gold.fact_active view for currently enrolled students.
    Enriches data with the Is_At_Risk_Flag for the Mentor/HOD Operational Dashboard.
===========================================================================================================
*/

IF OBJECT_ID('gold.fact_active', 'V') IS NOT NULL DROP VIEW gold.fact_active;
GO

CREATE VIEW gold.fact_active AS
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
    
    -- Letter Grade Transformation (Maintains consistency with historical data)
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
    
    -- =========================================================
    -- CORE OBJECTIVE: Early Intervention & At-Risk Flag
    -- =========================================================
    CASE 
        WHEN attendance_percentage < 75 OR internal_marks < 25 THEN 1 
        ELSE 0 
    END                     AS [Is_At_Risk_Flag],
    
    -- Standard Business Logic / Derived Flags
    CASE 
        WHEN result_status = 'Pass' THEN 1 
        ELSE 0 
    END                     AS [Is_Passed_Flag],
    
    CASE 
        WHEN result_status = 'Fail' THEN 1 
        ELSE 0 
    END                     AS [Is_Failed_Flag]

FROM silver.fact_active
WHERE is_valid_data = 1; -- Ensures only clean data reaches Power BI
GO

PRINT 'Gold Active Fact View Created Successfully!';
