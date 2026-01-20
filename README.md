📊 E-commerce Sales Performance Dashboard

An end-to-end data analytics project that simulates real-world e-commerce data, processes it using SQL, and visualizes business insights through an interactive Power BI dashboard.

🚀 Project Overview

This project demonstrates the complete analytics workflow:

Synthetic data generation using Python (Faker)

Data modeling & transformations using SQL

Interactive reporting and KPI tracking using Power BI

The dashboard provides a bird’s-eye view of sales performance, customer behavior, and product trends.

🛠️ Tech Stack

Python – Data generation (Faker)

SQL (MySQL) – Data modeling & transformations

Power BI – Data visualization & dashboarding

GitHub – Version control & project documentation

📁 Project Folder Structure

ecommerce-sales-dashboard/
│
├── python/
│   └── data_generation_faker.ipynb
│
├── sql/
│   ├── create_tables.sql
│   └── transformations.sql
│
├── data/
│   ├── raw/
│   │   ├── customers.csv
│   │   ├── orders.csv
│   │   ├── order_items.csv
│   │   └── products.csv
│   └── processed/
│
├── ecommerce-sales-dashboard.pbix
├── ecommerce-sales-dashboard screenshot.png
└── README.md

🔄 Data Pipeline

1️⃣ Data Generation (Python)

Used Faker to generate realistic e-commerce data:

Customers

Orders

Order items

Products

Exported datasets as CSV files

📄 File: python/data_generation_faker.ipynb

2️⃣ Data Modeling & Preparation (SQL)

Created database tables from raw CSV data

Performed joins and transformations to build a fact table

Derived fields such as:

YearMonth

Revenue metrics

Aggregated order values

3️⃣ Data Visualization (Power BI)

Built an interactive dashboard featuring:

Total Revenue

Total Orders

Total Customers

Average Order Value (AOV)

Monthly revenue & order trends

Revenue by category

Top 10 products

Top customers

📸 Dashboard Preview

