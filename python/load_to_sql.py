import pandas as pd
from sqlalchemy import create_engine

#1. Load dataset
df = pd.read_csv('data/Financial Statements.csv')

#2. Data cleaning and preprocessing
df_cleaned = df.dropna()
df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_').str.replace(r'[()/]', '', regex=True)

#3. Create connection to MySQL
engine = create_engine('mysql+pymysql://root:Juliaalie2003*@localhost/financial_health')

#4. Upload to MySQL 
df.to_sql('financial_statements_data', con=engine, if_exists='replace', index=False) 
print("Data loaded to MySQL!")
