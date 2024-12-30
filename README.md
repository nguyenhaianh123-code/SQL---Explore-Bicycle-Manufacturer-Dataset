# SQL---Explore-Bicycle-Manufacturer-Dataset

## Introduction
This project aims to analyze and generate insights from the AdventureWorks sample database, which simulates real-world online transaction processing scenarios for a fictitious bicycle manufacturer, Adventure Works Cycles. The project focuses on utilizing advanced SQL techniques to answer critical business questions across key domains such as Sales, Product Management, and Customer Retention. The analysis will provide actionable insights to improve operational efficiency and decision-making.

## The goal of creating this project
The specific objectives of this project are:
1. **Sales Performance Analysis:**
- Calculate the quantity of items, sales value, and order quantity by subcategory over the last 12 months (L12M).
- Determine the year-over-year (YoY) growth rate by subcategory, identifying the top 3 subcategories with the highest growth rates based on quantity_item.
  
2. **Territory Analysis:**
- Rank the top 3 Territory IDs with the largest order quantities for each year, ensuring rankings handle ties without skipping ranks.

3. **Discount Cost Analysis:**

- Compute the total discount cost attributed to Seasonal Discounts for each subcategory.
4. **Customer Retention Analysis:**
- Perform cohort analysis to calculate the retention rate of customers in 2014 with orders in the "Successfully Shipped" status.

5. **Stock Level Trends:**
- Analyze the trend of stock levels in 2011, including the month-over-month (MoM) percentage difference for all products, with growth rates rounded to 1 decimal place.
  
6. **Stock-to-Sales Ratio:**
- Compute the ratio of stock to sales in 2011 by product name and month, ordering the results by month (descending) and ratio (descending), with ratios rounded to 1 decimal place.
Pending Orders:

- Calculate the number of orders and their total value in the Pending status for 2014.

## Import raw data
The dataset is stored in a public Google BigQuery dataset. To access the dataset, follow these steps:

- Log in to your Google Cloud Platform account and create a new project.
- Navigate to the BigQuery console and select your newly created project.
- Select "Add Data" in the navigation panel and then "Start project by name".
- Enter the project ID "adventureworks2019" and click "Enter".
= Click on the "ga_sessions_" table to open it.


## Data Dictionary 
https://drive.google.com/file/d/1bwwsS3cRJYOg1cvNppc1K_8dQLELN16T/view

## Explore Dataset 

