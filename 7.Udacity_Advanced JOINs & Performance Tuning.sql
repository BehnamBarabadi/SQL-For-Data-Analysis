USE `parch and posey`;

-------------------------------------------------------------------------------------------------------
# 2.FULL OUTER JOIN >> NOT SUPPORTED BY MySQL <<
# when we want to have all the rows in both tables
# FULL JOIN is commonly used in conjunction with aggregations to understand the amount of overlap between two tables.
-------------------------------------------------------------------------------------------------------
# 3.quiz
-------------------------------------------------------------------------------------------------------
# 1.Shows Each account who has a sales rep and each sales rep that has an account (all of the columns in these returned rows will be full)
# but also each account that does not have a sales rep and each sales rep that does not have an account (some of the columns in these returned rows will be empty

-- ACCOUNTS WITH SALES_REP ANS SALES_REP WITH ACCOUNT
SELECT * 
FROM accounts A
JOIN sales_reps S
 ON A.sales_rep_id = S.id;
 
-- MySQL DOESN'T SUPPORT FULL JOIN INSTEAD WE USE THIS APPROACH --
SELECT * 
FROM accounts A
LEFT JOIN sales_reps S
 ON A.sales_rep_id = S.id
WHERE S.id IS NULL -- THERE'S NO account WITHOUT sales_rep 
UNION
SELECT *
FROM accounts A
RIGHT JOIN sales_reps S
	ON A.sales_rep_id = S.id
WHERE sales_rep_id IS NULL; -- THERE IS NO sales_rep WITHOUT AN account

---------------------------------------------------------------------------------------------------------------------------
# 5.JOINs with Comparison Operators
--------------------------------------------------------------------------------------------------------------------------
# EX.FIND ALL THE WEB_EVENTS ACTION EACH ACCOUNT TOOK PRIOR TO THEIR FIRST ORDER.

-- FIND THE FIRST DATE ANY ORDER TOOK PLACE IN TERMS AMF YYYY-MM
SELECT MIN(DATE_FORMAT(occurred_at, '%Y-%m')) AS DATE
FROM orders; -- '2013-12'
                       
-- LET'S FIND ALL THE ORDERS OF COMPANIES AT THAT DATE 
SELECT *
FROM orders
WHERE DATE_FORMAT((occurred_at), '%Y-%m') = (SELECT MIN(DATE_FORMAT(occurred_at, '%Y-%m'))
										     FROM orders)
ORDER BY occurred_at;
		
        # ATTANTION!
-- THE BELOW QUERY DOESN'T WORK

-- WITH FIRST_DATE_TABLE AS( 
-- 		 SELECT MIN(DATE_FORMAT(occurred_at, '%Y-%m')) ORDERS_DATE
-- 		 FROM orders)
-- SELECT *
-- FROM orders
-- WHERE DATE_FORMAT(occurred_at, '%Y-%m') = FIRST_DATE_TABLE.ORDERS_DATE		-- '2013-12'
-- ORDER BY occurred_at;

-- NOW LET'S JOIN ORDERS WITH WEB_EVENTS TABLE AND APPLY THE CONDITION
-- NOTICE THAT EACH ACCOUNT MAY HAVE MANY EVENTS
SELECT *
FROM orders O
LEFT JOIN web_events W
	ON O.account_id = W.account_id	
    AND W.occurred_at < O.occurred_at -- ANY ACTION PRIOR TO THE FIRST ORDER
WHERE DATE_FORMAT(O.occurred_at, '%Y-%m') = (SELECT MIN(DATE_FORMAT(O.occurred_at, '%Y-%m'))
										     FROM orders)
ORDER BY O.occurred_at;

---------------------------------------------------------------------------------------------------------------------------
# 6.QUIZ JOINS WITH COMPARISSON
---------------------------------------------------------------------------------------------------------------------------
# 1.Write a query that left joins the accounts table and the sales_reps tables on each sale rep's ID number
# and joins it using the < comparison operator on accounts.primary_poc and sales_reps.name, like so:
# accounts.primary_poc < sales_reps.name

SELECT *
FROM accounts A
LEFT JOIN sales_reps S
	ON A.sales_rep_id = S.id
    AND A.primary_poc < S.name;

---------------------------------------------------------------------------------------------------------------------------
# SELF JOIN
# JOINIG A TABLE WITH ITSELF
# One of the most common use cases for self JOINs is in cases where two events occurred, one after another.
---------------------------------------------------------------------------------------------------------------------------
# EX.WHICH ACCOUNTS MADE MULIPLE ORDERS WITHIN A 28 DAYS PERIOD.

-- LET'S FIRST FIND THE ALL COMBINATIONS OF account_idS
SELECT  ROW_NUMBER() OVER() COUNTER, -- COUNT THE NUMBER ROWS, WE HAVE 261622 ROWS AFTER JOIN
		O1.ID,
	 	O1.account_id,
 		O1.occurred_at,
		O2.ID,
 		O2.account_id,
 		O2.occurred_at
