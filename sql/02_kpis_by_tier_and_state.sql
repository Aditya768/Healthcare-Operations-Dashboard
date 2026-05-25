-- ============================================================
-- QUERY 2: KPIs by Performance Tier
-- Purpose: Compare all key metrics across hospital tiers
-- Concepts: GROUP BY, window function for % of total
-- ============================================================

SELECT
    performance_tier,
    COUNT(*)                                                       AS hospital_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)             AS pct_of_total,
    ROUND(AVG(composite_satisfaction_score), 2)                    AS avg_satisfaction,
    ROUND(AVG(avg_er_wait_minutes), 1)                             AS avg_er_wait,
    ROUND(AVG(READM_30_HOSP), 2)                                   AS avg_readmission,
    ROUND(AVG(hospital_overall_rating), 2)                         AS avg_star_rating,
    ROUND(AVG(bed_count), 0)                                       AS avg_bed_count
FROM hospitals
WHERE performance_tier IS NOT NULL
GROUP BY performance_tier
ORDER BY avg_satisfaction DESC;


-- ============================================================
-- QUERY 3: State-Level Performance Scorecard
-- Purpose: Rank all 51 states on key healthcare metrics
-- Concepts: GROUP BY multi-column, ORDER BY, ROUND
-- ============================================================

SELECT
    state,
    COUNT(*)                                                        AS hospitals,
    ROUND(AVG(composite_satisfaction_score), 2)                     AS avg_satisfaction,
    ROUND(AVG(avg_er_wait_minutes), 1)                              AS avg_er_wait_min,
    ROUND(AVG(READM_30_HOSP), 2)                                    AS avg_readmission_rate,
    ROUND(AVG(MORT_30_AMI), 2)                                      AS avg_ami_mortality,
    ROUND(100.0 * SUM(high_readmission_flag) / COUNT(*), 1)         AS pct_high_readmission,
    ROUND(AVG(median_income) / 1000.0, 1)                           AS median_income_k,
    ROUND(AVG(poverty_rate), 1)                                     AS poverty_rate_pct
FROM hospitals
WHERE state IS NOT NULL
GROUP BY state
ORDER BY avg_satisfaction DESC;
