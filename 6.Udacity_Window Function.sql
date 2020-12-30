USE `parch and posey`;

--------------------------------------------------------------------------------------------
# WINDOW FUNCTION
# For each row from a query, perform a calculation using rows related to that row
# Unlike regular aggregate functions, use of a window function does not cause rows to become grouped into a single output row
# You can’t use window functions and standard aggregations in the same query. 
# More specifically, you can’t include window functions in a GROUP BY clause
-----------------------------------------------------------------------------------------------
# EX.1 CALCULATE RUNNING TOTAL OF standard_qty
select standard_qty,	
        occurred_at,
	    SUM(standard_qty) OVER(ORDER BY occurred_at) AS RUNNING_TOTAL
FROM orders; -- STARTS FROM THE FORDST DATE AND SUMS UP ALL standard_qty TOGETHER AS RUNNING_TOTAL

# ATTENTION!
-- if we remove order by, it would become exactly like GROUP BY
select standard_qty,	
        occurred_at,
	    SUM(standard_qty) OVER() AS RUNNING_TOTAL
FROM orders;


# EX.2 CALCULATE RUNNING TOTAL OF standard_qty FOR EACH MONTH
SELECT  standard_qty,	
        DATE_FORMAT(occurred_at, '%Y-%m') Y_M, -- EXTRACT YEAR AND MONTH
        SUM(standard_qty) OVER (PARTITION BY DATE_FORMAT(occurred_at, '%Y-%m') ORDER BY occurred_at) AS MONTHLY_RUNNING_TOTAL
FROM ORDERS;

# EX.3 CALCULATE THE RUNNING TOTAL FOR EACH COMPANY
SELECT A.name COMPANY_NAME,
	   DATE(occurred_at) DATE,
	   SUM(total_amt_usd) OVER (PARTITION BY account_id ORDER BY occurred_at) RUNNING_TOTAL
FROM orders O
JOIN ACCOUNTS A
	ON O.account_id = A.id;
    
# EX.4 RANK ORDERS BASED ON total_amt_usd DESCENDING FOR EACH COMPANY
SELECT O.id,
	    A.name COMPANY_NAME,
		DATE(occurred_at) DATE,
        total_amt_usd,
	    RANK() OVER (PARTITION BY account_id ORDER BY total_amt_usd DESC) RANKING
FROM orders O
JOIN ACCOUNTS A
	ON O.account_id = A.id;


-----------------------------------------------------------------------------------------
# QUIZ
----------------------------------------------------------------------------------------------
# 1. Create another running total of standard_amt_usd (in the orders table) over order time with no date truncation. 
# Your final table should have two columns: one with the amount being added for each new row, and a second with the running total.

SELECT standard_amt_usd STANDARD_AMOUNT,
		occurred_at DATE,
        SUM(standard_amt_usd) OVER(ORDER BY occurred_at) RUNNING_TOTAL
FROM orders;


-----------------------------------------------------------------------------------------------
# 2.Create a running total of standard_amt_usd over order time, but this time, date truncate occurred_at by year and partition by 
# that same year-truncated occurred_at variable. Your final table should have three columns: One with the amount being added for each row, 
# one for the truncated date, and a final column with the running total within each year.

SELECT standard_amt_usd STANDARD_AMOUNT,
		YEAR(occurred_at) YEAR,
        SUM(standard_amt_usd) OVER(PARTITION BY YEAR(occurred_at) ORDER BY occurred_at) YEARLY_RUNNING_TOTAL
FROM orders;


-----------------------------------------------------------------------------------------------
# 3.FIND THE SAME YEARLY_RUNNING_TOTAL BUT THIS TIME SEPERATELY FOR EACH COMPANY

SELECT A.name, 
		standard_amt_usd STANDARD_AMOUNT,
		YEAR(occurred_at) YEAR,
        SUM(standard_amt_usd) OVER(PARTITION BY account_id, YEAR(occurred_at) ORDER BY occurred_at) YEARLY_RUNNING_TOTAL
FROM orders O
JOIN accounts A
	ON O.account_id = A.id;
    
------------------------------------------------------------------------------------------------------
# 4.Select the id, account_id, and total variable from the orders table, then create a column called total_rank that ranks this total amount
#  of paper ordered (from highest to lowest) for each account using a partition. Your final table should have these four columns.

