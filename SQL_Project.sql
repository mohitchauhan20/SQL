CREATE DATABASE NEWTON;
use NEWTON;
CREATE TABLE CustomerInfo (
CustomerId INT,
Surname VARCHAR (50),
Age INT,
EstimatedSalary DECIMAL(10,2),
BankDOJ DATE,
GenderCategory VARCHAR(50),
GeographyLocation VARCHAR(50));
	
SELECT * FROM CustomerInfo;

CREATE TABLE Bank_Churn(
CustomerId INT,
CreditScore INT,
Tenure INT,
Balance DECIMAL(10,2),
NumOfProducts INT,
ActiveCategory VARCHAR(50),
HasCrCard VARCHAR(50),
ExitCategory VARCHAR(50));

SELECT * FROM Bank_Churn;

-- 1.What is the distribution of account balances across different regions?

SELECT c.GeographyLocation,ROUND(SUM(bc.Balance),2) AS account_balances
FROM CustomerInfo c
JOIN Bank_Churn bc
ON c.CustomerId=bc.CustomerID
GROUP BY GeographyLocation;

-- 2.	Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)

SELECT Surname,SUM(EstimatedSalary) highest_Estimated_Salary
From customerinfo
where MONTH(BankDOJ) IN(10,11,12)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 3.	Calculate the average number of products used by customers who have a credit card. (SQL)
SELECT c.Surname,ROUND(Avg(bc.NumOfProducts),0) Avg_Number_of_Product
From bank_churn bc
JOIN customerinfo c 
ON c.CustomerId=bc.CustomerId
WHERE HasCrCard ="Credit Card Holder"
GROUP BY 1;

-- 4.	Determine the churn rate by gender for the most recent year in the dataset.
WITH CTE AS(
	SELECT c.GenderCategory,COUNT(c.customerId) AS 'Churn'
	FROM customerinfo c 
    JOIN bank_churn bc 
    ON c.CustomerId=bc.CustomerId
	WHERE ExitCategory='Exit' AND YEAR(BankDOJ)=(SELECT MAX(YEAR(BankDOJ))
	FROM customerinfo)
	GROUP BY 1
),totalCTE AS
(
	SELECT GenderCategory,COUNT(*) AS 'total'
	FROM customerinfo
    GROUP BY 1
)
SELECT a.GenderCategory,ROUND(Churn/total,2)*100 AS `churn rate`
FROM CTE a
JOIN totalCTE b
ON a.GenderCategory=b.GenderCategory
GROUP BY 1;

-- 5.	Compare the average credit score of customers who have exited and those who remain. (SQL)
Select ExitCategory Customer_status,Avg(CreditScore) Credit_score
from bank_churn
Group by 1;

-- 6.	Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
Select GenderCategory,
round(Avg(EstimatedSalary),2) 'Higher Avg Estimated Salary',
Count(c.CustomerId) 'Count of Active Cust'
From customerinfo c 
Join bank_churn bc
ON c.CustomerId=bc.CustomerId
where ActiveCategory='Active Member'
Group by 1
Order by 2 DESC
Limit 1;

-- 7.	Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)
SELECT CASE 
WHEN CreditScore BETWEEN 350 AND 450 THEN '350-450'
WHEN CreditScore BETWEEN 450 AND 550 THEN '450-550'
WHEN CreditScore BETWEEN 550 AND 650 THEN '550-650'
WHEN CreditScore BETWEEN 650 AND 750 THEN '650-750'
ELSE '750-850' END AS CreditScoreRange,
COUNT(bc.customerId) AS Exit_Rate_Customers
from bank_churn bc
where ExitCategory='Exit'
Group by 1
Order by 2 Desc;

-- 8.	Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
Select c.GeographyLocation, Count(bc.CustomerID) 'Active Customers'
from customerinfo c 
Join bank_churn bc
ON c.CustomerId=bc.CustomerID
Where ActiveCategory='Active Member' And Tenure>5
Group by 1
Order by 2 Desc
limit 1;

-- 9.	What is the impact of having a credit card on customer churn, based on the available data?
Select ActiveCategory,ExitCategory,Count(CustomerID) as 'CustomerCount'
From bank_churn
where HasCrCard='Credit Card Holder' and ExitCategory='Exit'
Group by 1,2;

-- 10.	For customers who have exited, what is the most common number of products they have used?
Select NumOfProducts, count(CustomerID) as Custmer_Count
From bank_churn
Where ExitCategory='Exit'
group by 1
Order by 2 desc;

--  11.	Examine the trend of customer exits over time and identify any seasonal patterns (yearly or monthly).
--  Prepare the data through SQL and then visualize it.
Select YEAR(BankDOJ) 'Years',Count(c.CustomerID) Customers
From CustomerInfo c 
Join bank_churn bc
ON c.CustomerId=bc.CustomerID
Where ExitCategory='Exit'
group by 1
Order by 2 desc;

