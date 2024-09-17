# E-commerce-Customer-Segmentation-and-Behavioral-Analysis
Here is a suggested README based on your provided information:

---

# E-commerce Customer Segmentation and Behavioral Analysis

This project analyzes the behavior of 1 million Taobao users based on nearly 100 million behavioral data points. The data processing was carried out using MySQL, followed by visualization using Tableau.

## Project Overview

- **Tableau Visualization Link**: [Tableau Public Dashboard](https://public.tableau.com/app/profile/chaoyang.sun7474/viz/Analysisbasedon100millionbehavioraldataof1milliontaobaousers/1)
- **Data Source**: [Alibaba Tianchi Dataset](https://tianchi.aliyun.com/dataset/649)

This project includes customer behavior segmentation and the analysis of different behavior patterns based on Taobao user data. We used SQL to preprocess and filter the dataset, followed by visualization of various metrics such as customer retention, conversion rate, and behavioral paths.

## Data Processing

1. **Data Import**: To efficiently process the large dataset (~100 million rows), we utilized MySQL for data import and manipulation. The import process may take over an hour if performed directly. Using command-line MySQL improves the speed. The database creation script is as follows:

   ```sql
   CREATE DATABASE taobao;
   USE taobao;

   CREATE TABLE user_behavior (
       user_id INT(9), 
       item_id INT(9), 
       category_id INT(9), 
       behavior_type VARCHAR(5), 
       timestamp INT(14)
   );
   ```

2. **Data Filtering**: The dataset can be filtered during the import process to reduce the size and focus on specific user behaviors (such as clicks, cart additions, purchases, etc.).

## Data Visualization

- **Connection to Tableau**: MySQL was connected to Tableau for visualization. However, due to potential compatibility issues between MySQL drivers and macOS, it is recommended to export MySQL tables as CSV files and import them into Tableau if the connection doesn't work.

- **Key Visualizations**: 
   - Customer retention rates
   - Conversion rates by behavior type
   - RFM (Recency, Frequency, Monetary) model segmentation
   - Behavioral path analysis
   - Time-series analysis of user actions

## Tools Used

- **MySQL**: For large-scale data processing and SQL-based querying.
- **Tableau**: For interactive data visualization and presentation.

## How to Use

1. Download the dataset from the provided link.
2. Import the dataset into MySQL using the provided SQL script.
3. Filter and preprocess the data according to your needs.
4. Connect MySQL to Tableau or export the tables as CSV files for visualization.
5. Explore the Tableau dashboard linked above for insights into user behavior.

---

Feel free to customize this README further according to your preferences.
