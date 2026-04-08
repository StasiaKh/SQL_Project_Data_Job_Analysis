# Introduction
This project analyzes the data analyst job market using SQL — identifying top-paying roles, the most in-demand skills, and the overlap between the two. 

As someone actively transitioning into data analytics, I wanted a practical answer to a real question: which skills actually matter, and which ones pay?

🔍 SQL queries: [project_sql folder](/project_sql/)

# Background
After completing Luke Barousse's [SQL for Data Analytics course](https://www.lukebarousse.com/sql), I built this project to put my new skills into practice. And to better understand the data analyst job market I'm actively working toward entering.

The dataset comes from the SQL Course and is packed with insights on job titles, salaries, locations, and essential skills.

### The questions I wanted to answer through my SQL queries were:

1. What are the top-paying data analyst jobs?
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for data analysts?
4. Which skills are associated with higher salaries?
5. What are the most optimal skills to learn?

# Tools I Used
- SQL — every insight in this project came from writing queries by hand.
- PostgreSQL — where all the job posting data lived.
- Visual Studio Code — where I wrote, tested, and refined my queries.
- Git & GitHub — to track my progress and share the finished work.

# The Analysis

### 1. Top paying data analyst jobs
To find the highest-paying roles, I filtered for remote data analyst positions with a listed average yearly salary, then sorted by salary descending.

```
SELECT	
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS company_name
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst' AND 
    job_location = 'Anywhere' AND 
    salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 10;
```
What the results showed:
- Salary range — top 10 roles span from $184,000 to $650,000, showing significant earning potential.
- Diverse employers — companies like SmartAsset, Meta, and AT&T all appear, across very different industries.
- Title variety — from Data Analyst to Director of Analytics, the roles vary widely in seniority and scope.


![Top paying roles](assets\bar_graph.png)
*Bar graph visualizing the salary for the top 10 salaries for data analysts; ChatGPT generated this graph from my SQL query results*

### 2. Skills for top paying jobs
Knowing which jobs pay the most is only half the picture. To understand what it actually takes to land those roles, I joined the top-paying job list with skills data.

```sql
WITH top_paying_jobs AS (
    SELECT	
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM
        job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title_short = 'Data Analyst' AND 
        job_location = 'Anywhere' AND 
        salary_year_avg IS NOT NULL
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)

SELECT 
    top_paying_jobs.*,
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC;
```
Three skills stood out clearly:
- SQL (8 mentions) — the foundation. No surprise here.
- Python (7 mentions) — practically required at senior level.
- Tableau (6 mentions) — being able to communicate findings visually is valued highly.

Beyond the top three, R, Snowflake, Pandas, and Excel appeared with lower but still notable frequency.

![Top paying roles](assets\skills.png)
*Bar graph visualizing the count of skills for the top 10 paying jobs for data analysts; ChatGPT generated this graph from my SQL query results*

### 3. In-demand skills for data analysts
To understand what the broader market wants, not just top-paying roles — I counted skill mentions across all remote data analyst job postings.
```sql
SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' 
    AND job_work_from_home = True 
GROUP BY
    skills
ORDER BY
    demand_count DESC
LIMIT 5;
```

| Skill | Demand Count |
|-------|-------------|
| SQL | 7,291 |
| Excel | 4,611 |
| Python | 4,330 |
| Tableau | 3,745 |
| Power BI | 2,609 |

Two clear patterns emerged:
- Foundations first — SQL and Excel appear far more often than any other skill, suggesting that most employers still expect these as baseline competencies.
- Technical skills are rising — Python, Tableau, and Power BI in the top 5 signals that data storytelling and programming are no longer optional.

### 4. Skills Based on Salary

Demand alone doesn't tell the full story. This query looked at which skills are associated with the highest average salaries — a different angle on what's actually worth learning.

```sql
SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True 
GROUP BY
    skills
ORDER BY
    avg_salary DESC
LIMIT 25;
```

| Skill | Average Salary ($) |
|-------|-------------------|
| PySpark | 208,172 |
| Bitbucket | 189,155 |
| Couchbase | 160,515 |
| Watson | 160,515 |
| DataRobot | 155,486 |
| GitLab | 154,500 |
| Swift | 153,750 |
| Jupyter | 152,777 |
| Pandas | 151,821 |
| Elasticsearch | 145,000 |

*Table of the average salary for the top 10 paying skills for data analysts*

What stood out:
- The top-paying skills skew heavily toward big data and ML — PySpark alone averages over $208k.
- Many of these tools sit at the intersection of data analysis and engineering, suggesting that crossing into that territory pays off significantly.
- Cloud and pipeline tools appear throughout, confirming that knowing how data moves matters as much as knowing how to analyze it.

### 5. Most Optimal Skills to Learn

The last query was the most useful one for me personally — combining demand and salary to find skills worth prioritizing. Not just what's common, and not just what pays the most, but what does both.

```sql
SELECT 
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True 
GROUP BY
    skills_dim.skill_id
HAVING
    COUNT(skills_job_dim.job_id) > 10
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 25;
```

| Skill | Demand Count | Average Salary ($) |
|-------|-------------|-------------------|
| Go | 27 | 115,320 |
| Confluence | 11 | 114,210 |
| Hadoop | 22 | 113,193 |
| Snowflake | 37 | 112,948 |
| Azure | 34 | 111,225 |
| BigQuery | 13 | 109,654 |
| AWS | 32 | 108,317 |
| Java | 17 | 106,906 |
| SSIS | 12 | 106,683 |
| Jira | 20 | 104,918 |

*Table of the most optimal skills for data analysts sorted by salary*

What I took away from this:
- **Cloud skills** like Snowflake, Azure, and AWS offer strong demand and above-average pay — a clear next step after the fundamentals.
- **Python and R** are in high demand but have lower average salaries than cloud or big data tools, suggesting they are table stakes rather than differentiators.
- **Tableau and Looker** sit in a comfortable middle ground — worth learning early for anyone focused on analytics and reporting.

# What I Learned
This project pushed my SQL skills further than any exercise could:
- Complex queries — learned to write multi-table JOINs and use CTEs to break complex problems into readable steps.
- Data aggregation — got comfortable with GROUP BY, COUNT(), and AVG() to summarize large datasets meaningfully.
- Analytical thinking — practiced turning a real business question into a structured SQL query and interpreting the results.
# Conclusions
### Insights

- Top-paying roles have a high ceiling — the highest remote data analyst salary in the dataset reaches $650,000, with significant variation across the top 10.
- SQL is the foundation — it leads in demand across the entire market and appears in nearly every top-paying role.
- Niche expertise carries a salary premium — specialized skills like PySpark and Couchbase average well above $150,000, even with lower overall demand.
- Cloud proficiency is increasingly expected — Snowflake, Azure, BigQuery, and AWS all appear in the high-demand, high-salary quadrant.
- The optimal skill set is well-defined — SQL first, then Python, then cloud or visualization tools depending on the direction you want to go.

### Closing thoughts
The goal of this project was to replace guesswork with data. It worked. The analysis points clearly toward which skills to prioritize, which roles to target, and what the market actually rewards.

I really enjoyed completing this course and putting new skills into practice on real data.