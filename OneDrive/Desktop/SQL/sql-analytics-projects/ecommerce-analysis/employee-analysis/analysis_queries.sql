Question 1: Average Salary by Department
WITH department_stats AS (
    SELECT 
        d.dept_id,
        d.dept_name,
        d.location,
        d.budget,
        COUNT(e.emp_id) AS employee_count,
        ROUND(AVG(e.salary), 2) AS avg_salary,
        MIN(e.salary) AS min_salary,
        MAX(e.salary) AS max_salary,
        SUM(e.salary) AS total_salary_budget,
        ROUND(STDDEV(e.salary), 2) AS salary_std_dev,
        ROUND(AVG(e.performance_rating), 2) AS avg_performance_rating
    FROM departments d
    LEFT JOIN employees e ON d.dept_id = e.department_id
    GROUP BY d.dept_id, d.dept_name, d.location, d.budget
),
department_ranks AS (
    SELECT 
        *,
        RANK() OVER (ORDER BY avg_salary DESC) AS salary_rank,
        RANK() OVER (ORDER BY avg_performance_rating DESC) AS performance_rank,
        ROUND((total_salary_budget / budget) * 100, 2) AS budget_utilization_percent
    FROM department_stats
)
SELECT 
    dept_name,
    location,
    employee_count,
    avg_salary,
    min_salary,
    max_salary,
    max_salary - min_salary AS salary_range,
    salary_std_dev,
    total_salary_budget,
    budget,
    budget_utilization_percent,
    avg_performance_rating,
    salary_rank,
    performance_rank,
    CASE 
        WHEN avg_salary > 100000 THEN 'High Paying'
        WHEN avg_salary > 80000 THEN 'Medium Paying'
        ELSE 'Standard Paying'
    END AS salary_tier
FROM department_ranks
ORDER BY avg_salary DESC;

Question 2: Employee with Highest Salary in Each Department
WITH department_top_earners AS (
    SELECT 
        e.emp_id,
        e.first_name,
        e.last_name,
        e.job_title,
        e.salary,
        e.hire_date,
        e.performance_rating,
        d.dept_name,
        d.location,
        RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS dept_salary_rank,
        RANK() OVER (PARTITION BY e.department_id ORDER BY e.performance_rating DESC) AS dept_performance_rank,
        AVG(e.salary) OVER (PARTITION BY e.department_id) AS dept_avg_salary,
        MAX(e.salary) OVER (PARTITION BY e.department_id) AS dept_max_salary
    FROM employees e
    JOIN departments d ON e.department_id = d.dept_id
),
top_earners AS (
    SELECT *
    FROM department_top_earners
    WHERE dept_salary_rank = 1
),
company_metrics AS (
    SELECT 
        AVG(salary) AS company_avg_salary,
        MAX(salary) AS company_max_salary
    FROM employees
)
SELECT 
    te.emp_id,
    te.first_name,
    te.last_name,
    te.job_title,
    te.dept_name,
    te.location,
    te.salary,
    te.dept_avg_salary,
    te.dept_max_salary,
    cm.company_avg_salary,
    cm.company_max_salary,
    te.performance_rating,
    te.dept_performance_rank,
    te.hire_date,
    DATEDIFF(CURDATE(), te.hire_date) AS days_employed,
    -- Salary comparisons
    ROUND(te.salary - te.dept_avg_salary, 2) AS above_dept_avg,
    ROUND((te.salary - te.dept_avg_salary) * 100.0 / te.dept_avg_salary, 2) AS above_dept_avg_percent,
    ROUND(te.salary - cm.company_avg_salary, 2) AS above_company_avg,
    ROUND((te.salary - cm.company_avg_salary) * 100.0 / cm.company_avg_salary, 2) AS above_company_avg_percent,
    -- Compensation analysis
    CASE 
        WHEN te.salary > cm.company_avg_salary * 1.5 THEN 'Executive Level'
        WHEN te.salary > cm.company_avg_salary * 1.2 THEN 'Senior Level'
        WHEN te.salary > cm.company_avg_salary THEN 'Above Average'
        ELSE 'Standard'
    END AS compensation_tier
