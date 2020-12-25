USE `parch and posey`;

------------------------------------------------------------------------------------------------
# 3 & 4.SUBQUERIES
# SUBQUERIES RUNS FIRST THEN THE OUTER QUERY
# ALWAYS NEED TO GIVE A NAME TO THE SUBQUARY TABLE
# SUBQUARY WITH WHERE SHOULD BE PLACED INSIDE PARANTHESIS ()
# WHEN USING SUBQUERY WITH WHERE, HAVING, or even SELECT, ONLY ONE SINGLE VALUE SHOULD BE RETURNED FROM THE SBQUARY
# If we returned an entire column instead of a SINGLE VALUE, IN would need to be used to perform a logical argument
# Note that you should NOT include an AS when you write a subquery in a conditional statement.
------------------------------------------------------------------------------------------------
# EX.1 We want to find the average number of events for each day for each channel. RESULT SHOULD HAVE 2 COLUMNS: CHANNEL AND AVG FOR EACH DAY.

-- FIRST FIND THE NUMBER OF EVENTS FOR EACH CHANNEL FOR EACH DAY:
SELECT DATE(occurred_at) DAYS,
		channel,
		COUNT(*) NUMBER_OF_EVENTS
FROM web_events
GROUP BY 1, 2
ORDER BY 3 DESC; -- DAY_CHANNEL_COUNT_TABLE

-- NOW AVERAGE THESE VALUES USING AN OUTER QUERY
SELECT channel,
       AVG(NUMBER_OF_EVENTS)
FROM (SELECT DATE(occurred_at) DAYS,
		     channel,
		     COUNT(*) NUMBER_OF_EVENTS
	  FROM web_events
	  GROUP BY 1, 2) AS DAY_CHANNEL_COUNT_TABLE
	-- ORDER BY 1; NO NEED FOR ORDER BY INSIDE THE SUBQUERY
GROUP BY 1
ORDER BY 2 DESC;


# SOMETHING EXTRA
-- IF YOU WANT TO KNOW HOW MANY RECCORDS WE HAVE IN THE DAY_CHANNEL_COUNT_TABLE, USE COUNT(*) AS THE OUTER QUERY
SELECT COUNT(*) TOTAL_NUMB_OF_RECORDS
FROM (SELECT DATE(occurred_at) DAYS,
			channel,
			COUNT(*) NUMBER_OF_EVENTS
	  FROM web_events
	  GROUP BY 1, 2
	  ORDER BY 3 DESC ) TOTAL_NUMB_OF_RECORDS_TABLE;
      
--------------------------------------------------------------------------
# EX.2 RETURN ORDERS FOR ONLY THE FIRST MONTH THAT ANY ORDER WAS PLACED

-- WE NEED TO USE DATE_FORMAT(occurred_at, '%Y-%m') TO EXTRACT YEAR AD MOTN ONLY
SELECT * 
FROM orders
WHERE DATE_FORMAT(occurred_at, '%Y-%m') = (SELECT DATE_FORMAT( MIN(occurred_at), '%Y-%m')-- SUBQUARY MIST BE INSIDE ()
										   FROM orders) -- NO NEED FOR ALIAS FOR SUBQUERIES INSIDE WHERE CLAUSE 
ORDER BY occurred_at;

      
---------------------------------------------------------------------------
# 3.QUIZ & 7.QUIZ
--------------------------------------------------------------------------
# 1. WHAT'S THE NUMBER OF MOST EVENT OCCURED IN A DAY?

SELECT NUMBER_OF_EVENTS 
FROM(SELECT DATE(occurred_at) DAYS,
			channel,
			COUNT(*) NUMBER_OF_EVENTS
	FROM web_events
	GROUP BY 1, 2
	ORDER BY 3 DESC
    LIMIT 1) AS MOST_EVENT_OCCURED;
    
------------------------------------------------------------------
# 2.On which day-channel pair did the most events occur.
-- MOST EVENT OCCURED IN 2 DAYS, CHECK THE 

SELECT DAYS
FROM( SELECT DATE(occurred_at) DAYS,
			channel,
			COUNT(*) NUMBER_OF_EVENTS
	  FROM web_events
	  GROUP BY 1, 2
	  ORDER BY 3 DESC) AS MOST_EVENET_DATES 
