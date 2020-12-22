USE `parch and posey`;

SELECT *
FROM web_events
-- where channel = 'direct';
-- order by channel;
ORDER BY FIELD(channel, 'facebook', 'twitter');

SELECT *
FROM web_events
-- where channel = 'direct';
-- order by channel;
ORDER BY FIELD(channel, 'facebook', 'twitter') DESC, channel; 

SELECT *
FROM orders
WHERE standard_qty > 1000 AND poster_qty = 0 AND gloss_qty = 0;

SELECT * 
FROM accounts
-- LIMIT 5;
WHERE name NOT LIKE 'C%' AND name LIKE '%s';

SELECT occurred_at, gloss_qty
FROM orders
-- LIMIT 5
WHERE gloss_qty BETWEEN 24 AND 29;

SELECT COUNT(*) 
FROM web_events
-- LIMIT 5;
-- WHERE channel IN ('organic', 'adwords') AND occurred_at > '2016-00-00' AND occurred_at < '2017-00-00'
-- WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-00-00' AND '2017-00-00'
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC ;

SELECT id
FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000;

SELECT *
FROM orders
WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);

SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%') 
	AND (primary_poc LIKE '%ANA%' OR Primary_poc LIKE '%ana%')
	AND primary_poc NOT LIKE '%eana%';

SELECT * 
FROM accounts
WHERE name IS NOT NULL;
-- LIMIT 5

-------------------------------------------------------------------
# JOINS
---------------------------------------------------------------

SELECT * 
FROM accounts
JOIN orders
ON accounts.id = orders.account_id;

SELECT * 
FROM orders O
JOIN  accounts A
ON A.id = O.account_id;

SELECT orders.*, accounts.*
FROM accounts
JOIN orders
ON accounts.id = orders.account_id;

-------------------------------------------

SELECT orders.standard_qty, orders.gloss_qty, 
       orders.poster_qty,  accounts.website, 
       accounts.primary_poc
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

SELECT standard_qty, gloss_qty, poster_qty,
		website, primary_poc
FROM orders O
JOIN accounts A
ON  O.account_id = A.id;

----------------------------------------------------

SELECT (standard_qty + gloss_qty + poster_qty) TOTAL_QTY,
		website, primary_poc
FROM orders O
JOIN accounts A
ON  O.account_id = A.id;

----------------------------------------------------------
# 11. QUIZ ON JOINS
----------------------------------------------------------
# 1.Provide a table for all web_events associated with account name of Walmart. 
# There should be three columns. Be sure to include the primary_poc, time of the event, and the channel for each event.
# Additionally, you might choose to add a fourth column to assure only Walmart events were chosen.

SELECT primary_poc, occurred_at, name, channel
FROM web_events W
JOIN accounts A
ON W.account_id = A.id
WHERE A.name = 'Walmart';

-------------------------------------------------------
# 2. Provide a table that provides the region for each sales_rep along with their associated accounts. 
# Your final table should include three columns: the region name, the sales rep name, and the account name. 
# Sort the accounts alphabetically (A-Z) according to account name.

SELECT R.name REGION_NAME, S.name SALES_REP_NAME, A.name ACCOUNT_NAME
FROM region R
JOIN sales_reps S
ON R.id = S.region_id
JOIN accounts A
ON A.sales_rep_id = S.id
ORDER BY A.name;

--------------------------------------------------------------
# 3.Provide the name for each region for every order, as well as the account name and the unit price they paid 
# (total_amt_usd/total) for the order. Your final table should have 3 columns: region name, account name, and unit price.
# A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero.
 
SELECT R.name REGION_NAME, 
	   A.name ACCOUNT_NAME, 
       O.total_amt_usd/(O.total + 0.01) UNIT_PRICE
FROM region R
JOIN sales_reps S
ON R.id = S.region_id
JOIN accounts A
ON S.id = A.sales_rep_id
JOIN orders O
ON A.id = O.account_id;
-----------------------------------------------------------------------
# 18.JOINS AND FILTERING
-----------------------------------------------------------------------
SELECT * 
FROM orders O
LEFT JOIN accounts A
	ON O.account_id = A.id
WHERE A.sales_rep_id = 321500; # WHERE is executed after JOIN is done

SELECT * 
FROM orders O
LEFT JOIN accounts A
	ON O.account_id = A.id
	AND A.sales_rep_id = 321500; # This is executed before JOIN is done, works like WHERE before JOIN
						# It means the accounts which is the Right table is now has only rows with  sales_rep_id = 321500

----------------------------------------------------------------------------
# Quiz: Last CHeck
------------------------------------------------------------------------------
# 1.Provide a table that provides the region for each sales_rep along with their associated accounts. 
# This time only for the Midwest region. Your final table should include three columns:
# the region name, the sales rep name, and the account name. 
# Sort the accounts alphabetically (A-Z) according to account name.

SELECT R.name REGION_NAME, S.name SALES_REP_NAME, A.name ACCOUNT_NAME
FROM region R
JOIN  sales_reps S
	ON R.id = S.region_id
    AND R.name = 'Midwest'
JOIN accounts A
	ON S.id = A.sales_rep_id
    -- AND S.name LIKE 'K%'
ORDER BY ACCOUNT_NAME;

-- OR

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest'
ORDER BY a.name;

-----------------------------------------------------------------
# 2.Provide a table that provides the region for each sales_rep along with their associated accounts. 
# This time only for accounts where the sales rep has a first name starting with S and in the Midwest region.
#  Your final table should include three columns: the region name, the sales rep name, and the account name. 
# Sort the accounts alphabetically (A-Z) according to account name.