SELECT  O.id ORDER_ID , 
	    O.account_id,
        A.name ACCOUNT_NAME,
        O.total TOTAL_AMOUNT,
	    RANK() OVER(PARTITION BY account_id ORDER BY total DESC) TOTAL_RANK -- RANK EACH COMPANY BASED ON total_amt_usd
FROM orders O
JOIN accounts A
	ON O.account_id = A.id;
    
    
------------------------------------------------------------------------------------------------------
# 5.GIVE A NUMBER TO EACH ORDER FOR EACH COMPANY SEPARATELY BASED ON occurred_at.

SELECT  O.id ORDER_ID , 
	    O.account_id,
        DATE(occurred_at),
        A.name ACCOUNT_NAME,
        O.total_amt_usd  TOTAL_AMOUNT,
	    ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY DATE(occurred_at) ) COUNT
FROM orders O
JOIN accounts A
	ON O.account_id = A.id;

----------------------------------------------------------------------------------------------------------------------
# EX. ALL TO GETHER
-- ORDERS WITHIN THE SAME PARTION, HAVE THE SAME AGGERAGATE VALUE 

SELECT  O.id ORDER_ID , 
        a.name ACCOUNT_NAME,
        account_id,
        standard_qty STD_QTY,
		DATE_FORMAT(occurred_at, '%Y-%m') YEAR_MONT, -- EXTRACT YEAR AND MONTH
		DENSE_RANK() OVER(PARTITION BY account_id ORDER BY DATE_FORMAT(occurred_at, '%Y-%m')) DENSE_RAN, -- ORDERS AT THE SAME DATE ARE WITHIN 1 GROUP SO ALL HAVE THE SAME RANK
        SUM(standard_qty) OVER(PARTITION  BY account_id ORDER BY DATE_FORMAT(occurred_at, '%Y-%m')) SUM_STD_QTY, -- ORDERS AT THE SAME DATE ARE WITHIN 1 GROUP SO ALL HAVE THE SAME SUM
        COUNT(standard_qty) OVER(PARTITION BY account_id ORDER BY DATE_FORMAT(occurred_at, '%Y-%m')) COUNT_STD_QT, -- ORDERS AT THE SAME DATE ARE WITHIN 1 GROUP SO ALL HAVE THE SAME COUNT
        AVG(standard_qty) OVER(PARTITION BY account_id ORDER BY DATE_FORMAT(occurred_at, '%Y-%m')) AVG_STD_QT,
        MAX(standard_qty) OVER(PARTITION BY account_id ORDER BY DATE_FORMAT(occurred_at, '%Y-%m')) MAX_STD_QT,
        MIN(standard_qty) OVER(PARTITION BY account_id ORDER BY DATE_FORMAT(occurred_at, '%Y-%m')) MIN_STD_QT
FROM orders O 
JOIN accounts A
	ON O.account_id = A.id;

# ATTENTION!
-- Inside each PARTITION, aggregate functio result is the same for all the rows with the same order.
-- Compare the result of the above and below queries:

SELECT  O.id ORDER_ID , 
        a.name ACCOUNT_NAME,
        account_id,
        standard_qty STD_QTY,
		DATE_FORMAT(occurred_at, '%Y-%m') YEAR_MONT, -- EXTRACT YEAR AND MONTH
		DENSE_RANK() OVER(PARTITION BY account_id , DATE_FORMAT(occurred_at, '%Y-%m')) DENSE_RAN, -- ORDERS AT THE SAME DATE ARE WITHIN 1 GROUP SO ALL HAVE THE SAME RANK
        SUM(standard_qty) OVER(PARTITION  BY account_id,  DATE_FORMAT(occurred_at, '%Y-%m') ORDER BY DATE_FORMAT(occurred_at, '%Y-%m')) SUM_STD_QTY, -- ORDERS AT THE SAME DATE ARE WITHIN 1 GROUP SO ALL HAVE THE SAME SUM
        COUNT(standard_qty) OVER(PARTITION BY account_id, DATE_FORMAT(occurred_at, '%Y-%m') ORDER BY DATE_FORMAT(occurred_at, '%Y-%m')) COUNT_STD_QT -- ORDERS AT THE SAME DATE ARE WITHIN 1 GROUP SO ALL HAVE THE SAME COUNT
--         AVG(standard_qty) OVER(PARTITION BY account_id , DATE_FORMAT(occurred_at, '%Y-%m')) AVG_STD_QT,
--         MAX(standard_qty) OVER(PARTITION BY account_id , DATE_FORMAT(occurred_at, '%Y-%m')) MAX_STD_QT,
--         MIN(standard_qty) OVER(PARTITION BY account_id , DATE_FORMAT(occurred_at, '%Y-%m')) MIN_STD_QT
FROM orders O  
JOIN accounts A
	ON O.account_id = A.id;
    
    
