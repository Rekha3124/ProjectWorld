USE DAB422
SELECT * FROM [dbo].[amazon_products];
SELECT * FROM [dbo].[amazon_categories];
DROP table amazon;
create table amazon(
Product_id varchar(500),
Category_id varchar(100),
Title varchar(500),
Image_url VARCHAR(500),
Product_url varchar(500),
Stars varchar(500),
Reviews varchar(500),
Price varchar(500),
List_price varchar(500),
Best_seller varchar(500),
BoughtIn_Lastmonth varchar(500),
Category_name varchar(500)
)
INSERT INTO [dbo].[amazon] (Product_id, Category_id, Title, Image_url, Product_url, Stars, Reviews, Price, List_price, Best_seller, BoughtIn_Lastmonth, Category_name)
SELECT
    LEFT(D1.[asin], 500) AS Product_id,
	LEFT([category_id],200) AS Category_id,
    LEFT([title], 500) AS Title,
    LEFT([imgUrl], 500) AS Image_url,
    LEFT([productURL], 500) AS Product_url,
    LEFT([stars], 500) AS Stars,
    LEFT([reviews], 500) AS Reviews,
    LEFT([price], 500) AS Price,
    LEFT([listPrice], 500) AS List_price,
    LEFT(D1.[isBestSeller], 500) AS Best_seller,
    LEFT(D1.[boughtInLastMonth], 500) AS BoughtIn_Lastmonth,
    LEFT([dbo].[amazon_categories].[category_name], 500) AS Category_name
FROM [dbo].[amazon_products] AS D1
INNER JOIN [dbo].[amazon_categories] ON D1.category_id = [dbo].[amazon_categories].id;
select * from [dbo].[amazon];

--DATA CLEANING
-- To check the Unique values
SELECT COUNT(DISTINCT [Product_id]) AS unique_values_count
FROM [dbo].[amazon];
--To check the missing values
SELECT
    COUNT(*) - COUNT([BoughtIn_Lastmonth]) AS missing_id_count,
    COUNT(*) - COUNT([Category_name]) AS missing_category_count
FROM [dbo].[amazon];
--To check the null values 
SELECT
    SUM(CASE WHEN [Product_id] IS NULL THEN 1 ELSE 0 END) AS column1_null_count,
    SUM(CASE WHEN [Category_id] IS NULL THEN 1 ELSE 0 END) AS column2_null_count,
    SUM(CASE WHEN [Category_name] IS NULL THEN 1 ELSE 0 END) AS column3_null_count
    FROM [dbo].[amazon];

--Delete the record where there is string value instead of integer in Stars column
DELETE FROM [dbo].[amazon]
WHERE stars IS NOT NULL
AND (
    CHARINDEX('http', Stars) > 0
    OR CHARINDEX('www', Stars) > 0
);

DELETE FROM [dbo].[amazon]
WHERE Stars IS NOT NULL
AND Stars NOT LIKE '%[^0-9]%';

select [Stars] from [dbo].[amazon];
DELETE FROM [dbo].[amazon]
WHERE stars NOT LIKE '%[0-9]%';
select [Stars]  from  [dbo].[amazon];

DELETE FROM [dbo].[amazon]
WHERE Stars IS NOT NULL
AND ISNUMERIC(Stars) = 0;

--Deleting all the string values from reviews column
DELETE FROM [dbo].[amazon]
WHERE [Reviews] IS NOT NULL
AND ISNUMERIC([Reviews]) = 0;

DELETE FROM [dbo].[amazon]
WHERE [Price] IS NOT NULL
AND ISNUMERIC([Price]) = 0;
--Dropping a column
Alter table [dbo].[amazon]
Drop column [BoughtIn_Lastmonth];

select * from [dbo].[amazon];
--Q1))Uncover trending product categories and their sales performance.
SELECT TOP 10
    Category_name,
    SUM(CAST(Price AS DECIMAL(10, 2))) AS total_sales
FROM amazon
GROUP BY Category_name
ORDER BY total_sales DESC;
--Q2)Analyze customer ratings to find top-rated products.
SELECT TOP 15
    [Product_id],
    [Title],
    [Stars]
FROM [dbo].[amazon]
WHERE [Stars] = (SELECT MAX([Stars]) FROM [dbo].[amazon]);
--Q3)What is the distribution of prices for products?
SELECT
    MIN(CAST([Price] AS DECIMAL(10, 2))) AS min_price,
    MAX(CAST([Price] AS DECIMAL(10, 2))) AS max_price,
    CAST(AVG(CAST([Price] AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS avg_price,
    COUNT([Price]) AS count_price
FROM [dbo].[amazon];
--Q4)What is the average rating and review count for products?
SELECT
    AVG(CAST(Stars AS DECIMAL(10, 2))) AS avg_rating,
    AVG(CAST(Reviews AS DECIMAL(10, 2))) AS avg_review_count
FROM [dbo].[amazon];
--Q5)Gain insight into the best price for any given product based on sales data and competition.
WITH ProductCategoryStats AS (
    SELECT
        Category_name,
        AVG(CAST(Price AS DECIMAL(10, 2))) AS avg_price,
        MAX(CAST(Reviews AS INT)) AS max_reviews
    FROM [dbo].[amazon]
    GROUP BY Category_name
)

SELECT TOP 10
    p.Product_id,
    p.Category_id,
    p.Stars,
    p.Reviews,
    p.Price,
    p.List_price,
    s.avg_price AS avg_category_price,
    s.max_reviews AS max_reviews_in_category
FROM [dbo].[amazon] p
JOIN ProductCategoryStats s ON p.Category_name = s.Category_name;

--Q6)Gain insights into the general spending habits of online shoppers.
SELECT TOP 10
    Category_name,
    AVG(CAST(Price AS DECIMAL(10, 2))) AS avg_spending,
    COUNT(*) AS purchase_count
FROM [dbo].[amazon]
GROUP BY Category_name;
--Q7)Identify which niches are the easiest to make sales in.
SELECT TOP 10
    Category_name,
    COUNT(Product_id) AS sales_count
FROM [dbo].[amazon]
GROUP BY Category_name
ORDER BY sales_count DESC;

--Q8)Which product is the best selling product?
UPDATE [dbo].[amazon]
SET Best_seller = CASE
    WHEN Best_seller = '1' THEN 1
    WHEN Best_seller = '0' THEN 0
    ELSE 0  -- Set any other values to 0 (not a best seller)
END;

SELECT TOP 10 Category_id,Category_name,Best_seller,Stars,Price
FROM [dbo].[amazon]
WHERE Best_seller = 1;




