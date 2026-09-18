-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Business Question
-- MAGIC **How should the retailer target and time a promotional campaign for West-region and Consumer-segment customers, based on their purchasing activity, conversion speed, and product preferences?**
-- MAGIC
-- MAGIC This notebook answers the supporting questions below using SQL, then synthesizes the results into a final recommendation on target audience, timing, and products to promote.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Q1: Who purchased what, and which customers/products have no activity?**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Q1, Part A: Who purchase what?**

-- COMMAND ----------

SELECT a.customer_id, b.order_id, d.product_name, c.quantity
FROM workspace.retail.customers AS a 
INNER JOIN workspace.retail.orders AS b 
ON a.customer_id = b.customer_id 
INNER JOIN workspace.retail.order_items AS c 
ON b.order_id = c.order_id 
INNER JOIN workspace.retail.products AS d 
ON c.product_id = d.product_id
;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Q1, Part b: Which customers have orders at all? This will explain activity.**

-- COMMAND ----------

-- We would use LEFT JOIN where customers table will be the left and we are finding the customers with no orders. 
-- LEFT JOIN keeps all customers, matched or not.
SELECT a.customer_id
FROM workspace.retail.customers AS a 
LEFT JOIN workspace.retail.orders AS b 
ON a.customer_id = b.customer_id 
WHERE b.order_id IS NULL
;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Q1, Part c: Which products have been not been purchased at all?**

-- COMMAND ----------

-- We would use LEFT JOIN where products table will be the left and we are finding the products with no orders. 
-- LEFT JOIN keeps all products, matched or not.
SELECT a.product_id, a.product_name
FROM workspace.retail.products AS a 
LEFT JOIN workspace.retail.order_items AS b 
ON a.product_id = b.product_id
WHERE b.product_id IS NULL
;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC While every product has at least one recorded sale, sales volume varies meaningfully across products (which can be seens from the analysis below). This distinction matters for the final promotional recommendation.

-- COMMAND ----------

-- How much of each product has been sold?
SELECT b.product_id, b.product_name, SUM(a.quantity) AS total_units_sold
FROM workspace.retail.order_items AS a
INNER JOIN workspace.retail.products AS b 
ON a.product_id = b.product_id 
GROUP BY b.product_id, b.product_name
ORDER BY total_units_sold DESC
;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Q2: Which unique customers qualify because they are West region or Consumer?**

-- COMMAND ----------

SELECT a.customer_id, a.region, a.segment
FROM workspace.retail.customers AS a
WHERE region = 'West' OR segment = 'Consumer'
;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Q3: Who qualifies for one campaign versus both campaigns?**

-- COMMAND ----------

SELECT a.customer_id, a.region, a.segment,
  CASE 
    WHEN a.region = 'West' AND a.segment = 'Consumer' THEN 'Qualifies for Both Campaigns'
    WHEN a.region = 'West' THEN 'Qualifies for West Region Campaign Only'
    WHEN a.segment = 'Consumer' THEN 'Qualifies for Consumer Segment Campaign Only'
  END AS campaign_qualifier
FROM workspace.retail.customers AS a
WHERE a.region = 'West' OR a.segment = 'Consumer'
ORDER BY campaign_qualifier
;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Q4: Which West customers have completed an order?**

-- COMMAND ----------

-- SELECT DISTINCT would remove rows that are completely identical across every column we selected
SELECT DISTINCT a.customer_id, b.order_id, b.status
FROM workspace.retail.customers AS a  
INNER JOIN workspace.retail.orders AS b 
ON a.customer_id = b.customer_id
WHERE b.status = 'Completed' AND a.region = 'West'
;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Q5, What period does the analysis cover?**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC The order data spans exactly 2 years, from 2024-01-01 to 2025-12-30. This gives a substantial window to identify seasonal patterns and conversion speed trends with reasonable confidence, since two full annual cycles are captured.

-- COMMAND ----------

SELECT 
MIN(order_date) AS oldest_order, MAX(order_date) AS most_recent_order
FROM workspace.retail.orders
;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Q6, Which months receive the most orders?**

-- COMMAND ----------

SELECT MONTH(order_date) AS order_month, COUNT(*) AS num_orders
FROM workspace.retail.orders 
GROUP BY order_month
ORDER BY num_orders DESC
;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Q7, Which days are best for launching communications?**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC - We should look at when orders actually happen (which day of the week) 
-- MAGIC - Whichever day(s) show the highest order volume are the days customers are demonstrably active

