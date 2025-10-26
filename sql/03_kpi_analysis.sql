-- 1. Profitability Analysis View (net profit margin, gross profit margin, revenue growth)
CREATE OR REPLACE VIEW v_profitability AS
SELECT 
    company_name,
    year,
    net_income,
    revenue,
    CASE 
        WHEN revenue IS NULL OR revenue = 0 THEN NULL
        ELSE (net_income / revenue) * 100
    END AS net_profit_margin_percentage,
    CASE 
        WHEN gross_profit IS NULL OR revenue IS NULL OR revenue = 0 THEN NULL
        ELSE (gross_profit / revenue) * 100
    END AS gross_profit_margin_percentage
FROM financial_statements_data;

-- 2. Liquidity Analysis View (current ratio)
CREATE OR REPLACE VIEW v_liquidity AS
SELECT 
    company_name,
    year,
    current_ratio
FROM financial_statements_data; 

-- 3. Leverage Analysis View (debt to equity ratio)
CREATE OR REPLACE VIEW v_leverage AS
SELECT 
    company_name,
    year,
    debt_equity_ratio
FROM financial_statements_data; 

-- 4. Returns Analysis View (ROE, ROA, ROI)
CREATE OR REPLACE VIEW v_returns AS
SELECT 
    company_name,
    year,
    roe,
    roa,
    roi
FROM financial_statements_data; 

--5. Cash Flow Analysis View (operating, investing, financing cash flows ratios)
CREATE OR REPLACE VIEW v_cashflow_mix AS
SELECT 
    company_name,
    year,
    cash_flow_operating,
    cash_flow_investing,
    cash_flow_financing,
    free_cash_flow_per_share,
    CASE 
        WHEN cash_flow_operating IS NULL THEN NULL
        WHEN cash_flow_investing IS NULL THEN NULL
        WHEN cash_flow_financing IS NULL THEN NULL
        ELSE (cash_flow_operating / (cash_flow_operating + cash_flow_investing + cash_flow_financing)) * 100
    END AS cfo_percentage,
    CASE 
        WHEN cash_flow_operating IS NULL THEN NULL
        WHEN cash_flow_investing IS NULL THEN NULL
        WHEN cash_flow_financing IS NULL THEN NULL
        ELSE (cash_flow_investing / (cash_flow_operating + cash_flow_investing + cash_flow_financing)) * 100
    END AS cfi_percentage,
    CASE 
        WHEN cash_flow_operating IS NULL THEN NULL
        WHEN cash_flow_investing IS NULL THEN NULL
        WHEN cash_flow_financing IS NULL THEN NULL
        ELSE (cash_flow_financing / (cash_flow_operating + cash_flow_investing + cash_flow_financing)) * 100
    END AS cff_percentage
FROM financial_statements_data; 

--6. Operational Efficiency View (EBITDA margin, total debt)
CREATE OR REPLACE VIEW v_operational_efficiency AS
SELECT 
    company_name,
    year,
    ebitda,
    revenue,
    shareholders_equity,
    debt_equity_ratio,
    CASE 
        WHEN revenue IS NULL OR revenue = 0 THEN NULL
        ELSE (ebitda / revenue) * 100
    END AS ebitda_margin_percentage,
    CASE 
        WHEN shareholders_equity IS NULL OR shareholders_equity = 0 THEN NULL
        ELSE shareholders_equity * debt_equity_ratio
    END AS total_debt
FROM financial_statements_data;

--7. Asset Turnover View (asset turnover ratio)
CREATE OR REPLACE VIEW v_asset_turnover AS
SELECT 
    company_name,
    year,
    revenue,
    shareholders_equity,
    total_debt,
    CASE
        WHEN shareholders_equity IS NULL OR total_debt IS NULL OR (shareholders_equity + total_debt) = 0 THEN NULL
        ELSE revenue / (shareholders_equity + total_debt)
    END AS asset_turnover_ratio
FROM v_operational_efficiency;

-- 8. Growth Metrics View (year-over-year growth in key metrics)
CREATE OR REPLACE VIEW v_growth_metrics AS
SELECT 
    company_name,
    year,
    revenue,
    net_income,
    eps,
    market_capitalization,
    LAG(revenue) OVER (PARTITION BY company_name ORDER BY year) AS previous_year_revenue,
    CASE 
        WHEN LAG(revenue) OVER (PARTITION BY company_name ORDER BY year) IS NULL THEN NULL
        ELSE ((revenue - LAG(revenue) OVER (PARTITION BY company_name ORDER BY year)) / LAG(revenue) OVER (PARTITION BY company_name ORDER BY year)) * 100
    END AS revenue_growth_percentage,
    LAG(net_income) OVER (PARTITION BY company_name ORDER BY year) AS previous_year_net_income,
    CASE 
        WHEN LAG(net_income) OVER (PARTITION BY company_name ORDER BY year) IS NULL THEN NULL
        ELSE ((net_income - LAG(net_income) OVER (PARTITION BY company_name ORDER BY year)) / LAG(net_income) OVER (PARTITION BY company_name ORDER BY year)) * 100
    END AS net_income_growth_percentage,
    LAG(eps) OVER (PARTITION BY company_name ORDER BY year) AS previous_year_eps,
    CASE 
        WHEN LAG(eps) OVER (PARTITION BY company_name ORDER BY year) IS NULL THEN NULL
        ELSE ((eps - LAG(eps) OVER (PARTITION BY company_name ORDER BY year)) / LAG(eps) OVER (PARTITION BY company_name ORDER BY year)) * 100
    END AS eps_growth_percentage,
    LAG(market_capitalization) OVER (PARTITION BY company_name ORDER BY year) AS previous_year_market_cap,
    CASE 
        WHEN LAG(market_capitalization) OVER (PARTITION BY company_name ORDER BY year) IS NULL THEN NULL
        ELSE ((market_capitalization - LAG(market_capitalization) OVER (PARTITION BY company_name ORDER BY year)) / LAG(market_capitalization) OVER (PARTITION BY company_name ORDER BY year)) * 100
    END AS market_cap_growth_percentage
