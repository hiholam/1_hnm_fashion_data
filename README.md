# Background Overview

H&M is one of the world's largest fast-fashion retailers, offering customers both online and in-store shopping experiences. To remain competitive in the market, H&M provides a wide range of products and frequently refreshes its collections throughout the year. Data-driven insights are therefore essential for helping customers discover products that match their preferences and enabling the company to make informed business decisions and develop effective strategies.

This project aims to uncover insights into seasonal trends, product category demand, customer segments, and shopping behaviour by analysing H&M's 2019 retail data, which includes product, customer, and transaction information.

The key stakeholders for this project are executive management, the marketing team, and the inventory management team. The findings are intended to support strategic decision-making, targeted marketing initiatives, and more effective inventory planning.

### Assumptions and Caveats:
1.	The dataset does not include product costs or other expense data. Therefore, revenue is used to assess sales performance, but profit margins cannot be evaluated.
2.	The analysis is based on an open-source dataset downloaded from Kaggle, which may not represent H&M's complete retail operations or actual company performance in 2019.
3.	Fast fashion involves rapidly changing trends and frequent product turnover, making shorter time intervals more suitable for tracking short-term changes. Due to data limitations, this project focuses on overall sales patterns throughout 2019 rather than real-time trends. Additionally, data spanning multiple years is required to identify recurring seasonal or long-term trends, so this project does not assess year-over-year changes or long-term trends.

### Data source:
https://www.kaggle.com/datasets/sohyunjun0401/h-and-m-personalized-fashion-data

# Data Structure Overview

# Executive Summary
Analysis of the 2019 retail data reveals two distinct seasonal peaks. The first is **the summer peak occurs in June ($311.3K Revenue, 100.1K Units Sold), is driven by high-velocity, low-priced summer items** like T-shirts and Shorts. The second is **the autumn rebound ($258.2K Revenue, 66.2K Units Sold), which recovers from an August trough, is primarily driven by higher-priced cold-weather items** categories such as Sweaters and Outerwear.

**Millennials (25–38) and Gen X (39–55) dominate the customer base**, added up to 67.4% of total. Across the customer segments, Trousers, Dresses, and Sweaters are the top 3 categories in both sales volume and revenue throughout the year.

To maximize the most from the dual seasonal peaks, **marketing and inventory strategies must directly align with product seasonality, pricing, and targeted customer segments**.

The following sections explore the insights and actionable recommendations in depth.

# Insights Deep Dive

1. To establish a baseline for 2019, we analysed total revenue and total units sold.
![alt text](https://github.com/hiholam/1_hnm_fashion_data/blob/main/charts/1.png)
Takeaway: Summer revenue is driven by high sales volumes of lower-priced items, while the autumn rebound appears to be supported by higher-priced products.

2. To better understand customer purchasing behaviour behind the overall sales trends, we analysed Average Order Value (AOV), which measures the average spending per order, and purchase frequency, which measures the average number of orders per active customer.
![alt text](https://github.com/hiholam/1_hnm_fashion_data/blob/main/charts/2.png)
Takeaway: Again, summer sales were associated with more frequent purchases but lower spending per transaction, while autumn saw higher spending per transaction alongside less frequent purchases.

3. Customer distribution across age groups and newsletter subscription status are analyzed to identify the key customer segments and their contributions to revenue.
![alt text](https://github.com/hiholam/1_hnm_fashion_data/blob/main/charts/3.png)
Takeaway: Millennials and Gen X represent the largest customer segments, while Gen Z and customers aged 56+ show stronger newsletter engagement. This suggests an opportunity to improve newsletter subscriptions among Millennials, the largest customer group.

4. To assess the relationship between newsletter subscriptions and customer spending behaviour, we analyzed Average Revenue Per User (ARPU), which measures average revenue per customer, and Average Order Value (AOV), which measures average spending per transaction, between subscribers and non-subscribers.
![alt text](https://github.com/hiholam/1_hnm_fashion_data/blob/main/charts/4.png)
Takeaway: Despite subscribers' lower AOV, they have higher ARPU in every age group, suggesting that their higher purchasing frequency offsets their lower average transaction value.

5. To identify the core product categories, revenue drivers, and age-specific items, we ranked the product categories by units sold and total revenue across all four age groups.
![alt text](https://github.com/hiholam/1_hnm_fashion_data/blob/main/charts/5.png)
We also used heatmap to examine the seasonal trends of the top 25 selling categories.
![alt text](https://github.com/hiholam/1_hnm_fashion_data/blob/main/charts/6.png)
Trousers, dresses, and sweaters are core product categories that drive sales across age groups, while differences in category rankings reveal distinct age group preferences. Seasonal demand patterns further highlight the importance of aligning inventory and marketing with product demand: prioritise warm-weather items ahead of summer, increase cold-weather inventory from September, and maintain consistent stock levels for the Big 3.

# Recommendations
