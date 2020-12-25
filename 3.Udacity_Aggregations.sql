USE `parch and posey`;

--------------------------------------------
# NULL
--------------------------------------------
SELECT *
FROM accounts
WHERE primary_poc IS NULL;

SELECT COUNT(*)
FROM orders
WHERE account_id = 1001; # NUMBER OF ORDERS BY INTEL

SELECT COUNT(*)products 
FROM web_events
WHERE ID IS NULL;


--------------------------------------------
# COUNT
-- COUNT(*) COUNTS THE NUMBER OF ROWS IN A TABLE
-- COUNT(COLUMN_NAME) COUNTS THE NUMBER OF NON-NULL VALUES IN THAT SPECIFIC COLUMN
--------------------------------------------
SELECT COUNT(*) 
FROM accounts; # TOTAL NUMBER OF ACCOUNTS

SELECT COUNT(*)
FROM orders
WHERE account_id = 1001; # NUMBER OF ORDERS BY INTEL

--------------------------------------------------
# 7. QUIZZ SUM
--------------------------------------------------

# 1.Find the total amount of poster_qty paper ordered in the orders table
SELECT SUM(poster_qty)
FROM orders;	

------------------------------------------------------------------------
# 2.Find the total amount of standard_qty paper ordered in the orders table
SELECT SUM(standard_qty)
FROM orders;

------------------------------------------------------------------------
# 3.Find the total dollar amount of sales using the total_amt_usd in the orders table.alter
SELECT SUM(total_amt_usd)
FROM orders;

------------------------------------------------------------------------
# 4.Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order in the orders table.
#  This should give a dollar amount for each order in the table.
SELECT id AS ORDER_ID, account_id, (standard_amt_usd + gloss_amt_usd) AS total_amount
FROM orders;

------------------------------------------------------------------------
# 5.Find the standard_amt_usd per unit of standard_qty paper for wholde orders dataset (only output is requred).
# Your solution should use both an aggregation and a mathematical operator.
SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit
FROM orders;

--------------------------------------------------
 # MIN, MAX, AVG
 # MIN & MAX WORK WITH ALPHABETIC AND NUMERIC VALUES
 # AVG WORKS ONLY WITH NUMERIC VALUES
 -------------------------------------------------
 SELECT MIN(standard_qty), MAX(standard_qty),
		MIN(gloss_qty), MAX(gloss_qty),
        MIN(poster_qty), MAX(poster_qty),
        SUM(standard_qty), SUM(gloss_qty), SUM(poster_qty),
        MIN(occurred_at), MAX(occurred_at)
FROM orders;
# SUM OF TOTAL ORDERS FOR POSTER IS LESS THAN THE OTHER 2 ('723646') BUT THE MAXIMUM AMOUNT FOR 1 ORDER BELONGS TO POSTER ('28262')

 
SELECT MIN(name), MAX(name) #MIN & MAX WORKS WITH ALPHABETIC COLUMNS AS WELL
FROM accounts;


SELECT AVG(standard_qty),
	   AVG(gloss_qty),
	   AVG(poster_qty)
FROM orders;
# THE BIGGEST ORDER BELONGES TO POSTER ('28262'), BUT AVERAGE SHOWS THAT THAT NUMBER WAS AN OUTLIER CAUSE THE AVG OF ALL POSTER ORDERS IS MUCH SAMLLER THAN THAT NUMBER.(104)

--------------------------------------------------------
# 11. QUIZ MIN MAX AVG		
----------------------------------------------------------
# 1.When was the earliest order ever placed? You only need to return the date.
SELECT MIN(occurred_at)
FROM orders;

------------------------------------------------------------------------
# 2.Try performing the same query as in question 1 without using an aggregation function.
SELECT occurred_at
FROM orders
ORDER BY occurred_at
LIMIT 1;

------------------------------------------------------------------------
# 3.When did the most recent (latest) web_event occur?
SELECT MAX(occurred_at)
FROM web_events;

------------------------------------------------------------------------
# 4.Try to perform the result of the previous query without using an aggregation function.
SELECT occurred_at 
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

------------------------------------------------------------------------
# 5.FOR EACH PAPER TYPE, Find the mean (AVERAGE) number of sales, as well as the average amount. Your final answer should BE 1 RESULT WITH 6 values.
SELECT AVG(standard_qty) , AVG(gloss_qty) , AVG(poster_qty) ,
	   AVG(standard_amt_usd) , AVG(gloss_amt_usd) , AVG(poster_amt_usd) 
FROM orders;

------------------------------------------------------------------------
# 6.what is the MEDIAN total_usd spent on all orders?
SELECT COUNT(*)/2
FROM orders; # 3456 IS THE HALF OF DATA AND BECAUSE IT'S AN EVEN NUMBER, WE NEED TO AVERAGE IT WITH THE NEXT NUMBER

