#Phase 1: Database Setup
#1. Create database ‘churn_analysis’. 
#2.Import CSV files as tables (create those table from existing dataset only) 
#3. Verify data import 

    
CREATE DATABASE Churn_analysis;
use churn_analysis;

CREATE TABLE customers (
    customerID    VARCHAR(20)  PRIMARY KEY,
    gender        VARCHAR(10)  NOT NULL,
    SeniorCitizen TINYINT      NOT NULL DEFAULT 0,
    Partner       VARCHAR(5)   NOT NULL,
    Dependents    VARCHAR(5)   NOT NULL,
    tenure        INT          NOT NULL
);
CREATE TABLE services (
    customerID       VARCHAR(20) PRIMARY KEY,
    PhoneService     VARCHAR(5),
    MultipleLines    VARCHAR(25),
    InternetService  VARCHAR(20),
    OnlineSecurity   VARCHAR(25),
    OnlineBackup     VARCHAR(25),
    DeviceProtection VARCHAR(25),
    TechSupport      VARCHAR(25),
    StreamingTV      VARCHAR(25),
    StreamingMovies  VARCHAR(25),
    FOREIGN KEY (customerID) REFERENCES customers(customerID)
);

CREATE TABLE billing (
    customerID       VARCHAR(20)    PRIMARY KEY,
    Contract         VARCHAR(20),
    PaperlessBilling VARCHAR(5),
    PaymentMethod    VARCHAR(40),
    MonthlyCharges   DECIMAL(8,2),
    TotalCharges     DECIMAL(10,2)  DEFAULT 0,
    FOREIGN KEY (customerID) REFERENCES customers(customerID)
);
CREATE TABLE churn (
    customerID VARCHAR(20) PRIMARY KEY,
    Churn      VARCHAR(5)  NOT NULL,
    Churn_Flag TINYINT     NOT NULL DEFAULT 0,
    FOREIGN KEY (customerID) REFERENCES customers(customerID)
);
Select * from customers limit 10;
Select * from billing limit 10 ;
select * from services limit 10 ;
select * from churn limit 10;

#Phase 2: Data Exploration 
#1. Understand table structures: 

DESCRIBE customers;
DESCRIBE services;
DESCRIBE billing;
DESCRIBE churn;
#2. Check for NULL values.
SELECT
    SUM(CASE WHEN customerID      IS NULL THEN 1 ELSE 0 END) AS null_id,
    SUM(CASE WHEN gender          IS NULL THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN tenure          IS NULL THEN 1 ELSE 0 END) AS null_tenure
FROM customers;
SELECT
    SUM(CASE WHEN TotalCharges IS NULL THEN 1 ELSE 0 END) AS null_total,
    SUM(CASE WHEN MonthlyCharges IS NULL THEN 1 ELSE 0 END) AS null_monthly
FROM billing; 
#3. Identify churn distribution

SELECT
    Churn,
    COUNT(*)                                         AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM churn
GROUP BY Churn;


#Phase 3: Churn Metric Calculations 
#1. Overall churn rate 

SELECT
    COUNT(*)                                               AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END)        AS churned,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                                      AS churn_rate_percentage
