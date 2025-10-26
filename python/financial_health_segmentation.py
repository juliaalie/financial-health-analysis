import pandas as pd
from sqlalchemy import create_engine
from sklearn.cluster import KMeans
from sklearn.preprocessing import MinMaxScaler

engine = create_engine('mysql+pymysql://root:Juliaalie2003*@localhost/financial_health')

#1. Load dataset from MySQL
df = pd.read_sql("SELECT * FROM export_kpis", con=engine)

#2. Data preprocessing for clustering
features = [
    "net_profit_margin_percentage", 
    "gross_profit_margin_percentage",
    "current_ratio", 
    "debt_equity_ratio",
    "roe",
    "roa",
    "roi",
    "asset_turnover_ratio",
    "cfo_percentage",
    "cfi_percentage",
    "cff_percentage"
]


X = df[features].copy()

##handle missing and infinite values
X = X.replace([float('inf'), -float('inf')], pd.NA)
X = X.fillna(X.median(numeric_only=True))

#3. Scale and cluster (3 clusters: Healthy, Moderate, At Risk)
scaler = MinMaxScaler()
X_scaled = scaler.fit_transform(X)
kmeans = KMeans(n_clusters=3, random_state=42)

kmeans = KMeans(n_clusters=3, random_state=42, n_init=10)
df['cluster'] = kmeans.fit_predict(X_scaled)

#4. Map clusters to labels based on their averages
centroids = pd.DataFrame(kmeans.cluster_centers_, columns=features)
summary = df.groupby('cluster')[features].mean().round(4)

#5. Function to label clusters
def label_cluster(row):
    c = row["cluster"]
    #profitability metrics and leverage/liquidity metrics
    if c == summary["roe"].idxmax() and c == summary["net_profit_margin_percentage"].idxmax():
        return "Healthy"
    elif c == summary["debt_equity_ratio"].idxmax() and c == summary["current_ratio"].idxmin():
        return "At Risk"
    else:
        return "Moderate"
    

df["cluster_label"] = df.apply(label_cluster, axis=1)

#6. Composite Financial Health Score (0-100)
df["financial_health_score_raw"] = (
    df["net_profit_margin_percentage"].fillna(0) * 0.25 +
    df["current_ratio"].fillna(0) * 0.2 +
    df["roe"] * 0.15 -
    df["debt_equity_ratio"] * 0.2 +  
    df["asset_turnover_ratio"] * 0.1 +
    df["cfo_percentage"].fillna(0) * 0.1
)

df["financial_health_score"] = MinMaxScaler().fit_transform(df[["financial_health_score_raw"]]) * 100

#7. Save for exports visualizations and reports
out = df[[
    "company_name", "year", "cluster_label", "cluster", "financial_health_score", 
    "net_profit_margin_percentage", "gross_profit_margin_percentage", "ebitda_margin_percentage",
    "current_ratio", "debt_equity_ratio", "roe", "roa", "roi", "asset_turnover_ratio",
    "cfo_percentage", "cfi_percentage", "cff_percentage", 
    "revenue", "net_income", "market_capitalization"
]]

out.to_csv('data/financial_health_segmentation.csv', index=False)
print("Financial health segmentation data saved!")

#ALTMAN Z-SCORE CALCULATION
##Z = 1.2X1 + 1.4X2 + 3.3X3 + 0.6X4 + 1.0X5
##X1 = Working Capital / Total Assets
##X2 = Retained Earnings / Total Assets
##X3 = EBIT / Total Assets
##X4 = Market Value of Equity / Total Liabilities
##X5 = Sales / Total Assets

df2 = pd.read_sql(
    "SELECT company_name, year, market_capitalization, revenue, ebitda, current_ratio, shareholders_equity, total_debt FROM export_kpis", con=engine)

eps = 1e-6 #small constant to avoid division by zero
df2["total_assets"] = df2["shareholders_equity"] + df2["total_debt"] + eps
df2["total_liabilities"] = df2["total_debt"] + eps

##assuming current liabilities is 50% of total liabilities
df2["X1"] = (0.5 * df2["total_liabilities"] * (df2["current_ratio"] - 1)) / df2["total_assets"]
df2["X2"] = (df2["shareholders_equity"] / df2["total_assets"]) #SH equity as proxy for retained earnings
df2["X3"] = (df2["ebitda"] / df2["total_assets"])
df2["X4"] = (df2["market_capitalization"] / df2["total_liabilities"])
df2["X5"] = (df2["revenue"] / df2["total_assets"])

df2["z_score"] = (
    1.2 * df2["X1"] +
    1.4 * df2["X2"] +
    3.3 * df2["X3"] +
    0.6 * df2["X4"] +
    1.0 * df2["X5"]
)

def z_score_label(z):
    if z > 2.99:
        return "Safe Zone"
    elif 1.81 < z <= 2.99:
        return "Grey Zone"
    else:
        return "Distress"
    
df2["z_score_label"] = df2["z_score"].apply(z_score_label)

df2[["company_name", "year", "z_score", "z_score_label"]].to_csv('data/altman_z_scores.csv', index=False)
print("Altman Z-Scores data saved!")

final = out.merge(df2[["company_name", "year", "z_score", "z_score_label"]], on=["company_name", "year"], how="left")
final.to_csv('data/financial_health_segmentation_with_zscores.csv', index=False)
print("Final financial health segmentation with Z-scores data saved!")