WHERE NUMBER_OF_EVENTS = 21; -- 21 IS CALCULATED FROM THE PREVIOUS QUERY
------------------------------------------------------------
# 3.SOLIVING THE SAME PROBLEM WITHOUT HARD CODING THE MAX NUMBER OF EVENTS

SELECT DAYS -- NESTED SUBQUARIES
FROM( 
	SELECT DATE(occurred_at) DAYS,
			channel,
			COUNT(*) NUMBER_OF_EVENTS
	FROM web_events
	GROUP BY 1, 2
	ORDER BY 3 DESC) AS MOST_EVENT_DATES --  SHOWS A TABLE WITH ALL 'DAYS, channel, NUMBER_OF_EVENTS'
WHERE NUMBER_OF_EVENTS = (SELECT MAX(NUMBER_OF_EVENTS) -- FIND THE MAX NUMBER_OF_EVENTS FROM THE ABOVE TABLE
						 FROM (SELECT DATE(occurred_at) DAYS, -- A SUBQUARY INSIDE ANOTHER SUBQUARY INSIDE WHERE CALUSE
										channel,
										COUNT(*) NUMBER_OF_EVENTS
								FROM web_events
								GROUP BY 1, 2
								ORDER BY 3 DESC) AS D); -- THE INNER SUBQUARY NEEDS AN ALIAS BUT NOT THE OUTER ONE


------------------------------------------------------------------------------
# 4.What was the month/year combo for the first order placed?

SELECT DATE(MIN(occurred_at))
FROM orders;
	
---------------------------------------------------------------------------------
# 5.The average amount of EACH paper TYPE (in terms of quantity) AND TOTAL AMOUNT OF ALL PAPER TYPES sold (IN TERMS OF DOLLARS) on the first month that any order was placed.

SELECT AVG(standard_qty) AVERAGE_STANDRAD_SOLD,
		AVG(poster_qty) AVERAGE_POSTER_SOLD,
		AVG(gloss_qty) AVERAGE_GLOSS_SOLD,
        SUM(total_amt_usd) TOTAL_AMOUNT_SOLD
        
FROM orders
WHERE DATE_FORMAT(occurred_at, '%Y-%M') = (SELECT DATE_FORMAT(MIN(occurred_at), '%Y-%M')
										   FROM orders)
ORDER BY occurred_at;

--------------------------------------------------------------------------------------
# 9.Quiz: Subquery Mania
---------------------------------------------------------------------------------------
# 1.Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales FOR ALL OF HIS SALES.

-- A. USE JOIN TO CONNECT 4 TABLES TO GETHER AND FIND THE SUM OF EACH SALES_REPS SALES >> ORIGINAL_TABLE
SELECT  S.name SALES_REP_NAME,
		R.name REGION_NAME,
        SUM(O.total_amt_usd) TOTAL_AMOUNT -- MAXIMUM TOTAL SALES BY EACH SALES_REP IS ASKED
FROM sales_reps S
JOIN accounts A
	ON S.id = A.sales_rep_id
JOIN orders O
	ON A.id = O.account_id
JOIN region R
	ON S.region_id = R.id
GROUP BY 1,2
ORDER BY 3 DESC; -- ORIGINAL_TABLE


-- B. WE WANT THE MAXIMUM OF EACH REGION, BUT WE NEED TO DO IT FOR REGION ONLY WITHOUT SALES_REP.
-- OTHERWISE, IT WOULD BE THE SAME AS THE PREV TABLE >> MAX_TABLE
SELECT REGION_NAME, MAX(TOTAL_AMOUNT) MAX_TOTAL_AMOUNT
FROM (SELECT  S.name SALES_REP_NAME,
			  R.name REGION_NAME,
			  SUM(O.total_amt_usd) TOTAL_AMOUNT -- MAXIMUM TOTAL SALES BY EACH SALES_REP IS ASKED
	  FROM sales_reps S
	  JOIN accounts A
		  ON S.id = A.sales_rep_id
	  JOIN orders O
		  ON A.id = O.account_id
	  JOIN region R
		  ON S.region_id = R.id
	  GROUP BY 1,2) AS TOTAL_TABLE
