# Retail Campaign Targeting

Goal: Learn from the dataset who to target, when to send, and what to promote using SQL. 

### Business Question: How should a retailer target and time a promotional campaign for West-region and Consumer-segment customers, based on purchasing activity and product preferences?

## Data
Four tables (`customers`, `orders`, `order_items`, `products`) covering 5,000 customers and 25,000 orders from Jan 2024 to Dec 2025.

## Methods Used
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
Target the 911 West and "Consumer" customers, send promotions on Tuesday, Wednesday, or Friday at any time of year, and lead with Office Supplies and Home & Kitchen.

## Limitations
Timing differences are small. For example, Tuesday had 3,678 orders and Sunday had 3,466, which is only about a 6% gap. This is a weak signal, so "send Tue/Wed/Fri" is a reasonable guess initally, but not a proven result. An A/B test would be better, where we would send the same campaign on different days to similar customer groups and compare responses, to see whether the day actually changes results.
