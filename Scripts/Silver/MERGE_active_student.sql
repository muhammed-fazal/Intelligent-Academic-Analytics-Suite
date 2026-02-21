/* =============================================================================
2. SILVER LAYER: Transformation & Merge (Upsert)
=============================================================================
Script Purpose:
    Cleans, standardizes, and enriches data from bronze.dim_student.
    Merges the results into silver.dim_student to prevent duplicate keys.
=============================================================================
*/

MERGE INTO silver.dim_student AS target
USING (
    -- Transformation & Standardization Logic (Same as before)
    SELECT 
        TRIM(student_id) AS student_id,
        TRIM(full_name) AS full_name,
        CASE 
            WHEN UPPER(TRIM(gender)) IN ('M', 'MALE') THEN 'Male'
            WHEN UPPER(TRIM(gender)) IN ('F', 'FEMALE') THEN 'Female'
            ELSE 'Unknown'
        END AS gender,
        TRIM(dept_id) AS dept_id,
        TRIM(batch_year) AS batch_year,
        CAST(LEFT(batch_year, 4) AS INT) AS enrollment_year,
        CAST(RIGHT(batch_year, 4) AS INT) AS graduation_year,
        CAST(high_school_gpa AS DECIMAL(4,2)) AS high_school_gpa,
        ABS(CAST(commute_distance_km AS DECIMAL(10,2))) AS commute_distance_km
    FROM bronze.dim_student
) AS source
ON target.student_id = source.student_id

-- If the student already exists in Silver, update their details
WHEN MATCHED THEN
    UPDATE SET 
        target.full_name = source.full_name,
        target.gender = source.gender,
        target.dept_id = source.dept_id,
        target.batch_year = source.batch_year,
        target.enrollment_year = source.enrollment_year,
        target.graduation_year = source.graduation_year,
        target.high_school_gpa = source.high_school_gpa,
        target.commute_distance_km = source.commute_distance_km,
        target.inserted_date = GETDATE() -- Updates the modified timestamp

-- If the student is brand new (Active 2nd/3rd/4th years), insert them
WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        student_id, full_name, gender, dept_id, batch_year, 
        enrollment_year, graduation_year, high_school_gpa, commute_distance_km
    )
    VALUES (
        source.student_id, source.full_name, source.gender, source.dept_id, source.batch_year, 
        source.enrollment_year, source.graduation_year, source.high_school_gpa, source.commute_distance_km
    );
GO

PRINT 'Silver Student Merge Complete!';
