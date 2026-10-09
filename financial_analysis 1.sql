
CREATE TABLE company_financials (
    company_id INT,
    company_name VARCHAR(100),
    industry VARCHAR(100),
    region VARCHAR(100),
    year INT,
    revenue NUMERIC,
    profit_margin NUMERIC,
    market_cap NUMERIC,
    growth_rate NUMERIC,
    esg_overall NUMERIC,
    esg_environmental NUMERIC,
    esg_social NUMERIC,
    esg_governance NUMERIC,
    carbon_emissions NUMERIC,
    water_usage NUMERIC,
    energy_consumption NUMERIC
);




SELECT * FROM company_financials
LIMIT 10;





SELECT count(*)
FROM company_financials;




SELECT
    COUNT(*) - COUNT(company_id) AS company_id_nulls,
    COUNT(*) - COUNT(company_name) AS company_name_nulls,
    COUNT(*) - COUNT(industry) AS industry_nulls,
    COUNT(*) - COUNT(region) AS region_nulls,
    COUNT(*) - COUNT(year) AS year_nulls,
    COUNT(*) - COUNT(revenue) AS revenue_nulls,
    COUNT(*) - COUNT(profit_margin) AS profit_margin_nulls,
    COUNT(*) - COUNT(market_cap) AS market_cap_nulls,
    COUNT(*) - COUNT(growth_rate) AS growth_rate_nulls,
    COUNT(*) - COUNT(esg_overall) AS esg_overall_nulls,
    COUNT(*) - COUNT(esg_environmental) AS esg_environmental_nulls,
    COUNT(*) - COUNT(esg_social) AS esg_social_nulls,
    COUNT(*) - COUNT(esg_governance) AS esg_governance_nulls,
    COUNT(*) - COUNT(carbon_emissions) AS carbon_emissions_nulls,
    COUNT(*) - COUNT(water_usage) AS water_usage_nulls,
    COUNT(*) - COUNT(energy_consumption) AS energy_consumption_nulls
FROM company_financials;

SELECT year, growth_rate
FROM company_financials
WHERE growth_rate IS NULL;

SELECT
    company_id,
    company_name,
    industry,
    region,
    year,
    revenue,
    profit_margin,
    market_cap,
    growth_rate,
    esg_overall,
    esg_environmental,
    esg_social,
    esg_governance,
    carbon_emissions,
    water_usage,
    energy_consumption,
    COUNT(*) AS duplicate_count
FROM company_financials
GROUP BY
    company_id,
    company_name,
    industry,
    region,
    year,
    revenue,
    profit_margin,
    market_cap,
    growth_rate,
    esg_overall,
    esg_environmental,
    esg_social,
    esg_governance,
    carbon_emissions,
    water_usage,
    energy_consumption
HAVING COUNT(*) > 1;


SELECT company_id, year,
       COUNT(*) AS duplicate
FROM company_financials
GROUP BY company_id, year
HAVING COUNT(*) > 1;

SELECT revenue,
       market_cap,
       esg_overall,
       carbon_emissions,
       water_usage,
       energy_consumption
FROM company_financials
WHERE revenue = 0
   OR market_cap = 0
   OR esg_overall = 0
   OR carbon_emissions = 0
   OR water_usage = 0
   OR energy_consumption = 0;

   SELECT revenue,
       market_cap
FROM company_financials
WHERE revenue < 0
   OR market_cap < 0;

 SELECT esg_overall
FROM company_financials
WHERE esg_overall < 0
   OR esg_overall > 100;

SELECT SUM(REVENUE)
FROM company_financials;


SELECT avg(profit_margin)
FROM company_financials;

SELECT sum(market_cap)
FROM company_financials;

SELECT AVG (growth_rate)
FROM company_financials;


WITH industry_summary AS (
    SELECT industry,
           SUM(revenue) AS total_revenue,
		   AVG (esg_overall) AS avg_esg_score
    FROM company_financials
    GROUP BY industry
)
SELECT *
FROM industry_summary
ORDER BY total_revenue DESC;


SELECT *
FROM (
    SELECT region,
           AVG(esg_overall) AS avg_esg_score,
           SUM(market_cap) AS total_market_cap
    FROM company_financials
    GROUP BY region
) AS region_summary
ORDER BY total_market_cap DESC;



