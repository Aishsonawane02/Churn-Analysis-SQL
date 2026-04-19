# Churn-Analysis-SQL
SQL-based Customer Churn Analysis using MySQL, with churn metrics, cohort analysis, RFM segmentation, and business insights.
Customer Churn Analysis (SQL Project)
Project Overview
Customer churn is a critical problem for subscription-based businesses because losing customers directly impacts revenue. This project analyzes telecom customer data to identify churn patterns, understand customer behavior, and provide insights that can help improve customer retention strategies.
Using SQL, the dataset was explored to calculate churn rate, analyze customer tenure patterns, and segment customers based on their value and engagement.

Objectives
The main objectives of this project were:

Calculate overall customer churn rate

Identify factors contributing to customer churn

Analyze churn patterns based on customer tenure and contract type

Segment customers using RFM analysis

Provide business insights for improving customer retention

Dataset
The dataset contains telecom customer information including:

Customer ID, Gender, SeniorCitizen status

Tenure, Contract Type, Monthly Charges, Total Charges

Services (PhoneService, InternetService, TechSupport, Streaming)

Payment Method, Churn Status

Tools & Technologies

SQL

MySQL

python


**Dataset**
CSV files imported to MySQL using Python, then analyzed with SQL queries covering customer demographics, billing, services, and churn status.
Key Insights

Data Analysis & RFM Segmentation

Key Analysis Performed

Churn Rate Calculation
Overall churn rate analysis across all customers.
Result: 26.54% churn rate identified as significant business challenge.

Churn by Contract Type
Month-to-month contracts showed highest churn risk.
Insight: Long-term contracts significantly reduce churn probability.

Churn by Tenure
New customers (0-12 months) at highest risk.
Insight: Early retention strategies needed for onboarding phase.

RFM Customer Segmentation

Recency: Tenure-based engagement

Frequency: Service usage count

Monetary: Total charges value
Segments: High Risk, Regular, Loyal High Value, High Value customers

Overall churn rate: 26.54%

Month-to-month contracts: Highest churn risk

Short tenure customers: 50%+ churn probability

Electronic check payments: Highest churn among payment methods

2-year contracts: Only 3% churn rate

Business Recommendations

Convert month-to-month to long-term contracts

Targeted onboarding for new customers (0-12 months)

Retention campaigns for electronic check users

Tech support bundles for fiber optic customers

Loyalty incentives for high-value customers

Project Structure

text
customer-churn-analysis/
├── Project3_Churn_Analysis.sql
├── customers.csv
├── services.csv
├── billing.csv
└── churn.csv
├── README.md
Conclusion
This project demonstrates comprehensive SQL analysis skills for customer churn prediction and business decision-making. The structured approach from database creation through actionable insights shows practical data analysis capabilities for real-world retention challenges.

Future Improvements

Power BI/Tableau interactive dashboard

Machine learning churn prediction model

Customer lifetime value (CLV) optimization

A/B testing retention strategies

Author
Aishwarya Sonawane
