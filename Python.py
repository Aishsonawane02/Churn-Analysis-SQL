%pip install sqlalchemy pymysql
import pandas as pd
from sqlalchemy import create_engine

# Read the CSV
df = pd.read_csv('WA_Fn-UseC_-Telco-Customer-Churn.csv')

# Fix TotalCharges — some rows have blank spaces instead of numbers
df['TotalCharges'] = pd.to_numeric(df['TotalCharges'], errors='coerce')
df['TotalCharges'] = df['TotalCharges'].fillna(df['TotalCharges'].median())

# Add the numeric churn flag
df['Churn_Flag'] = (df['Churn'] == 'Yes').astype(int)

# Connect to your MySQL database
# Replace 'root' and 'yourpassword' with your MySQL credentials
engine = create_engine("mysql+pymysql://root:Aishwarya%402@localhost/churn_analysis")

# Split and load each table
df[['customerID','gender','SeniorCitizen','Partner','Dependents','tenure']
  ].to_sql('customers', engine, if_exists='append', index=False)

df[['customerID','PhoneService','MultipleLines','InternetService',
    'OnlineSecurity','OnlineBackup','DeviceProtection',
    'TechSupport','StreamingTV','StreamingMovies']
  ].to_sql('services', engine, if_exists='append', index=False)

df[['customerID','Contract','PaperlessBilling','PaymentMethod',
    'MonthlyCharges','TotalCharges']
  ].to_sql('billing', engine, if_exists='append', index=False)

df[['customerID','Churn','Churn_Flag']
  ].to_sql('churn', engine, if_exists='append', index=False)

print("Done! All 4 tables loaded.")
import pandas as pd
from sqlalchemy import create_engine

# Read the CSV
df = pd.read_csv('WA_Fn-UseC_-Telco-Customer-Churn.csv')

# Fix TotalCharges — some rows have blank spaces instead of numbers

# Add the numeric churn flag
df['Churn_Flag'] = (df['Churn'] == 'Yes').astype(int)

# Connect to your MySQL database
# Replace 'root' and 'yourpassword' with your MySQL credentials
engine = create_engine('mysql+pymysql://root:yourpassword@localhost/churn_analysis')

# Split and load each table


print("Done! All 4 tables loaded.")