SELECT total_amt_usd
FROM orders
ORDER BY total_amt_usd
LIMIT 3457; # TAKE A LOOK AT THE FIRST HALF OF ORDERED DATA

SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT 3457) AS Table1 # SELECTING THE FIRST HALF OF ORDERED DATA
ORDER BY total_amt_usd DESC # RE-ORDERING DATA FROM HIGH TO LOW
LIMIT 2; # SELECTING THE FIRST 2 VALUES
# THE FINAL RESULT IS THE AVAREGE OF THESE 2 ELEMENTS 

--------------------------------------------------------------
# GROUP BY
# Any column in the SELECT statement that is not within an aggregator MUST be in the GROUP BY clause
# The GROUP BY always goes between WHERE and ORDER BY
--------------------------------------------------------------
SELECT account_id, # account_id MUST BE IN GROUP BY
	   SUM(poster_qty) ,
	   SUM(standard_qty) ,
	   SUM(gloss_qty) ,
      (SUM(poster_qty) + SUM(standard_qty) + SUM(gloss_qty)) / 3 AS AVG_ORDER_QTY # AVERAGE OF THOSE 3 ORDERD QUANTITIES
FROM orders
GROUP BY account_id
-- ORDER BY account_id
ORDER BY AVG_ORDER_QTY DESC
LIMIT 10; # ONLY 10 WITH HIGHEST AVERAGE ORDERED QUANTITY

----------------------------------------------------------------------
# 14. QUIZ GROUP BY
-----------------------------------------------------------------------
# 1.Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order

SELECT MIN(occurred_at)
FROM orders;

SELECT * FROM orders
WHERE occurred_at = '2013-12-04 04:22:44';

SELECT * FROM accounts
WHERE ID = '2861';

SELECT O.occurred_at, O.account_id, A.name
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
ORDER BY O.occurred_at
LIMIT 1;
    
-- OR

SELECT *  # FIND THE ROW FOR THE EARLIEST DATE
FROM web_events
WHERE occurred_at = (SELECT MIN(occurred_at) 
                    FROM web_events);
                    
SELECT occurred_at, account_id, A.name  
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
	AND O.occurred_at = (SELECT MIN(occurred_at) 
					FROM orders);


------------------------------------------------------------------------
# 2.Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.

SELECT account_id, SUM(total) # THIS IS WITHOUT COMPANY'S NAME
FROM orders
GROUP BY account_id;

SELECT A.name, SUM(O.total_amt_usd) AS total_sales # NOW WE NEED TO JOIN WITH ACCOUNT TABLE TO ADD COMPANY'S NAME
FROM orders O
JOIN accounts A
	ON  O.account_id = A.id
GROUP BY account_id;
-- GROUP BY A.name; BOTH WORKS HERE


------------------------------------------------------------------------
# 3.Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? 
# Your query should return only three values - the date, channel, and account name.

SELECT W.occurred_at MOST_RECENT, W.channel, A.name
FROM web_events W
JOIN accounts A
	ON W.account_id =  A.id
	AND occurred_at = (SELECT MAX(occurred_at) 
					  FROM web_events);
    
-- OR --

SELECT w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id 
ORDER BY w.occurred_at DESC
LIMIT 1;

------------------------------------------------------------------------
# 4.Find the total number of times each type of channel from the web_events was used.
# Your final table should have two columns - the channel and the number of times the channel was used.

SELECT COUNT(ID) NUMBER_OF_TIMES_USED, channel 
FROM web_events
GROUP BY channel
ORDER BY NUMBER_OF_TIMES_USED DESC; 


------------------------------------------------------------------------
# 5.Who was the primary contact associated with the earliest web_event?

SELECT MIN(occurred_at) FROM web_events; # EARLIEST DATE

SELECT *  # ROW FOR THE EARLIEST DATE
FROM web_events
WHERE occurred_at = (SELECT MIN(occurred_at) 
                    FROM web_events);
                    
SELECT W.occurred_at EARLIEST_OCCURED_DATE, A.primary_poc
FROM web_events W
JOIN accounts A
	ON W.account_id = A.id
    AND W.occurred_at = (SELECT MIN(occurred_at)
					     FROM web_events);
    
-- OR --

SELECT a.primary_poc
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at
LIMIT 1;

------------------------------------------------------------------------
# 6. What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd. 
# Order from smallest dollar amounts to largest.

SELECT MIN(O.total_amt_usd) SMALLEST_ORDER_AMT, A.name ACCOUNT_NAME
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
GROUP BY account_id
ORDER BY MIN(total);


