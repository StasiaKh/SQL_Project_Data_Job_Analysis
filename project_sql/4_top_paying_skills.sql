SELECT
  skills,
  round(avg(salary_year_avg),0) as avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
WHERE
  job_title_short= 'Data Analyst' 
  AND salary_year_avg IS NOT NULL
GROUP BY
  skills
  ORDER BY
  avg_salary DESC
LIMIT 25

/*
SVN is a huge outlier ($400K) → niche legacy skill, high pay due to low supply
Top salaries come from engineering tools (Golang, Terraform, Kafka) → not typical analyst stack
ML skills (PyTorch, TensorFlow) pay well, but not the highest
Data pipeline tools (Airflow, Kafka) boost salary → companies value data infrastructure
Collaboration tools (GitLab, Atlassian) still matter → higher roles involve teamwork and systems.
*/