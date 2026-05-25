-- ============================================================
-- QUERY 7: Peer Group Benchmarking
-- Purpose: Compare each hospital to its type+state peers
-- Concepts: Multi-step CTE, LEFT JOIN, HAVING, CASE WHEN
-- ============================================================

WITH peer_group_stats AS (
    -- Step 1: Calculate peer group averages
    -- (same hospital type in same state, min 3 hospitals)
    SELECT
        hospital_type,
        state,
        COUNT(*)                                            AS peer_count,
        ROUND(AVG(composite_satisfaction_score), 2)         AS peer_avg_satisfaction,
        ROUND(AVG(avg_er_wait_minutes), 1)                  AS peer_avg_er_wait,
        ROUND(AVG(READM_30_HOSP), 2)                        AS peer_avg_readmission
    FROM hospitals
    WHERE hospital_type IS NOT NULL
        AND state IS NOT NULL
    GROUP BY hospital_type, state
    HAVING COUNT(*) >= 3
),
hospital_vs_peers AS (
    -- Step 2: Join each hospital with its peer benchmark
    SELECT
        h.facility_id,
        h.facility_name,
        h.state,
        h.hospital_type,
        ROUND(h.composite_satisfaction_score, 2)            AS hospital_satisfaction,
        p.peer_avg_satisfaction,
        ROUND(h.composite_satisfaction_score
              - p.peer_avg_satisfaction, 2)                 AS vs_peer_satisfaction,
        ROUND(h.avg_er_wait_minutes, 1)                     AS hospital_er_wait,
        p.peer_avg_er_wait,
        ROUND(h.avg_er_wait_minutes
              - p.peer_avg_er_wait, 1)                      AS vs_peer_er_wait,
        p.peer_count
    FROM hospitals h
    LEFT JOIN peer_group_stats p
        ON h.hospital_type = p.hospital_type
        AND h.state = p.state
)
-- Step 3: Classify as outperformer / underperformer
SELECT
    *,
    CASE
        WHEN vs_peer_satisfaction > 3  THEN 'Strong Outperformer'
        WHEN vs_peer_satisfaction > 0  THEN 'Slight Outperformer'
        WHEN vs_peer_satisfaction > -3 THEN 'Slight Underperformer'
        ELSE 'Significant Underperformer'
    END                                                     AS peer_benchmark_status
FROM hospital_vs_peers
ORDER BY vs_peer_satisfaction DESC;


-- ============================================================
-- QUERY 8: Multi-Dimensional Risk Scoring
-- Purpose: Flag hospitals at risk across 5 dimensions
-- Concepts: Nested CTEs, CASE WHEN scoring, ORDER BY CASE
-- ============================================================

WITH risk_flags AS (
    SELECT
        facility_id,
        facility_name,
        state,
        hospital_type,
        performance_tier,
        ROUND(composite_satisfaction_score, 2)              AS satisfaction,
        ROUND(avg_er_wait_minutes, 1)                       AS er_wait,
        ROUND(READM_30_HOSP, 2)                             AS readmission_rate,
        ROUND(MORT_30_AMI, 2)                               AS ami_mortality,
        -- Individual risk flags (1 = at risk)
        CASE WHEN er_inefficiency_flag = 1
             THEN 1 ELSE 0 END                              AS flag_er,
        CASE WHEN high_readmission_flag = 1
             THEN 1 ELSE 0 END                              AS flag_readmission,
        CASE WHEN composite_satisfaction_score < 65
             THEN 1 ELSE 0 END                              AS flag_low_satisfaction,
        CASE WHEN MORT_30_AMI > 15
             THEN 1 ELSE 0 END                              AS flag_high_mortality,
        CASE WHEN hospital_overall_rating <= 2
             THEN 1 ELSE 0 END                              AS flag_low_rating
    FROM hospitals
),
risk_scored AS (
    SELECT
        *,
        (flag_er + flag_readmission + flag_low_satisfaction
         + flag_high_mortality + flag_low_rating)           AS total_risk_flags,
        CASE
            WHEN (flag_er + flag_readmission + flag_low_satisfaction
                  + flag_high_mortality + flag_low_rating) >= 4
                THEN 'CRITICAL'
            WHEN (flag_er + flag_readmission + flag_low_satisfaction
                  + flag_high_mortality + flag_low_rating) = 3
                THEN 'HIGH'
            WHEN (flag_er + flag_readmission + flag_low_satisfaction
                  + flag_high_mortality + flag_low_rating) = 2
                THEN 'MEDIUM'
            ELSE 'LOW'
        END                                                 AS risk_level
    FROM risk_flags
)
SELECT
    risk_level,
    COUNT(*)                                                AS hospital_count,
    ROUND(AVG(satisfaction), 2)                             AS avg_satisfaction,
    ROUND(AVG(er_wait), 1)                                  AS avg_er_wait,
    ROUND(AVG(readmission_rate), 2)                         AS avg_readmission
FROM risk_scored
GROUP BY risk_level
ORDER BY
    CASE risk_level
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH'     THEN 2
        WHEN 'MEDIUM'   THEN 3
        ELSE 4
    END;
