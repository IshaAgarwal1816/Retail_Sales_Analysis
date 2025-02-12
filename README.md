# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Database**: `sql_project1`

This project is designed to demonstrate SQL skills and techniques typically used to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. 

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `sql_project1`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE sql_project1;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```
### 2. Understanding the Data

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
  
```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;
```

### 3. Data Cleaning

**Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
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
```

### 4. Data Exploration

1. **How many sales we have?**
```sql
SELECT COUNT(*) AS Total_sales 
FROM retail_sales;
```

2. **What is the variation in sales? (What are the minimum and maximum sales figures observed)**
```sql
SELECT 
   MIN(total_sale) as min_sale_value,
   MAX(total_sale) as max_sale_value
FROM retail_sales;
```

3. **How many unique customers we have?**
```sql
SELECT COUNT(DISTINCT(customer_id)) 
FROM retail_sales;
```

4. **How many categories we have?**
```sql
SELECT DISTINCT(category) 
FROM retail_sales;
```

5. **What is the average Transaction Value?**
```sql
SELECT 
SUM(total_sale) / COUNT(DISTINCT(transactions_id)) AS avg_transaction_value
FROM retail_sales;
```

6. **How many repeat customers exist?**
```sql
SELECT
  customer_id, 
  COUNT(customer_id) AS no_of_purchases
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(customer_id)>1
ORDER BY no_of_purchases DESC;
```

7. **How does the sales volume vary across different product categories?**
```sql
SELECT 
  category,
  SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY  category;
```


### 5. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
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
```

3. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category**:
```sql
SELECT
  ROUND(AVG(age)) as average_age
FROM retail_sales
WHERE category = 'Beauty';
```

4. **Write a SQL query to find all transactions where the total_sale is greater than 1000**:
```sql
SELECT *
FROM retail_sales
WHERE total_sale>1000;
```

5. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category**:
```sql
SELECT
    category,
    gender,
    COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY 
    category,
    gender
ORDER BY category;
```

6. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
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
```

7. **Write a SQL query to find the top 5 customers based on the highest total sales**:
```sql
SELECT
   customer_id AS customers, 
   SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customers
ORDER BY total_sales DESC
LIMIT 5;
```

8. **Write a SQL query to find the number of unique customers who purchased items from each category**:
```sql
SELECT
  category,
  COUNT(DISTINCT(customer_id)) AS no_of_customers
FROM retail_sales
GROUP BY category;
```

9. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
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
```

10. **What are the peak sales hours during the day**:
```sql
SELECT 
    EXTRACT(HOUR FROM sale_time) AS sale_hour, 
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY sale_hour
ORDER BY total_sales DESC;
```

11. **Which category had the highest profit margin (Total Sales - COGS)**:
```sql
SELECT 
  category,
  ROUND(SUM(total_sale - cogs)) AS profit_margin
FROM retail_sales
GROUP BY category
ORDER BY profit_margin DESC;
```

12. **What is the average spending per customer**:
```sql
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
```

13. **What are the top 10 highest spending customers**:
```sql
SELECT 
    customer_id, 
    SUM(total_sale) AS total_spent_per_customer
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spent_per_customer DESC LIMIT 10;
```

14. **Find the gender wise distribution of sales across categories**:
```sql
SELECT 
  category,
  gender,
  SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY
  category,
  gender
ORDER BY category, total_sales DESC;
```

15. **Which day of the week sees the highest sales volume**:
```sql
SELECT 
    DAYNAME(sale_date) AS day_of_week,  
    COUNT(*) AS total_sales  
FROM retail_sales
GROUP BY day_of_week
ORDER BY total_sales DESC
LIMIT 1; 
```

16. **Find customers who made at most two purchases in different months**:
```sql
SELECT customer_id
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT DATE_FORMAT(sale_date, '%Y-%m')) <= 2;
```

17. **Find customers who only buy from one product category**:
```sql
SELECT customer_id, MAX(category) AS only_category
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT category) = 1;
```


## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