-------------------------------------------------------------------------------------------------------------
# 11.QUIZ
------------------------------------------------------------------------------------------------------------
# REMOVE THE ORDER BY FROM THE PREVIOUS QUERY THEN RUN IT AND COMPARE THE RESLUT.

SELECT  O.id ORDER_ID , 
        a.name ACCOUNT_NAME,
        account_id,
        standard_qty STD_QTY,
		DATE_FORMAT(occurred_at, '%Y-%m') YEAR_MONT, -- EXTRACT YEAR AND MONTH
		DENSE_RANK() OVER(PARTITION BY account_id) DENS_RANK, -- ORDERS AT THE SAME DATE ARE WITHIN 1 GROUP SO ALL HAVE THE SAME RANK
        SUM(standard_qty) OVER(PARTITION  BY account_id) SUM_STD_QTY, -- ORDERS AT THE SAME DATE ARE WITHIN 1 GROUP SO ALL HAVE THE SAME SUM
        COUNT(standard_qty) OVER(PARTITION BY account_id) COUNT_STD_QT, -- ORDERS AT THE SAME DATE ARE WITHIN 1 GROUP SO ALL HAVE THE SAME COUNT
        AVG(standard_qty) OVER(PARTITION BY account_id) AVG_STD_QT,
        MAX(standard_qty) OVER(PARTITION BY account_id ) MAX_STD_QT,
        MIN(standard_qty) OVER(PARTITION BY account_id ) MIN_STD_QT
FROM orders O  
JOIN accounts A
	ON O.account_id = A.id;
    

----------------------------------------------------------------------------------------------------------------------
# 2.What is the value of dense_rank in every row for the following account_id values AND WHY?

-- BECAUSE WE DON'T HAVE ANY ORDER IN EACH PARTITION, THE DENSE_RANK FOR ALL ROWS IN EACH PARTITION IS 1 AND ROWS IN THE NEXT PARTITION GETS THE RANK OF 1 AGAIN.
-- ALL ROWS IN EACH PARTIOTION TREATED THE SAME.

# The easiest way to think about this - leaving the ORDER BY out is equivalent to "ordering" in a way that all rows in the partition are "equal" to each other

----------------------------------------------------------------------------------------------------------------------------------------------------------------
# 13.Aliases for Multiple Window Functions
# REPLACING EVERYTHING INSIDE OVER WITH AN ALIAS 
---------------------------------------------------------------------------------------------------------------------------------------------------------------
# 1.USE ALIAS FOR THE WINDOW STATEMENT
SELECT id,
       account_id,
       YEAR(occurred_at) AS year,
	   total_amt_usd,
       DENSE_RANK() OVER ACCOUNT_YEAR_WINDOW AS DENS_RANK,
       SUM(total_amt_usd) OVER ACCOUNT_YEAR_WINDOW AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER ACCOUNT_YEAR_WINDOW AS count_total_amt_usd,
       AVG(total_amt_usd) OVER ACCOUNT_YEAR_WINDOW AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER ACCOUNT_YEAR_WINDOW AS min_total_amt_usd,
       MAX(total_amt_usd) OVER ACCOUNT_YEAR_WINDOW AS max_total_amt_usd
FROM orders
WINDOW ACCOUNT_YEAR_WINDOW AS (PARTITION BY account_id ORDER BY YEAR(occurred_at));

---------------------------------------------------------------------------------------------------
# 16. LAG & LEAD
# LAG: It returns the value from a previous row to the current row in the table.
# LEAD: Return the value from the row following the current row in the table
---------------------------------------------------------------------------------------------------
# EX FIND THE DIFFERENCE BETWEEN EACH CURRENT ROW OF DATA AND ITS PREVIOUS AND NEXT ROW IN THE TABLE OF TOTAL STD_QTY FOR ALL COMPANIES

-- FIRST FIND THE TABLE OF TOTAL STD_QTY FOR ALL COMPANIES
SELECT O.account_id,
	   A.name,
       SUM(standard_qty) AS STANDARD_SUM
FROM ORDERS O
JOIN accounts A
	ON O.account_id = A.id
GROUP BY 1; -- TOTAL_STD_QTY