GROUP BY 1
ORDER BY 2 DESC; -- MAX_TABLE



-- C. NOW WE NEED TO JOIN IT TO THE ORIGINAL_TABLE TO GET THE SALES_REP AGAIN
SELECT ORIGINAL_TABLE.SALES_REP_NAME,
	   ORIGINAL_TABLE.REGION_NAME,
	   MAX_TABLE.MAX_TOTAL_AMOUNT
FROM(SELECT REGION_NAME, MAX(TOTAL_AMOUNT) MAX_TOTAL_AMOUNT
	 FROM (SELECT  S.name SALES_REP_NAME,
				  R.name REGION_NAME,
				  SUM(O.total_amt_usd) TOTAL_AMOUNT -- MAXIMUM TOTAL SALES BY EACH SALES_REP IS ASKED
		   FROM sales_reps S
		   JOIN accounts A
			   ON S.id = A.sales_rep_id
		   JOIN orders O
			   ON A.id = O.account_id
		   JOIN region R
			   ON S.region_id = R.id
		   GROUP BY 1,2) AS TOTAL_TABLE
	 GROUP BY 1) AS MAX_TABLE
JOIN (SELECT S.name SALES_REP_NAME,
			 R.name REGION_NAME,
	 		 SUM(O.total_amt_usd) TOTAL_AMOUNT -- SUM OF TOTAL SALES BY EACH SALES_REP IS ASKED
	  FROM sales_reps S
	  JOIN accounts A
		  ON S.id = A.sales_rep_id
	  JOIN orders O
		  ON A.id = O.account_id
	  JOIN region R
		  ON S.region_id = R.id
	  GROUP BY 1,2
	  ORDER BY 3 DESC) AS ORIGINAL_TABLE
  ON ORIGINAL_TABLE.REGION_NAME = MAX_TABLE.REGION_NAME 
  AND ORIGINAL_TABLE.TOTAL_AMOUNT = MAX_TABLE.MAX_TOTAL_AMOUNT;
      
------------------------------------------------------------------------------------
# 2.For the region with the largest sales total_amt_usd, how many total orders were placed?

-- A. FIND the total_amt_usd for each region.
SELECT  R.name REGION_NAME, 
		SUM(O.total_amt_usd) TOTAL_AMOUNT -- SUM OF TOTAL SALES 		
FROM sales_reps S
JOIN accounts A
	  ON S.id = A.sales_rep_id
JOIN orders O
	  ON A.id = O.account_id
JOIN region R
	  ON S.region_id = R.id
GROUP BY 1
ORDER BY 2 DESC; -- TOTAL_SALE_TABLE

-- B. FIND THE LARGEST SALE VALUE
SELECT MAX(TOTAL_AMOUNT) MAX_AMOUNT
FROM(  SELECT  R.name REGION_NAME,
		-- COUNT(O.id),		 
	   SUM(O.total_amt_usd) TOTAL_AMOUNT -- SUM OF ALL SALES		
	   FROM sales_reps S
	   JOIN accounts A
			ON S.id = A.sales_rep_id
	   JOIN orders O
			  ON A.id = O.account_id
	   JOIN region R
			  ON S.region_id = R.id
	   GROUP BY 1
	   ORDER BY 2 DESC) AS MAX_TABLE;
       
-- C. We want to pull the total orders for the region with this amount
-- FIRST JOIN ALL NEEDED TABLES AND SHOW NUMBER OF ORDERS FOR EACH REGION
SELECT R.name REGION_NAME, COUNT(O.id) NUMBER_OF_ORDERS
FROM sales_reps S
JOIN accounts A
	ON S.id = A.sales_rep_id
JOIN orders O
	ON A.id = O.account_id
JOIN region R
	ON S.region_id = R.id
GROUP BY(R.name);

-- D. NOW WE CAN FILTER THE REGION WITH THE MAX TOTAL_AMOUNT AND SHOW THE NUMBER OF ORDERS
SELECT R.name, COUNT(O.id)
FROM sales_reps S
JOIN accounts A
	ON S.id = A.sales_rep_id
JOIN orders O
	ON A.id = O.account_id
JOIN region R
	ON S.region_id = R.id
