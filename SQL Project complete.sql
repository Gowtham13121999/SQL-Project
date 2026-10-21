use sql_project;

SELECT * FROM customer;
SELECT * FROM product; 
SELECT * FROM sales;

DESCRIBE customer;

ALTER TABLE customer
RENAME COLUMN ï»¿CustomerID TO CustomerID;

ALTER TABLE  product
RENAME COLUMN ï»¿ProductID TO ProductId;

# Write a query to identify the number of duplicates in "sales_transaction" table. Also, create a separate table containing the unique 
# values and remove the the original table from the databases and replace the name of the new table with the original name.

SELECT
     TransactionID,
     COUNT(*) 
     FROM
      sales_transaction
      GROUP BY
        TransactionID
        HAVING
        COUNT(*) >1;


CREATE TABLE UNIQUE_SALES_TRASACTION AS 
SELECT DISTINCT* FROM sales;

DROP TABLE sales;

ALTER TABLE UNIQUE_SALES_TRASACTION
RENAME  TO sales;

SELECT transactionID
FROM sales;
DESCRIBE sales; 
ALTER TABLE sales
RENAME COLUMN ï»¿TransactionID to TransactionID;

# Write a query to identify the discrepancies in the price of the same product in "sales_transaction" and "product_inventory" tables. Also, 
# update those discrepancies to match the price in both the tables.
SELECT
   s.TransactionID,
   s.Price AS transactionprice,
   p.Price AS inventoryprice 
   FROM sales s 
   JOIN product p 
   ON
   s.ProductID=p.ProductID
   WHERE    s.Price <> p.Price ;


   UPDATE sales s
   join product p  
   ON s.ProductID=p.ProductID 
     SET s.Price=p.Price
   WHERE s.Price<>p.Price;

   SELECT*FROM sales;
   # Write a SQL query to identify the null or emty values in the dataset and replace those by “Unknown”.
   SELECT COUNT(*) from customer
WHERE Location = '';

UPDATE customer
SET Location ='Unknown' 
WHERE Location = '';

SELECT*FROM customer;
# Write a SQL query to clean the DATE column in the dataset.

CREATE TABLE sales_updated AS
SELECT
  *,
  CAST(TransactionDate AS DATE) AS TransactionDate_updated
FROM sales;
DROP TABLE sales;
ALTER TABLE sales_updated RENAME TO sales;

SELECT * FROM sales;
# Write a SQL query to summarize the total sales and quantities sold per product by the company.

SELECT 
    ProductID,
    SUM(QuantityPurchased) AS TotalUnitsSold,
    SUM(QuantityPurchased * Price) AS TotalSales
FROM sales
GROUP BY ProductID
ORDER BY TotalSales DESC;
# Write a SQL query to count the number of transactions per customer to understand purchase frequency.
SELECT
CustomerID,
COUNT(*) AS NumberofTransactions
from sales
GROUP BY CustomerID
order by 
COUNT(*) desc ;

# Write a SQL query to evaluate the performance of the product categories based on the total sales which help us understand the product categories which needs 
# to be promoted in the marketing campaigns.

 SELECT
     p.Category,
     sum(s.QuantityPurchased) AS TotalUnitsSold,
     sum(s.QuantityPurchased*s.Price) AS TotalSales
FROM
   product p 
   join 
    sales s 
    on s.ProductID=p.ProductID
GROUP BY
  p.Category
  ORDER BY
TotalSales DESC;

# Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. 
# This will help the company to identify the High sales products which needs to be focused to increase the revenue of the company.

SELECT
  ProductID,
  SUM(QuantityPurchased*Price) as totalRevenue
  from sales
  GROUP BY
  ProductID
  ORDER BY
  totalRevenue DESC
  LIMIT 10 ;
  # Write a SQL query to find the ten products with the least amount of units sold from the sales transactions, 
  # provided that at least one unit was sold for those products.
  
  SELECT 
  ProductID,
  SUM(QuantityPurchased) AS TotalUnitsSold
FROM sales
GROUP BY ProductID
HAVING TotalUnitsSold > 0
ORDER BY TotalUnitsSold
LIMIT 10;