-- NOW LETS ADD LEAD AND LAG
WITH TOTAL_STD_QTY  AS(
							SELECT O.account_id ACCOUNT_ID,
								   A.name ACCOUNT_NAME,
								   SUM(standard_qty) AS STANDARD_SUM
							FROM ORDERS O
							JOIN accounts A
								ON O.account_id = A.id
							GROUP BY 1 )
SELECT ACCOUNT_NAME, 
	   STANDARD_SUM,
	   LAG(STANDARD_SUM) OVER(ORDER BY STANDARD_SUM) LAG_COL,  -- THE TABLE IS ORDERED BY STANDARD_SUM AND THE PREVIOUS VALUE IS BASED ON THIS ORDER
       LEAD(STANDARD_SUM) OVER(ORDER BY STANDARD_SUM) LEAD_COL  -- THE TABLE IS ORDERED BY STANDARD_SUM AND THE NEXT VALUE IS BASED ON THIS ORDER
FROM TOTAL_STD_QTY;

-- NEW LET'S ADD LEAD AND LAG DIFFERENRCE
WITH TOTAL_STD_QTY  AS(
							SELECT O.account_id ACCOUNT_ID,
								   A.name ACCOUNT_NAME,
								   SUM(standard_qty) AS STANDARD_SUM
							FROM ORDERS O
							JOIN accounts A
								ON O.account_id = A.id
							GROUP BY 1 )
SELECT ACCOUNT_NAME, 
	   STANDARD_SUM,
	   LAG(STANDARD_SUM) OVER(ORDER BY STANDARD_SUM) LAG_COL, 
       LEAD(STANDARD_SUM) OVER(ORDER BY STANDARD_SUM) LEAD_COL,
       STANDARD_SUM -  LAG(STANDARD_SUM) OVER(ORDER BY STANDARD_SUM) LAG_DIFF, -- DIFFERENCE BETWEEN CURRENCT ROW AND THE PREVIOUS ROW
       LEAD(STANDARD_SUM) OVER(ORDER BY STANDARD_SUM) - STANDARD_SUM LEAD_DIFF -- DIFFERENCE BETWEEN THE NEXT ROW AND THE CURRENT ROW
FROM TOTAL_STD_QTY;

-- LET'S USE ALIAS INSTEAD OF COMPLETE WINDOW STATAMENT
WITH TOTAL_STD_QTY  AS(
							SELECT O.account_id ACCOUNT_ID,
								   A.name ACCOUNT_NAME,
								   SUM(standard_qty) AS STANDARD_SUM
							FROM ORDERS O
							JOIN accounts A
								ON O.account_id = A.id
							GROUP BY 1 )
SELECT ACCOUNT_NAME, 
	   STANDARD_SUM,
	   LAG(STANDARD_SUM) OVER STD_SUM_WIN LAG_COL,
       LEAD(STANDARD_SUM) OVER STD_SUM_WIN LEAD_COL,
       STANDARD_SUM -  LAG(STANDARD_SUM) OVER STD_SUM_WIN LAG_DIFF, -- DIFFERENCE BETWEEN CURRENCT ROW AND THE PREVIOUS ROW
       LEAD(STANDARD_SUM) OVER STD_SUM_WIN - STANDARD_SUM LEAD_DIFF -- DIFFERENCE BETWEEN THE NEXT ROW AND THE CURRENT ROW
FROM TOTAL_STD_QTY
WINDOW STD_SUM_WIN AS (ORDER BY STANDARD_SUM); -- ALIAS FOW WINDOIW

-- NOW LETS ADD PARTITION TO SUM()
WITH TOTAL_STD_QTY  AS(
						SELECT O.account_id ACCOUNT_ID,
							   A.name ACCOUNT_NAME,
							   YEAR(O.occurred_at) AS YEAR,
							   SUM(standard_qty) AS STANDARD_SUM
						FROM ORDERS O
						JOIN accounts A
							ON O.account_id = A.id
						GROUP BY 1 )
SELECT ACCOUNT_NAME, 
	   YEAR,
	   STANDARD_SUM,
       SUM(STANDARD_SUM) OVER(PARTITION BY YEAR ORDER BY STANDARD_SUM) COMPANIES_PARTITION_SUM, -- THIS SUM ADDS UP FOR COMPANIES IN EACH PARTITION ADN ORDERED BY STANDARD_SUM
       SUM(STANDARD_SUM) OVER(ORDER BY YEAR) COMPANIES_SUM, -- THIS SUM IS THE SAME FOR ALL ROWS IN THE SAME ORDER(ROWS IN THE SAME YEAR)
	   LAG(STANDARD_SUM) OVER(ORDER BY YEAR) LAG_COL  -- THE TABLE IS ORDERED BY STANDARD_SUM AND THE PREVIOUS VALUE IS BASED ON THIS ORDER
