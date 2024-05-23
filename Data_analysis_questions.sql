-- B. Data Analysis Questions



-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions;


-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT 
  DATE_FORMAT(start_date, '%Y-%m-01') AS month_start,
  COUNT(*) AS trial_starts
FROM 
  subscriptions
WHERE 
  plan_id = 0
GROUP BY 
  month_start
ORDER BY 
  month_start;



-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT 
  p.plan_name, 
  COUNT(*) AS count_of_events
FROM 
  subscriptions s
JOIN 
  plans p ON s.plan_id = p.plan_id
WHERE 
  s.start_date > '2020-12-31'
GROUP BY 
  p.plan_name
ORDER BY 
  count_of_events DESC;



-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT 
  COUNT(DISTINCT CASE WHEN plan_id = 4 THEN customer_id END) AS churned_customers,
  CONCAT(
    ROUND((COUNT(DISTINCT CASE WHEN plan_id = 4 THEN customer_id END) / COUNT(DISTINCT customer_id)) * 100, 1),
    '%'
  ) AS churn_percentage
FROM 
  subscriptions;



-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

SELECT 
  COUNT(DISTINCT CASE WHEN s.plan_id = 4 THEN s.customer_id END) AS churned_after_trial_count,
  CONCAT(ROUND((COUNT(DISTINCT CASE WHEN s.plan_id = 4 THEN s.customer_id END) / MAX(trial_customers.total_trial_customers)) * 100), '%') 
  AS churned_after_trial_percentage
FROM 
  subscriptions s
JOIN (
  SELECT COUNT(DISTINCT customer_id) AS total_trial_customers
  FROM subscriptions
  WHERE plan_id = 0
) AS trial_customers ON 1 = 1
WHERE 
  EXISTS (
    SELECT 1
    FROM subscriptions s1
    WHERE s1.customer_id = s.customer_id
    AND s1.plan_id = 0
  );


-- 6. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

SELECT 
  p.plan_name,
  COUNT(s.customer_id) AS customer_count,
  CONCAT(ROUND((COUNT(s.customer_id) / MAX(total_customers.total_count)) * 100, 1), '%'
  ) AS percentage
FROM 
  plans p
LEFT JOIN 
  subscriptions s ON p.plan_id = s.plan_id
CROSS JOIN (
  SELECT COUNT(DISTINCT customer_id) AS total_count
  FROM subscriptions
  WHERE start_date <= '2020-12-31'
) AS total_customers
WHERE 
  s.start_date <= '2020-12-31' OR s.start_date IS NULL
GROUP BY 
  p.plan_name;



-- 7. How many customers have upgraded to an annual plan in 2020?

SELECT COUNT(DISTINCT customer_id) AS upgraded_to_annual_count
FROM subscriptions
WHERE plan_id = 3
AND EXTRACT(YEAR FROM start_date) = 2020;


-- 8. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?

SELECT 
  AVG(DATEDIFF(sub_annual.start_date, sub_first.start_date)) 
  AS average_days_to_upgrade
FROM 
  (
    SELECT 
      customer_id, 
      MIN(start_date) AS start_date
    FROM 
      subscriptions
    GROUP BY 
      customer_id
  ) AS sub_first
JOIN 
  subscriptions sub_annual ON sub_first.customer_id = sub_annual.customer_id
WHERE 
  sub_annual.plan_id = 3;


-- 9. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

-- Calculate the overall average days
SELECT 
  AVG(DATEDIFF(sub_annual.start_date, sub_first.start_date)) AS overall_average_days
FROM 
  (
    SELECT 
      customer_id, 
      MIN(start_date) AS start_date
    FROM 
      subscriptions
    GROUP BY 
      customer_id
  ) AS sub_first
JOIN 
  subscriptions sub_annual ON sub_first.customer_id = sub_annual.customer_id
WHERE 
  sub_annual.plan_id = 3;

-- Breakdown into 30-day periods using the overall average days
SELECT 
  AVG(
    CASE 
      WHEN DATEDIFF(sub_annual.start_date, sub_first.start_date) BETWEEN 0 AND 30 THEN DATEDIFF(sub_annual.start_date, sub_first.start_date)
      ELSE NULL
    END
  ) AS "0-30 days",
  AVG(
    CASE 
      WHEN DATEDIFF(sub_annual.start_date, sub_first.start_date) BETWEEN 31 AND 60 THEN DATEDIFF(sub_annual.start_date, sub_first.start_date)
      ELSE NULL
    END
  ) AS "31-60 days",
  AVG(
    CASE 
      WHEN DATEDIFF(sub_annual.start_date, sub_first.start_date) BETWEEN 61 AND 90 THEN DATEDIFF(sub_annual.start_date, sub_first.start_date)
      ELSE NULL
    END
  ) AS "61-90 days",
  AVG(
    CASE 
      WHEN DATEDIFF(sub_annual.start_date, sub_first.start_date) > 90 THEN DATEDIFF(sub_annual.start_date, sub_first.start_date)
      ELSE NULL
    END
  ) AS "More than 90 days"
FROM 
  (
    SELECT 
      customer_id, 
      MIN(start_date) AS start_date
    FROM 
      subscriptions
    GROUP BY 
      customer_id
  ) AS sub_first
JOIN 
  subscriptions sub_annual ON sub_first.customer_id = sub_annual.customer_id
WHERE 
  sub_annual.plan_id = 3;



-- 10. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

SELECT COUNT(DISTINCT customer_id) AS downgraded_customers_count
FROM subscriptions
WHERE 
  plan_id = (
    SELECT plan_id FROM plans WHERE plan_name = 'pro monthly'
  )
  AND customer_id IN (
    SELECT customer_id FROM subscriptions WHERE plan_id = (
      SELECT plan_id FROM plans WHERE plan_name = 'basic monthly'
    )
  )
  AND EXTRACT(YEAR FROM start_date) = 2020;


