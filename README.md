![Data Career](data-career-salary.jpg)
# Data Science Jobs & Salaries: Querying and Cleaning Data with SQL

A SQL project on a dataset of data-related job listings. It covers filtering, sorting and aggregating job and salary data (Questions 1–7), then cleaning the data with `UPDATE` and `DELETE` statements (Questions 8–10).

## Dataset

A single `jobs` table in a MySQL schema (`mission3`) with **9,355 records** and **12 columns**, covering work years 2020–2023.

| Column | Description |
|---|---|
| `work_year` | Year of the record |
| `job_title`, `job_category` | Job title (125 distinct) and its category |
| `salary_currency`, `salary` | Salary in the original currency |
| `salary_in_usd` | Salary converted to US dollars |
| `employee_residence`, `company_location` | Country of the employee and of the company |
| `experience_level` | Entry-level, Mid-level, Senior, Executive |
| `employment_type` | Full-time, Part-time, Contract, Freelance |
| `work_setting` | Remote, Hybrid, In-person |
| `company_size` | S, M, L |

## Tools

MySQL (MySQL Workbench syntax) and Excel, where the result of each query was saved.

## Part 1: Querying the data (Q1–Q7)

| # | Question | Techniques | Rows returned |
|---|---|---|---|
| 1 | All job titles with their USD salaries | `SELECT`, `ORDER BY` | 9,355 |
| 2 | Data Scientist / Data Analyst jobs with work year and salary | `WHERE ... IN (...)` | 3,377 |
| 3 | Senior, full-time employees | `WHERE ... AND ...` | 6,701 |
| 4 | Jobs paying more than $100,000 USD | comparison operator, `ORDER BY ... DESC` | 7,239 |
| 5 | Remote jobs at companies in the United States | multiple conditions | 2,917 |
| 6 | Senior employees at large (L) companies | multiple conditions | 459 |
| 7 | Average USD salary per job title | `AVG()`, `GROUP BY`, `FORMAT()` | 125 |

```sql
-- Q7: average salary per job title
SELECT job_title, FORMAT(AVG(salary_in_usd), 0) AS avg_salary_in_usd
FROM jobs
GROUP BY job_title
ORDER BY AVG(salary_in_usd) DESC;
```

## Part 2: Cleaning the data (Q8–Q10)

| # | Task | Statement |
|---|---|---|
| 8 | Records marked part-time but with a salary above $50,000 should be full-time | `SELECT` with `LIKE 'P%T%'`, then `UPDATE` |
| 9 | Missing or "Unknown" job titles should become "Data Specialist" | `SELECT` with `IS NULL`, then `UPDATE` |
| 10 | Remove records with a salary below $70,000 | `SELECT` to preview, then `DELETE` |

Each change was previewed with a `SELECT` using the same `WHERE` clause before it was run.

## Key Findings

### Salary overview
- The dataset has 9,355 records, and **77% pay more than $100,000** (7,239 records).
- USD salaries range from **$15,000 to $450,000**, with a mean of about **$150,300** and a median of **$143,000**.
- **Four titles make up 70% of the records:** Data Engineer (2,195), Data Scientist (1,989), Data Analyst (1,388) and Machine Learning Engineer (991).

### Experience, location and work setting
- **Senior full-time roles dominate**: 6,701 records (72% of the dataset).
- **High pay is concentrated in the United States**: 6,791 of the 7,239 jobs above $100,000 (94%) are at US companies. The highest salary is **$450,000** (Research Scientist, United States).
- Remote US jobs (2,917) are almost all at **medium-sized companies** (2,707, or 93%), with only 165 at large and 45 at small companies.
- Senior roles at large companies (459) are also mostly in the US (402, or 88%).

