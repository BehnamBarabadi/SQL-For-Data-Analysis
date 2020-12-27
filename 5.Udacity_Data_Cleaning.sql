USE `parch and posey`;

------------------------------------------------------------------------------
# LESSON 5 -- DATA CLEANING --
------------------------------------------------------------------------------
---------------------------------------------------------------------
# 2.LEFT, RIGHT, LENGTH
---------------------------------------------------------------------
# EX1. Extract PREFIX, POSTFIX AND NAME FORM THE URL OF EACH COMPANY.
 
SELECT  name ,
		LEFT( website, 3) PREFIX,
        RIGHT( website, 3) POSTFIX,
		RIGHT( website, LENGTH(website) - 4) URL_NAME_PLUS_POSTFIX, -- ONLY FOR CLARIFICATION
        LEFT( RIGHT(website, LENGTH(website) - 4) , LENGTH(RIGHT( website, LENGTH(website) - 4)) -4) AS URL_NAME
FROM ACCOUNTS;

--------------------------------------------------------------------
# 3.Quiz: LEFT & RIGHT
---------------------------------------------------------------------

# 1.In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using. 
# list of extensions (and pricing) is provided here. Pull these extensions and provide how many of each website type exist in the accounts table.

SELECT RIGHT(website, 3) AS EXTENSIONS,
		COUNT(*) TOTAL_NUMBER
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-------------------------------------------------------------------------------------------------------------
# 2.Use the accounts table to pull the first letter of each company name to see the distribution of company names that 
# begin with each letter (or number).

SELECT LEFT(UPPER(name), 1) _FIRST_LETTER,
	    COUNT(*) TOTAL_NUMBER
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-------------------------------------------------------------------------------------------------------------
# 3. Use the accounts table and a CASE statement to create two groups: one group of company names that start with 
# a number and a second group of those company names that start with a letter. What proportion of company names 
# start with a letter?

-- WE NEED TO CREATE 2 NEW COLUMNS ANS ADD 0 OR 1 FOR EACH ROW
SELECT name COMPANY_NAME, 
	   CASE WHEN LEFT( UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 1
            ELSE 0
	   END AS 'NUMERIC',
	   CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 0
            ELSE 1
	   END AS 'ALPHABETIC'
FROM accounts; -- COMPANY_GROUPS_TABLE

-- NOW FIND THE NPROPORTION OF EACH COLUMN
WITH COMPANY_GROUPS_TABLE AS(
							SELECT name COMPANY_NAME, 
							CASE WHEN LEFT( UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 1
								 ELSE 0
						    END AS 'NUMERIC_COL',
						    CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 0
								ELSE 1
						    END AS 'ALPHABETIC_COL'
					        FROM accounts) -- COMPANY_GROUPS_TABLE

SELECT SUM(NUMERIC_COL)    / (SUM(NUMERIC_COL) + SUM(ALPHABETIC_COL)) NUMB_PROPORTION, 
	   SUM(ALPHABETIC_COL) / (SUM(NUMERIC_COL) + SUM(ALPHABETIC_COL)) ALPH_PROPORTION
FROM COMPANY_GROUPS_TABLE;

----------------------------------------------------------------------------------------------------------------

# 4.Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent 
# start with anything else?

-- CREATE 2 COLUMNS FOR EACH GROUP
SELECT name,
	   CASE WHEN LEFT(LOWER(name), 1) IN ('a', 'e', 'i', 'o', 'u') THEN 1
			ELSE 0
		END AS 'VOWELS',
        CASE WHEN LEFT(LOWER(name), 1) IN ('a', 'e', 'i', 'o', 'u') THEN 0
			 ELSE 1
		END AS 'NON_VOWELS'
FROM accounts; -- VOWELS_TABLES
        
-- NOW FIND THE PERCENTAGE OF EACH GROUP
WITH VOWELS_TABLES AS(
					  SELECT name,
					         CASE WHEN LEFT(LOWER(name), 1) IN ('a', 'e', 'i', 'o', 'u') THEN 1
						  	      ELSE 0
						     END AS 'VOWELS',
						     CASE WHEN LEFT(LOWER(name), 1) IN ('a', 'e', 'i', 'o', 'u') THEN 0
							      ELSE 1
						     END AS 'NON_VOWELS'
				      FROM accounts)    

SELECT SUM(VOWELS) / (SUM(VOWELS) + SUM(NON_VOWELS)) * 100 PERC_VOWLES,
	   SUM(NON_VOWELS) / (SUM(VOWELS) + SUM(NON_VOWELS)) * 100 PERC_NON_VOWELS
FROM VOWELS_TABLES;

-----------------------------------------------------------------------------------------
# 5.POSITION 
# takes a character and a column, and provides the index where that character is for each row
# The index of the first position is 1 in SQL
# POSITION IS case sensitive
# LOWER or UPPER to make all of the characters lower or uppercase
---------------------------------------------------------------------------------------------
# 6.Quiz: POSITION, STRPOS, & SUBSTR - AME DATA AS QUIZ 1
---------------------------------------------------------------------------------------------
# 1.Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.

SELECT primary_poc,
	   POSITION( ' ' IN primary_poc) SPACE_POSITION,
       LEFT(primary_poc, POSITION( ' ' IN primary_poc)-1) FIRST_NAME, # -1 ID ADDED TO REMOVE THE SAPCE AT THE END OF RESULT
       RIGHT(primary_poc, LENGTH(primary_poc) - POSITION( ' ' IN primary_poc)) LAST_NAME
FROM accounts;


-------------------------------------------------------------------------------------------------
# 2.Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.

SELECT name SALES_REP_NAME,
	   -- POSITION(' ' IN name) SPACE_POITION,
	   -- POSITION(' ' IN name) SPACE_POITION,
       LEFT(name, POSITION(' ' IN name) - 1) FIRST_NAME,
       RIGHT(name, LENGTH(name) - POSITION(' ' IN name) ) LAST_NAME
FROM sales_reps;


--------------------------------------------------------------------------------------
# 8.CONCAT 
# combine columns together across rows
# REPLACE() replaces all the occurrences of a substring within a string.
-- REPLACE(str, find_string, replace_with)
-----------------------------------------------------------------------------------------
# 1.Each company in the accounts table wants to create an email address for each primary_poc.
# The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.

SELECT primary_poc AS SALES_REP_NAME,
	   LEFT(primary_poc, POSITION(' '  IN primary_poc)-1) FIRST_NAME,
       RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' '  IN primary_poc)) LAST_NAME,
       CONCAT ( LEFT(primary_poc, POSITION(' '  IN primary_poc)-1), '.', 
						RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' '  IN primary_poc)), '@', name, '.COM' ) EMAIL
