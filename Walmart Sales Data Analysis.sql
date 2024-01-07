-- ********************************Walmart Sales Data Analysis ***********************************************

-- STEP 1: Data Wrangling: This is the first step where inspection of data is done to make sure NULL values and missing values are detected 
-- and data replacement methods are used to replace, missing or NULL values.
-- 1.Build a database
-- 2.Create table and insert the data.
-- 3.Select columns with null values in them. There are no null values in our database as in creating the tables, we set NOT NULL for each field, hence null values are filtered out.

-- Create database
CREATE DATABASE IF NOT EXISTS salesDatawalmart;
-- Use database
use salesDatawalmart;

-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- AFTER IMPORTING DATA LETS VIEW OUR  AND EGIN WITH DATA CLEANING
SELECT * FROM SALES;

-- STEP : 2 Feature Engineering: This will help use generate some new columns from existing ones.
-- Add a new column named time_of_day to give insight of sales in the Morning, Afternoon and Evening. 
-- This will help answer the question on which part of the day most sales are made.

-- Add the time_of_day column

SELECT 
      time,
      (
      CASE 
          WHEN  time BETWEEN  "00:00:00" AND "12:00:00" THEN "Morning"
          WHEN  time BETWEEN  "12:01:00" AND "16:00:00" THEN "Afternoon"
          ELSE "Evening"
          END
      ) AS time_of_day
FROM SALES;

-- Lets alter tale to add time_of_day column 
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

-- Insert data into time_of_day using update table
UPDATE sales 
SET time_of_day =  (
      CASE 
          WHEN  time BETWEEN  "00:00:00" AND "12:00:00" THEN "Morning"
          WHEN  time BETWEEN  "12:01:00" AND "16:00:00" THEN "Afternoon"
          ELSE "Evening"
          END
      );
      

-- Add a new column named day_name that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). 
-- This will help answer the question on which week of the day each branch is busiest
SELECT 
      date,
      DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales 
SET day_name = DAYNAME(date);

-- Similary Add a new column named month_name that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). 
-- Help determine which month of the year has the most sales and profit.
SELECT 
      date,
      MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales 
SET month_name =MONTHNAME(date);

-- STEP 3 : Data Analysis
/****************************** Business Questions ***********************************************/
-- 1. How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM sales;

-- 2. In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM sales;

/************ Questions on Product data **************/
-- 3.How many unique product lines does the data have?
SELECT 
      DISTINCT product_line
FROM sales;

-- 4. What is the most selling product line
SELECT 
       product_line,
      SUM(quantity) as qty
FROM Sales 
GROUP BY product_line
ORDER BY qty DESC
LIMIT 1 ;

-- RESULT
-- Electronic accessories	961

-- 5. What is the most common payment method?
SELECT 
       payment,
      COUNT(payment) as cnt
FROM Sales 
GROUP BY payment
ORDER BY cnt DESC
LIMIT 1 ;

-- RESULT : Cash	344

-- 6. What is the total revenue by month?
SELECT 
    month_name as month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month 
ORDER BY total_revenue;

-- RESULT 
/*February	95727.3765
March	108867.1500
January	116291.8680*/

-- 7.What month had the largest COGS?
SELECT 
    month_name as month,
    SUM(cogs) AS total_cogs
FROM sales
GROUP BY month 
ORDER BY total_cogs desc
LIMIT 1;

-- RESULT
/* January	110754.16*/

-- 8 .What product line had the largest revenue?
SELECT
	product_line,
	SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;

-- Result
/* Food and beverages	56144.8440*/
-- 9. Which is the city with the largest revenue?

SELECT
	city,
	SUM(total) as total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

-- Result : Naypyitaw	110490.7755

-- 10.What product line had the largest VAT?
SELECT
	product_line,
	AVG(tax_pct) as VAT
FROM sales
GROUP BY product_line
ORDER BY VAT DESC
LIMIT 1;

-- RESULT : Home and lifestyle	16.03033124

-- 11.Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

-- Avg Qty -5.4995

SELECT 
      product_line,
      CASE
          WHEN AVG(quantity) > 6 then "Good"
          ELSE "Bad"
          END AS remark 
FROM sales
GROUP BY product_line;

-- Result
/*Food and beverages	Bad
Health and beauty	Bad
Sports and travel	Bad
Fashion accessories	Bad
Home and lifestyle	Bad
Electronic accessories	Bad*/

-- 12. Which branch sold more products than average product sold?
SELECT 
     branch,
     SUM(quantity) as qty
FROM sales 
GROUP  BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales)
ORDER BY qty DESC
LIMIT 1;

-- RESULT : A	1849

-- 13.What is the most common product line by gender?
SELECT 
      gender,
      product_line,
      COUNT(gender) AS total_cnt
FROM sales 
GROUP BY gender,product_line
ORDER BY total_cnt desc;

-- Result :
/* Female	Fashion accessories	96
Female	Food and beverages	90
Male	Health and beauty	88
Female	Sports and travel	86
Male	Electronic accessories	86
Male	Food and beverages	84
Female	Electronic accessories	83
Male	Fashion accessories	82
Male	Home and lifestyle	81
Female	Home and lifestyle	79
Male	Sports and travel	77
Female	Health and beauty	63*/

-- 14.What is the average rating of each product line?
SELECT 
       product_line,
      ROUND(AVG(rating),2) as avg_rating
FROM sales 
GROUP BY product_line
ORDER BY avg_rating DESC;

-- RESULT :
/*Food and beverages	7.11
Fashion accessories	7.03
Health and beauty	6.98
Electronic accessories	6.91
Sports and travel	6.86
Home and lifestyle	6.84*/

/************ Questions on Sales data **************/
-- 15. Number of sales made in each time of the day per weekday

SELECT 
      time_of_day,
      count(*) as total_sales
FROM sales 
GROUP BY time_of_day
ORDER BY total_sales DESC;

/* Evening	429
Afternoon	376
Morning	190*/

-- 15. Number of sales made in each time of the day for sunday
SELECT 
      time_of_day,
      count(*) as total_sales
FROM sales 
WHERE day_name = "Sunday"
GROUP BY time_of_day
ORDER BY total_sales DESC;

/* Evening	58
Afternoon	52
Morning	22 */


-- 16 .Which of the customer types brings the most revenue?
SELECT 
     DISTINCT customer_type 
FROM sales;

SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;

-- Member	163625.1015

-- 17.Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS VAT
FROM sales
GROUP BY city 
ORDER BY VAT DESC
LIMIT 1;

-- RESULT : Naypyitaw	16.09

-- 18. Which customer type pays the most in VAT?
SELECT
	customer_type,
    ROUND(AVG(tax_pct), 2) AS VAT
FROM sales
GROUP BY city 
ORDER BY VAT DESC
LIMIT 1;

-- Member	16.09

/************ Questions on Customer data **************/
-- 19. How many unique customer types does the data have?
SELECT
	count(DISTINCT customer_type) as unique_customer
FROM sales;
-- unique_customer -2

-- 20.How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM sales;

-- Credit card
-- Ewallet
-- Cash

-- 21.What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

/* Member	499
Normal	496*/

-- 22. What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;
/* Male	498
Female	497*/

-- 23.What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;

/* Female	177
Male	150*/

-- 24.Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

/* Afternoon	7.02340
Morning	6.94474
Evening	6.90536*/

-- 25.Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;

/* Afternoon	7.18889
Morning	7.00548
Evening	6.87143 */

-- 26.Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC
LIMIT 1;

-- Monday	7.13065

-- 27.Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC
LIMIT 1;

/* Tuesday	54*/


























































































 












