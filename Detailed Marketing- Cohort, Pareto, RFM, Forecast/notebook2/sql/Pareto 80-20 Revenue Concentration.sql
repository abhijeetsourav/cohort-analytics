-- STEP 6 — Pareto (80/20) Revenue Concentration Analysis
WITH ranked_customers AS (
  SELECT
    customer_id,
    monetary,
    SUM(monetary) OVER () AS total_revenue,
    SUM(monetary) OVER (ORDER BY monetary DESC) AS cumulative_revenue
  FROM uk_rfm_customers
),
pareto AS (
  SELECT
    customer_id,
    monetary,
    cumulative_revenue,
    cumulative_revenue / total_revenue AS cumulative_revenue_pct
  FROM ranked_customers
)
SELECT
  COUNT(*) FILTER (WHERE cumulative_revenue_pct <= 0.8) AS customers_80pct_revenue,
  COUNT(*) AS total_customers,
  ROUND(
    COUNT(*) FILTER (WHERE cumulative_revenue_pct <= 0.8)::NUMERIC
    / COUNT(*) * 100,
    2
  ) AS pct_customers_driving_80pct_revenue
FROM pareto;