------------------------------------------------------------------------
# 7.Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. Order from fewest reps to most reps

SELECT  S.region_id, R.name REGION_NAME, COUNT(S.name) NUMBER_OF_SALES_REPS
FROM sales_reps S
join region r
	ON s.region_id = r.id
GROUP BY R.name
ORDER BY NUMBER_OF_SALES_REPS;

SELECT  S.region_id, R.name REGION_NAME
FROM sales_reps S
join region r
	ON s.region_id = r.id
GROUP BY R.name;
        
        
--------------------------------------------------------------------------------
# MULTIPLE GROUP BY
# The order of column names in your GROUP BY clause doesn’t matter—the results will be the same regardless
# The order of columns listed in the ORDER BY clause does make a difference. You are ordering the columns from left to right.
---------------------------------------------------------------------------------
SELECT account_id, 
		channel,
        COUNT(id) AS NUMBER_OF_EVENTS
FROM web_events
-- GROUP BY account_id, channel;
 GROUP BY channel, account_id # THE ORDER IN GROUP BY DOESN'T MATTER
 ORDER BY account_id, NUMBER_OF_EVENTS DESC;
 
 -----------------------------------------------------------------------------
 # 17. QUIZ GROUP BY Part II
 -----------------------------------------------------------------------------
 # 1.For each account, determine the average amount of each type of paper they purchased across their orders.
 # Your result should have four columns - one for the account name and one for the average quantity purchased
 # for each of the paper types for each account.
 
SELECT A.name, AVG(standard_qty), AVG(gloss_qty), AVG(poster_qty)
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
GROUP BY account_id
ORDER BY A.name;
 
 
------------------------------------------------------------------------
 # 2.For each account, determine the average amount spent per order on each paper type. 
 # Your result should have four columns - one for the account name
 # and one for the average amount spent on each paper type.
 
SELECT A.name, AVG(standard_amt_usd), AVG(gloss_amt_usd), AVG(poster_amt_usd)
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
GROUP BY A.name
ORDER BY A.name;

------------------------------------------------------------------------
# 3.Determine the number of times a particular channel was used in the web_events table for each sales rep.
# Your final table should have three columns - the name of the sales rep, the channel,
# and the number of occurrences. Order your table with the highest number of occurrences first.

SELECT COUNT(W.channel) number_of_occurrence, W.channel, S.name SALES_REP_NAME
-- OR USE COUNT(*)
FROM web_events W
JOIN accounts A
	ON W.account_id = A.id
JOIN sales_reps S
	ON A.sales_rep_id = S.id
GROUP BY W.channel, S.name
ORDER BY number_of_occurrence DESC;
    

------------------------------------------------------------------------    
# 4.Determine the number of times a particular channel was used in the web_events table for each region. 
# Your final table should have three columns - the region name, the channel, and the number of occurrences. 
# Order your table with the highest number of occurrences first.
 
SELECT W.channel, R.name # FIRST JOIN ALL THE TABLES
FROM web_events W
JOIN accounts A
	ON W.account_id = A.id
JOIN sales_reps S
	ON A.sales_rep_id = S.id
JOIN region R
	ON S.region_id = R.id;
    
SELECT W.channel, R.name REGION_NAME, COUNT(W.channel) number_of_occurrence # ADD COUNT() AND GROUP BY
-- OR USE COUNT(*)
FROM web_events W
JOIN accounts A
	ON W.account_id = A.id
JOIN sales_reps S
	ON A.sales_rep_id = S.id
JOIN region R
	ON S.region_id = R.id
GROUP BY W.channel, R.name
ORDER BY number_of_occurrence DESC;


--------------------------------------------------------------------------------
# DISTINCT
# DISTINCT provides the unique rows for ALL COLUMNS written in the SELECT statement. 
# Therefore, you only use DISTINCT ONCE in any particular SELECT statement.
---------------------------------------------------------------------------------
SELECT DISTINCT account_id, channel -- NO AGGREGATION FUCNTION HERE, NO NEED FOR GROUP BY
FROM web_events
-- GROUP BY account_id, channel    >> GROUP BY IS NOT NEEDED <<
ORDER BY account_id;
-- OR 
SELECT account_id, channel, COUNT(ID) -- COUNT() INSTEAD OF DISTINCT
FROM web_events
GROUP BY account_id, channel -- GOROUP BY IS NEEDED
ORDER BY account_id;

--------------------------------------------------------------------------------------
# 20.QUIZ DITINCT
---------------------------------------------------------------------------------------
# 1.Use DISTINCT to test if there are any accounts associated with more than one region.

SELECT A.id, A.name ACCOUNT_NAME, R.name REGION, COUNT(*)
FROM accounts A
JOIN sales_reps S
	ON A.sales_rep_id = S.id