GROUP BY(R.name)
HAVING SUM(O.total_amt_usd) = (SELECT MAX(TOTAL_AMOUNT) MAX_AMOUNT
							  FROM( SELECT  R.name REGION_NAME, 
									SUM(O.total_amt_usd) TOTAL_AMOUNT -- SUM OF TOTAL SALES 	
							   FROM sales_reps S
							   JOIN accounts A
									ON S.id = A.sales_rep_id
							   JOIN orders O
									  ON A.id = O.account_id
							   JOIN region R
									  ON S.region_id = R.id
							   GROUP BY 1
							   ORDER BY 2 DESC) AS MAX_TABLE);
                               

-----------------------------------------------------------------------------------------------------------------------------
# 3. How many accounts had more total purchases than the TOTAL PURCHASE OF THE  account which has bought the most standard_qty 
# paper throughout their lifetime as a customer?

-- FIRST FIND the account name which has bought the most standard_qty paper throughout their lifetime as a customer
SELECT A.name ACCOUNT_NAME, SUM(standard_qty) TOTAL_STD_QTY, SUM(o.total) TOTAL
FROM orders O
JOIN accounts A
  ON A.id = O.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1; -- MOST_STD_TABLE

-- FIND all the accounts with more total sales THAN TOTAL SALE OFTHE ACCOUNT WHICH BOUGHT MOST STANDRAD PAPAER
-- COMPARE TOTAL BETWEEN ALL ACCOUNTS AND THE ACCOUNT WITH MAX STARNDRAD PAPERS SOLD
SELECT A.name ACCOUNT_NAME, SUM(total) TOTAL
FROM orders O
JOIN accounts A
  ON A.id = O.account_id
GROUP BY 1
HAVING SUM(O.total) > (SELECT  TOTAL
					   FROM(SELECT A.name ACCOUNT_NAME, SUM(O.standard_qty) TOTAL_STD_QTY, SUM(O.total) TOTAL
							FROM orders O
							JOIN accounts A
							  ON A.id = O.account_id
							GROUP BY 1
							ORDER BY 2 DESC
                            LIMIT 1 ) AS MOST_STD_TABLE);
                            
-- NOW WE JUST NEED TO COUNT THESE ACCOUNTS WITH COUNT(*)
SELECT COUNT(*)
FROM (SELECT A.name ACCOUNT_NAME, SUM(total) TOTAL
FROM orders O
JOIN accounts A
  ON A.id = O.account_id
GROUP BY 1
HAVING SUM(O.total) > (SELECT  TOTAL
					   FROM(SELECT A.name ACCOUNT_NAME, SUM(O.standard_qty) TOTAL_STD_QTY, SUM(O.total) TOTAL
							FROM orders O
							JOIN accounts A
							  ON A.id = O.account_id
							GROUP BY 1
							ORDER BY 2 DESC
                            LIMIT 1 ) AS MOST_STD_TABLE)
) DESIRED_ACCOUNTS_TABLE;


------------------------------------------------------------------------------------------------------------
# 4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, 
# how many web_events did they have for each channel?

-- LETS FIND THE CUSTOMER WHO SPENT THE MOST
SELECT A.id ACCOUNT_ID, A.name ACCOUNT_NAME, SUM(total_amt_usd) TOTAL_AMOUNT
FROM orders O
JOIN accounts A
  ON A.id = O.account_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;

-- LET'S SHOW ONLY THAT ACOOUNT'S NAME ADN ID
SELECT ACCOUNT_ID, ACCOUNT_NAME
FROM (SELECT A.id ACCOUNT_ID, A.name ACCOUNT_NAME, SUM(total_amt_usd) TOTAL_AMOUNT
FROM orders O
JOIN accounts A
  ON A.id = O.account_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1 ) AS THE_CUTSOMER_TABLE;

