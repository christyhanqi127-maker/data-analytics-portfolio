-- =========================================
-- Project: E-Commerce Customer Behavior Analysis
-- Tool: MySQL
-- Description: End-to-end analysis including data cleaning, segmentation, retention, and time series
-- =========================================


-- =========================================
-- 1. Data Cleaning & Overview
-- =========================================

SELECT COUNT(*) AS total_rows
FROM customer_order_train;

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS null_customer,
  SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS null_age,
  SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS null_gender,
  SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
  SUM(CASE WHEN ProductCategory IS NULL THEN 1 ELSE 0 END) AS null_category,
  SUM(CASE WHEN PurchaseAmount IS NULL THEN 1 ELSE 0 END) AS null_amount,
  SUM(CASE WHEN PaymentMethod IS NULL THEN 1 ELSE 0 END) AS null_method,
  SUM(CASE WHEN PurchaseDate IS NULL THEN 1 ELSE 0 END) AS null_date,
  SUM(CASE WHEN DeviceUsed IS NULL THEN 1 ELSE 0 END) AS null_device,
  SUM(CASE WHEN ReturningCustomer IS NULL THEN 1 ELSE 0 END) AS null_return
FROM customer_order_train;
	
#duplicate
GROUP BY CustomerID, PurchaseDate,ProductCategory,PurchaseAmount
HAVING COUNT(*) > 1;

#outliers
Select CustomerID, Age from customer_order_train
where age < 18 or age >69;

select distinct gender from customer_order_train;

select CustomerID, PurchaseAmount from customer_order_train
where PurchaseAmount <= 0;

select distinct ReturningCustomer from customer_order_train;
select distinct DeviceUsed from customer_order_train;
SELECT DISTINCT ProductCategory FROM customer_order_train;
SELECT COUNT(DISTINCT Location) FROM customer_order_train;

-- =========================================
-- 2. EDA
-- =========================================
SELECT 
  CASE 
    WHEN Age < 25 THEN 'Under 25'
    WHEN Age BETWEEN 25 AND 40 THEN '25-40'
    WHEN Age BETWEEN 41 AND 60 THEN '41-60'
    ELSE '60+'
  END AS age_group,
  COUNT(*) AS orders,
  SUM(PurchaseAmount) AS revenue,
  AVG(PurchaseAmount) AS avg_spent
FROM customer_order_train
GROUP BY age_group
ORDER BY orders DESC;

select COUNT(*) AS orders, Location, sum(PurchaseAmount) as Total_revenue from customer_order_train
group by Location
order by orders desc;

SELECT 
  MIN(PurchaseAmount),
  MAX(PurchaseAmount),
  AVG(PurchaseAmount)
FROM customer_order_train;

SELECT Location, 
count(distinct CustomerID) as total_customer,
count(distinct case when ReturningCustomer='Yes' Then CustomerID end) as return_customer,
count(distinct case when ReturningCustomer='Yes' Then CustomerID end)/count(distinct CustomerID)as retention_rate
from customer_order_train 
group by Location
order by retention_rate desc;

SELECT 
  Location,
  SUM(CASE WHEN ReturningCustomer = 'Yes' THEN PurchaseAmount ELSE 0 END) AS returning_revenue,
  SUM(PurchaseAmount) AS total_revenue,
  SUM(CASE WHEN ReturningCustomer = 'Yes' THEN PurchaseAmount ELSE 0 END) 
    / SUM(PurchaseAmount) AS retention_revenue_ratio
FROM customer_order_train
GROUP BY Location
order by retention_revenue_ratio desc;

SELECT ProductCategory, 
count(distinct CustomerID) as total_customer,
count(distinct case when ReturningCustomer='Yes' Then CustomerID end) as return_customer,
count(distinct case when ReturningCustomer='Yes' Then CustomerID end)/count(distinct CustomerID)as retention_rate
from customer_order_train 
group by ProductCategory
order by retention_rate desc;

SELECT 
  DATE_FORMAT(PurchaseDate, '%m') AS month,
  COUNT(*) AS orders
FROM customer_order_train
GROUP BY month
ORDER BY orders desc limit 10;

SELECT 
  DATE_FORMAT(PurchaseDate, '%m') AS month,
  COUNT(*) AS orders,
  SUM(PurchaseAmount) AS revenue,
   SUM(PurchaseAmount)/COUNT(*) as revenue_per_order
FROM customer_order_train
GROUP BY month
ORDER BY month;

SELECT *
FROM (
  SELECT 
    CustomerID,
    SUM(PurchaseAmount) AS total_spent,
    NTILE(5) OVER (ORDER BY SUM(PurchaseAmount) DESC) AS spend_group
  FROM customer_order_train
  GROUP BY CustomerID
) t
WHERE spend_group = 1;

-- =========================================
-- 3. Revenue Analysis (Time Series)
-- =========================================

SELECT 
  DATE_FORMAT(PurchaseDate, '%Y-%m') AS month,
  COUNT(*) AS orders,
  SUM(PurchaseAmount) AS revenue,
  SUM(PurchaseAmount)/COUNT(*) AS revenue_per_order
FROM customer_order_train
GROUP BY month
ORDER BY month;


-- =========================================
-- 4. Price Segmentation
-- =========================================

SELECT 
  CASE 
    WHEN PurchaseAmount < 100 THEN 'Low'
    WHEN PurchaseAmount < 500 THEN 'Mid'
    WHEN PurchaseAmount < 1000 THEN 'High'
    ELSE 'Premium'
  END AS price_segment,
  COUNT(*) AS orders,
  SUM(PurchaseAmount) AS revenue
FROM customer_order_train
GROUP BY price_segment
ORDER BY revenue DESC;


-- =========================================
-- 5. Customer Retention
-- =========================================

SELECT 
  ReturningCustomer,
  COUNT(DISTINCT CustomerID) AS customers,
  COUNT(*) AS orders,
  SUM(PurchaseAmount) AS revenue,
  AVG(PurchaseAmount) AS avg_order_value
FROM customer_order_train
GROUP BY ReturningCustomer;


-- =========================================
-- 6. Weekday Analysis
-- =========================================

SELECT 
  DAYNAME(PurchaseDate) AS weekday,
  COUNT(*) AS orders
FROM customer_order_train
GROUP BY weekday;