JOIN region R
	ON S.region_id = R.id; # RETURNED NUMBER IS 351
    
SELECT DISTINCT id, name ACCOUNT_NAME, COUNT(*)
FROM accounts; # RETURNED NUMBER IS 351

# ANSWER IS NO, both queries have the same number of resulting rows (351), so we know that every account is
# associated with only one region. If each account was associated with more than one region,
# the first query should have returned more rows than the second query.

------------------------------------------------------------------------
# 2.Have any sales reps worked on more than one account?

SELECT DISTINCT name, COUNT(*)
FROM sales_reps;  -- 50 DISTINCT SALES REPS WE HAVE

SELECT S.name, A.name-- , COUNT(*)
FROM sales_reps S
JOIN accounts A
	ON S.id = A.sales_rep_id; -- 351 COMBINATION OF SALES REPS AND ACCOUNTS
    
# ANSWER IS YES. Actually all of the sales reps have worked on more than one account.
# The fewest number of accounts any sales rep works on is 3. There are 50 sales reps, and they all have more than one account. 
# Using DISTINCT in the second query assures that all of the sales reps are accounted for in the first query.

-------------------------------------------------------------------------------------
# HAVING
-- use HAVING to Iinstead of WHERE on an element of your query that was created by an AGGREGATE.
-------------------------------------------------------------------------------------
SELECT account_id, SUM(total_amt_usd) TOTAL_AMT_USED
FROM orders O
GROUP BY 1
	HAVING SUM(total_amt_usd) > 250000
ORDER BY 2 DESC;

---------------------------------------------------------------------
# 23.QUIZ HAVING
---------------------------------------------------------------------
# 1.How many of the sales reps have more than 5 accounts that they manage?

SELECT S.name SALES_REP_NAME, COUNT(*) NUMBER_OF_ACCOUNTS # FIRST WE NEEW TO FIND THESE SALES_REPS
FROM sales_reps S
JOIN accounts A
	ON S.id = A.sales_rep_id
GROUP BY S.name
HAVING COUNT(*) > 5
ORDER BY NUMBER_OF_ACCOUNTS DESC; 

# NOW WE USE SUBQUARY TO FIND THE NUMBER OF THESE SALES_REPS
SELECT COUNT(*) num_reps_above5
FROM(SELECT s.id, s.name, COUNT(*) num_accounts
     FROM accounts a
     JOIN sales_reps s
		ON s.id = a.sales_rep_id
     GROUP BY s.id, s.name -- THEY BOTH MUST BE IN GROUP BY BECAUSE THEYE ARE NOT AGGREGATED
     HAVING COUNT(*) > 5
     ORDER BY num_accounts) AS Table1;

------------------------------------------------------------------------     
# 2.How many accounts have more than 20 orders?

SELECT account_id, COUNT(*) NUMBER_OF_ORDERS -- FIND THESE ACCOUNTS
FROM orders
GROUP BY account_id
HAVING NUMBER_OF_ORDERS > 20
ORDER BY 2 DESC;

SELECT COUNT(*) NUMB_ACCOUNTS_WITH_ORDERS_ABOVE_20 -- NUMBER OF THESE ACCOUNTS
FROM( SELECT account_id, COUNT(*) NUMBER_OF_ORDERS
	  FROM orders
	  GROUP BY account_id
	  HAVING NUMBER_OF_ORDERS > 20) AS TABLE1;
 
------------------------------------------------------------------------     
# 3.Which account has the most orders?

SELECT O.account_id, A.name ACCOUNT_NAME, COUNT(*) NUMBER_OF_ORDERS -- 
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
GROUP BY ACCOUNT_NAME
ORDER BY NUMBER_OF_ORDERS DESC
LIMIT 1;

------------------------------------------------------------------------
# 4.How many accounts spent more than 30,000 usd total across all orders?

SELECT O.account_id, A.name, SUM(O.total_amt_usd) TOTAL_SPENT -- FIRST SHOW THESE ACCOUNTS 
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
GROUP BY O.account_id, A.name -- BOTH MUST BE IN GROUP BY BECAUSE THEY ARE NOT AGGREGATED
HAVING TOTAL_SPENT > 30000
ORDER BY TOTAL_SPENT DESC;

SELECT COUNT(*) NUM_ACCOUNTS_ABOVE_30000 -- NOW COUNT THE NUMBER OF THESE ACCOUNTS
FROM (SELECT O.account_id, A.name, SUM(O.total_amt_usd) TOTAL_SPENT
	FROM orders O
	JOIN accounts A
		ON O.account_id = A.id
	GROUP BY O.account_id, A.name
	HAVING TOTAL_SPENT > 30000) AS TABLE1;