FROM orders O1
LEFT JOIN ORDERS O2
		ON O1.account_id = O2.account_id; -- EXPLANATION: account_id 1001 HAS 28 ORDERS. LEFT JOINING ORDERS TABLE WITH IT SELF CONNECTS ALL THESE 28 ORDERS WITH THEMSELVES. 
										  -- IT MEANS THAT WE WILL HAVE 28*28=784 ROWS AFTER JOIN FOR account_id 1001.
    
-- NOW LET'S IMPOSE THE 28 DAYS PERIOD CONDITION
SELECT  ROW_NUMBER() OVER() COUNTER, -- COUNT THE ROWS, 261622 ROWS WE HAVE AFTER JOIN 
		O1.ID,
		O1.account_id,
		O1.occurred_at,
		O2.ID,
		O2.account_id,
		O2.occurred_at
FROM orders O1
LEFT JOIN ORDERS O2
	ON O1.account_id = O2.account_id
    AND O2.occurred_at > O1.occurred_at 
    AND O2.occurred_at <= O1.occurred_at +  INTERVAL 28 DAY -- BETWEEN ALL THE CONNECTED account_id CHOSE THOSE WHICH HAS O2 DATE IS LESS THAN 28 DAYS GREAQTER THAN O1 DATE BIGGER 
WHERE O2.occurred_at IS NOT NULL -- SHOWS ONLY THE ROWS THAT HAS A VALUE FOR O2 (NOT NULL) BECAUSE USING AND INSIDE JOIN, CREATES NULL VALUES FOR ROWS THAT DON'T MEET THE CONDITION.
ORDER BY O1.account_id, O1.occurred_at;


---------------------------------------------------------------------------------------------------------------------------
# 9.QUIZ SELF JOINS
---------------------------------------------------------------------------------------------------------------------------
# 1.Modify the query from the previous video, to perform the same interval analysis except for the web_events table.
# Also: change the interval to 1 day to find those web events that occurred after, but not more than 1 day after, 
# another web event add a column for the channel variable in both instances of the table in your query.

SELECT row_number() over() COUNTER, -- THIS SHOWS THAT WE HAVE 1046 RECORD THAT MEET THIS CONDITION
		w1.id,
        w1.account_id,
        w1.occurred_at,
        w2.id,
        W2.account_id,
        W2.occurred_at
FROM web_events W1
LEFT JOIN web_events W2
	ON W1.account_id = w2.account_id -- account_id 1001 HAS 39 EVENETS AND WE CONNECT ALL OF THEM TOGETHER SO WE WOULD BE ABLE TO FIND THOSE EVENTS WHICH OCCURED WITHIN 1 DAY
    AND W2.occurred_at > W1.occurred_at
    AND W2.occurred_at <= W1.occurred_at + INTERVAL 1 DAY
WHERE W2.occurred_at IS NOT NULL; -- NOT SURE IF THIS COMMAND MUST BE HERE OR NOT


-----------------------------------------------------------------------------------------------------------------------------
# 11.UNION
# The UNION operator is used to combine the result sets of 2 or more SELECT statements.
# Both tables must have the same number of columns.
# Those columns must have the same data types in the same order as the first table.
# Column names, in fact, don't need to be the same to append two tables.
# UNION removes duplicate rows.
# UNION ALL does not remove duplicate rows.
# ONE USE CASE IS USING UNIONS INSTEAD OF FULL OUTER JOIN WHICH MySQL DOESN'T SUPPORT

----------------------------------------------------------------------------------------------------------------------------
# 12.Quiz: UNION
----------------------------------------------------------------------------------------------------------------------------
# 1.Write a query that uses UNION ALL on two instances (and selecting all columns) of the accounts table. Then inspect the results and answer the subsequent quiz.

WITH UNION_TABLE AS(
                    SELECT *
                    FROM ACCOUNTS
                    UNION ALL 
                    SELECT *
                    FROM ACCOUNTS)
SELECT COUNT(*)
FROM UNION_TABLE;

# 2.Add a WHERE clause to each of the tables that you unioned in the query above, filtering the first table where name equals
#  Walmart and filtering the second table where name equals Disney. Inspect the results then answer the subsequent quiz.

SELECT * 
FROM accounts	
WHERE name = 'Walmart'
UNION ALL
SELECT *
FROM accounts
WHERE name = 'Disney';


# 3.Perform the union in your first query (under the Appending Data via UNION header) in a common table expression and name it double_accounts. 
# Then do a COUNT the number of times a name appears in the double_accounts table. If you do this correctly, your query results 
#should have a count of 2 for each name.

WITH double_accounts AS(
                    SELECT *
                    FROM ACCOUNTS
                    UNION ALL 
                    SELECT *
                    FROM ACCOUNTS)
SELECT COUNT(*) NUMBER_OF_OCCURANCE
FROM double_accounts
WHERE name = 'Disney'; 

---------------------------------------------------------------------------------------------------------------------------
# 15.Performance Tuning 1
---------------------------------------------------------------------------------------------------------------------------
# 1.TEST YOUR QUERY FIRST ON A SUBSET OF DATA USING SUBQUARY INSIDE FROM AND THEN RUN IT ON THE WHOLE DATASET