FROM top_earners te
CROSS JOIN company_metrics cm
ORDER BY te.salary DESC;

Question 3: Salary Difference between Each Employee and Department Average
-- Comprehensive employee salary analysis with department comparisons
WITH department_aggregates AS (
    SELECT 
        department_id,
        COUNT(*) AS dept_employee_count,
        ROUND(AVG(salary), 2) AS dept_avg_salary,
        MIN(salary) AS dept_min_salary,
        MAX(salary) AS dept_max_salary,
        ROUND(STDDEV(salary), 2) AS dept_salary_std_dev,
        ROUND(AVG(performance_rating), 2) AS dept_avg_performance
    FROM employees
    GROUP BY department_id
),
employee_analysis AS (
    SELECT 
        e.emp_id,
        CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
        e.job_title,
        e.hire_date,
        e.salary,
        e.performance_rating,
        d.dept_name,
        d.location,
        da.dept_employee_count,
        da.dept_avg_salary,
        da.dept_min_salary,
        da.dept_max_salary,
        da.dept_salary_std_dev,
        da.dept_avg_performance,
        -- Salary comparisons
        ROUND(e.salary - da.dept_avg_salary, 2) AS salary_difference,
        ROUND((e.salary - da.dept_avg_salary) * 100.0 / da.dept_avg_salary, 2) AS salary_difference_percent,
        -- Z-score for salary within department
        ROUND((e.salary - da.dept_avg_salary) / NULLIF(da.dept_salary_std_dev, 0), 2) AS salary_z_score,
        -- Performance comparisons
        e.performance_rating - da.dept_avg_performance AS performance_difference,
        -- Tenure
        DATEDIFF(CURDATE(), e.hire_date) AS tenure_days,
        ROUND(DATEDIFF(CURDATE(), e.hire_date) / 365.25, 2) AS tenure_years,
        -- Rankings
        RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS dept_salary_rank,
        RANK() OVER (PARTITION BY e.department_id ORDER BY e.performance_rating DESC) AS dept_performance_rank,
        PERCENT_RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary) AS dept_salary_percentile
    FROM employees e
    JOIN departments d ON e.department_id = d.dept_id
    JOIN department_aggregates da ON e.department_id = da.department_id
)
SELECT 
    employee_name,
    job_title,
    dept_name,
    location,
    salary,
    dept_avg_salary,
    salary_difference,
    salary_difference_percent,
    salary_z_score,
    performance_rating,
    dept_avg_performance,
    performance_difference,
    tenure_years,
    dept_salary_rank,
    dept_performance_rank,
    ROUND(dept_salary_percentile * 100, 2) AS dept_salary_percentile,
    -- Analysis categories
    CASE 
        WHEN salary_difference_percent > 20 THEN 'Significantly Above Average'
        WHEN salary_difference_percent > 10 THEN 'Above Average'
        WHEN salary_difference_percent > -10 THEN 'Average'
        WHEN salary_difference_percent > -20 THEN 'Below Average'
        ELSE 'Significantly Below Average'
    END AS salary_position,
    CASE 
        WHEN salary_z_score > 1.5 THEN 'Outlier High'
        WHEN salary_z_score > 0.5 THEN 'Above Mean'
        WHEN salary_z_score > -0.5 THEN 'Around Mean'
        WHEN salary_z_score > -1.5 THEN 'Below Mean'
        ELSE 'Outlier Low'
    END AS salary_distribution,
    -- Compensation fairness indicator
    CASE 
        WHEN performance_rating > dept_avg_performance AND salary_difference_percent > 0 THEN 'Fairly Compensated'
        WHEN performance_rating < dept_avg_performance AND salary_difference_percent < 0 THEN 'Fairly Compensated'
        WHEN performance_rating > dept_avg_performance AND salary_difference_percent < 0 THEN 'Potential Underpaid'
        WHEN performance_rating < dept_avg_performance AND salary_difference_percent > 0 THEN 'Potential Overpaid'
        ELSE 'Needs Review'
    END AS compensation_fairness
FROM employee_analysis
ORDER BY dept_name, salary DESC;