-- LET'S COUNT THE NUMBER OF WEB EVENTS FOR THIS ACCOUNT_ID
-- ACCOUNT_ID AND ACCOUNT_NAME ON;Y ADDED TO CHECK THE RESULT
SELECT A.id ACCOUNT_ID , A.name ACCOUNT_NAME, W.channel, COUNT(*) NUMB_EVENTS
FROM web_events W
JOIN accounts A
	ON W.account_id = A.id 
    AND A.id  = (SELECT ACCOUNT_ID
						FROM (SELECT A.id ACCOUNT_ID, SUM(total_amt_usd) TOTAL_AMOUNT
						FROM orders O
						JOIN accounts A
						  ON A.id = O.account_id
						GROUP BY 1
						ORDER BY 2 DESC
						LIMIT 1) AS THE_CUTSOMER_TABLE) 
GROUP BY 1, 2, 3
ORDER BY 4 DESC;


------------------------------------------------------------------------------------------------------------
# 5.What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
 
 -- LET'S FIND THE top 10 total spending accounts
SELECT A.id, A.name, SUM(total_amt_usd) TOTAL_AMOUT_SPENT
FROM orders O
JOIN accounts A
ON A.id = O.account_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10; -- TOP_10_ACCOUNTS

-- LET'S FIND THE average amount spent in terms of total_amt_usd for EACH OF THESE top 10 ACCOUNTS
SELECT A.id, A.name, AVG(total_amt_usd) AVERAGE_AMOUT_SPENT
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
WHERE account_id IN (SELECT account_id
					 FROM (SELECT account_id, SUM(total_amt_usd) TOTAL_AMOUT_SPENT
						   FROM orders
						   GROUP BY account_id
						   LIMIT 10) AS DESIRED_ACCOUTS)
GROUP BY 1,2
ORDER BY 3 DESC;
 

-- Now, we just want the average of these 10 amounts
SELECT AVG(TOTAL_AMOUT_SPENT)
FROM (SELECT A.id, A.name, SUM(total_amt_usd) TOTAL_AMOUT_SPENT
      FROM orders O
      JOIN accounts A
      ON A.id = O.account_id
      GROUP BY 1,2
      ORDER BY 3 DESC
	  LIMIT 10) AS TOP_10_ACCOUNTS;

--------------------------------------------------------------------------------------------------------------------------------
# 6.What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, 
# on average, than the average of all orders.

-- FIND THE AVERAGE OF ALL ORDERS 
SELECT AVG(total_amt_usd)
FROM orders;

-- LET'S FIND COMPANIE'S WHICH spent more per order on average, than the average of all orders
SELECT account_id , AVG(total_amt_usd) AVERAGE_SALE
FROM orders
GROUP BY account_id
HAVING AVERAGE_SALE > ( SELECT AVG(total_amt_usd)
						FROM orders); -- DESIRED_ACCOUTNS_TABLE

-- NOW FIND the lifetime average amount spent in terms of total_amt_usd ONLY FOR THOSE COMPANIES
SELECT AVG(AVERAGE_SALE)
FROM (SELECT account_id , AVG(total_amt_usd) AVERAGE_SALE
		FROM orders
		GROUP BY account_id
		HAVING AVERAGE_SALE > ( SELECT AVG(total_amt_usd)
								FROM orders) 
	  ) AS DESIRED_ACCOUTNS_TABLE;


----------------------------------------------------------------------------------------------------------------------------------
# WITH & SUBQUERY
# NAMING SUBQUERY AS A NEW TABLE TO MAKE THE CODE MORE REDABLE
# ADD , AFTER EACH TABLE WHEN ADDING MULTIPLE TABLES
---------------------------------------------------------------------------------------------------------------------------------
# EX.Find the average number of events for each channel per day.

-- THIS PROBLEM IS ALREADY SOLVED IN THE BEGINNING OF THIS NOTEBOOK
SELECT DATE(occurred_at) DAY, channel, COUNT(*) NUMB_EVENETS
FROM web_events
GROUP BY 1,2
ORDER BY 3 DESC;

SELECT channel, AVG(NUMB_EVENETS)
FROM (SELECT DATE(occurred_at) DAY, channel, COUNT(*) NUMB_EVENETS
	  FROM web_events
	  GROUP BY 1,2
	  ORDER BY 3 DESC) AS DAY_CHANNEL_COUNT_TABLE
GROUP BY 1
ORDER BY 2 DESC;

