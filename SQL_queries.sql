CREATE DATABASE IF NOT EXISTS  salesDataWalmart; -- Creating the Database salesDataWalmart


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
   
--      Feature engineering     --
-- time of day--
SELECT 
time ,
(CASE 
     WHEN time BETWEEN '00:00:00' and '12:00:00' THEN "Morning"
     WHEN time BETWEEN '12:01:00' and '16:00:00' THEN "Afternoon"
     ELSE "Evening"
     END
) as time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales 
SET time_of_day = (
   CASE 
     WHEN time BETWEEN '00:00:00' and '12:00:00' THEN "Morning"
     WHEN time BETWEEN '12:01:00' and '16:00:00' THEN "Afternoon"
     ELSE "Evening"
    END
);
-- Day name --
ALTER TABLE sales 
ADD COLUMN day_name VARCHAR(10);

UPDATE sales 
SET day_name = DAYNAME(date);

-- Month Name--
ALTER TABLE sales 
ADD COLUMN month_name VARCHAR(20);

UPDATE sales 
SET month_name = MONTHNAME(date);
   
-- ---------------------------------------------------------------------------------------
-- How many unique cities does the data have?
SELECT 
    DISTINCT city 
FROM sales;

-- In which city is each branch?----
SELECT 
    DISTINCT branch,
    city 
FROM sales;

-- How many unique product lines does the data have?
SELECT 
    COUNT(DISTINCT product_line)
FROM sales;

-- What is the most selling product line?
SELECT 
    product_line,
    COUNT(product_line) as cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- What is the top most common payment method?
SELECT 
   payment,
   COUNT(payment) as cnt
FROM sales 
GROUP BY payment
ORDER BY cnt DESC
LIMIT 1 ;

-- What is the total revenue by month?
SELECT 
   SUM(total) as total_revenue,
   month_name
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT 
   month_name,
   SUM(cogs) as total
FROM sales
GROUP BY month_name
ORDER BY total DESC ;

-- What product line had the largest revenue?
SELECT 
   product_line,
   SUM(total)as revenue
FROM sales
GROUP BY product_line
ORDER BY revenue DESC;

-- What is the city with the largest revenue?
SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch 
ORDER BY total_revenue;


-- What product line had the largest VAT?
SELECT
	product_line,
	AVG(tax_pct) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;


-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales
-- USING subquery

SELECT 
   product_line,
   CASE WHEN avg(quantity) > (SELECT avg(quantity) FROM sales) THEN "Good"
   ELSE "BAD"
   END as rating
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?

SELECT branch
FROM sales
GROUP BY branch
HAVING (AVG(quantity) > (SELECT AVG(quantity) FROM sales));

-- What is the most common product line by gender?
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line

SELECT product_line, avg(rating) as avg_rating
FROM sales
GROUP BY product_line;

-- CUSTOMERS
-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM sales;


-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?

SELECT customer_type,
       SUM(total) as total
FROM sales
GROUP BY customer_type
ORDER BY total DESC;

-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT branch,gender,COUNT(*)
FROM SALES
WHERE branch = "c"
GROUP BY branch,gender;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give good ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- The average ratings are almost same so I don't think the time of the day effects the rating.

-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.

-- Which day fo the week has the best avg ratings?
SELECT day_name,AVG(rating) as avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

SELECT day_name,COUNT(*) as total
FROM sales
GROUP BY day_name
ORDER BY total DESC;

-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?
-- Even though sales are high on Saturday  the ratings are not high so this means
-- there is no corelation between rating and the sales 

-- -Sales---

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;





       


