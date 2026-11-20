CREATE SCHEMA IF NOT EXISTS mission3;
USE mission3;   -- added: make sure the queries run against the mission3 schema

SELECT * FROM jobs;

-- Question 1
SELECT job_title, salary_in_usd FROM jobs ORDER BY job_title;

-- Question 2
SELECT job_title, work_year, salary FROM jobs WHERE job_title IN ('Data Scientist', 'Data Analyst') ORDER BY work_year;

-- Question 3
SELECT job_title, experience_level, employment_type FROM jobs WHERE experience_level = 'Senior' AND employment_type = 'Full-time' ORDER BY job_title;

-- Question 4
SELECT job_title, company_location, salary_in_usd FROM jobs WHERE salary_in_usd > 100000 ORDER BY salary_in_usd DESC;

-- Question 5 (changed: the question asks for salaries in USD, so salary_in_usd is used instead of salary)
SELECT job_title, company_size, salary_in_usd FROM jobs WHERE company_location = 'United States' AND work_setting = 'Remote' ORDER BY company_size;

-- Question 6
SELECT job_title, company_location, salary FROM jobs WHERE experience_level = 'Senior' AND company_size = 'L' ORDER BY job_title;

-- Question 7
SELECT job_title, FORMAT(AVG(salary_in_usd), 0) AS avg_salary_in_usd FROM jobs GROUP BY job_title ORDER BY AVG(salary_in_usd) DESC;

-- Question 7 (optional extra): many titles have only 1-3 records, so also show how many records each average is based on
SELECT job_title, COUNT(*) AS records, FORMAT(AVG(salary_in_usd), 0) AS avg_salary_in_usd
FROM jobs GROUP BY job_title HAVING COUNT(*) >= 10 ORDER BY AVG(salary_in_usd) DESC;


-- ---------------------------------------------------------------------------
-- DATA CLEANING (Questions 8 - 10) - these statements change the data
-- ---------------------------------------------------------------------------

-- Safety copy of the table, so the changes below can be undone
CREATE TABLE jobs_backup AS SELECT * FROM jobs;

-- Safe update mode blocks UPDATE/DELETE statements that do not filter on a key column.
-- Turn it OFF before the changes and back ON afterwards (in the original it was switched on after the first UPDATE).
SET SQL_SAFE_UPDATES = 0;

-- Question 8: part-time records with a salary above $50,000 should be full-time
-- (changed: salary_in_usd is used everywhere, because "salary" is in many different currencies,
--  e.g. 180,000 DKK is only about $28,600)
SELECT job_title, employment_type, salary_in_usd FROM jobs WHERE employment_type LIKE 'P%T%' AND salary_in_usd > 50000 ORDER BY salary_in_usd DESC;

START TRANSACTION;
-- Change employment type from 'Part-time' to 'Full-time'
UPDATE jobs SET employment_type = 'Full-time' WHERE employment_type = 'Part-time' AND salary_in_usd > 50000;

-- Verify the update (should return 0 rows)
SELECT * FROM jobs WHERE employment_type = 'Part-time' AND salary_in_usd > 50000;
COMMIT;      -- use ROLLBACK; instead if the check above is not what you expected

-- Question 9: missing or 'Unknown' job titles
SELECT * FROM jobs WHERE job_title IS NULL OR job_title = '' OR job_title = 'Unknown';

START TRANSACTION;
-- Change job title to 'Data Specialist' (the SELECT above returned 0 rows, so this changes nothing on this dataset)
UPDATE jobs SET job_title = 'Data Specialist' WHERE job_title IS NULL OR job_title = '' OR job_title = 'Unknown';
COMMIT;

-- Question 10: delete records with a salary below $70,000
SELECT COUNT(*) AS rows_to_delete FROM jobs WHERE salary_in_usd < 70000;
SELECT * FROM jobs WHERE salary_in_usd < 70000 ORDER BY salary_in_usd DESC;

START TRANSACTION;
DELETE FROM jobs WHERE salary_in_usd < 70000;
SELECT COUNT(*) AS rows_left FROM jobs;
COMMIT;      -- use ROLLBACK; instead to undo the delete (or restore from jobs_backup)

-- Turn safe update mode back ON
SET SQL_SAFE_UPDATES = 1;