### Data Scientist vs Data Analyst (Q2)
Average salaries per work year (in the salary's original currency, mostly USD):

| Year | Data Scientist | Data Analyst |
|---|---|---|
| 2020 | 86,174 (19 records) | 58,500 (6 records) |
| 2021 | 91,260 (34) | 81,445 (19) |
| 2022 | 138,197 (398) | 107,969 (272) |
| 2023 | 163,433 (1,538) | 110,282 (1,091) |

Both roles show rising salaries. In 2023, Data Scientists average about 48% more than Data Analysts. The 2020 and 2021 averages rest on very few records.

### Salary by job title (Q7)
- Highest average: **Analytics Engineering Manager ($399,880)**, then Data Science Tech Lead ($375,000) and Managing Director Data Science ($300,000).
- Lowest average: **Compliance Data Analyst ($45,000)**, then Insight Analyst ($47,674) and Machine Learning Specialist ($55,000).
- **Be careful with the extremes:** 14 of the 125 titles have only one record and 47 have three or fewer. The top three averages each come from a single record.

### Cleaning results
- **Q8:** 10 part-time records had a salary above 50,000, up to 180,000 (see the currency problem below).
- **Q9:** the check returned **0 rows**, so there are no missing or "Unknown" titles and the `UPDATE` changes nothing.
- **Q10:** **788 records (8.4%)** have a USD salary below $70,000. They average about $51,100 and are mostly 2023 records (476), mid-level (336), senior (244) and full-time (760).

## Issues Found and Fixed

1. **Q8 used `salary` (local currency) instead of `salary_in_usd`.** Three of the 10 records returned are not above $50,000 at all: 180,000 DKK is about $28,600, 120,000 DKK about $19,100 and 78,000 PLN about $18,200. The `UPDATE` would have wrongly made them full-time. The verify query used `salary_in_usd`, so it didn't match the `UPDATE`. All three now use `salary_in_usd`.
2. **The transaction was empty.** `START TRANSACTION; COMMIT; ROLLBACK;` had nothing between them, and the `UPDATE` ran afterwards, outside any transaction, so it could not be rolled back. Each change now runs inside `START TRANSACTION ... COMMIT`.
3. **Safe update mode was switched on after the first `UPDATE`.** `SET SQL_SAFE_UPDATES = 1` makes MySQL Workbench block `UPDATE` and `DELETE` statements that don't filter on a key column, so the Q9 `UPDATE` and Q10 `DELETE` would fail with error 1175. It is now set to `0` before the changes and back to `1` at the end.
4. **Q5 asks for salaries in USD** but selected `salary`. It now selects `salary_in_usd`.
5. **No `USE mission3;`** after creating the schema. Added.
6. **No backup before a permanent `DELETE`.** A `jobs_backup` copy is now created first.

## Limitations
- **Mixed currencies.** `salary` is in 11+ currencies (USD, EUR, GBP, CAD, PLN, DKK and others), so it can't be compared or averaged across rows. Use `salary_in_usd` for any salary comparison. Q2 and Q6 still select `salary`, so their figures should be read as approximate.
- **Possible duplicates.** The table has no ID column, and 167 of the 788 records returned in Q10 are identical in every column. They may be genuine separate records or duplicates, so check before drawing conclusions.
- **Small groups.** Many job titles and the early work years (2020–2021) have very few records, so their averages are unreliable. The data is also heavily weighted to 2022–2023.
- **Deleting low salaries (Q10) changes the data.** After the `DELETE`, every later statistic describes only the higher-paid 92%, so the average salaries are overstated. This is why a backup matters.
- **No time or cost-of-living adjustment.** Salaries from different years and countries are compared as they are.

## Possible Improvements
- Use `salary_in_usd` consistently and add `COUNT(*)` next to every average (and `HAVING COUNT(*) >= 10`).
- Check for duplicate rows with `GROUP BY` all columns `HAVING COUNT(*) > 1`.
- Add a **salary comparison by experience level, company size and work setting**, and by year, to explain what drives pay.
- Add a simple percentile or median analysis (MySQL window functions) because the averages are pulled up by a few very high salaries.
- Keep cleaning separate from analysis: use a `WHERE` filter or a view instead of deleting rows, so no data is lost.
- Visualise the results (Excel, Power BI or Python): average salary by job title, by year and by country.
