--------------------------------------validate data--------------------------------------
--check any transaction with same customer_id, t_dat, article_id, price (16472)
WITH cntTrans AS (
	SELECT t_dat, customer_id, count(1) as cnt
	FROM [DataPlayground].[dbo].[hm_transactions]
	group by customer_id, t_dat, article_id, price
	HAVING count(1) > 1
) SELECT SUM(cnt) FROM cntTrans

--check any transaction with same customer_id, t_dat, article_id but different price (1645)
;WITH cntTrans AS (
	SELECT t_dat, customer_id, count(1) as cnt
	FROM [DataPlayground].[dbo].[hm_transactions]
	group by customer_id, t_dat, article_id
	HAVING COUNT(DISTINCT price) > 1
)SELECT SUM(cnt) FROM cntTrans


--double check any transaction with same customer_id, t_dat but different article_id (292663)
;WITH cntTrans AS (
	SELECT t_dat, customer_id, count(1) as cnt
	FROM [DataPlayground].[dbo].[hm_transactions]
	group by customer_id, t_dat
	HAVING COUNT(DISTINCT article_id) > 1
) SELECT SUM(cnt) FROM cntTrans


--------------------------------------analyze data--------------------------------------
-- overall trend of sales by day (distinct customer)
;WITH transBycust AS (
    SELECT [t_dat], customer_id , sum(price) as price
    FROM [DataPlayground].[dbo].[hm_transactions]
    group by t_dat, customer_id
) SELECT [t_dat], sum(price)*100 as price, count(1) as cnt
FROM transBycust
group by [t_dat]
order by [t_dat] asc

-- overall trend of sales by month (distinct customer)
;WITH transBycust AS (
SELECT [t_dat], customer_id, sum(price)*100 as price
  FROM [DataPlayground].[dbo].[hm_transactions]
  group by t_dat, customer_id
) SELECT MONTH([t_dat]) as month, sum(price) as price, count(1) as cnt, SUM(price) / COUNT(1) AS monthly_aov
FROM transBycust
group by MONTH([t_dat])
order by MONTH([t_dat]) asc

-- overall trend of sales by day
SELECT [t_dat], sum(price)*100  as price, count(1) as cnt
FROM [DataPlayground].[dbo].[hm_transactions]
group by [t_dat]
order by [t_dat] asc

-- overall trend of sales by month
SELECT MONTH([t_dat]) as month, sum(price)*100 as price, count(1) as cnt
FROM [DataPlayground].[dbo].[hm_transactions]
group by MONTH([t_dat])
order by MONTH([t_dat]) asc

-- AOV and average orders per customer by month
;WITH MonthlyCustomerOrders AS (
SELECT 
        FORMAT(t_dat, 'yyyy-MM') AS sales_month,
        customer_id,
        COUNT(DISTINCT t_dat) AS orders_count,
        SUM(price) * 100 AS customer_monthly_spend
    FROM [DataPlayground].[dbo].[hm_transactions]
    GROUP BY 
        FORMAT(t_dat, 'yyyy-MM'),
        customer_id
)-- Step 2: Aggregate to the monthly level
SELECT 
    sales_month,
    COUNT(DISTINCT customer_id) AS active_customers,
    SUM(orders_count) AS total_orders,
    
    -- Metric 1: Average Order Value (AOV)
    SUM(customer_monthly_spend) / SUM(orders_count) AS aov,
    
    -- Metric 2: Average Orders per Active Customer
    CAST(SUM(orders_count) AS FLOAT) / COUNT(DISTINCT customer_id) AS avg_orders_per_customer
    
FROM MonthlyCustomerOrders
GROUP BY sales_month
ORDER BY sales_month

--Top 3 bestsellers by month
;WITH MonthlyProductSales AS (
    SELECT 
        FORMAT(t_dat, 'yyyy-MM') AS sales_month,
        product_code,
        MAX(t2.prod_name) as product_name,
        COUNT(1) AS total_units_sold,
        SUM(price) AS total_revenue
    FROM [DataPlayground].[dbo].[hm_transactions] t1
    LEFT JOIN hm_articles t2
    on t1.article_id = t2.article_id
    GROUP BY 
        FORMAT(t_dat, 'yyyy-MM'),
        product_code
),
RankedProducts AS (
    SELECT 
        sales_month,
        product_code,
        product_name,
        total_units_sold,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY sales_month 
            ORDER BY total_units_sold DESC
        ) AS product_rank
    FROM MonthlyProductSales
)
SELECT 
    r.sales_month,
    LEFT(DATENAME(month, sales_month+'-01'), 3),
    r.product_rank,
    r.product_code,
    r.product_name,
    r.total_units_sold,
    r.total_revenue
FROM RankedProducts r
WHERE r.product_rank <= 3
ORDER BY r.sales_month, r.product_rank

--Top 3 product ranked by revenue by month
;WITH MonthlyProductSales AS (
    SELECT 
        FORMAT(t_dat, 'yyyy-MM') AS sales_month,
        product_code,
        MAX(t2.prod_name) as product_name,
        COUNT(1) AS total_units_sold,
        SUM(price)*100 AS total_revenue
    FROM [DataPlayground].[dbo].[hm_transactions] t1
    LEFT JOIN hm_articles t2
    on t1.article_id = t2.article_id
    GROUP BY 
        FORMAT(t_dat, 'yyyy-MM'),
        product_code
),
RankedProducts AS (
    SELECT 
        sales_month,
        product_code,
        product_name,
        total_units_sold,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY sales_month
            ORDER BY total_revenue DESC
        ) AS product_rank
    FROM MonthlyProductSales
)
SELECT 
    r.sales_month,
    LEFT(DATENAME(month, sales_month+'-01'), 3),
    r.product_rank,
    r.product_code,
    r.product_name,
    r.total_units_sold,
    r.total_revenue
