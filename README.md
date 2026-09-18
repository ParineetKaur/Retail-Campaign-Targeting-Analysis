# Retail Campaign Targeting: West Region & Consumer Segment

Who to target, when to send, and what to promote, using SQL in Databricks.

## Business Question
How should a retailer target and time a promotional campaign for West-region and Consumer-segment customers, based on purchasing activity and product preferences?

## Data
Four tables (`customers`, `orders`, `order_items`, `products`) covering 5,000 customers and 25,000 orders from Jan 2024 to Dec 2025.

## Methods
- **Joins:** multi-table `INNER JOIN` to link customers, orders, items, and products
- **Anti-joins:** `LEFT JOIN ... IS NULL` to find inactive customers (392) and unsold products (none)
- **Segmentation:** `CASE WHEN` to split customers into West-only, Consumer-only, or both
- **Aggregation:** `GROUP BY` on month, day of week, and product category
- **Date functions:** `MONTH`, `DAYOFWEEK`, `DATEDIFF`

## Key Findings
- **Audience:** 911 customers are both West and Consumer; 92% of West customers (1,440 of 1,563) have a completed order.
- **Timing:** No meaningful monthly seasonality (~12% spread). Tuesday, Wednesday, and Friday have the most orders (~6% above Sunday).
- **Products:** Office Supplies and Home & Kitchen are the top categories for the target group.
- **Data quality:** For 53% of ordering customers, the first order predates signup, so conversion speed was not used.

## Recommendation
Target the 911 West + Consumer customers, send on Tuesday, Wednesday, or Friday at any time of year, and lead with Office Supplies and Home & Kitchen.

## Limitations
Timing differences are small (test with A/B). Analysis uses units, not revenue or margin.

## Files
- `retail_campaign_targeting.sql`: Databricks notebook
- `output/retail_campaign_targeting_results.xlsx`: query results
