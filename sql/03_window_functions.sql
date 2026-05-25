-- ============================================================
-- QUERY 4: Hospital Rankings Within State
-- Purpose: Rank hospitals within their state by satisfaction
-- Concepts: RANK() OVER (PARTITION BY), COUNT() OVER,
--           QUALIFY clause, window percentile
-- ============================================================

SELECT
    facility_id,
    facility_name,
    state,
    hospital_type,
    ROUND(composite_satisfaction_score, 2)                          AS satisfaction_score,
    ROUND(avg_er_wait_minutes, 1)                                   AS er_wait_min,
    performance_tier,
    RANK() OVER (
        PARTITION BY state
        ORDER BY composite_satisfaction_score DESC
    )                                                               AS state_rank,
    COUNT(*) OVER (PARTITION BY state)                              AS hospitals_in_state,
    ROUND(
        100.0 * RANK() OVER (
            PARTITION BY state
            ORDER BY composite_satisfaction_score DESC
        ) / COUNT(*) OVER (PARTITION BY state),
    1)                                                              AS state_percentile
FROM hospitals
WHERE composite_satisfaction_score IS NOT NULL
QUALIFY RANK() OVER (
    PARTITION BY state
    ORDER BY composite_satisfaction_score DESC
) <= 3
ORDER BY state, state_rank;


-- ============================================================
-- QUERY 5: Satisfaction Quartile Bands
-- Purpose: Divide hospitals into quartiles and profile each
-- Concepts: NTILE() window function, CTE, CASE WHEN
-- ============================================================

WITH percentile_bands AS (
    SELECT
        facility_id,
        facility_name,
        state,
        composite_satisfaction_score,
        avg_er_wait_minutes,
        NTILE(4) OVER (
            ORDER BY composite_satisfaction_score
        )                                                           AS satisfaction_quartile
    FROM hospitals
    WHERE composite_satisfaction_score IS NOT NULL
)
SELECT
    satisfaction_quartile,
    CASE satisfaction_quartile
        WHEN 1 THEN 'Bottom 25% (Struggling)'
        WHEN 2 THEN 'Q2 (Below Average)'
        WHEN 3 THEN 'Q3 (Above Average)'
        WHEN 4 THEN 'Top 25% (Excellent)'
    END                                                             AS quartile_label,
    COUNT(*)                                                        AS hospitals,
    ROUND(MIN(composite_satisfaction_score), 2)                     AS min_score,
    ROUND(MAX(composite_satisfaction_score), 2)                     AS max_score,
    ROUND(AVG(composite_satisfaction_score), 2)                     AS avg_score,
    ROUND(AVG(avg_er_wait_minutes), 1)                              AS avg_er_wait
FROM percentile_bands
GROUP BY satisfaction_quartile
ORDER BY satisfaction_quartile;


-- ============================================================
-- QUERY 6: Time Series — Moving Average & QoQ Change
-- Purpose: Analyze healthcare quality trends over 12 quarters
-- Concepts: LAG(), FIRST_VALUE(), rolling AVG() OVER ROWS
-- ============================================================

SELECT
    Quarter,
    ROUND("Composite Satisfaction (%)", 2)                          AS satisfaction,
    ROUND("Avg ER Wait (minutes)", 1)                               AS er_wait,
    ROUND("30-Day Readmission Rate (%)", 2)                         AS readmission,
    -- 3-quarter rolling average
    ROUND(AVG("Composite Satisfaction (%)") OVER (
        ORDER BY Quarter
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                                                           AS satisfaction_3q_avg,
    -- Quarter-over-quarter change
    ROUND(
        "Composite Satisfaction (%)"
        - LAG("Composite Satisfaction (%)") OVER (ORDER BY Quarter),
    2)                                                              AS satisfaction_qoq_change,
    -- Cumulative ER wait increase from baseline (Q1 2022)
    ROUND(
        "Avg ER Wait (minutes)"
        - FIRST_VALUE("Avg ER Wait (minutes)") OVER (ORDER BY Quarter),
    1)                                                              AS er_wait_change_from_baseline
FROM time_series
ORDER BY Quarter;