-- EX. FIND THE TOTAL poster_qty SOLD FOR EACH ACCOUNT DIRUNG '2016-01-01' AND '2017-05-01'.

Set profiling = 1; -- TO GET THE EXECUTION TIME
SELECT account_id ACCOUNT_ID,
	   SUM(poster_qty) STANDARD_ORDER
FROM (SELECT * FROM orders LIMIT 100) AS TEST_DATA -- CREATE A SUBSET OF DATA TO TEST THE QUERY ON
WHERE occurred_at > '2016-01-01'
AND occurred_at < '2017-05-01' 
GROUP BY 1;
Show profiles; -- TO SHOW THE EXECUTION TIME


-----------------------------------------------------------------------------------------
# 2.DO THE AGGREGATION BEFORE JOINING IF POSSIBLE

-- FIND THE NUMBER OF WEB EVENTS FOR EACH ACCOUNT

SELECT A.name,	
	   COUNT(*) NUMBER
FROM accounts A
JOIN web_events W
	ON A.id = W.account_id
GROUP BY 1
ORDER BY 2 DESC;

 -- IT'S BETTER TO DO THE AGGREGATION IN WEB_EVENETS TABLE BEFORE JOINIG
 
 WITH WEB_AGGREGATED_TABLE AS ( 
								SELECT  account_id ACCOUNT_ID,
										COUNT(*) NUMBER
								FROM web_events
                                GROUP BY 1
                                ORDER BY 2 DESC)
SELECT A.name,	
	   NUMBER
FROM WEB_AGGREGATED_TABLE WG
JOIN accounts A
	ON WG.ACCOUNT_ID  = A.id 
ORDER BY 2 DESC;

--------------------------------------------------------------------------------------------------------------
# 3. ADD EXPLAIN AT THE BEGINNING OF THE QUERY TO GET THE SENCE OF TIME TO EXECUTE AND TRY TO MODIFY THE QUERY

EXPLAIN FORMAT=TREE
SELECT account_id ACCOUNT_ID,
	   SUM(poster_qty) STANDARD_ORDER
FROM  orders-- (SELECT * FROM orders LIMIT 100) AS TEST_DATA -- CREATE A SUBSET OF DATA TO TEST THE QUERY ON
WHERE occurred_at > '2016-01-01'
AND occurred_at < '2017-05-01' 
GROUP BY 1;

---------------------------------------------------------------------------------------------------------------------------
# 18.JOINing Subqueries
-- IS FASTER THAN JOINING TABLES
----------------------------------------------------------------------------------------------------------------------------
# EX.FIND THE NUMBER OF UNIQUE SALES_REPS AND ORDERS IN EACH DAY AND ALSO FIND THE NUMBER OF WEB_EVENETS OCCURED IN EACH OF THESE DAYS. 

-- THE FIRST APPROACH >> JOINS 3 TABLES AND TO AVOID COUNTING DUPLICATES, WE NEED TO USE COUNT(DISTINCT()) WHICH IS VERY TIME CONSUMING 
CREATE VIEW v_today AS
SELECT  DATE(O.occurred_at) AS DATE,
		COUNT(DISTINCT(A.sales_rep_id)) ACTIVE_SALES_REPS,
		COUNT(DISTINCT(O.id)) AS ORDERS,
		COUNT(DISTINCT(W.id)) AS WEB_VISITS
FROM accounts Av_today
JOIN orders O
	ON A.id = O.account_id
JOIN web_events W
	ON DATE(O.occurred_at) = DATE(W.occurred_at)
GROUP BY 1
ORDER BY 1 DESC;

-- THE BETTER APPROACH >> TO DO THE AGGREGATION SPEERATELY INSIDE DIFFERENT SUBQUERIES WITHOUT COUNT(DISTINCT()) AND THE MERGE THE TABLES TO GETHER
WITH ORDER_SALES_REP_TABLE AS 
							 (SELECT DATE(O.occurred_at) AS DATE, -- COUNTS THE NUMBER OF ORDERS AND SASLES_REPS CORRESPONDING TO EACH ACCOUNT FOR EACH DAY
									 COUNT(A.sales_rep_id) ACTIVE_SALES_REPS,
									 COUNT(O.id) AS ORDERS
							 FROM accounts A
							 JOIN orders O
								ON A.id = O.account_id
							 GROUP BY 1), -- OS
    
WEB_EVETES_TABLE AS 
					(SELECT DATE(occurred_at) AS DATE, -- COUNTS THE NUMBER OF WEB_EVENST HAPPEND IN EACH DAY					
							COUNT(id) AS WEB_VISITS
					FROM web_events 
					 GROUP BY 1) -- WE 
SELECT COALESCE(OS.DATE, WE.DATE) DATE,
		OS.ACTIVE_SALES_REPS,
        OS.ORDERS,
        WE.WEB_VISITS
FROM ORDER_SALES_REP_TABLE OS
JOIN WEB_EVETES_TABLE WE
	ON OS.DATE = WE.DATE
ORDER BY 1 DESC;