SELECT *
FROM (
    SELECT year,
           AVG(esg_overall) AS avg_esg_score,
           SUM(revenue) AS total_revenue
    FROM company_financials
    GROUP BY year
) AS year_summary
ORDER BY year;





SELECT industry,
       region,
       AVG(carbon_emissions) AS avg_carbon_emissions,
       AVG(profit_margin) AS avg_profit_margin,
       CASE
           WHEN AVG(carbon_emissions) > 
                (SELECT AVG(carbon_emissions) FROM company_financials)
                AND AVG(profit_margin) < 10
           THEN 'High Emission - Low Profit'
           ELSE 'Normal'
       END AS risk_category
FROM company_financials
GROUP BY industry, region
ORDER BY avg_carbon_emissions DESC;


SELECT
    CASE
        WHEN esg_overall > 75 THEN 'High ESG'
        WHEN esg_overall < 40 THEN 'Low ESG'
    END AS esg_group,
    AVG(profit_margin) AS avg_profit_margin,
    AVG(market_cap) AS avg_market_cap
FROM company_financials
WHERE esg_overall > 75
   OR esg_overall < 40
GROUP BY esg_group;



SELECT company_name,
       AVG(esg_overall) AS avg_esg_score
FROM company_financials
GROUP BY company_name
ORDER BY avg_esg_score DESC
LIMIT 10;

SELECT company_name,
       AVG(carbon_emissions) AS avg_carbon_emissions
FROM company_financials
GROUP BY company_name
ORDER BY avg_carbon_emissions DESC
LIMIT 10;



WITH yearly_esg AS (
    SELECT
        company_name,
        year,
        esg_environmental,
        LAG(esg_environmental) OVER (
            PARTITION BY company_name
            ORDER BY year
        ) AS previous_esg
    FROM company_financials
),

improvement_check AS (
    SELECT
        company_name,
        COUNT(*) FILTER (
            WHERE previous_esg IS NOT NULL
        ) AS year_comparisons,
        COUNT(*) FILTER (
            WHERE esg_environmental > previous_esg
        ) AS improved_years
    FROM yearly_esg
    GROUP BY company_name
)

SELECT
    company_name,
    year_comparisons,
    improved_years
FROM improvement_check
WHERE year_comparisons = 10
  AND improved_years = 10
ORDER BY company_name;

WITH yearly_data AS (
    SELECT
        company_name,
        year,
        revenue,
        esg_overall,

        LAG(revenue) OVER (
            PARTITION BY company_name
            ORDER BY year
        ) AS previous_revenue,

        LAG(esg_overall) OVER (
            PARTITION BY company_name
            ORDER BY year
        ) AS previous_esg

    FROM company_financials
)

SELECT
    company_name,
    year,
    revenue,
    previous_revenue,

    ROUND(
        ((revenue - previous_revenue) / previous_revenue) * 100,
        2
    ) AS revenue_growth_pct,

    esg_overall,
    previous_esg,

    ROUND(
        esg_overall - previous_esg,
        2
    ) AS esg_change

FROM yearly_data
WHERE previous_revenue IS NOT NULL
  AND previous_esg IS NOT NULL
ORDER BY company_name, year;



SELECT 
    SUM(market_cap) AS Total_Market_Cap_2025
FROM company_financials
WHERE year = 2025;


-- 2. Weighted Average Profit Margin
SELECT
    ROUND(SUM(revenue * profit_margin) / SUM(revenue), 2) AS weighted_profit_margin
FROM company_financials;

-- 3. ESG vs Profit Margin Correlation
SELECT
    ROUND(CORR(esg_overall, profit_margin)::numeric, 4) AS esg_profit_correlation
FROM company_financials;

-- 4. Top 5 Companies by Market Cap (2025)
SELECT
    company_name,
    industry,
    market_cap,
    esg_overall
FROM company_financials
WHERE year = 2025
ORDER BY market_cap DESC
LIMIT 5;

-- 5. Top 5 Companies by Average Carbon Emissions
SELECT
    company_name,     
    industry,
    ROUND(AVG(carbon_emissions), 2) AS avg_carbon_emissions
FROM company_financials
GROUP BY company_name, industry
ORDER BY avg_carbon_emissions DESC
LIMIT 5;