FROM accounts; -- EMAIL_WITH_SPACE_TABLE

-- OR--

WITH FIRST_LAST_NAME_TABLE AS(
							SELECT primary_poc AS SALES_REP_NAME,
								   name AS COMPANY_NAME,
								   LEFT(primary_poc, POSITION(' '  IN primary_poc)-1) FIRST_NAME,
								   RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' '  IN primary_poc)) LAST_NAME
							FROM accounts)
SELECT SALES_REP_NAME,
	   CONCAT(FIRST_NAME, '.', LAST_NAME, '@', COMPANY_NAME, '.COM') EMAIL  
FROM FIRST_LAST_NAME_TABLE; -- EMAIL_WITH_SPACE_TABLE


-------------------------------------------------------------------------------------------------------
# 2.You may have noticed that in the previous solution some of the company names include spaces, which will certainly
# not work in an email address. See if you can create an email address that will work by removing all of the spaces in 
# the account name, but otherwise your solution should be just as in question 1. Some helpful documentation is here.

-- LET'S FIRST SEE HOW REPLAC WORK
SELECT REPLACE(name, ' ', '')  NAME_NO_SPACE -- REPLACE SPACE WITH NOTHING
FROM accounts;

-- NOW LET'S REPLACE SPACE WITH NOTHING IN ALL EMAILS
WITH FIRST_LAST_NAME_TABLE AS(
							SELECT primary_poc AS SALES_REP_NAME,
								   name AS COMPANY_NAME,
								   LEFT(primary_poc, POSITION(' '  IN primary_poc)-1) FIRST_NAME,
								   RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' '  IN primary_poc)) LAST_NAME
							FROM accounts)
SELECT SALES_REP_NAME,
	   CONCAT(FIRST_NAME, '.', LAST_NAME, '@', COMPANY_NAME, '.COM') EMAIL_WITH_SPACE,
	   CONCAT(FIRST_NAME, '.', LAST_NAME, '@', REPLACE(COMPANY_NAME, ' ', ''), '.COM') EMAIL_NO_SPACE 
FROM FIRST_LAST_NAME_TABLE; -- EMAIL_NO_SPACE_TABLE

-------------------------------------------------------------------------------------------------------
# 3.We would also like to create an initial password, which they will change after their first log in. 
# The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of 
# their first name (lowercase), the first letter of their last name (lowercase), the last letter of their 
# last name (lowercase), the number of letters in their first name, the number of letters in their last name, 
# and then the name of the company they are working with, all capitalized with no spaces.

-- FIRST CREATE A TABLE WITH ALL NEEDED ELEMENETS
SELECT S.name SALES_REP_NAME,
	   A.name COMPANY_NAME,
       LEFT(S.name, POSITION(' ' IN S.name) - 1) FIRST_NAME,
       RIGHT(S.name, LENGTH(S.name) - POSITION(' ' IN S.name) ) LAST_NAME
FROM sales_reps S
JOIN accounts A
	ON A.sales_rep_id = S.id; -- PASSWORD_READY_TABLE
    
