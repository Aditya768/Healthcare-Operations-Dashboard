-- ============================================================
-- QUERY 9: Socioeconomic Impact Analysis
-- Purpose: Does area income explain satisfaction differences?
-- Result: Confirms null result — income weakly predicts
-- Concepts: CASE WHEN bands, CTE, window AVG for comparison
-- ============================================================

WITH income_bands AS (
    SELECT
        CASE
            WHEN median_income < 55000 THEN '1. Low Income (<$55K)'
            WHEN median_income < 65000 THEN '2. Lower-Mid ($55K-$65K)'
            WHEN median_income < 75000 THEN '3. Upper-Mid ($65K-$75K)'
            WHEN median_income < 85000 THEN '4. High ($75K-$85K)'
            ELSE '5. Very High (>$85K)'
        END                                                     AS income_band,
        composite_satisfaction_score,
        avg_er_wait_minutes,
        READM_30_HOSP,
        poverty_rate,
        pct_uninsured,
        bed_count
    FROM hospitals
    WHERE median_income IS NOT NULL
        AND composite_satisfaction_score IS NOT NULL
)
SELECT
    income_band,
    COUNT(*)                                                    AS hospitals,
    ROUND(AVG(composite_satisfaction_score), 2)                 AS avg_satisfaction,
    ROUND(AVG(avg_er_wait_minutes), 1)                          AS avg_er_wait,
    ROUND(AVG(READM_30_HOSP), 2)                                AS avg_readmission,
    ROUND(AVG(poverty_rate), 1)                                 AS avg_poverty_rate,
    ROUND(AVG(pct_uninsured), 1)                                AS avg_pct_uninsured,
    ROUND(AVG(bed_count), 0)                                    AS avg_bed_count,
    -- Satisfaction difference vs overall national average
    ROUND(
        AVG(composite_satisfaction_score)
        - AVG(AVG(composite_satisfaction_score)) OVER (),
    2)                                                          AS vs_national_avg
FROM income_bands
GROUP BY income_band
ORDER BY income_band;


-- ============================================================
-- QUERY 10: ER Wait Time Cohort Analysis
-- Purpose: Quantify how satisfaction drops as ER wait rises
-- Key Finding: Each 50-min ER increase = ~1.5% satisfaction drop
-- Concepts: CASE WHEN cohorts, FIRST_VALUE window, STDDEV
-- ============================================================

WITH er_cohorts AS (
    SELECT
        CASE
            WHEN avg_er_wait_minutes < 100  THEN '1. Fast (<100 min)'
            WHEN avg_er_wait_minutes < 150  THEN '2. Efficient (100-150)'
            WHEN avg_er_wait_minutes < 200  THEN '3. Average (150-200)'
            WHEN avg_er_wait_minutes < 250  THEN '4. Slow (200-250)'
            WHEN avg_er_wait_minutes < 300  THEN '5. Very Slow (250-300)'
            ELSE '6. Critical (>300 min)'
        END                                                     AS er_cohort,
        composite_satisfaction_score,
        READM_30_HOSP,
        hospital_overall_rating,
        state
    FROM hospitals
    WHERE avg_er_wait_minutes IS NOT NULL
        AND composite_satisfaction_score IS NOT NULL
)
SELECT
    er_cohort,
    COUNT(*)                                                    AS hospitals,
    ROUND(AVG(composite_satisfaction_score), 2)                 AS avg_satisfaction,
    ROUND(MIN(composite_satisfaction_score), 2)                 AS min_satisfaction,
    ROUND(MAX(composite_satisfaction_score), 2)                 AS max_satisfaction,
    ROUND(STDDEV(composite_satisfaction_score), 2)              AS stddev_satisfaction,
    -- Satisfaction drop vs fastest cohort
    ROUND(
        AVG(composite_satisfaction_score)
        - FIRST_VALUE(AVG(composite_satisfaction_score))
          OVER (ORDER BY er_cohort),
    2)                                                          AS vs_fastest_cohort
FROM er_cohorts
GROUP BY er_cohort
ORDER BY er_cohort;


-- ============================================================
-- QUERY 11: Hospital Bed Count Impact Analysis
-- Purpose: Quantify the "scale penalty" — larger = lower sat
-- Key Finding: 500+ bed hospitals score 8-10pts lower
-- Concepts: CASE WHEN, GROUP BY, window comparison
-- ============================================================

WITH bed_cohorts AS (
    SELECT
        CASE
            WHEN bed_count < 50   THEN '1. Small (<50 beds)'
            WHEN bed_count < 150  THEN '2. Medium (50-150)'
            WHEN bed_count < 300  THEN '3. Large (150-300)'
            WHEN bed_count < 500  THEN '4. Very Large (300-500)'
            ELSE '5. Major (500+ beds)'
        END                                                     AS bed_category,
        composite_satisfaction_score,
        avg_er_wait_minutes,
        hospital_overall_rating,
        READM_30_HOSP
    FROM hospitals
    WHERE bed_count IS NOT NULL
        AND composite_satisfaction_score IS NOT NULL
)
SELECT
    bed_category,
    COUNT(*)                                                    AS hospitals,
    ROUND(AVG(composite_satisfaction_score), 2)                 AS avg_satisfaction,
    ROUND(AVG(avg_er_wait_minutes), 1)                          AS avg_er_wait,
    ROUND(AVG(hospital_overall_rating), 2)                      AS avg_star_rating,
    ROUND(AVG(READM_30_HOSP), 2)                                AS avg_readmission,
    -- Satisfaction vs smallest hospitals
    ROUND(
        AVG(composite_satisfaction_score)
        - FIRST_VALUE(AVG(composite_satisfaction_score))
          OVER (ORDER BY bed_category),
    2)                                                          AS vs_small_hospitals
FROM bed_cohorts
GROUP BY bed_category
ORDER BY bed_category;


-- ============================================================
-- QUERY 12: Recommendation Priority Analysis
-- Purpose: What are the most common improvement actions?
-- Concepts: GROUP BY, COUNT, PARTITION BY for % within group
-- ============================================================

SELECT
    priority,
    feature,
    COUNT(*)                                                    AS recommendation_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY priority),
    1)                                                          AS pct_within_priority,
    recommendation
FROM recommendations
WHERE rank = 1
GROUP BY priority, feature, recommendation
ORDER BY priority,
         recommendation_count DESC;
