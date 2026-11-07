# 📊 Data Science Salary Insights Dashboard
## 🖥️ Live Dashboard Preview
*A high-fidelity interactive dashboard built with custom Canva Soft UI containers and fully optimized DAX measures inside Power BI:*

<img width="871" height="508" alt="powerbi-dashboard-visual" src="https://github.com/user-attachments/assets/988c26f8-77a5-4b64-9111-3030a20b3a6d" />

---


An end-to-end data analytics and business intelligence project. This project covers everything from raw database staging, cleaning, and window-function EDA in **MySQL/MariaDB**, complex data modeling via **Power Query**, to custom **Canva Soft UI design** and backend **DAX Studio performance tuning**.

---

## 🛠️ Project Architecture & Workflow

### 1. 🗄️ Database Ingestion & ETL (MySQL/MariaDB)
* **Staging Strategy:** To protect data integrity, a separate `ds_salaries_staging` table was engineered to safely perform sanitization without altering raw logs.
* **Data Standardization:** Converted cryptic shorthand values (e.g., *MI, SE, FT, L, M, 0, 100*) into descriptive corporate-grade labels (*Mid_Level, Senior_Level, Full_Time, Large, On_site, Remote*) using SQL `CASE` statements.
* **Typing Fixes:** Altered structural field properties (e.g., transforming `work_year` into `VARCHAR`) to block unwanted automatic formatting like default numeric comma separators in frontend tools.

#### 📝 Core Data Cleaning & EDA Queries Used:
```sql
-- 1. Standardizing Cryptic Source Codes to Full Professional Names
UPDATE ds_salaries_staging
SET experience_level = CASE 
    WHEN experience_level = 'MI' THEN 'Mid_Level'
    WHEN experience_level = 'SE' THEN 'Senior_Level'
    WHEN experience_level = 'EN' THEN 'Entry_Level'
    WHEN experience_level = 'EX' THEN 'Executive_Level'
    ELSE 'UNKNOWN'
END;
-- 1. Advanced EDA: Total Salary Growth & Rolling Total Over the Years (Window Function)
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

-- 2. Advanced EDA: Fetching Top 3 Highest Paid Job Titles Per Year using Window Functions
WITH avg_salary_cte AS (
    SELECT work_year AS `year`, job_title, AVG(salary_in_usd) AS avg_salary
    FROM ds_salaries_staging
    GROUP BY work_year, job_title
),
salary_ranking AS (
    SELECT `year`, job_title, avg_salary,
           DENSE_RANK() OVER (PARTITION BY `year` ORDER BY avg_salary DESC) AS ranking
    FROM avg_salary_cte
)
SELECT * FROM salary_ranking WHERE ranking <= 3 ORDER BY `year` ASC, ranking ASC;
```

---

### 2. 🧩 Data Modeling & Schema Transformation (Power Query)
* **Star Schema Architecture:** Deconstructed the staging source table into a high-performance analytics structure containing **1 Fact Table** and **4 Dimension Tables**.
* **Referential Integrity (RI) Re-Engineering:** 
  An active **RI Violation (Value: 1)** inside the `dim_company` relationship model was detected via VertiPaq Analyzer. To completely resolve it without schema bloating:
  1. Isolated and merged `company_size`, `company_location`, and `remote_ratio` using `Ctrl` in Power Query.
  2. Generated a unified, robust composite surrogate key called **`company_key`** across both layers.
  3. Dropped the redundant standalone columns from `dim_company` to maintain an enterprise-grade lightweight metadata footprint, reducing the violation count to exactly **0**.
#### 📐 Optimized Data Model (Star Schema View)
*The re-engineered data model showcasing 1-to-Many relationships and clean cross-filtering streams built inside Power BI:*

<img width="998" height="510" alt="star schema" src="https://github.com/user-attachments/assets/48ac3adf-922d-4c28-89cc-b2b9638d0132" />

---

## ⚙️ Core DAX Measures & Business Logic

The backend business formulas constructed to run the executive visual KPI metrics are detailed below:

* **Total Employees Count:**
  ```dax
  total_employees = COUNTROWS(fact_salaries)
  ```
* **Average Normalized Salary (USD):**
  ```dax
  average_salary_usd = AVERAGE(fact_salaries[salary_in_usd])
  ```
* **Senior-Level Workforce Distribution:**
  ```dax
  senior_level_employees = CALCULATE([total_employees], dim_experience[experience_level]="Senior_Level")
  ```
* **Salary Variance (Gap):**
  ```dax
  salary_gap = MAX(fact_salaries[salary_in_usd]) - [average_salary_usd]
  ```

---

## 🎨 UI/UX Layout & Visualization (Canva + Power BI)

* **Soft UI Structure:** A layout grid was custom-built inside **Canva** deploying minimalist micro-shadow container cards for clean data containment.
* **Visual Polish:** Imported the high-res canvas into Power BI and turned off native borders and visual backgrounds to deliver an organic interface.
* **Slicer Overhaul:** Converted outdated vertical list objects into a modern, 3-row grid **Button Slicer** specifically for `Work Year` selection to fit cleanly inside the sidebar layout.

---

## 📊 Performance Tuning & Query Validations

### 📐 1. VertiPaq Metrics (Data Structure Audit)
*Audited using DAX Studio to certify ideal memory compression and confirm the zero-error resolution of structural database anomalies.*

<img width="794" height="188" alt="dax-studio-metrics" src="https://github.com/user-attachments/assets/52661abc-86f7-42d9-9b8b-a5f5146cfbb8" />

*Figure 1: Clean VertiPaq Analyzer layout indicating fully optimized database structures.*

### 💻 2. Advanced Query Execution & Rounding Tuning
*Validating pipeline aggregation latency and verifying floating-point evaluation string restrictions via `ROUND(AVERAGE(...), 2)` to standard dual-decimal corporate outputs.*

<img width="807" height="499" alt="dax-query-results" src="https://github.com/user-attachments/assets/6340d11f-b2c8-41d3-b915-6a31a73c8ef6" />

*Figure 2: Verified query execution testing cross-filtering responses.*

---

## 🧰 Tech Stack Used
* **MariaDB / MySQL Server** — Source staging, parsing, data transformation, and Windows-based EDA
* **Power BI Desktop** — Composite surrogate key engineering, Star Schema design, and advanced UI design
* **Canva** — High-fidelity Soft UI background container schemas
* **DAX Studio** — VertiPaq engine metric compression audits & core execution testing
