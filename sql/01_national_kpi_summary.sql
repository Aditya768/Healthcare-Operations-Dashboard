-- ============================================================
-- Healthcare Operations Analytics — SQL Queries
-- Author: Aditya | M.S. Applied Data Science | Syracuse 2026
-- Database: DuckDB | Data: CMS Hospital Compare 2024
-- ============================================================

-- ============================================================
-- QUERY 1: National KPI Dashboard Summary
-- Purpose: Single-row executive summary of all key metrics
-- Concepts: Aggregations, COUNT DISTINCT, ROUND, division
-- ============================================================

SELECT
    COUNT(DISTINCT facility_id)                                    AS total_hospitals,
    COUNT(DISTINCT state)                                          AS states_covered,
    ROUND(AVG(composite_satisfaction_score), 2)                    AS avg_satisfaction_pct,
    ROUND(AVG(avg_er_wait_minutes), 1)                             AS avg_er_wait_minutes,
    ROUND(AVG(READM_30_HOSP), 2)                                   AS avg_readmission_rate,
    ROUND(AVG(MORT_30_AMI), 2)                                     AS avg_ami_mortality,
    SUM(high_readmission_flag)                                     AS high_readmission_hospitals,
    ROUND(100.0 * SUM(high_readmission_flag) / COUNT(*), 1)        AS pct_high_readmission,
    SUM(er_inefficiency_flag)                                      AS er_inefficient_hospitals,
    ROUND(100.0 * SUM(er_inefficiency_flag) / COUNT(*), 1)         AS pct_er_inefficient
FROM hospitals;