-- 12.Analyze the relationship between the number of products and the account balance for customers who have exited.
Select NumOfProducts, Sum(Balance) Acc_balance
From bank_churn
Where ExitCategory='Exit'
Group by 1
Order by 2 Desc;

-- 13.	Identify any potential outliers in terms of balance among customers who have remained with the bank
Select c.Surname,Sum(bc.Balance) Acc_Balance
From customerinfo c
JOIN bank_churn bc
ON c.CustomerId=bc.CustomerId
Where ExitCategory='Retain'
Group by 1
Order by 2 DESC;


-- 14.	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id.
--  Also, rank the gender according to the average value. (SQL)
WITH CTE AS
(Select GenderCategory,GeographyLocation,ROUND(Avg(EstimatedSalary),0) as Avg_income
FROM customerinfo c 
Group by GenderCategory,GeographyLocation)
	Select *,
    dense_rank() OVER (Order by Avg_income DESC) as 'Rank'
    from CTE;
    
-- 15.	Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
SELECT CASE 
	WHEN Age BETWEEN 18 AND 30 THEN '18-30'
    WHEN Age BETWEEN 30 AND 50 THEN '30-50'
    ELSE '50+' END AS AGE_BRACKET,ROUND(AVG(Tenure),0) AVG_TENURE
From CustomerInfo c 
JOIN Bank_Churn bc 
ON c.CustomerID=bc.CustomerID
WHERE ExitCategory='Exit'
Group by 1
ORDER BY 1;

 -- 16)	Rank each bucket of credit score as per the number of customers who have churned the bank.
 SELECT CASE 
WHEN CreditScore BETWEEN 350 AND 450 THEN '350-450'
WHEN CreditScore BETWEEN 450 AND 550 THEN '450-550'
WHEN CreditScore BETWEEN 550 AND 650 THEN '550-650'
WHEN CreditScore BETWEEN 650 AND 750 THEN '650-750'
ELSE '750-850' END AS CreditScore,
    COUNT(*) AS ChurnedCustomers,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS CreditScoreRank
FROM bank_churn 
GROUP BY 1;

-- 17)	According to the age buckets find the number of customers who have a credit card. Also, retrieve those buckets that have a lesser than average number of credit cards per bucket.
WITH CreditCardCounts AS (
    SELECT 
        CASE 
            WHEN Age >= 18 AND Age <= 30 THEN '18-30'
            WHEN Age >= 31 AND Age <= 40 THEN '31-40'
            WHEN Age >= 41 AND Age <= 50 THEN '41-50'
            WHEN Age >= 51 AND Age <= 60 THEN '51-60'
            WHEN Age >= 61 AND Age <= 70 THEN '61-70'
            WHEN Age >= 71 AND Age <=80  THEN '71-80'
            WHEN Age >80 THEN '80+'
        END AS AgeBucket,
        SUM(CASE WHEN bc.HasCrCard = 'Credit Card Holder' THEN 1 ELSE 0 END) AS CreditCardCount
    FROM CustomerInfo ci
    JOIN Bank_Churn bc ON ci.CustomerId = bc.CustomerId
    GROUP BY AgeBucket
)
SELECT 
    AgeBucket,
    CreditCardCount
FROM CreditCardCounts
WHERE CreditCardCount < (SELECT AVG(CreditCardCount) 
    FROM CreditCardCounts);

-- 18) Rank the Locations as per the number of people who have churned the bank and the average balance of the learners.

WITH AverageBalance AS (
    SELECT 
        ci.GeographyLocation,
        COUNT(*) AS ChurnedCount,
        Round(AVG(bc.Balance),2) AS AvgBalance
    FROM 
        CustomerInfo ci
    JOIN 
        bank_churn bc ON ci.CustomerId = bc.CustomerId
	Where ExitCategory='Exit'
    GROUP BY 
        GeographyLocation
)
SELECT 
    GeographyLocation,
    ChurnedCount,
    AvgBalance,
    RANK() OVER (ORDER BY ChurnedCount DESC, AvgBalance DESC) AS LocationRank
FROM AverageBalance ;

-- 19.	As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.
Select Concat(bc.CustomerId,'_',c.Surname) as CustomerID_Surname
From customerinfo c 
Join bank_churn bc ON c.CustomerId=bc.CustomerId;

-- 20)  Write the query to get the customer ids, their last name and whether they are active or not for the customers whose surname ends with “on”.
Select c.CustomerId,c.Surname,bc.ActiveCategory
from customerinfo c 
JOIN bank_churn bc 
ON c.CustomerId=bc.CustomerId
Where c.Surname LIKE('%on');

 -- 21)Utilize SQL queries to segment customers based on demographics, account details, and transaction behaviours.
 Select c.GeographyLocation, Round(Sum(bc.Balance),0) Acc_Balance
 From customerinfo c 
 JOIN bank_churn bc 
 ON c.CustomerId=bc.CustomerId
 Group by 1
 Order by 2 DESC;