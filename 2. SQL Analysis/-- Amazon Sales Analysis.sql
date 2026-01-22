-- Amazon Sales Analysis
-- Internship Project
-- SQL Dialect: Databricks SQL


SELECT * FROM workspace.internship.asp_cleaned;

UPDATE internship.asp_cleaned
SET amount = NULL
WHERE amount = 'N/A';

--1. What are the total orders, total sales amount, and total quantity sold?

SELECT 
  COUNT(order_id) AS Total_order, 
  SUM(amount) AS Total_sales, 
  SUM(qty) AS Total_qty_sold
FROM workspace.internship.asp_cleaned; 

--2. What is the average order value (AOV)?

SELECT AVG(amount) AS avg_order_value
FROM workspace.internship.asp_cleaned; 

--3. How do monthly sales and order volume trend over time?

SELECT MONTH(date) AS month, SUM(amount) AS total_sales, COUNT(order_id) AS total_orders
FROM workspace.internship.asp_cleaned
GROUP BY month
ORDER BY month;

--4. Which month generated the highest sales revenue?

SELECT MONTH(date) AS month, SUM(amount) AS total_sales
FROM workspace.internship.asp_cleaned
GROUP BY month
ORDER BY total_sales DESC;

--5. What is the distribution of orders by order status (Completed, Cancelled, etc.)?

SELECT COUNT(order_id) AS Total_order, status
FROM workspace.internship.asp_cleaned
GROUP BY status;

--6. Which product categories generate the highest sales revenue?

SELECT Category AS Product, SUM(amount) As Total_Sales
FROM workspace.internship.asp_cleaned
GROUP BY Product
ORDER BY Total_Sales DESC;

--7. Which categories have the highest order volume?

SELECT Category AS Product, SUM(qty) As Total_qty
FROM workspace.internship.asp_cleaned
GROUP BY Product
ORDER BY Total_qty DESC;


--8. Which product sizes sell the most by quantity?

SELECT size, SUM(qty) as Total_qty
FROM workspace.internship.asp_cleaned
GROUP BY size
ORDER BY Total_qty DESC;

--9. What is the average quantity per order by category?

SELECT AVG(qty) AS Avg_qty, Category
FROM workspace.internship.asp_cleaned
GROUP BY category;

--10. What percentage of total sales comes from the top 3 categories?

WITH Total_sales AS (
  SELECT Category AS Product, SUM(amount) AS Sales
  FROM workspace.internship.asp_cleaned
  GROUP BY Product
),

top3_product AS (
  SELECT Sales, Product
  FROM Total_sales
  ORDER BY Sales DESC
  LIMIT 3
)

SELECT 
  100 * SUM(Sales) /  (SELECT SUM(Sales) FROM Total_sales) AS top_3_sales_percentage, Product
FROM top3_product
GROUP BY Product;

--11. What percentage of orders are fulfilled by Amazon vs Merchant?

WITH total_order_fulfilment AS (
  SELECT DISTINCT Fulfilment as ful, COUNT(order_id) AS Totalorders
  FROM workspace.internship.asp_cleaned
  GROUP BY Fulfilment
),

total_orders  AS (
  SELECT totalorders, ful
  FROM total_order_fulfilment
)

SELECT ful AS Fulfiment, 
  100 * SUM(Totalorders) / (SELECT SUM(Totalorders) FROM total_order_fulfilment) AS Amazon_VS_Merchent_Percentage
FROM total_orders
GROUP BY ful;

--12. What is the total sales revenue by fulfilment method?

SELECT Fulfilment, ROUND(SUM(amount),2) as Sales_revenue
FROM workspace.internship.asp_cleaned
GROUP BY Fulfilment;

--13. Percentage share of total cancellations by fulfilment method 

WITH total_cancellation AS (
  SELECT fulfilment, COUNT(status) AS total_cancel
  FROM workspace.internship.asp_cleaned
  WHERE status = "Cancelled"
  GROUP BY fulfilment
),

cancelled_by_fulfilment AS (
  SELECT total_cancel
  FROM total_cancellation
)

SELECT Fulfilment, 100 * SUM(total_cancel) / (SELECT SUM(total_cancel) FROM cancelled_by_fulfilment) AS Cancellation_Rate
FROM total_cancellation
GROUP BY fulfilment
ORDER BY Cancellation_Rate DESC;

--14. Which fulfilment method has a higher cancellation rate?

SELECT
  fulfilment,
  100 * SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*) AS cancellation_rate
FROM workspace.internship.asp_cleaned
GROUP BY fulfilment
ORDER BY cancellation_rate DESC;

--15. What is the average order value for each fulfilment type?

SELECT fulfilment, AVG(amount) AS AOV
FROM workspace.internship.asp_cleaned
GROUP BY fulfilment;

--16. What proportion of orders are B2B vs B2C?