SELECT R.name REGION_NAME, S.name SALES_REP_NAME, A.name ACCOUNT_NAME
FROM region R
JOIN  sales_reps S
	ON R.id = S.region_id
    AND R.name = 'Midwest'
JOIN accounts A
	ON S.id = A.sales_rep_id
    AND S.name LIKE 'S%'
ORDER BY ACCOUNT_NAME;

-- OR

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest' AND s.name LIKE 'S%'
ORDER BY a.name;

-------------------------------------------------------------------------
# 3.Provide a table that provides the region for each sales_rep along with their associated accounts. 
# This time only for accounts where the sales rep has a first name starting with K and in the Midwest region.
# Your final table should include three columns: the region name, the sales rep name, and the account name. 
# Sort the accounts alphabetically (A-Z) according to account name.

SELECT R.name REGION_NAME, S.name SALES_REP_NAME, A.name ACCOUNT_NAME
FROM region R
JOIN  sales_reps S
	ON R.id = S.region_id
    AND R.name = 'Midwest'
JOIN accounts A
	ON S.id = A.sales_rep_id
    AND S.name LIKE '% K%' -- LAST NAME STARTING WITJ K
ORDER BY ACCOUNT_NAME;

-- OR

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest' AND s.name LIKE '% K%'
ORDER BY a.name;
-------------------------------------------------------------------------------
# 4.Provide the name for each region for every order, as well as the account name and the unit price they paid
# (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity 
# exceeds 100. Your final table should have 3 columns: region name, account name, and unit price. 
# In order to avoid a division by zero error, adding .01 to the denominator here is helpful total_amt_usd/(total+0.01).

SELECT  R.name REGION_NAME,
		A.name ACCOUNT_NAME,
        O.total_amt_usd/(O.total+0.01) UNIT_PTICE
        , O.standard_qty -- NOT ASKED IN THE QUESTION, JUST TO MAKE SURE THE RESULT IS CORRECT
FROM region R
JOIN sales_reps S
	ON R.id = S.region_id
JOIN accounts A
	ON S.id = A.sales_rep_id
JOIN orders O
	ON A.id = O.account_id
    AND O.standard_qty > 100;
    
-- OR

SELECT r.name region, a.name account, o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100;
    
--------------------------------------------------------------------------------------------
# 5.Provide the name for each region for every order, as well as the account name and the unit price they paid
# (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity 
# exceeds 100 and the poster order quantity exceeds 50. Your final table should have 3 columns: region name, account name,
# and unit price. In order to avoid a division by zero error: total_amt_usd/(total+0.01).
 
SELECT  R.name REGION_NAME,
		A.name ACCOUNT_NAME,
        O.total_amt_usd/(O.total+0.01) UNIT_PRICE
        , O.standard_qty -- NOT ASKED IN THE QUESTION, JUST TO MAKE SURE THE RESULT IS CORRECT
        , O.poster_qty -- NOT ASKED IN THE QUESTION, JUST TO MAKE SURE THE RESULT IS CORRECT
FROM region R
JOIN sales_reps S
	ON R.id = S.region_id
JOIN accounts A
	ON S.id = A.sales_rep_id
JOIN orders O
	ON A.id = O.account_id
    AND O.standard_qty > 100
    AND O.poster_qty> 50
ORDER BY UNIT_PRICE;

-- OR

SELECT r.name region, a.name account, o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price;

-------------------------------------------------------------------------------------------
# 6.Provide the name for each region for every order, as well as the account name and the unit price they paid
# (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity 
# exceeds 100 and the poster order quantity exceeds 50. Your final table should have 3 columns: region name, account name,
# and unit price. Sort for the largest unit price first.

SELECT  R.name REGION_NAME,
		A.name ACCOUNT_NAME,
        O.total_amt_usd/(O.total+0.01) UNIT_PTICE
        , O.standard_qty -- NOT ASKED IN THE QUESTION, JUST TO MAKE SURE THE RESULT IS CORRECT
        , O.poster_qty -- NOT ASKED IN THE QUESTION, JUST TO MAKE SURE THE RESULT IS CORRECT
FROM region R
JOIN sales_reps S
	ON R.id = S.region_id
JOIN accounts A
	ON S.id = A.sales_rep_id
JOIN orders O
	ON A.id = O.account_id
    AND O.standard_qty > 100
    AND poster_qty> 50
ORDER BY UNIT_PTICE DESC;

-- OR

SELECT r.name region, a.name account, o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price DESC;

--------------------------------------------------------------------------------
# 7.What are the different channels used by account id 1001? Your final table should have only 2 columns:
# account name and the different channels.
# You can try SELECT DISTINCT to narrow down the results to only the unique values.

SELECT DISTINCT A.name, 
		A.id, -- NOT ASKED IN THE QUESTION, JUST TO MAKE SURE THE RESULT IS CORRECT
        W.channel
FROM accounts A
JOIN web_events W
	ON A.id = W.account_id
	AND A.id = 1001 ;

-- OR

SELECT DISTINCT a.name, w.channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.id = '1001';
-----------------------------------------------------------------------------------------
# 8.Find all the orders that occurred in 2015. Your final table should have 4 columns:
# occurred_at, account name, order total, and order total_amt_usd. Order by date desceding.

SELECT  O.occurred_at,
		A.name ACCOUNT_NAME,
        O.total,
        O.total_amt_usd
FROM orders O
JOIN accounts A
	ON O.account_id = A.id
    AND occurred_at BETWEEN  '2015-00-00' AND '2016-00-00'
ORDER BY O.occurred_at DESC;
    
-- OR

SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
FROM accounts a
JOIN orders o
ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '2015-00-00 ' AND '2016-00-00'
ORDER BY o.occurred_at DESC;