FROM RankedProducts r
WHERE r.product_rank <= 3
ORDER BY r.sales_month, r.product_rank

--identify the products which make up of 80% of the revenue
;WITH ProductPerformance AS (
    SELECT 
        a.product_code,
        a.prod_name,
        COUNT(t.article_id) AS total_units_sold,
        SUM(t.price*100)/COUNT(1) AS avg_revenue,
        SUM(t.price*100) AS total_revenue
    FROM [DataPlayground].[dbo].[hm_transactions] t
    INNER JOIN [DataPlayground].[dbo].[hm_articles] a 
        ON t.article_id = a.article_id
    GROUP BY a.product_code, a.prod_name
),PercentileRankings AS (
    SELECT 
        product_code,
        prod_name,
        total_units_sold,
        avg_revenue,
        total_revenue,
        PERCENT_RANK() OVER (ORDER BY total_units_sold) AS volume_percentile,
        PERCENT_RANK() OVER (ORDER BY total_revenue) AS revenue_percentile
    FROM ProductPerformance
)
SELECT * FROM PercentileRankings
WHERE revenue_percentile >= 0.8
order by total_revenue desc

--ARPU & AOV by age Segments
;WITH CustomerSegmentTotals AS (
    SELECT 
        c.customer_id,
        CASE 
            WHEN c.age < 25 THEN '1. Under 25 (Gen Z)'
            WHEN c.age BETWEEN 25 AND 38 THEN '2. 25-38 (Millennials)'
            WHEN c.age BETWEEN 39 AND 55 THEN '3. 39-55 (Gen X)'
            WHEN c.age >= 56 THEN '4. 56+ (Seniors)'
            ELSE '5. Unknown Age'
        END AS age_group,
        
        CASE 
            WHEN [FN] = 1 THEN 'Subscriber'
            ELSE 'Non-Subscriber'
        END AS subscriber_status,
        
        COUNT(DISTINCT t.t_dat) AS total_orders,
        COUNT(t.article_id) AS total_units_bought,
        SUM(t.price*100) AS total_customer_spend
    FROM [DataPlayground].[dbo].[hm_customer] c
    INNER JOIN [DataPlayground].[dbo].[hm_transactions] t
        ON c.customer_id = t.customer_id
    GROUP BY 
        c.customer_id,
        c.age,
        c.FN
)
SELECT 
    age_group,
    subscriber_status,
    
    -- Segment Sizes (Population Base)
    COUNT(DISTINCT customer_id) AS active_customer_count,
    SUM(total_orders) AS total_segment_orders,
    SUM(total_customer_spend) AS total_segment_revenue,
    
    -- 1. Normalized: Average Revenue Per User (ARPU)
    ROUND(SUM(total_customer_spend) / COUNT(DISTINCT customer_id), 2) AS arpu,
    
    -- 2. Normalized: Average Order Value (AOV)
    ROUND(SUM(total_customer_spend) / SUM(total_orders), 2) AS aov,
    
    -- 3. Normalized: Purchase Frequency (Orders per Customer)
    ROUND(CAST(SUM(total_orders) AS FLOAT) / COUNT(DISTINCT customer_id), 2) AS orders_per_customer
FROM CustomerSegmentTotals
GROUP BY 
    age_group,
    subscriber_status
ORDER BY 
    age_group, 
    subscriber_status

--units sold & revenue by product categories
SELECT 
    -- Group customers into age cohorts
    CASE 
        WHEN c.age < 25 THEN 'Under 25 (Gen Z)'
        WHEN c.age BETWEEN 25 AND 38 THEN '25-38 (Millennials)'
        WHEN c.age BETWEEN 39 AND 55 THEN '39-55 (Gen X)'
        ELSE '56+'
    END AS age_cohort,
    -- Product Group / Category level (or join to find specific top products)
    a.product_type_name,
    --a.[garment_group_name],  a.colour_group_name,  a.graphical_appearance_name,
    COUNT(t.article_id) AS total_units_sold,
    SUM(t.price*100) AS total_revenue
    
FROM [DataPlayground].[dbo].[hm_transactions] t
INNER JOIN [DataPlayground].[dbo].[hm_articles] a 
    ON t.article_id = a.article_id --AND a.product_type_name = 'Trousers'
INNER JOIN [DataPlayground].[dbo].[hm_customer] c 
    ON t.customer_id = c.customer_id
GROUP BY 
    CASE 
        WHEN c.age < 25 THEN 'Under 25 (Gen Z)'
        WHEN c.age BETWEEN 25 AND 38 THEN '25-38 (Millennials)'
        WHEN c.age BETWEEN 39 AND 55 THEN '39-55 (Gen X)'
        ELSE '56+'
    END
   ,a.product_type_name
    --a.[garment_group_name],  a.colour_group_name,  a.graphical_appearance_name
order by  age_cohort asc, total_revenue desc