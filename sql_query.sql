-- CREATING TABLE

CREATE TABLE retail_sales 
(transactions_id INT PRIMARY KEY,	
sale_date DATE, 
sale_time	TIME,
customer_id	INT,
gender	VARCHAR(15),
age	INT,
category VARCHAR(50),	
quantiy	INT,
price_per_unit 	FLOAT,
cogs	FLOAT,
total_sale FLOAT ); 

SELECT * FROM retail_sales
LIMIT 10;


SELECT COUNT(*) 
FROM retail_sales;

-- DATA CLEANING

SELECT * FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantiy IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
SET SQL_SAFE_UPDATES = 0;
    
DELETE FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantiy IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
    
-- DATA EXPLORATION

-- 1. How many sales we have?
SELECT COUNT(*) AS Total_sales 
FROM retail_sales;

-- 2. What is the variation in sales? (What are the minimum and maximum sales figures observed? )
SELECT 
   MIN(total_sale) as min_sale_value,
   MAX(total_sale) as max_sale_value
FROM retail_sales;

-- 3. How many unique customers we have?
SELECT COUNT(DISTINCT(customer_id)) 
FROM retail_sales;

-- 4. How many categories we have?
SELECT DISTINCT(category) 
FROM retail_sales;

-- 5. Average Transaction Value
SELECT 
SUM(total_sale) / COUNT(DISTINCT(transactions_id)) AS avg_transaction_value
FROM retail_sales;

-- 6. How many repeat customers exist?
SELECT
  customer_id, 
  COUNT(customer_id) AS no_of_purchases
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(customer_id)>1
ORDER BY no_of_purchases DESC;

-- 7. How does the sales volume vary across different product categories?
SELECT 
  category,
  SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY  category;

-- DATA ANALYSIS 

-- 1. Write a SQL query to retrieve all columns for sales made on '2022-11-05:
SELECT *
FROM retail_sales
WHERE sale_date= '2022-11-05';

-- 2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:
-- APPROACH 1
SELECT *
FROM retail_sales
WHERE 
     category = 'Clothing' 
     AND
     sale_date BETWEEN '2022-11-01' AND '2022-11-30' 
     AND
     quantiy >= '4';
     
-- APPROACH 2
SELECT * 
FROM retail_sales 
WHERE 
   category = 'Clothing' 
   AND 
   quantiy >= 4 
   AND 
   YEAR(sale_date) = 2022 
   AND 
   MONTH(sale_date) = 11;

-- APPROACH 3
SELECT *
FROM retail_sales
WHERE 
     category = 'Clothing' 
     AND
     DATE_FORMAT(sale_date, '%Y-%m') = '2022-11' 
     AND
     quantiy >= '4';

-- 3. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
SELECT
  ROUND(AVG(age)) as average_age
FROM retail_sales
WHERE category = 'Beauty';

-- 4. Write a SQL query to find all transactions where the total_sale is greater than 1000.:
SELECT *
FROM retail_sales
WHERE total_sale>1000;

-- 5. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category
SELECT
    category,
    gender,
    COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY 
    category,
    gender
ORDER BY category;

-- 6. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
-- Average sale for each month
SELECT 
	YEAR(sale_date) AS year,
    MONTHNAME(sale_date) AS month,
    AVG(total_sale) AS avg_monthly_sale
FROM retail_sales
GROUP BY year, month
ORDER BY year, month;

-- Best selling month in each year
SELECT year, month, avg_sale
FROM (
    SELECT 
        YEAR(sale_date) AS year,
        MONTH(sale_date) AS month,
        AVG(total_sale) AS avg_sale
    FROM retail_sales
    GROUP BY year, month
) AS t1
WHERE avg_sale = (
    SELECT MAX(avg_sale)
    FROM (
        SELECT 
            YEAR(sale_date) AS year,
            MONTH(sale_date) AS month,
            AVG(total_sale) AS avg_sale
        FROM retail_sales
        GROUP BY year, month
    ) AS t2
    WHERE t2.year = t1.year
);
   
-- 7. Write a SQL query to find the top 5 customers based on the highest total sales
SELECT
   customer_id AS customers,  -- here, distinct serves no purpose because GROUP BY customers already ensures unique rows for each customer_id.
   SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customers
ORDER BY total_sales DESC
LIMIT 5;

-- 8. Write a SQL query to find the number of unique customers who purchased items from each category.:
SELECT
  category,
  COUNT(DISTINCT(customer_id)) AS no_of_customers
FROM retail_sales
GROUP BY category;

-- 9. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift;

-- 10. What are the peak sales hours during the day?
SELECT 
    EXTRACT(HOUR FROM sale_time) AS sale_hour, 
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY sale_hour
ORDER BY total_sales DESC;


-- 11. Which category had the highest profit margin (Total Sales - COGS)?
SELECT 
  category,
  ROUND(SUM(total_sale - cogs)) AS profit_margin
FROM retail_sales
GROUP BY category
ORDER BY profit_margin DESC;

-- 12. What is the average spending per customer?
-- Approach 1 : To just get the figure
SELECT 
  SUM(total_sale) / COUNT(DISTINCT(customer_id)) AS avg_customer_spending
FROM retail_sales;

-- Approach 2 : To display each customers avg spend
SELECT 
    customer_id, 
    SUM(total_sale) AS total_spent_per_customer,
    COUNT(*) AS total_transactions,
    SUM(total_sale) / COUNT(*) AS avg_spending_per_transaction
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spent_per_customer DESC;

-- 13. What are the top 10 highest spending customers?
SELECT 
    customer_id, 
    SUM(total_sale) AS total_spent_per_customer
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spent_per_customer DESC LIMIT 10;

-- 14. Find the gender wise distribution of sales across categories
SELECT 
  category,
  gender,
  SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY
  category,
  gender
ORDER BY category, total_sales DESC;
 
-- 15. Which day of the week sees the highest sales volume
SELECT 
    DAYNAME(sale_date) AS day_of_week,  -- Extracts the day of the week
    COUNT(*) AS total_sales  -- Counts the number of sales transactions
FROM retail_sales
GROUP BY day_of_week
ORDER BY total_sales DESC
LIMIT 1;  -- Returns the day with the highest sales volume

-- 16. Find customers who made at most two purchases in different months.
SELECT customer_id
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT DATE_FORMAT(sale_date, '%Y-%m')) <= 2;

-- 17. Find customers who only buy from one product category
SELECT customer_id, MAX(category) AS only_category
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT category) = 1;

-- (We use MAX(category) just to retrieve the category in a single-column aggregate function, 
-- as SQL requires all selected columns (other than aggregates) to be in the GROUP BY clause)

