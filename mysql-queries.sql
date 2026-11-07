
-- PROJECT: DATA SCIENCE SALARIES - DATA CLEANING & EDA
-- AUTHOR: DATA ANALYST PRO
-- DESCRIPTION: Cleaning raw data and performing Exploratory Data Analysis

USE world_layoffs;

-- --------------------------------------------------------------------
-- STEP 1: STAGING (Creating a backup table to work safely)
-- --------------------------------------------------------------------
DROP TABLE IF EXISTS ds_salaries_staging;

CREATE TABLE ds_salaries_staging
LIKE ds_salaries;

INSERT INTO ds_salaries_staging
SELECT * FROM ds_salaries;

-- STEP 2: REMOVE DUPLICATES (Identifying duplicate rows)

WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER( 
            PARTITION BY id, work_year, experience_level, employment_type, 
                         job_title, salary, salary_currency, salary_in_usd, 
                         employee_residence, remote_ratio, company_location, company_size
        ) AS row_num
    FROM ds_salaries_staging
)
SELECT * 
FROM duplicate_cte 
WHERE row_num > 1; -- Returns empty if dataset is already unique

-- STEP 3: DATA STANDARDIZATION & CLEANING
-- 1. Trimming spaces from Job Titles

UPDATE ds_salaries_staging
SET job_title = TRIM(job_title);

-- 2. Modifying work_year to text to avoid automatic comma separators 
ALTER TABLE ds_salaries_staging MODIFY work_year VARCHAR(50);

-- 3. Standardizing Experience Level codes to full names

UPDATE ds_salaries_staging
SET experience_level = CASE 
    WHEN experience_level = 'MI' THEN 'Mid_Level'
    WHEN experience_level = 'SE' THEN 'Senior_Level'
    WHEN experience_level = 'EN' THEN 'Entry_Level'
    WHEN experience_level = 'EX' THEN 'Executive_Level'
    ELSE 'UNKNOWN'
END;

-- 4. Standardizing Remote Ratio codes to professional status strings
ALTER TABLE ds_salaries_staging MODIFY remote_ratio VARCHAR(50);

UPDATE ds_salaries_staging
SET remote_ratio = CASE
    WHEN remote_ratio = '0' THEN 'On_site'
    WHEN remote_ratio = '50' THEN 'Hybrid'
    WHEN remote_ratio = '100' THEN 'Remote'
    ELSE 'Unknown'
END;

-- 5. Standardizing Employment Type codes to full names
UPDATE ds_salaries_staging
SET employment_type = CASE
    WHEN employment_type = 'FT' THEN 'Full_Time'
    WHEN employment_type = 'CT' THEN 'Contract'
    WHEN employment_type = 'PT' THEN 'Part_Time'
    WHEN employment_type = 'FL' THEN 'Freelance'
    ELSE 'Unknown'
END;

-- 6. Standardizing Company Size codes to full names
UPDATE ds_salaries_staging
SET company_size = CASE
    WHEN company_size = 'L' THEN 'Large'
    WHEN company_size = 'M' THEN 'Medium'
    WHEN company_size = 'S' THEN 'Small'
    ELSE 'Unknown'
END;


-- STEP 4: EXPLORATORY DATA ANALYSIS (EDA) WITH WINDOW FUNCTIONS
-- Question 1: Total Salary growth and its Rolling Total over the years

WITH salary_year AS (
    SELECT 
        work_year AS `year`,
        SUM(salary_in_usd) AS total_salary
    FROM ds_salaries_staging
    WHERE work_year IS NOT NULL
    GROUP BY work_year
)
SELECT 
    `year`,
    total_salary,
    SUM(total_salary) OVER(ORDER BY `year` ASC) AS rolling_total_salary
FROM salary_year;

-- Question 2: Top 3 Highest Paid Job Titles Per Year based on Average Salary

WITH avg_salary_cte AS (
    SELECT
        work_year AS `year`,
        job_title,
        AVG(salary_in_usd) AS avg_salary
    FROM ds_salaries_staging
    GROUP BY work_year, job_title
),
salary_ranking AS (
    SELECT 
        `year`,
        job_title,
        avg_salary,
        DENSE_RANK() OVER (PARTITION BY `year` ORDER BY avg_salary DESC) AS ranking
    FROM avg_salary_cte
)
SELECT *
FROM salary_ranking
WHERE ranking <= 3
ORDER BY `year` ASC, ranking ASC;