FROM churn;

 #2. Churn by tenure cohorts 
 SELECT
    CASE
        WHEN c.tenure BETWEEN 0  AND 12 THEN '0-1 Year'
        WHEN c.tenure BETWEEN 13 AND 24 THEN '1-2 Years'
        WHEN c.tenure BETWEEN 25 AND 48 THEN '2-4 Years'
        WHEN c.tenure BETWEEN 49 AND 72 THEN '4-6 Years'
    END                                                    AS tenure_group,
    COUNT(*)                                               AS total,
    SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END)     AS churned,
    ROUND(
        SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                                      AS churn_rate_pct
FROM customers c
JOIN churn ch ON c.customerID = ch.customerID
GROUP BY tenure_group
ORDER BY MIN(c.tenure);


#3. Churn by contract type
SELECT
    b.Contract,
    COUNT(*)                                               AS total,
    SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END)     AS churned,
    ROUND(
        SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                                      AS churn_rate_pct
FROM billing b
JOIN churn ch ON b.customerID = ch.customerID
GROUP BY b.Contract
ORDER BY churn_rate_pct DESC;

#Phase 4: Cohort & RFM Analysis
# 4.1 — Customer Lifetime Value (CLV)

SELECT
    ch.Churn,
    ROUND(AVG(b.TotalCharges), 2)     AS avg_clv,
    ROUND(AVG(b.MonthlyCharges), 2)   AS avg_monthly,
    ROUND(AVG(c.tenure), 2)           AS avg_tenure_months
FROM customers c
JOIN billing b  ON c.customerID = b.customerID
JOIN churn ch   ON c.customerID = ch.customerID
GROUP BY ch.Churn;



#4.2 — RFM Segmentation using CTE
-- RFM: Recency=tenure (higher=less recent churn risk), 
--       Frequency=number of services, Monetary=TotalCharges

WITH rfm AS (
    SELECT
        c.customerID,
        c.tenure                                            AS recency,
        (
            CASE WHEN s.PhoneService     = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN s.MultipleLines    = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN s.OnlineSecurity   = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN s.OnlineBackup     = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN s.DeviceProtection = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN s.TechSupport      = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN s.StreamingTV      = 'Yes' THEN 1 ELSE 0 END +
            CASE WHEN s.StreamingMovies  = 'Yes' THEN 1 ELSE 0 END
        )                                                   AS frequency,
        b.TotalCharges                                      AS monetary,
        ch.Churn
    FROM customers c
    JOIN services s ON c.customerID = s.customerID
    JOIN billing  b ON c.customerID = b.customerID
    JOIN churn   ch ON c.customerID = ch.customerID
)
SELECT
    CASE
        WHEN recency  >= 48 THEN 'High'
        WHEN recency  >= 24 THEN 'Medium'
        ELSE 'Low'
    END                        AS recency_band,
    CASE
        WHEN frequency >= 6   THEN 'High'
        WHEN frequency >= 3   THEN 'Medium'
        ELSE 'Low'
    END                        AS frequency_band,
    CASE
        WHEN monetary >= 4000 THEN 'High'
        WHEN monetary >= 1500 THEN 'Medium'
        ELSE 'Low'
    END                        AS monetary_band,
    COUNT(*)                   AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned
FROM rfm
GROUP BY recency_band, frequency_band, monetary_band
ORDER BY churned DESC;	


#Phase 5: Insights & Reporting
#5.1 — Create reusable views
-- View 1: Full customer profile joined together
CREATE VIEW vw_customer_full AS
SELECT
    c.customerID, c.gender, c.SeniorCitizen, c.tenure,
    b.Contract, b.MonthlyCharges, b.TotalCharges, b.PaymentMethod,
    s.InternetService, s.TechSupport, s.OnlineSecurity,
    ch.Churn
FROM customers c
JOIN billing  b  ON c.customerID = b.customerID
JOIN services s  ON c.customerID = s.customerID
JOIN churn   ch  ON c.customerID = ch.customerID;

-- Now you can simply query it like a table:
SELECT * FROM vw_customer_full WHERE Churn = 'Yes' LIMIT 10;

#5.2 — High risk segment query
-- Top vulnerable segments: month-to-month + fiber optic + no tech support
SELECT
    b.Contract,
    s.InternetService,
    s.TechSupport,
    COUNT(*)                                              AS total,
    SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END)    AS churned,
    ROUND(
        SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                                     AS churn_rate_pct
FROM billing b
JOIN services s ON b.customerID = s.customerID
JOIN churn   ch ON b.customerID = ch.customerID
GROUP BY b.Contract, s.InternetService, s.TechSupport
ORDER BY churn_rate_pct DESC
LIMIT 10;

#5.3 — Churn by payment method
SELECT
    b.PaymentMethod,
    COUNT(*)                                              AS total,
    SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END)    AS churned,
    ROUND(
        SUM(CASE WHEN ch.Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                                     AS churn_rate_pct
FROM billing b
JOIN churn ch ON b.customerID = ch.customerID
GROUP BY b.PaymentMethod
ORDER BY churn_rate_pct DESC;


SELECT * FROM vw_customer_full
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/churn_report.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


-- Key Business Insights You Will Find
-- Month-to-month contracts → 43% churn — biggest single factor
--  New customers (0–12 months) → 50% churn — need early retention strategy
--  Electronic check payment users churn the most among all payment methods
-- Fiber optic + no tech support + month-to-month = highest-risk combination
-- The analysis reveals that customer churn is strongly associated 
-- with short tenure and flexible contract types
-- Two-year contract customers → only 3% churn — incentivise upgrades


SELECT * FROM vw_customer_full;




