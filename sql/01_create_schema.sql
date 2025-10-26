CREATE DATABASE financial_health;

USE financial_health; 

CREATE TABLE financial_statements_data (
    year INT,
    company VARCHAR(100),
    category VARCHAR(100),
    market_capitalization DECIMAL(10, 5),
    revenue DECIMAL(10, 5),
    gross_profit DECIMAL(10, 5),
    net_income DECIMAL(15, 5),
    eps DECIMAL(10, 5),
    ebitda DECIMAL(15, 5), 
    shareholders_equity DECIMAL(15, 5), 
    cash_flow_operating DECIMAL(15, 5),
    cash_flow_investing DECIMAL(15, 5),
    cash_flow_financing DECIMAL(15, 5),
    current_ratio DECIMAL(10,5),
    debt_equity_ratio DECIMAL(10,5),
    roe DECIMAL(10,5),
    roa DECIMAL(10,5),
    roi DECIMAL(10,5),
    net_profit_margin DECIMAL(10,5),
    free_cash_flow_per_share DECIMAL(10,5),
    return_on_tangible_equity DECIMAL(10,5),
    num_employees INT,
    inflation_rate DECIMAL(10,5)
);

-- Sample query to verify table creation
SELECT * FROM financial_statements_data;

-- Load data into the table (run python script separately to load data)