FROM financial_statements_data;


-- 8. Year-by-year Company Rankings
CREATE OR REPLACE VIEW v_company_rankings AS
SELECT 
    year,
    company_name,
    revenue,
    net_income,
    current_ratio,
    debt_equity_ratio,
    net_profit_margin_percentage,
    DENSE_RANK() OVER (PARTITION BY year ORDER BY revenue DESC) AS revenue_rank,
    DENSE_RANK() OVER (PARTITION BY year ORDER BY net_income DESC) AS net_income_rank,
    DENSE_RANK() OVER (PARTITION BY year ORDER BY net_profit_margin_percentage DESC) AS profit_margin_rank
FROM v_profitability p
LEFT JOIN v_liquidity l USING (company_name, year)
LEFT JOIN v_leverage le USING (company_name, year);

-- 9. Export KPIs for dashboarding and visualization
CREATE OR REPLACE VIEW export_kpis AS
SELECT
    f.company_name,
    f.year,

    -- Size / core financials
    f.market_capitalization,
    f.revenue,
    f.net_income,
    f.gross_profit,
    f.ebitda,
    f.eps,
    f.shareholders_equity,

    -- Liquidity & leverage
    liq.current_ratio,
    lev.debt_equity_ratio,

    -- Returns
    ret.roe,
    ret.roa,
    ret.roi,

    -- Margins
    prof.net_profit_margin_percentage,
    prof.gross_profit_margin_percentage,
    op.ebitda_margin_percentage,

    -- Capital structure / assets
    op.total_debt,
    at.asset_turnover_ratio,

    -- Cash flow & FCF
    cf.cash_flow_operating,
    cf.cash_flow_investing,
    cf.cash_flow_financing,
    cf.free_cash_flow_per_share,
    cf.cfo_percentage,
    cf.cfi_percentage,
    cf.cff_percentage,

    -- Growth metrics
    g.previous_year_revenue,
    g.revenue_growth_percentage,
    g.previous_year_net_income,
    g.net_income_growth_percentage,
    g.previous_year_eps,
    g.eps_growth_percentage,
    g.previous_year_market_cap,
    g.market_cap_growth_percentage

FROM financial_statements_data f
LEFT JOIN v_profitability prof USING (company_name, year)
LEFT JOIN v_liquidity liq USING (company_name, year)
LEFT JOIN v_leverage lev USING (company_name, year)
LEFT JOIN v_returns ret USING (company_name, year)
LEFT JOIN v_operational_efficiency op USING (company_name, year)
LEFT JOIN v_asset_turnover ast USING (company_name, year)
LEFT JOIN v_cashflow_mix cf USING (company_name, year)
LEFT JOIN v_growth_metrics g USING (company_name, year)
ORDER BY f.company_name, f.year;

-- Sample query to verify views
SELECT * FROM v_profitability;
SELECT * FROM v_liquidity;
SELECT * FROM v_leverage;
SELECT * FROM v_returns;
SELECT * FROM v_cashflow_mix;
SELECT * FROM v_company_rankings; 
SELECT * FROM v_operational_efficiency;
SELECT * FROM v_asset_turnover; 

-- Example analysis queries 
---1. Top 10 companies by revenue in 2022
SELECT * FROM v_company_rankings
WHERE year = 2022
ORDER BY revenue_rank;
---2. Companies with high liquidity (current ratio > 2) in 2022
SELECT * FROM v_liquidity
WHERE year = 2022 AND current_ratio > 2;
---3. Companies with low leverage (debt to equity ratio < 1) in 2022
SELECT * FROM v_leverage
WHERE year = 2022 AND debt_equity_ratio < 1;
---4. Companies with high ROE (>15%) in 2022
SELECT * FROM v_returns
WHERE year = 2022 AND roe > 15;  
---5. Companies with strong cash flow from operations (>50% of total cash flow) in 2022
SELECT * FROM v_cashflow_mix
WHERE year = 2022 AND cfo_percentage > 50;        

--Note: Further analysis (segmentation and health scoring) is done in Python (financial_health_segmentation.py) using the export_kpis view as the data source.
--Visualizations and dashboards can be created in Tableau with financial health segmentation and altman z-score dataset (in data folder).


