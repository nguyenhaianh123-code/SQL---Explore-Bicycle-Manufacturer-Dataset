-- Câu 1: "Calc Quantity of items, Sales value & Order quantity by each Subcategory in L12M
-- (find out The lastest date, and then get data in last 12 months)"

select format_datetime('%b %Y', a.ModifiedDate) month
      ,c.Name
      ,sum(a.OrderQty) qty_item
      ,sum(a.LineTotal) total_sales
      ,count(distinct a.SalesOrderID) order_cnt
FROM `adventureworks2019.Sales.SalesOrderDetail` a 
left join `adventureworks2019.Production.Product` b
  on a.ProductID = b.ProductID
left join `adventureworks2019.Production.ProductSubcategory` c
  on b.ProductSubcategoryID = cast(c.ProductSubcategoryID as string)
where date(a.ModifiedDate) between   (date_sub(date(a.ModifiedDate), INTERVAL 12 month)) and '2014-06-30'
 --where date(a.ModifiedDate) >= (select date_sub(max(date(a.ModifiedDate)), INTERVAL 12 month) FROM `adventureworks2019.Sales.SalesOrderDetail`)
group by 1,2
order by 2,1;

-- Câu 2: Calc % YoY growth rate by SubCategory & release top 3 cat with highest grow rate. Can use metric: quantity_item. Round results to 2 decimal
WITH SalesData AS
(SELECT ps.name AS cat_name,
      SUM(sod.OrderQty) Qty_item,
      EXTRACT(YEAR FROM sod.ModifiedDate) AS Year,
FROM adventureworks2019.Sales.SalesOrderDetail sod
LEFT JOIN adventureworks2019.Production.Product p ON sod.ProductID = p.ProductID
LEFT JOIN adventureworks2019.Production.ProductSubcategory ps ON CAST(p.ProductSubcategoryID AS INT64) = ps.ProductSubcategoryID
GROUP BY cat_name,
         Year),

Growth_rate AS (
SELECT cat_name, 
       Year,
       Qty_item,
       LEAD(Qty_item) OVER (PARTITION BY cat_name ORDER BY Year) AS Prv_qty,
        ROUND(((Qty_item - LEAD(Qty_item) OVER (PARTITION BY cat_name ORDER BY Year)) / LEAD(Qty_item) OVER (PARTITION BY cat_name ORDER BY Year)) * 100, 2) AS Grow_rate
    FROM SalesData
)

SELECT cat_name,
      Qty_item,
      Prv_qty,
    Grow_rate
FROM Growth_rate
ORDER BY
    Grow_rate DESC
LIMIT 3;




-- Câu 3: Ranking Top 3 TeritoryID with biggest Order quantity of every year. If there's TerritoryID with same quantity in a year, do not skip the rank number

WITH OrderData AS
(SELECT soh.TerritoryID as TerritoryID,
      SUM(sod.OrderQty) as order_quantity,
       EXTRACT(YEAR from sod.ModifiedDate) as year_period,
FROM adventureworks2019.Sales.SalesOrderHeader soh
LEFT JOIN adventureworks2019.Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.TerritoryID,
         year_period
ORDER BY year_period),

RankOrderData AS
(SELECT year_period,
        TerritoryID,
        order_quantity,
        DENSE_RANK() OVER(PARTITION BY year_period ORDER BY order_quantity DESC) AS RANK
FROM OrderData)

SELECT year_period,
       TerritoryID,
       order_quantity,
       RANK
FROM RankOrderData
WHERE RANK <=3
ORDER BY year_period,
          RANK;


-- Câu 4 "Calc Total Discount Cost belongs to Seasonal Discount for each SubCategory"
WITH DiscountData AS
(SELECT EXTRACT(YEAR FROM sod.ModifiedDate) as year,
        ps.name as SubCate_name,
        p.StandardCost,
        sod.OrderQty,
        (sod.OrderQty * p.StandardCost * so.DiscountPct) AS DiscountAmount
FROM adventureworks2019.Sales.SalesOrderDetail sod 
LEFT JOIN adventureworks2019.Production.Product p ON sod.ProductID = p.ProductID
LEFT JOIN adventureworks2019.Production.ProductSubcategory ps ON CAST(p.ProductSubcategoryID as INT) = ps.ProductSubcategoryID
LEFT JOIN adventureworks2019.Sales.SpecialOffer so ON sod.SpecialOfferID = so.SpecialOfferID
WHERE LOWER(so.Type) LIKE '%seasonal discount%')

SELECT year,
       SubCate_name, 
       SUM(DiscountAmount) AS total_discount_amount
FROM DiscountData
GROUP BY SubCate_name,
          year;

-- Câu 5: Retention rate of Customer in 2014 with status of Successfully Shipped (Cohort Analysis)