------------------------------------------------------------------------    
# 5.How many accounts spent less than 1,000 usd total across all orders?

SELECT A.id, A.name ACCOUNT_NAME, SUM(O.total_amt_usd) TOTAL_AMOUNT_SPENT -- THESE ACCOUNTS
FROM accounts A
JOIN orders O
	ON A.id = O.account_id
GROUP BY A.id, A.name
HAVING TOTAL_AMOUNT_SPENT < 1000
ORDER BY TOTAL_AMOUNT_SPENT DESC;

SELECT COUNT(*) NUMB_ACCOUNTS_LESS_1000-- COUNT THEM
FROM(SELECT A.id, A.name ACCOUNT_NAME, SUM(O.total_amt_usd) TOTAL_AMOUNT_SPENT
	FROM accounts A
	JOIN orders O
		ON A.id = O.account_id
	GROUP BY A.id, A.name
	HAVING TOTAL_AMOUNT_SPENT < 1000) AS TABLE1;
    
 
------------------------------------------------------------------------   
# 6. Which account has spent the most with us?

SELECT A.id, A.name ACCOUNT_NAME, SUM(O.total_amt_usd) TOTAL_AMOUNT_SPENT -- THESE ACCOUNTS
FROM accounts A
JOIN orders O
	ON A.id = O.account_id
GROUP BY A.id, A.name
ORDER BY TOTAL_AMOUNT_SPENT DESC
LIMIT 1;

------------------------------------------------------------------------
# 7. Which account has spent the least with us?

SELECT A.id, A.name ACCOUNT_NAME, SUM(O.total_amt_usd) TOTAL_AMOUNT_SPENT -- THESE ACCOUNTS
FROM accounts A
JOIN orders O
	ON A.id = O.account_id
GROUP BY A.id, A.name
ORDER BY TOTAL_AMOUNT_SPENT 
LIMIT 1;

------------------------------------------------------------------------
 # 8. Which accounts used facebook as a channel to contact customers more than 6 times?
 
SELECT A.id, A.name, channel, COUNT(W.channel) USE_OF_CHANNEL -- FIRST LOOK AT THE THIS
FROM accounts A
JOIN web_events W
	ON A.id = W.account_id
GROUP BY A.id, A.name, W.channel -- W.channel MUST BE HERE TO SEPERATE THE CHANNELS FOR EACH ACCOUNT
ORDER BY A.name;

SELECT A.id, A.name, COUNT(W.channel) USE_OF_CHANNEL -- THE FINAL QUERRY
FROM accounts A
JOIN web_events W
	ON A.id = W.account_id
GROUP BY A.id, A.name, W.channel
HAVING USE_OF_CHANNEL > 6 AND W.channel = 'facebook'
ORDER BY A.name;

------------------------------------------------------------------------
# 9. Which account used facebook most as a channel?

SELECT A.id, A.name, channel, COUNT(W.channel) USE_OF_CHANNEL -- FIRST LOOK AT THE THIS
FROM accounts A
JOIN web_events W
	ON A.id = W.account_id
GROUP BY A.id, A.name, W.channel -- W.channel MUST BE HERE TO SEPERATE THE CHANNELS FOR EACH ACCOUNT
HAVING W.channel = 'FACEBOOK'
ORDER BY USE_OF_CHANNEL DESC
LIMIT 1; -- CHECK LIMIT 3 OR 5 FOR TIES

------------------------------------------------------------------------
# 10.Which channel was most frequently used by most accounts?

SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel -- FIRST LOOK AT THE FREQUENCY OF ALL CHANNELS FPR DIFFERENT ACCOUNTS
FROM accounts a
JOIN web_events w
	ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC;
-- LIMIT 10;


SELECT channel, SUM(use_of_channel) TOTAL_USE_OF_CHANNEL -- NOW LET'S LOOK AT TOTAL USE OF EACH CHANNEL
FROM(SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
	FROM accounts a
	JOIN web_events w
		ON a.id = w.account_id
	GROUP BY a.id, a.name, w.channel) AS TABLE1
GROUP BY channel;

------------------------------------------------------------------------------------------------
# DATE
# YYYY-MM-DD HH:MM:SS
# USE DATE FUNCTION TO TRUNCATE DATE
# 0 = Monday, 1 = Tuesday, … 6 = Sunday
# REFERENCE: https://dev.mysql.com/doc/refman/5.7/en/date-and-time-functions.html#function_date
------------------------------------------------------------------------------------------------

SELECT DATE(occurred_at) AS ONLY_DATE, SUM(standard_qty) -- EXTRACT DATE
FROM orders
GROUP BY SHORT_DATE
ORDER BY SHORT_DATE;