-- COMMAND ----------

SELECT DAYOFWEEK(order_date) AS day_of_week, COUNT(*) AS order_count
FROM workspace.retail.orders 
GROUP BY day_of_week
ORDER BY order_count DESC
;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Q8, How quickly do customers purchase after signup?**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC We will measure time until first order date for each customer because that's the window the retailer can actually influence -- the consumer is still deciding whether to become a customer or not.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC We can notice from the results that there is something off in this data output because for many customers, the first order purchase data is before their sign up date. For example, the customer with ID C03458, has a sign up date of 2025-11-14 but the order date was way before that sign up date (i.e. 2024-01-02). Hence, these customers may have created accounts after being satisfied from their orders. Another explanation indicate a data quality issue.

-- COMMAND ----------

SELECT a.customer_id, a.signup_date, MIN(b.order_date) AS first_order_date, 
DATEDIFF(MIN(b.order_date), a.signup_date) AS days_to_first_purchase
FROM workspace.retail.customers AS a
INNER JOIN workspace.retail.orders AS b 
ON a.customer_id = b.customer_id
GROUP BY a.customer_id, a.signup_date
ORDER BY days_to_first_purchase ASC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Recommendations**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Target Audience**
-- MAGIC From Question 3 (built directly on Question 2's qualifying pool), a customer who matches both criteria (West region AND Consumer segment) is the target audience. These are the 911 customers who qualify for both campaigns as a campaign prioritization. The reason to choose this audience is because a customer who is both West and Consumer is relevant to both campaigns at the same time. If the retailer sends this "both" group a single well-designed promotional message, that one message is doing double duty without needing two separate outreach efforts for that same person. Question 4 also showed that 1,440 of 1,563 of West customers have completed a real order. That's strong evidence that being a customer in the West region correlates with being an active buyer. Since the 911 "both" customers are, by definition, a subset of West customers, the high order rate applies to them too. 
-- MAGIC
-- MAGIC **Campaign Timing**
-- MAGIC From Question 6, order volume is nearly flat across all 12 months, ranging from 1,958 to 2,192 orders which is ~12% difference between the lowest and highest order volume months. There isn't any clear seasonal peak which means treating this metric as a real seasonal signal would be overfitting (which would create bias). In Question 7, we went deeper into understanding the audience/order purchases on a weekly basis. Order volume by day of week ranges from Sunday being the lowest to Friday being the highest. The day-of-week pattern indiciates a larger relative gap, making it the more reliable tool for timing decisions. 
-- MAGIC
-- MAGIC My recommendation, through the analysis of the given data outputs, is to schedule campaign communications on Tuesday, Wednesday, or Friday, avoiding weekends. Sending on Sunday particularly means you're reaching people who are largely not interested on that day so the communication is more likely to get buried or ignored to a later time/day. Looking at the bigger picture, since no single month drives meaningfully higher engagement, the campaign can launch at any point in the year. 
-- MAGIC
-- MAGIC **Products to Promote**
-- MAGIC As seen in the further investigation results from Question 1, all products have at least one recorded sale. Since the target audience being recommended is the West/Consumer target audience, I will analyze Which product categories this specfic group prefers for a stronger promotion recommendation:
-- MAGIC
-- MAGIC

-- COMMAND ----------

SELECT d.category, SUM(c.quantity) AS total_units_sold
FROM workspace.retail.customers AS a
INNER JOIN workspace.retail.orders AS b 
ON a.customer_id = b.customer_id
INNER JOIN workspace.retail.order_items AS c
ON b.order_id = c.order_id
INNER JOIN workspace.retail.products AS d
ON c.product_id = d.product_id
WHERE (a.region = 'West' AND a.segment = 'Consumer') AND b.status = 'Completed'
GROUP BY d.category
ORDER BY total_units_sold DESC
;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Products to Promote**
-- MAGIC From the output above, the retailer should promote Office Supplies and Home & Kitchen products first for the target audience (West/Consumer pool). From Question 1, where we were examining the product activity, we can confirm that Office Supplies and Home & Kitchen products is the right option. Top individual products for the overall population were also the following: 
-- MAGIC - Apex Office Supplies 23: 526 units
-- MAGIC - Cedar Office Supplies 55: 497 units
-- MAGIC - Everly Office Supplies 18: 485 units
-- MAGIC - Brightline Office Supplies 31: 483 units
-- MAGIC - Orion Office Supplies 65: 472 units