with 
info as (
  select  
      extract(month from ModifiedDate) as month_no
      , extract(year from ModifiedDate) as year_no
      , CustomerID
      , count(Distinct SalesOrderID) as order_cnt
  from `adventureworks2019.Sales.SalesOrderHeader`
  where FORMAT_TIMESTAMP("%Y", ModifiedDate) = '2014'
  and Status = 5
  group by 1,2,3
  order by 3,1 
),

row_num as (
  select *
      , row_number() over (partition by CustomerID order by month_no) as row_numb
  from info 
), 

first_order as (
  select *
  from row_num
  where row_numb = 1
), 

month_gap as (
  select 
      a.CustomerID
      , b.month_no as month_join
      , a.month_no as month_order
      , a.order_cnt
      , concat('M - ',a.month_no - b.month_no) as month_diff
  from info a 
  left join first_order b 
  on a.CustomerID = b.CustomerID
  order by 1,3
)

select month_join
      , month_diff 
      , count(distinct CustomerID) as customer_cnt
from month_gap
group by 1,2
order by 1,2;


-- Câu 6: Trend of Stock level & MoM diff % by all product in 2011. If %gr rate is null then 0. Round to 1 decimal

With MonthlyStock AS
(SELECT
        p.Name AS ProductName,
        EXTRACT(YEAR FROM wo.StartDate) AS Year,
        EXTRACT(MONTH FROM wo.StartDate) AS Month,
        SUM(wo.StockedQty) AS Stock_current
    FROM
        `adventureworks2019.Production.WorkOrder` wo
        JOIN `adventureworks2019.Production.Product` p ON wo.ProductID = p.ProductID
    WHERE
        EXTRACT(YEAR FROM wo.StartDate) = 2011
    GROUP BY
        p.Name, Year, Month),
StockTrend AS (
    SELECT
        ProductName,
        Year,
        Month,
        Stock_current,
        LEAD(Stock_current) OVER (PARTITION BY ProductName ORDER BY Year, Month) AS Stock_prv,
        ROUND((Stock_current - LEAD(Stock_current) OVER (PARTITION BY ProductName ORDER BY Year, Month)) / LEAD(Stock_current) OVER (PARTITION BY ProductName ORDER BY Year, Month) * 100, 1) AS diff_percentage
    FROM MonthlyStock
)
    
SELECT
    ProductName AS `Product Name`,
    Month,
    Year,
    Stock_current AS `Stock_current`,
    COALESCE(Stock_prv, 0) AS `Stock_prv`,
    COALESCE(diff_percentage, 0) AS `%diff`
FROM
    StockTrend
ORDER BY
    ProductName, Year, Month;


-- Câu 7: "Calc Ratio of Stock / Sales in 2011 by product name, by month
-- Order results by month desc, ratio desc. Round Ratio to 1 decimal"
with 
sale_info as (
  select 
      extract(month from a.ModifiedDate) as mth 
     , extract(year from a.ModifiedDate) as yr 
     , a.ProductId
     , b.Name
     , sum(a.OrderQty) as sales
  from `adventureworks2019.Sales.SalesOrderDetail` a 
  left join `adventureworks2019.Production.Product` b 
    on a.ProductID = b.ProductID
  where FORMAT_TIMESTAMP("%Y", a.ModifiedDate) = '2011'
  group by 1,2,3,4
), 

stock_info as (
  select
      extract(month from ModifiedDate) as mth 
      , extract(year from ModifiedDate) as yr 
      , ProductId
      , sum(StockedQty) as stock_cnt
  from 'adventureworks2019.Production.WorkOrder'
  where FORMAT_TIMESTAMP("%Y", ModifiedDate) = '2011'
  group by 1,2,3
)

select
      a.*
    , coalesce(b.stock_cnt,0) as stock
    , round(coalesce(b.stock_cnt,0) / sales,2) as ratio
from sale_info a 
full join stock_info b 
  on a.ProductId = b.ProductId
and a.mth = b.mth 
and a.yr = b.yr
order by 1 desc, 7 desc;


-- Câu 8: No of order and value at Pending status in 2014
SELECT
    EXTRACT(YEAR FROM poh.ModifiedDate) AS Year,
    poh.Status,
    COUNT(poh.PurchaseOrderID) AS Order_cnt,
    SUM(poh.TotalDue) AS Value
FROM
    adventureworks2019.Purchasing.PurchaseOrderHeader poh
WHERE
    EXTRACT(YEAR FROM poh.ModifiedDate) = 2014
    AND poh.Status = 1
GROUP BY
    Year,
    Status
ORDER BY
    Year,
    Status;

-->
select 
    extract (year from ModifiedDate) as yr
    , Status
    , count(distinct PurchaseOrderID) as order_Cnt 
    , sum(TotalDue) as value
from `adventureworks2019.Purchasing.PurchaseOrderHeader`
where Status = 1
and extract(year from ModifiedDate) = 2014
group by 1,2
;

