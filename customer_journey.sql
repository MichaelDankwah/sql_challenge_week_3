-- A. Customer Journey
-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each 
-- customer’s onboarding journey. Try to keep it as short as possible - you may also want to run some sort of join to make your 
-- explanations a bit easier!

  
WITH customer_journey AS (
  SELECT 
    s.customer_id, 
    s.start_date, 
    p.plan_name
  FROM 
    foodie_fi.subscriptions s
  JOIN 
    foodie_fi.plans p ON s.plan_id = p.plan_id
  ORDER BY 
    s.customer_id, s.start_date
)
SELECT
  customer_id,
  GROUP_CONCAT(CONCAT(start_date, ': ', plan_name) ORDER BY start_date SEPARATOR ' -> ') AS journey
FROM 
  customer_journey
GROUP BY 
  customer_id
ORDER BY 
  customer_id;