WITH b2b_orders AS (
SELECT b2b, COUNT(order_id) AS Orders
FROM workspace.internship.asp_cleaned
GROUP BY b2b
),

Total_orders AS (
  SELECT Orders
  FROM b2b_orders
)

SELECT b2b, 100 * SUM(Orders) / (SELECT SUM(Orders) FROM Total_orders) AS Proportion
FROM b2b_orders
GROUP BY b2b;

--17. How does sales revenue differ between B2B and B2C customers?

SELECT b2b, ROUND(SUM(amount),2) AS Sales_revenue
FROM workspace.internship.asp_cleaned
GROUP BY b2b;

--18. Which customer type has a higher average order value?

SELECT b2b, AVG(amount) AS AOV
FROM workspace.internship.asp_cleaned
GROUP BY b2b
ORDER BY AOV DESC;

--19.  Which customer segment has a higher cancellation rate?

SELECT
  b2b,
  100 * SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*) AS cancellation_rate
FROM workspace.internship.asp_cleaned
GROUP BY b2b
ORDER BY cancellation_rate DESC;

--20. Which states generate the highest sales revenue?

SELECT ship_state, ROUND(SUM(amount),2) AS total_revenue
FROM workspace.internship.asp_cleaned
GROUP BY ship_state
ORDER BY total_revenue DESC;

--21. Which cities place the most orders?

SELECT ship_city, COUNT(order_id) AS total_order
FROM workspace.internship.asp_cleaned
GROUP BY ship_city
ORDER BY total_order DESC;

--22. What is the average order value by state?

SELECT ship_state, ROUND(AVG(amount),2) AS AOV
FROM workspace.internship.asp_cleaned
GROUP BY ship_state;

--23. Which states have the highest cancellation rates?

SELECT
  ship_state,
  100.0 * SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*) AS cancellation_rate
FROM workspace.internship.asp_cleaned
GROUP BY ship_state
ORDER BY cancellation_rate DESC;

--24. Which product categories have the highest cancellation rate?

SELECT
  Category AS Product,
  100.0 * SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*) AS cancellation_rate
FROM workspace.internship.asp_cleaned
GROUP BY Product
ORDER BY cancellation_rate DESC;

--25. What is the successful delivery rate for Amazon vs Merchant fulfilment?

SELECT fulfilment, 100 * SUM(CASE WHEN Courier_status = 'Shipped' THEN 1 ELSE 0 END) / COUNT(*) AS Delivery_rate
FROM workspace.internship.asp_cleaned
GROUP BY fulfilment
ORDER BY Delivery_rate DESC;


--26. What is the average quantity per order for B2B vs B2C customers?

SELECT b2b, AVG(qty) AS Avg_qty_per_order
FROM workspace.internship.asp_cleaned
GROUP BY b2b;

--27. Which states have both high order volume and high cancellation rate?

SELECT
  ship_state,
  COUNT(order_id) AS Order_volumne,
  100 * ROUND(SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*),2) AS cancellation_rate
FROM workspace.internship.asp_cleaned
GROUP BY ship_state
ORDER BY Order_volumne  DESC, cancellation_rate DESC;

--28. What percentage of total revenue is contributed by the top 5 states?

WITH Total_sales AS (
  SELECT ship_state AS State, SUM(amount) AS Sales
  FROM workspace.internship.asp_cleaned
  GROUP BY State
),

top5_state AS (
  SELECT Sales, State
  FROM Total_sales
  ORDER BY Sales DESC
  LIMIT 5
)

SELECT 
  State, 100 * SUM(Sales) /  (SELECT SUM(Sales) FROM Total_sales) AS top_5_state_sales_percentage
FROM top5_state
GROUP BY State;

--29.What percentage of the total sales revenue does each month contribute?

WITH Total_sales AS (
  SELECT MONTH(date) AS Month, SUM(amount) AS Sales
  FROM workspace.internship.asp_cleaned
  GROUP BY Month
),

mom AS (
  SELECT Sales, Month
  FROM Total_sales
)

SELECT 
  Month, 100 * SUM(Sales) /  (SELECT SUM(Sales) FROM Total_sales) AS month_over_month_percentage
FROM mom
GROUP BY Month
ORDER BY Month;

--30. What is the month-over-month percentage growth or decline in sales revenue?

WITH monthly_sales AS (
  SELECT
    MONTH(date) AS month,
    SUM(amount) AS sales
  FROM workspace.internship.asp_cleaned
  GROUP BY MONTH(date)
),

mom_calc AS (
  SELECT
    month,
    sales,
    LAG(sales) OVER (ORDER BY month) AS prev_month_sales
  FROM monthly_sales
)

SELECT
  month,
  CASE
    WHEN prev_month_sales IS NULL THEN NULL
    ELSE 100.0 * (sales - prev_month_sales) / prev_month_sales
    END AS month_over_month_percentage
FROM mom_calc
ORDER BY month;