FROM TOTAL_STD_QTY;
       
--------------------------------------------------------------------------------------------------------------------------------------
 # 17. QUIZZ LAG & LEAP
 -------------------------------------------------------------------------------------------------------------------------------------
 # 1. USIG PREVIOUS EXAMPLE, determine how the current order's total revenue ("total" meaning from sales of all types of paper) compares to the next order's total revenue.
#  You'll need to use occurred_at and total_amt_usd in the orders table along with LEAD to do so. In your query results, there should be four columns:
#  occurred_at, total_amt_usd, lead, and lead_difference.

-- FIND ORDERS TOTAL REVENUE AND ADD LEAD AND LEAD_DIFFERENCE COLUMNS
WITH TOTAL_STD_QTY AS(
						SELECT 
							   O.occurred_at DATE,
							   total_amt_usd AS TOTAL_SUM
						FROM ORDERS O
						JOIN accounts A
							ON O.account_id = A.id
						GROUP BY 1 ) -- THIS FIND THE total_amt_usd FOR EACH DATE
SELECT  DATE,
	    TOTAL_SUM , 
        LEAD(TOTAL_SUM) OVER(ORDER BY DATE) LEAD_COL,
	    LEAD(TOTAL_SUM) OVER(ORDER BY DATE) - TOTAL_SUM LEAD_DIFFERENCE
FROM TOTAL_STD_QTY;

-- OR --
-- THIS IS SIMPLERE 
SELECT 
	   O.occurred_at DATE,
       total_amt_usd,
       LEAD(total_amt_usd) OVER(ORDER BY occurred_at) LEAD_COL,
	   LEAD(total_amt_usd) OVER(ORDER BY occurred_at) - total_amt_usd LEAD_DIFFERENCE
FROM ORDERS O
JOIN accounts A
	ON O.account_id = A.id;
    
-------------------------------------------------------------------------------------------------------------------------------------------------------
# NTILE()
# identify what percentile (or quartile, or any other subdivision) a given row falls into. 
# The syntax is NTILE(*# of buckets*).
# ORDER BY determines which column to use to determine the quartiles
------------------------------------------------------------------------------------------------------------------------------------------------

# EX.FIND THE PERCENTILE AND QUANTILE OF EACH ORDER

SELECT id,
	account_id,
    standard_qty,
    NTILE(4) OVER(ORDER BY standard_qty) AS QUARTILE,
    NTILE(100) OVER(ORDER BY standard_qty) AS PERCENTILE
FROM orders
ORDER BY standard_qty DESC;

------------------------------------------------------------------------------------------------------
# 21.QUIZ PERCENTILE
-------------------------------------------------------------------------------------------------------

# 1.FOR EACH SPECIFIC CUSTOMER Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for their orders. 
# Your resulting table should have the account_id, the occurred_at time for each order, the total amount of standard_qty paper purchased,
# and one of four levels in a standard_quartile column.

--
SELECT account_id, 
		occurred_at,
        standard_qty,
        NTILE(4) OVER(PARTITION BY account_id ORDER BY standard_qty) AS QUANTILE
FROM orders
ORDER BY account_id DESC;

---------------------------
# 2.FOR EACH SPECIFIC CUSTOMER Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders.
# Your resulting table should have the account_id, the occurred_at time for each order, the total amount of gloss_qty paper purchased,
# and one of two levels in a gloss_half column.

SELECT account_id,
		occurred_at,
        gloss_amt_usd,
        NTILE(2) OVER(PARTITION BY account_id ORDER BY gloss_qty) GLOSS_HALF
FROM ORDERS
ORDER BY account_id DESC;


--------------------------------
# 3.FOR EACH SPECIFIC CUSTOMER Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd
# for their orders. Your resulting table should have the account_id, the occurred_at time for each order, the total amount of
# total_amt_usd paper purchased, and one of 100 levels in a total_percentile column.

SELECT account_id,
		occurred_at,
        total_amt_usd,
        NTILE(100) OVER(PARTITION BY account_id ORDER BY total_amt_usd) PERCENTILE
FROM ORDERS
ORDER BY account_id DESC;