-- Let's try this again using a WITH statement.
-- NAMING THE SUBQUARY AS A NEW TABLE , THEN SELECTING THE DESIRED COLUMNS FROM THE NEWLY MADE TABLE 
WITH DAY_CHANNEL_COUNT_TABLE AS (
          SELECT DATE(occurred_at) DAY, channel, COUNT(*) NUMB_EVENETS
		  FROM web_events
		  GROUP BY 1,2)
          
SELECT channel, AVG(NUMB_EVENETS)
FROM DAY_CHANNEL_COUNT_TABLE
GROUP BY 1
ORDER BY 2 DESC;

----------------------------------------------------------------------------------------------------------
# 13.Quiz: WITH
----------------------------------------------------------------------------------------------------------
# 1.Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

-- FIND largest amount of total_amt_usd IN EACH REGION

SELECT S.name SALES_REP_NAME, R.name REGION_NAME, SUM(total_amt_usd) TOTAL_AMOUNT
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
JOIN sales_reps S
	ON A.sales_rep_id = S.id
JOIN region R
	ON S.region_id = R.id
GROUP BY 1,2
ORDER BY 3 DESC; -- TOTAL_AMOUNT_TABLE

-- FIND THE MAX TOTAL_AMOUNT FOR EACH REGION
WITH TOTAL_AMOUNT_TABLE AS
						(SELECT S.name SALES_REP_NAME, R.name REGION_NAME, SUM(total_amt_usd) TOTAL_AMOUNT
						FROM orders O
						JOIN accounts A
							ON O.account_id = A.id
						JOIN sales_reps S
							ON A.sales_rep_id = S.id
						JOIN region R
							ON S.region_id = R.id
						GROUP BY 1,2
						ORDER BY 3 DESC)
SELECT REGION_NAME, MAX(TOTAL_AMOUNT) MAX_TOTAL
FROM TOTAL_AMOUNT_TABLE
GROUP BY 1
ORDER BY 2 DESC; -- REGION_MAX_TABLE

-- FINALY - JOIN BACK THE TABLES
WITH TOTAL_AMOUNT_TABLE AS (
							SELECT S.name SALES_REP_NAME, R.name REGION_NAME, SUM(total_amt_usd) TOTAL_AMOUNT
							FROM orders O
							JOIN accounts A
								ON O.account_id = A.id
							JOIN sales_reps S
								ON A.sales_rep_id = S.id
							JOIN region R
								ON S.region_id = R.id
							GROUP BY 1,2
							ORDER BY 3 DESC), -- TOTAL_AMOUNT_TABLE >> T
REGION_MAX_TABLE AS (
					  SELECT REGION_NAME, MAX(TOTAL_AMOUNT) MAX_TOTAL
					  FROM TOTAL_AMOUNT_TABLE
					  GROUP BY 1
					  ORDER BY 2 DESC) -- REGION_MAX_TABLE >> M
SELECT T.SALES_REP_NAME, T.REGION_NAME, M.MAX_TOTAL
FROM TOTAL_AMOUNT_TABLE T
JOIN REGION_MAX_TABLE M
	ON T.REGION_NAME = M.REGION_NAME
    AND T.TOTAL_AMOUNT = M.MAX_TOTAL;
    
----------------------------------------------------------------------------------------------------------
# 2.For the region with the largest sales total_amt_usd, how many total orders were placed?

-- FIND REGION WITH LARGEST SALE
SELECT R.name REGION_NAME, SUM(total_amt_usd) TOTAL_AMOUNT
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
JOIN sales_reps S
	ON A.sales_rep_id = S.id
JOIN region R
	ON S.region_id = R.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1; -- LARGEST_SALE_TABLE

-- EXTRACT ONLY REGION NAME
WITH LARGEST_SALE_TABLE AS
						(SELECT R.name REGION_NAME, SUM(total_amt_usd) TOTAL_AMOUNT
						FROM orders O
						JOIN accounts A
							ON O.account_id = A.id
						JOIN sales_reps S
							ON A.sales_rep_id = S.id
						JOIN region R
							ON S.region_id = R.id
						GROUP BY 1
						ORDER BY 2 DESC
						LIMIT 1)
SELECT REGION_NAME
FROM LARGEST_SALE_TABLE;