-- LET'S CREATE THE PASSWORD AS IT'S MENTIONED
WITH PASSWORD_READY_TABLE AS(
							SELECT S.name SALES_REP_NAME,
								   A.name COMPANY_NAME,
								   LEFT(S.name, POSITION(' ' IN S.name) - 1) FIRST_NAME,
								   RIGHT(S.name, LENGTH(S.name) - POSITION(' ' IN S.name) ) LAST_NAME
							FROM sales_reps S
							JOIN accounts A
								ON A.sales_rep_id = S.id)
SELECT CONCAT(FIRST_NAME, ' ', LAST_NAME) SALES_REP_NAME,
	   CONCAT(
       LEFT(LOWER(FIRST_NAME), 1) ,
       RIGHT(LOWER(FIRST_NAME), 1) ,
       LEFT(LOWER(LAST_NAME), 1) ,
       RIGHT(LOWER(LAST_NAME), 1) ,
       LENGTH(FIRST_NAME) ,
       LENGTH(LAST_NAME) ,
       REPLACE(UPPER(COMPANY_NAME), ' ', '') ) PASSWORD
FROM PASSWORD_READY_TABLE;
       
	   
-----------------------------------------------------------------------------------------------
# 12.CAST
# STR_TO_DATE: convertS string to date, should use proper '%m-%d-%y'
-- check here: https://dev.mysql.com/doc/refman/8.0/en/date-and-time-functions.html#function_date-format
# DATE_FORMAT(date, '%Y-%m-%d'): CHANGES THE FORMAT OF DATE
-----------------------------------------------------------------------------------------------

SELECT * FROM `parch and posey`.sf_crime_data;
#1. CHNAGE DATE INTO CORRECT SQL FORMAT AND CONVERT IT TO DATE

WITH DATE_TABLE AS(
					SELECT date , 
						   REPLACE(LEFT(date, 19), '/', '-')  DATE_STRING
                    FROM sf_crime_data)
SELECT date INITAL_DATE,
	   DATE_STRING,
	   STR_TO_DATE(DATE_STRING, '%m-%d-%Y %T') CORRECT_FORMAT_DATE,
       STR_TO_DATE(DATE_STRING, '%m-%d-%Y') DATE_ONLY,
	   TIME(STR_TO_DATE(DATE_STRING, '%m-%d-%Y %T')) TIME_ONLY
FROM DATE_TABLE;

-------------------------------------------------------------------------------------------
# 14.COALESCE
# returns the first non-NULL value passed for each row
# ESPECIALLY USEFULL WHEN WORKING WITH NUMERIC VALUE AND COUNT(COLUMN)
--------------------------------------------------------------------------------------------

#EX RETURN THE FIRDT NOT NULL VALUE IN A LIST
SELECT COALESCE(NULL, 1, 2, 'W3Schools.com') OUTPUT ; -- OUTPUT IS 1


# 1. RUN THIS QUERY TO SEE THE NULL VALUES
-- WE HABE 1 NULL VALUE

SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL; 

------------------------------------------------------
#2. USE COALESCE TO FILL IN accounts.id WITH account.id FOR THE NULL VALUE FROM THE TABLE IN 1

-- FOR NULL VALUES, ADDS THE CLOUMN filled_id AND FILL IT WITH THE FIRST NOT NULL VALUE IN a.id FOR THAT NULL VALUE
SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.longi, a.primary_poc, a.sales_rep_id, o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

-- FOR NULL VALUES, ADDS THE CLOUMN filled_id AND FILL IT WITH THE FIRST NOT NULL VALUE IN BETWEEN 1 AND a.id 
-- FOR THAT NULL VALUE
SELECT COALESCE(1, A.id) FILLED_ID, A.name, A.website, A.lat, A.longi, A.primary_poc, A.sales_rep_id, O.*
FROM accounts A
LEFT JOIN orders O
ON a.id = o.account_id
WHERE o.total IS NULL;

------------------------------------
# 3.USE COALESCE TO FILL IN orders.accounts.id WITH account.id FOR THE NULL VALUE FROM THE TABLE IN 1

SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.longI, a.primary_poc, a.sales_rep_id,
	   COALESCE(o.account_id, a.id) account_id, o.occurred_at, o.standard_qty, o.gloss_qty, o.poster_qty, o.total,
       o.standard_amt_usd, o.gloss_amt_usd, o.poster_amt_usd, o.total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

-------------------------------------------------------------------------
# 4. FILL DTY AND USD COLOR WITH 0

SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.longI, a.primary_poc, a.sales_rep_id,
 COALESCE(o.account_id, a.id) account_id, o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty, 
 COALESCE(o.gloss_qty,0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, 
 COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, 
 COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

----------------------------------------------------------------------------------------
# 5. REMOVE WHWRE IN QUERY 1 AND COUNT THE NUMBER OF idS

SELECT COUNT(O.id)
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;


SELECT COUNT(*)
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;
-------------------------------------------------------------------------------------------
# 6. RUN THE ABOVE QUERY WITH ALL COALESCE

SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.longI, a.primary_poc, a.sales_rep_id,
 COALESCE(o.account_id, a.id) account_id, o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty, 
 COALESCE(o.gloss_qty,0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, 
 COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, 
 COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id