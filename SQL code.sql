CREATE table if not exists sales(
invoice_id varchar(30) NOT null Primary key,
branch varchar(30) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price decimal(10, 2) not null,
quantity int not null,
VAT FLOAT(6, 4) not null,
total decimal(12, 4) not null,
date date not null,
time TIME not null,
payment_method varchar(15) not null,
cogs decimal(10, 2) not null,
gross_margin_pct float(11, 9), 
gross_income decimal(12, 4) not null,
rating float(2, 1) 
);
 

--  Feature engineering ---------
-- to add time of day -------
select time,
case 
When time between "00:00:00" and "12:00:00" then "Morning"
When time between "12:00:01" and "16:00:00" then "Afternoon"
else "Evening" 
End 
AS Time_of_day From sales;

Alter Table sales Add column Time_of_day varchar(20);

UPDATE Sales 
Set Time_of_day = case 
When time between "00:00:00" and "12:00:00" then "Morning"
When time between "12:00:01" and "16:00:00" then "Afternoon"
else "Evening" 
End ;

-- Add Day name-----
select date,
dayname(date)
from sales;

ALter Table sales Add column Day_name varchar(10);

Update Sales
Set Day_name = dayname(date);

-- Add Month name----
Select date,
monthname(Date)
from sales;

Alter table sales modify column Month_name varchar(15);
Update sales
Set Month_name = monthname(date);

-- EDA Generic----

-- 1. Unique cicties and branches the data has-----
Select distinct City
from sales;
 
 -- 2. City in each branch-----
select distinct city, branch 
from sales;

-- Product based questions-----------------------------------------------------------------------------
-- 1. How many unique product lines does the data have?--
select 
Count(Distinct product_line) 
from sales;

-- 2. What is the most common payment method?--
SELECT payment_method, COUNT(payment_method) as Cnt
FROM sales 
GROUP BY payment_method
order by cnt DESC;

-- 3. What is the most selling product line?--
Select product_line, count(product_line) as cnt
from sales group by product_line
order by cnt desc;

-- 4. What is the total revenue by month?--
Select month_name as month,
SUM(total) as total_revenue
 from sales
 group by Month
 order by total_revenue DESC;
 
-- 5. What month had the largest COGS?--
 Select month_name as month1, 
 sum(cogs) as Total_cogs
 from sales
 Group by month1 
 order by Total_cogs;
 
-- 6. What product line had the largest revenue?--
Select product_line, SUM(total) as Ptotal from sales
Group by product_line
order by Ptotal DESC;

-- 7. What is the city with the largest revenue?--
Select city, sum(total) as revenue
from sales
group by city
order by revenue DESC;

-- 8. What product line had the largest VAT?--
Select product_line, avg(VAT) 
From sales
group by product_line
order by avg(VAT) Desc;

-- 9.Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales --
SELECT product_line, SUM(total) AS total_sales,
CASE  WHEN SUM(total) > (SELECT AVG(total) FROM sales) THEN 'Good'
ELSE 'Bad'
END AS sales_performance
FROM sales
GROUP BY product_line;

-- 10. Which branch sold more products than average product sold?--
select branch, sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);

-- 11. What is the most common product line by gender?--
select gender, product_line,
count(gender) as totalcount from sales
group by gender, product_line
order by totalcount desc;

-- 12. What is the average rating of each product line?--
Select round(avg(rating), 2) as rtng, product_line
from sales
group by product_line
order by rtng desc;


-- -----------------------------------------------------Sales------------------------------------

-- 1. Number of sales made in each time of the day per weekday--
select time_of_day, day_name, count(*) as totalsales 
from sales
GROUP BY day_name, time_of_day
ORDER BY FIELD(day_name, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
         FIELD(time_of_day, 'Morning', 'Afternoon', 'Evening');

-- 2. Which of the customer types brings the most revenue? --
select customer_type, sum(total) as totalrev 
from sales
group by customer_type
order by totalrev;

-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?--
Select city, round(avg(VAT), 2) as vatper
from sales
group by city
order by vatper;

-- 4. Which customer type pays the most in VAT?--
Select customer_type, round(avg(VAT), 2) as vatper
from sales
group by customer_type
order by vatper desc;

-- customer -----------------------------------------------------------------------------------------------

-- 1. How many unique customer types does the data have?---
select count(distinct customer_type) as count_of_customer_type
from sales;

-- 2. How many unique payment methods does the data have?--
select count(distinct payment_method) as paymenttype
from sales;

-- 3. What is the most common customer type?--
select customer_type, count(customer_type) as cnttype
from sales
group by customer_type
order by cnttype desc;

-- 4. Which customer type buys the most?--
select customer_type, sum(total) as ttlrev
from sales
group by customer_type
order by ttlrev desc;
-- SELECT customer_type, COUNT(*) FROM sales GROUP BY customer_type;-------

-- 5. What is the gender of most of the customers?--
Select gender, count(*) from sales
group by gender;

-- 6. What is the gender distribution per branch?--
select branch, gender, count(*) as gndrcnt
from sales
group by branch, gender
order by field(gender, 'Male', 'Female'), gndrcnt;

-- 7. Which time of the day do customers give most ratings?--
select Time_of_day, count(rating) as rtngcnt
from sales
group by Time_of_day
order by rtngcnt desc;

-- 8. Which time of the day do customers give most ratings per branch?--
select Time_of_day, branch, count(rating) as rtngcnt
from sales
group by Time_of_day, branch
order by rtngcnt desc;

-- 9. Which day of the week has the best avg ratings?--
select Day_name, round(avg(rating) ,2) as rtngavg
from sales
group by Day_name
order by rtngavg desc;

-- 10. Which day of the week has the best average ratings per branch?--
select Day_name, branch, round(avg(rating), 2) as rtngavg
from sales
group by Day_name, branch
order by rtngavg desc;