-- COUNT THE TOTAL NUMBER OF ORDERS FPR THAT REGION
SELECT R.name REGION_NAME, COUNT(*) TOTAL_NUMB_OF_ORDERS
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
JOIN sales_reps S
	ON A.sales_rep_id = S.id
JOIN region R
	ON S.region_id = R.id
GROUP BY 1
ORDER BY 2 DESC; -- REGION_ORDER_TABLE

WITH LARGEST_SALE_TABLE AS
						(SELECT R.name REGION_NAME, SUM(total_amt_usd) TOTAL_AMOUNT
						FROM orders O
						JOIN accounts A
							ON O.account_id = A.id
						JOIN sales_reps S
							ON A.sales_rep_id = S.id
						JOIN region R
							ON S.region_id = R.id
						GROUP BY 1
						ORDER BY 2 DESC
						LIMIT 1), -- LS >> THIS GIVES 'Northeast'
REGION_ORDER_TABLE AS 
				   (SELECT R.name REGION_NAME, COUNT(*) TOTAL_NUMB_OF_ORDERS
					FROM orders O
					JOIN accounts A
						ON O.account_id = A.id
					JOIN sales_reps S
						ON A.sales_rep_id = S.id
					JOIN region R
						ON S.region_id = R.id
					GROUP BY 1
					ORDER BY 2 DESC) -- RO >> THIS GIVES AL REGIONS AND THEIR ORDER COUNTS
SELECT LS.REGION_NAME, RO.TOTAL_NUMB_OF_ORDERS
FROM LARGEST_SALE_TABLE LS
JOIN REGION_ORDER_TABLE RO
	USING (REGION_NAME); -- OR: ON LS.REGION_NAME = RO.REGION_NAME;
					
-- OR --

WITH t1 AS (
   SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY r.name), -- ALL REGIONS AND THEIR SUM OF TOTAL SALES
t2 AS (
   SELECT MAX(total_amt)
   FROM t1) -- MAX OF TOTAL SALE
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);

--------------------------------------------------------------------------------------------
# 3.For the account that purchased the most (in total over their lifetime as a customer) standard_qty paper, 
# how many accounts still had more in total purchases?

-- ACC WITH MOST STD PAPER OVER LIFETIME
SELECT A.name ACCOUNT_NAME, SUM(standard_qty) STD_QTY, SUM(total) TOTAL_SALE
FROM accounts A
JOIN orders O
	ON O.account_id = A.id
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 1;

-- TOTAL PURCHASE OF ALL ACCOUNTS
SELECT A.name ACCOUNT_NAME,  SUM(total) TOTAL_SALE
FROM accounts A
JOIN orders O
	ON O.account_id = A.id
GROUP BY 1
ORDER BY 2 DESC;

-- COMBINING THESE 2 TALES
WITH MOST_STD_ACC AS(
					SELECT A.name ACCOUNT_NAME, SUM(standard_qty) STD_QTY, SUM(total) TOTAL_SALE
					FROM accounts A
					JOIN orders O
						ON O.account_id = A.id
					GROUP BY 1
					ORDER BY 2 DESC 
					LIMIT 1), -- MOST STANDARD SOLDY BY THIS ACCOUNTT
TOTAL_PURCHASE_GREATER AS(
						SELECT A.name ACCOUNT_NAME, SUM(total) TOTAL_SALE
						FROM accounts A
						JOIN orders O
							ON O.account_id = A.id
						GROUP BY 1
                        HAVING TOTAL_SALE > (SELECT TOTAL_SALE FROM MOST_STD_ACC) )-- ACCOUNTS THAT MEET THECONDITIOB
SELECT COUNT(*) NUMBER_OF_ACCOUNTS
FROM TOTAL_PURCHASE_GREATER;

-----------------------------------------------------------------------------------------------------
# 4.For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, 
# how many web_events did they have for each channel?

 -- CUSTOMER WITH MOST TOTAL AMOUNT SPENT
 SELECT A.name ACCOUNT_NAME, SUM(o.total_amt_usd) TOTAL_AMOUNT
   FROM accounts A
   JOIN orders o
   ON o.account_id = a.id
   GROUP BY 1
   ORDER BY 2 DESC
   LIMIT 1; -- MOST_TOTAL_TABLE
   
