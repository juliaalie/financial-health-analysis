-- Rename columns for clarity
ALTER TABLE financial_statements_data  
RENAME COLUMN company TO company_name,
RENAME COLUMN market_capin_b_usd TO market_capitalization,
RENAME COLUMN earning_per_share TO eps,
RENAME COLUMN share_holder_equity TO shareholders_equity,
RENAME COLUMN cash_flow_from_operating TO cash_flow_operating,
RENAME COLUMN cash_flow_from_investing TO cash_flow_investing,
RENAME COLUMN cash_flow_from_financial_activities TO cash_flow_financing,
RENAME COLUMN debtequity_ratio TO debt_equity_ratio,
RENAME COLUMN number_of_employees TO num_employees,
RENAME COLUMN inflation_ratein_us TO inflation_rate;

-- 1. Remove leading and trailing spaces from company_name and category AND Replace empty strings or 'N/A' in category with NULL
UPDATE financial_statements_data
SET company_name = TRIM(company_name),
    category = NULLIF(NULLIF(TRIM(category), ''), 'N/A');

-- 2. Clean and convert numeric fields, removing any non-numeric characters and handling missing or malformed data
-- Creating a new cleaned table to store the cleaned data
CREATE TABLE cleaned_financial_statements_data AS
SELECT 
    CASE 
        WHEN year IS NULL OR UPPER(TRIM(year)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(TRIM(year) AS SIGNED)
    END AS year,

    TRIM(company_name) AS company_name,
    CASE 
        WHEN category IS NULL OR UPPER(TRIM(category)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE TRIM(category)
    END AS category,

    CASE WHEN market_capitalization IS NULL OR UPPER(TRIM(market_capitalization)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(market_capitalization),'$',''),',',''),')',''),'(','-') AS DECIMAL(18,2))
    END AS market_capitalization,

    CASE WHEN revenue IS NULL OR UPPER(TRIM(revenue)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(revenue),'$',''),',',''),')',''),'(','-') AS DECIMAL(18,2))
    END AS revenue,

    CASE WHEN gross_profit IS NULL OR UPPER(TRIM(gross_profit)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(gross_profit),'$',''),',',''),')',''),'(','-') AS DECIMAL(18,2))
    END AS gross_profit,

    CASE WHEN net_income IS NULL OR UPPER(TRIM(net_income)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(net_income),'$',''),',',''),')',''),'(','-') AS DECIMAL(18,2))
    END AS net_income,

    CASE WHEN eps IS NULL OR UPPER(TRIM(eps)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(eps),'$',''),',',''),')',''),'(','-') AS DECIMAL(18,4))
    END AS eps,

    CASE WHEN ebitda IS NULL OR UPPER(TRIM(ebitda)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(ebitda),'$',''),',',''),')',''),'(','-') AS DECIMAL(18,2))
    END AS ebitda,

    CASE WHEN shareholders_equity IS NULL OR UPPER(TRIM(shareholders_equity)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(shareholders_equity),'$',''),',',''),')',''),'(','-') AS DECIMAL(18,2))
    END AS shareholders_equity,

    CASE WHEN cash_flow_operating IS NULL OR UPPER(TRIM(cash_flow_operating)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(cash_flow_operating),'$',''),',',''),')',''),'(','-') AS DECIMAL(18,2))
    END AS cash_flow_operating,

    CASE WHEN cash_flow_investing IS NULL OR UPPER(TRIM(cash_flow_investing)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(cash_flow_investing),'$',''),',',''),')',''),'(','-') AS DECIMAL(18,2))
    END AS cash_flow_investing,

    CASE WHEN cash_flow_financing IS NULL OR UPPER(TRIM(cash_flow_financing)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(cash_flow_financing),'$',''),',',''),')',''),'(','-') AS DECIMAL(18,2))
    END AS cash_flow_financing,

    CASE WHEN current_ratio IS NULL OR UPPER(TRIM(current_ratio)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(TRIM(current_ratio),',','') AS DECIMAL(10,4))
    END AS current_ratio,

    CASE WHEN debt_equity_ratio IS NULL OR UPPER(TRIM(debt_equity_ratio)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(TRIM(debt_equity_ratio),',','') AS DECIMAL(10,4))
    END AS debt_equity_ratio,

    CASE WHEN roe IS NULL OR UPPER(TRIM(roe)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(TRIM(roe),',','') AS DECIMAL(10,4))
    END AS roe,

    CASE WHEN roa IS NULL OR UPPER(TRIM(roa)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(TRIM(roa),',','') AS DECIMAL(10,4))
    END AS roa,

    CASE WHEN roi IS NULL OR UPPER(TRIM(roi)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(TRIM(roi),',','') AS DECIMAL(10,4))
    END AS roi,

    CASE WHEN net_profit_margin IS NULL OR UPPER(TRIM(net_profit_margin)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(TRIM(net_profit_margin),',','') AS DECIMAL(10,4))
    END AS net_profit_margin,

    CASE WHEN free_cash_flow_per_share IS NULL OR UPPER(TRIM(free_cash_flow_per_share)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(TRIM(free_cash_flow_per_share),',','') AS DECIMAL(18,4))
    END AS free_cash_flow_per_share,

    CASE WHEN return_on_tangible_equity IS NULL OR UPPER(TRIM(return_on_tangible_equity)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(TRIM(return_on_tangible_equity),',','') AS DECIMAL(10,4))
    END AS return_on_tangible_equity,

    CASE WHEN num_employees IS NULL OR UPPER(TRIM(num_employees)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(TRIM(num_employees),',','') AS SIGNED)
    END AS num_employees,

    CASE WHEN inflation_rate IS NULL OR UPPER(TRIM(inflation_rate)) IN ('', 'N/A', 'NA', 'NULL', '-') THEN NULL
        ELSE CAST(REPLACE(TRIM(inflation_rate),',','') AS DECIMAL(10,4))
    END AS inflation_rate
FROM financial_statements_data;

DROP TABLE financial_statements_data;
ALTER TABLE cleaned_financial_statements_data RENAME TO financial_statements_data;

-- 3. Handle invalid or out-of-range values by setting them to NULL (sanity checks)
UPDATE current_ratio SET current_ratio = NULL WHERE current_ratio <= 0;
UPDATE debt_equity_ratio SET debt_equity_ratio = NULL WHERE debt_equity_ratio < 0;

-- 4. Create indexes to optimize query performance
ALTER TABLE financial_statements_data 
MODIFY COLUMN company_name VARCHAR(100),
MODIFY COLUMN category VARCHAR(100);

CREATE INDEX fs_company_year ON financial_statements_data(company_name, year);
CREATE INDEX fs_year ON financial_statements_data(year);
CREATE INDEX fs_category ON financial_statements_data(category);
CREATE INDEX fs_company ON financial_statements_data(company_name);


