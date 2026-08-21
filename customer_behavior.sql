USE customer_behavior;

SELECT * 
FROM customer_behavior_cleaned
LIMIT 50;
-- Q1: What is the total revenue geneated by male vs. female customers?

SELECT gender, SUM(purchase_amount_) as Revenue
FROM customer_behavior_cleaned
GROUP BY gender

-- Q2: Which customers used a discount but still spend more than the average purchase amount?

SELECT customer_id, purchase_amount_
FROM customer_behavior_cleaned
WHERE discount_applied = 'Yes' and purchase_amount_ >= (select AVG(purchase_amount_) FROM customer_behavior_cleaned)

-- Q3: Which are the top 5 products with the highest average review rating?
SELECT item_purchased, AVG(review_rating) as "Average Product Rating"
FROM customer_behavior_cleaned
GROUP BY item_purchased
ORDER BY AVG(review_rating) DESC
LIMIT 5;

-- Q4: Compare the average Purchase Amounts between Standard and Express Shipping.
select shipping_type, AVG(purchase_amount_)
FROM customer_behavior_cleaned
WHERE shipping_type in ('Standard', 'Express')
group by shipping_type;

-- Q5: Do subscribed customers spend more? Compare average spend and total revenue between subscribers and non-subscribers?
SELECT subscription_status,
COUNT(customer_id) as Total_customers,
AVG(purchase_amount_) as avg_spend,
SUM(purchase_amount_) as Total_revenue
FROM customer_behavior_cleaned
GROUP BY subscription_status
ORDER BY Total_revenue, avg_spend DESC;

-- Q6: Which 5 products have the highest percentage of purchases with discounts applied?
SELECT item_purchased,
ROUND(SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*) * 100,2) as discount_rate
FROM customer_behavior_cleaned
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- Q7: Segment customers into New, Returning, and Loyal based on their total number of previous purchases, and show the count of each statement?
with customer_type as ( 
SELECT customer_id, previous_purchases,
CASE
WHEN previous_purchases = 1 THEN 'New'
WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
ELSE 'Loyal'
END AS customer_segment
from customer_behavior_cleaned
)
SELECT customer_segment, COUNT(*) as "Number of customers"
FROM customer_type
GROUP BY customer_segment
  
-- Q8: What are the top 3 most purchased products within each category?
with item_count as (
SELECT category, item_purchased, COUNT(customer_id) as total_orders,
ROW_NUMBER() over(partition by category order by COUNT(customer_id) DESC) as item_rank
from customer_behavior_cleaned
group by category, item_purchased
)
SELECT item_purchased, total_orders, item_rank, category
from item_count
where item_rank >=3;

-- Q9: Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT subscription_status,
COUNT(customer_id) as repeat_buyers
from customer_behavior_cleaned
where previous_purchases > 5
GROUP BY subscription_status

-- Q10: What is the revenue contribution of each age group?
SELECT age_group, SUM(purchase_amount_) AS total_revenue
FROM customer_behavior_cleaned
GROUP BY age_group
ORDER BY total_revenue DESC;