-- NUMBER OF EVENTS FOR EACH ACCOUNT AND CHANNEL
SELECT A.name ACCOUNT_NAME, W.channel, COUNT(*) NUMB_EVENETS
FROM web_events W
JOIN accounts A
	ON W.account_id = A.id
GROUP BY 1, 2; -- NUMB_EVENETS_TABLE

-- COMBINE THESE 2 TABLES
WITH MOST_TOTAL_TABLE AS(
						SELECT A.name ACCOUNT_NAME, SUM(o.total_amt_usd) TOTAL_AMOUNT
						FROM accounts A
						JOIN orders o
						   ON o.account_id = a.id
                           GROUP BY 1
					    ORDER BY 2 DESC
					    LIMIT 1) -- GIVES THE ACCOUNT WITH MOST TOTAL SALE
-- NUMB_EVENETS_TABLE AS (
SELECT A.name ACCOUNT_NAME, W.channel CHANNEL, COUNT(*) NUMB_EVENETS
FROM web_events W
JOIN accounts A
	ON W.account_id = A.id
    AND A.name = (SELECT ACCOUNT_NAME FROM MOST_TOTAL_TABLE)
GROUP BY 1, 2
ORDER BY 3 DESC; 

-----------------------------------------------------------------------------------------------------
#5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

-- FIND THE top 10 total spending accounts?
SELECT A.name ACCOUNT_NAME, SUM(total_amt_usd) TOTAL_AMOUNT
FROM accounts A
JOIN orders O
	ON A.id =  O.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10; -- TOP_10_ACCOUNTS_TABLE

-- FIND lifetime average amount spent in terms of total_amt_usd
SELECT A.name, AVG(total_amt_usd) AVERAGE_AMOUNT
FROM accounts A
JOIN orders O
	ON A.id =  O.account_id
GROUP BY 1; -- AVERAGE_AMOUNT_TABLE

-- COMBINE THESE 2 TABLES
WITH TOP_10_ACCOUNTS_TABLE AS (
							SELECT A.name ACCOUNT_NAME, SUM(total_amt_usd) TOTAL_AMOUNT
							FROM accounts A
							JOIN orders O
								ON A.id =  O.account_id
							GROUP BY 1
							ORDER BY 2 DESC
							LIMIT 10) -- TOP 10 ACCOUNTS
SELECT A.name ACCOUNT_NAME, AVG(total_amt_usd) AVERAGE_AMOUNT
FROM accounts A
JOIN orders O
	ON A.id =  O.account_id
GROUP BY 1
HAVING ACCOUNT_NAME IN (SELECT ACCOUNT_NAME FROM TOP_10_ACCOUNTS_TABLE); -- AVERAGE OF EACH ACCOUNT					

-- OR IF WE WANT THE AVERAGE OF ALL ACCOUNTS:

WITH TOP_10_ACCOUNTS_TABLE AS (
							SELECT A.name ACCOUNT_NAME, SUM(total_amt_usd) TOTAL_AMOUNT
							FROM accounts A
							JOIN orders O
								ON A.id =  O.account_id
							GROUP BY 1
							ORDER BY 2 DESC
							LIMIT 10)
SELECT AVG(TOTAL_AMOUNT)
FROM TOP_10_ACCOUNTS_TABLE;

---------------------------------------------------------------------------------------
# 6.What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent 
# more per order, on average, than the average of all orders.

-- companies that spent more per order, on average, than the average of all orders in terms of total_amt_usd
SELECT account_id, AVG(total_amt_usd) AVERAGE_SPENT
FROM orders
GROUP BY 1
HAVING AVERAGE_SPENT > (SELECT AVG(total_amt_usd) FROM orders); -- MORE_THAN_AVERAGE_TABLE
                        
-- FIND THE AVERAGE OF THESE COMPANIES
WITH MORE_THAN_AVERAGE_TABLE AS(
								SELECT account_id, AVG(total_amt_usd) AVERAGE_SPENT
								FROM orders
								GROUP BY 1
								HAVING AVERAGE_SPENT > (SELECT AVG(total_amt_usd) 
														FROM orders) )
SELECT AVG(AVERAGE_SPENT) TOTAL_AVERAGE
FROM MORE_THAN_AVERAGE_TABLE;