SELECT YEAR(occurred_at) AS ONLY_YEAR, SUM(standard_qty) -- EXTRACT YEAR
FROM orders
GROUP BY ONLY_YEAR
ORDER BY ONLY_YEAR;

SELECT MONTH(occurred_at) AS ONLY_MONTH, SUM(standard_qty) -- EXTRACT YEAR
FROM orders
GROUP BY ONLY_MONTH
ORDER BY ONLY_MONTH;

SELECT TIME(occurred_at) AS ONLY_TIME, SUM(standard_qty) -- EXTRACT TIME
FROM orders
GROUP BY ONLY_TIME
ORDER BY ONLY_TIME;

SELECT HOUR(occurred_at) AS ONLY_HOUR, SUM(standard_qty) -- EXTRACT HOUR
FROM orders
GROUP BY ONLY_HOUR
ORDER BY ONLY_HOUR;

SELECT DATE_FORMAT(occurred_at, '%Y-%m-%d') DATE_ONLY, -- EXTRACT DATE
       DATE_FORMAT(occurred_at,'%H:%i:%s') TIME_ONLY,  -- EXTRACT TIME
       DATE_FORMAT(occurred_at,'%Y') YEAR_ONLY -- EXTRACT YEAR
FROM orders;

# LET'S FIND WHICH DAY OF WEEK HAS THE MOST SELL
SELECT WEEKDAY(occurred_at) DAY_OF_WEEK, -- 0 = Monday, 1 = Tuesday, … 6 = Sunday
	   SUM(total) DAILY_SALE
FROM orders
GROUP BY DAY_OF_WEEK
ORDER BY DAILY_SALE DESC;

---------------------------------------------------------------
# 27.Quiz: DATE Functions
---------------------------------------------------------------
# 1.Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least.
# Do you notice any trends in the yearly sales totals?

SELECT YEAR(occurred_at) YEAR,
		SUM(total_amt_usd) YEARLY_SALE
FROM orders 
GROUP BY 1
ORDER BY 2 DESC;
-- SALES IN 2013 AND 2017 IS MUCH SMALLER THAN OTHER MPNTHS. LET'S LOOK AT MONTHLY SALES FOR SOME OF THESE YERAS

SELECT MONTH(occurred_at) MONTH, --  WE HAVE SALES IN ALL 12 MONTHS
		SUM(total_amt_usd) MONTHLY_SALE
FROM orders 
WHERE YEAR(occurred_at) = '2016'
GROUP BY 1
ORDER BY 2 DESC;

SELECT MONTH(occurred_at) MONTH, -- IN 2017 WE HAVE SALES ONLY IN THE FIRST MONTH
		SUM(total_amt_usd) MONTHLY_SALE
FROM orders 
WHERE YEAR(occurred_at) = '2017'
GROUP BY 1
ORDER BY 2 DESC;

SELECT MONTH(occurred_at) MONTH, -- IN 2013 WE HAVE SALES ONLY IN THE LAST MONTH
		SUM(total_amt_usd) MONTHLY_SALE
FROM orders 
WHERE YEAR(occurred_at) = '2013'
GROUP BY 1
ORDER BY 2 DESC;

-----------------------------------------------------------
# 2.Which month did Parch & Posey have the greatest sales in terms of total dollars? 
# Are all months evenly represented by the dataset?

SELECT MONTH(occurred_at) MONTH, SUM(total_amt_usd) MONTHLY_SALE
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- In order for this to be 'fair', we should remove the sales from 2013 and 2017.
-- For the same reasons as discussed above
				
SELECT MONTH(occurred_at) MONTH, SUM(total_amt_usd) MONTHLY_SALE
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01' -- EXCLUDING 2013 LAST MONTH AND 2017 FIRST MONTH
GROUP BY 1
ORDER BY 2 DESC;             

------------------------------------------------------------------------------
# 3.Which year did Parch & Posey have the greatest sales in terms of total number of orders? 
# Are all years evenly represented by the dataset?

SELECT YEAR(occurred_at) YEAR,
		COUNT(*) -- WE USE COUNT() BECAUE IT ASKS THE TOTAL NUMBER OF ORDERS AND NOT SALE AMOUNT
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
 --  2013 and 2017 are not evenly represented to the other years in the dataset.
 
 ---------------------------------------------------------------------------------
 # 4.Which month did Parch & Posey have the greatest sales in terms of total number of orders? 
 # Are all months evenly represented by the dataset?

SELECT MONTH(occurred_at) MONTH,
		count(*) MONTHLY_SALE
from orders
WHERE occurred_at BETWEEN '2014-00-00' AND '2017-00-00' -- EXCLUDING 2013 LAST MONTH AND 2017 FIRST MONTH
group by 1
ORDER BY 2 DESC;