# Write a SQL query to identify the sales trend to understand the revenue pattern of the company.
SELECT
  CAST(TransactionDate AS DATE) AS DATETRANS,
  COUNT(*) AS TRANSACTION_COUNT,
  SUM(QuantityPurchased) AS TOTALUNITSSOLD,
  ROUND(SUM(QuantityPurchased * Price), 2) AS TOTALSALES
FROM
  sales
GROUP BY
  DATETRANS
ORDER BY
  DATETRANS DESC;
# Write a SQL query to understand the month on month growth rate of sales of the company which will help understand the growth trend of the company.

WITH monthly_sales AS (
    SELECT 
        EXTRACT(MONTH FROM TransactionDate) AS month,
        SUM(QuantityPurchased * Price) AS total_sales
    FROM sales
    GROUP BY EXTRACT(MONTH FROM TransactionDate)
)
SELECT
    month,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(LAG(total_sales) OVER (ORDER BY month), 2) AS previous_month_sales,
    ROUND(
        ((total_sales - LAG(total_sales) OVER (ORDER BY month)) / LAG(total_sales) OVER (ORDER BY month)) * 100,
        2
    ) AS mom_growth_percentage
FROM monthly_sales
ORDER BY month;

# Write a SQL query that describes the number of transaction along with the total amount spent by each customer which are on the higher side and will help us 
# understand the customers who are the high frequency purchase customers in the company.

SELECT 
    CustomerID,
    COUNT(*) AS NumberOfTransactions,
    SUM(QuantityPurchased * Price) AS TotalSpent
FROM sales
GROUP BY CustomerID
HAVING COUNT(*) > 10 
   AND SUM(QuantityPurchased * Price) > 1000
ORDER BY TotalSpent DESC;

# Write a SQL query that describes the number of transaction along with the total amount spent by each customer, 
# which will help us understand the customers who are occasional customers or have low purchase frequency in the company.

SELECT 
    CustomerID,
    COUNT(*) AS NumberOfTransactions,
    SUM(QuantityPurchased * Price) AS TotalSpent
FROM Sales
GROUP BY CustomerID
HAVING COUNT(*) <= 2
ORDER BY NumberOfTransactions ASC, TotalSpent DESC;

# Write a SQL query that describes the total number of purchases made by each customer against each productID to understand the repeat customers in the company.
SELECT 
    CustomerID,
    ProductID,
    COUNT(*) AS TimesPurchased
FROM Sales
GROUP BY CustomerID, ProductID
HAVING COUNT(*) > 1
ORDER BY TimesPurchased DESC;

# Write a SQL query that describes the duration between the first and the last purchase of the customer in that particular company to understand the loyalty of the customer.

WITH casted_transactions AS (
    SELECT 
        CustomerID,
        CAST(TransactionDate AS DATE) AS clean_date
    FROM Sales
),
customer_dates AS (
    SELECT 
        CustomerID,
        MIN(clean_date) AS FirstPurchase,
        MAX(clean_date) AS LastPurchase
    FROM casted_transactions
    GROUP BY CustomerID
)
SELECT 
    CustomerID,
    FirstPurchase,
    LastPurchase,
    DATEDIFF(LastPurchase, FirstPurchase) AS DaysBetweenPurchases
FROM customer_dates
WHERE DATEDIFF(LastPurchase, FirstPurchase) > 0
ORDER BY DaysBetweenPurchases DESC;

# Write an SQL query that segments customers based on the total quantity of products they have purchased. 
# Also, count the number of customers in each segment which will help us target a particular segment for marketing.

CREATE TABLE customer_segment AS
SELECT 
    c.CustomerID,
    CASE 
        WHEN SUM(s.QuantityPurchased) BETWEEN 1 AND 10 THEN 'Low'
        WHEN SUM(s.QuantityPurchased) BETWEEN 11 AND 30 THEN 'Med'
        WHEN SUM(s.QuantityPurchased) > 30 THEN 'High'
    END AS CustomerSegment
FROM customer c
JOIN sales s ON c.CustomerID = s.CustomerID
GROUP BY c.CustomerID;

SELECT 
    CustomerSegment,
    COUNT(*) AS "COUNT(*)"
FROM customer_segment
GROUP BY CustomerSegment;







