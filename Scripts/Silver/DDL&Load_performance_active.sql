/* ===========================================================================================================
2. SILVER LAYER: Create Table and Apply Transformations
===========================================================================================================
*/

-- Create the Silver Table
IF OBJECT_ID('silver.fact_active', 'U') IS NOT NULL 
    DROP TABLE silver.fact_active;
GO

CREATE TABLE silver.fact_active(
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
GO

-- Transform and Insert Data from Bronze to Silver
INSERT INTO silver.fact_active (
    transaction_id, student_id, course_id, term_id, 
    internal_marks, external_marks, total_marks, 
    grade_point, result_status, attendance_percentage, is_valid_data
)
SELECT 
    TRIM(transaction_id),
    TRIM(student_id),
    TRIM(course_id),
    TRIM(term_id),
    CAST(internal_marks AS INT),
    CAST(external_marks AS INT),
    
    -- Enrichment / Cleaning: Recalculate Total to ensure data integrity
    (ISNULL(CAST(internal_marks AS INT), 0) + ISNULL(CAST(external_marks AS INT), 0)) AS total_marks, 
    
    CAST(grade_point AS INT),
    TRIM(result_status),
    CAST(attendance_percentage AS INT),
    
    -- Data Quality Check: Flag rows where logic is broken
    CASE 
        -- If the summed marks don't match the raw total marks, flag it as invalid (0)
        WHEN (CAST(internal_marks AS INT) + CAST(external_marks AS INT)) <> CAST(total_marks AS INT) THEN 0 
        -- Negative marks are impossible, flag as invalid (0)
        WHEN CAST(internal_marks AS INT) < 0 OR CAST(external_marks AS INT) < 0 THEN 0         
        ELSE 1 
    END AS is_valid_data

FROM bronze.fact_active;
GO

PRINT 'Silver Fact Active Transformation and Load Complete!';