-- December still has the most sales, but interestingly, November has the second most sales 
-- (but not the most dollar sales.

------------------------------------------------------------------------------------
# 5.In which month of which year did Walmart spend the most on gloss paper in terms of dollars?

SELECT YEAR(occurred_at) YEAR, MONTH(occurred_at) MONTH, SUM(gloss_amt_usd) TOTAL_GLOSS_SALE
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
WHERE A.name = 'Walmart'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 3;
-- May 2016 was when Walmart spent the most on gloss paper.

---------------------------------------------------------------------------------------------
# CASE
# LIKE IF THEN ELSE
# The CASE statement always goes in the SELECT clause.
# CASE must include WHEN, THEN, and END. ELSE is an optional component 
# USED INSTEAD OF WHERE FOR MORE THAN 1 CONDITION
-----------------------------------------------------------------------------------------------
# EX.1 CHECK IF THE CHANNEL IS FROM FACEBOOK OR TWITTER
SELECT  account_id,
		occurred_at,
        channel,
        CASE
			WHEN channel = 'facebook' OR 'twitter' THEN 'YES'-- IF FACEBOOK OR TWITTER ADD YES
            ELSE 'NO' -- OTHERWISE ADD NO
		END AS 'IS_SOCIAL_MEDIA' -- CREATES A NEW COLUMN
FROM web_events
ORDER BY occurred_at;


# EX.2 CATEGORIZE TOTAL SALE INTO 4 DEVISIONS
SELECT account_id,
		occurred_at,
        TOTAL,
        CASE
			WHEN total > 500 THEN 'OVER 500'
            WHEN total > 300 AND total <= 500 THEN '301 - 500'
            WHEN total > 100 AND total <= 300 THEN '101-300'
            ELSE 'BELOW 100'
		END AS CATEGORIES -- CREATE A NEW COLUMN
FROM orders;

# EX.3 Create a column that divides the standard_amt_usd by the standard_qty to find the unit price for standard paper for each order. 
# Limit the results to the first 10 orders, and include the id and account_id fields. TAKE CARE OF CASES OF DEVISION BY ZERO

SELECT ID, account_id, 
		CASE 
			WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0 -- WHEN DEVISOR IS ZERO OR NULL
            ELSE standard_amt_usd/standard_qty -- WHEN DEVISOR IS NOT ZERO OR NULL
		END AS UNIT_PRICE
FROM orders
LIMIT 10;

# EX.4
SELECT COUNT(*) NUNBER_OF_ORDERS, -- COUNT THE NUMBR OF ORDER IN EACH CATEGORY
        CASE -- CATEGORIZE THE ORDERS INTO 4 GROUPS
			WHEN total > 500 THEN 'OVER 500'
            WHEN total > 300 AND total <= 500 THEN '301 - 500'
            WHEN total > 100 AND total <= 300 THEN '101-300'
            ELSE 'BELOW 100'
		END AS CATEGORIES -- CREATE A NEW COLUMN
FROM orders
GROUP BY 2; -- GROUP BY EACH CATEGORY, CASE MUST BE HERE BECAUSE IT'S NOT AGGREGATED

# ATTENTION:
-- WE CAN USE WHERE BUT WITH ONLY FOR ONE CONDITION
SELECT COUNT(*) 
FROM orders
WHERE total > 500; -- WE CAN'T ADD MORE CONDITIONS IN WHERE CALUSE

----------------------------------------------------------------------------------
# 31.Quiz: CASE
----------------------------------------------------------------------------------
# 1.Write a query to display for each order, the account ID, total amount of the order,
# and the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, 
# or less than $3000.

SELECT account_id,
		total_amt_usd,
        CASE
			WHEN total_amt_usd > 3000 THEN 'LARGE'
            ELSE 'SMALL'
		END AS ORDER_LEVEL
FROM orders;

-------------------------------------------------------------------------------------
# 2.Write a query to display the number of orders in each of three categories, based on the total number of items in each order. 
# The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.

SELECT COUNT(*) ORDER_COUNT, -- number of orders MEANS COUNT(*)
		CASE 
			WHEN total >= 2000 THEN 'At Least 2000'
            WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
            ELSE 'Less than 1000'
		END AS CATEGORRY
FROM orders
GROUP BY 2;

-----------------------------------------------------------------------------------------
# 3.We would like to understand 3 different branches of customers based on the amount associated with their 
# purchases. The top branch includes anyone with a Lifetime Value (total sales of all orders) greater than
# 200,000 usd. The second branch is between 200,000 and 100,000 usd. The lowest branch is anyone under 100,000 usd. 
# Provide a table that includes the level associated with each account. You should provide the account name, 
# the total sales of all orders for the customer, and the level. Order with the top spending customers listed first
 
SELECT O.account_id, A.name, -- O.account_id IS NOT NEEDED
	SUM(O.total_amt_usd) TOTAL_SPENT,
    CASE
		WHEN SUM(O.total_amt_usd) > 200000 THEN 'TOP'
        WHEN SUM(O.total_amt_usd) >= 100000 AND SUM(O.total_amt_usd) <= 200000 THEN 'MIDDLE'
        ELSE 'LOW'
	END AS LEVEL -- LEVEL IS THE NEW COLUM NAME
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
GROUP BY 1, 2 -- CASE IS NOT IN GROUP BY BECAUSE IT HAS SUM(AGGREGATION) ISNDIE IT OTHERWISE IT NEEDS TO BE IN GROUP BY AS WELL.
ORDER BY TOTAL_SPENT DESC;

-----------------------------------------------------------------------------------------
# 4.We would now like to perform a similar calculation to the first, but we want to obtain the total amount
# spent by customers only in 2016 and 2017. Keep the same levels as in the previous question. 
# Order with the top spending customers listed first.

SELECT A.name, 
	SUM(O.total_amt_usd) TOTAL_SPENT,
    CASE
		WHEN SUM(O.total_amt_usd) > 200000 THEN 'TOP'
        WHEN SUM(O.total_amt_usd) >= 100000 AND SUM(O.total_amt_usd) <= 200000 THEN 'MIDDLE'
        ELSE 'LOW'
	END AS LEVEL -- LEVEL IS THE NEW COLUM NAME
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
    -- AND O.occurred_at BETWEEN '2016-00-00' AND '2018-00-00' -- JUTS FOR 2016 AND 2017
    AND O.occurred_at > '2016-00-00' -- AFTER 2016
GROUP BY 1 -- CASE IS NOT IN GROUP BY BECAUSE IT HAS SUM(AGGREGATION) ISNDIE IT OTHERWISE IT NEEDS TO BE IN GROUP BY AS WELL.
ORDER BY TOTAL_SPENT DESC;

-----------------------------------------------------------------------------------
# 5.We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders. 
# Create a table with the sales rep name, the total number of orders, and a column with top or not depending on 
# if they have more than 200 orders. Place the top sales people first in your final table

SELECT S.name SALES_REP_NAME,
	   COUNT(O.id) NUMB_ORDERS, -- COUNT(*) WORKS AS WELL 
       CASE
			WHEN COUNT(O.id) >= 200 THEN 'TOP' -- COUNT(*) WORKS AS WELL 
            ELSE 'NOT'
		END AS LEVEL -- LEVEL IS THE NAME OF THE NEW COLUMN
FROM sales_reps S
JOIN accounts A
	ON S.id =  A.sales_rep_id
JOIN orders O
	ON A.id = O.account_id
GROUP BY SALES_REP_NAME -- IT ASSUMES THAT NAMES ARE UNIQUE otherwise would want to break by the name and the id of the table.
ORDER BY NUMB_ORDERS DESC;
	
---------------------------------------------------------------------------------
# 6.The previous didn't account for the middle, nor the dollar amount associated with the sales. 
# Management decides they want to see these characteristics represented as well. We would like to identify
# top performing sales reps, which are sales reps associated with more than 200 orders or more than
# 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in sales.
# Create a table with the sales rep name, the total number of orders, total sales across all orders, 
# and a column with top, middle, or low depending on this criteria. Place the top sales people based on 
# dollar amount of sales first in your final table.

--    >> FOR THIS QUESTION WE USE COUNT(*) <<

SELECT S.name SALES_REP_NAME,
	   COUNT(*) NUMB_ORDERS, -- COUNT(*) ISNTEAD OF COUNT(O.id) RESULT IS THE SAME
       SUM(O.total_amt_usd) TOTAL_SALE,
       CASE
			WHEN COUNT(*) >= 200 OR SUM(O.total_amt_usd) > 750000 THEN 'TOP'  
            WHEN (COUNT(*) < 200 AND COUNT(*) >= 150) OR SUM(O.total_amt_usd) > 500000 THEN 'MIDDLE' 
            ELSE 'LOW'
		END AS LEVEL -- LEVEL IS THE NAME OF THE NEW COLUMN
FROM sales_reps S
JOIN accounts A
	ON S.id =  A.sales_rep_id
JOIN orders O
	ON A.id = O.account_id
GROUP BY SALES_REP_NAME -- IT ASSUMES THAT NAMES ARE UNIQUE otherwise would want to break by the name and the id of the table.
ORDER BY NUMB_ORDERS DESC;



