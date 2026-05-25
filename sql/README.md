# 🗄️ SQL Analytics — Healthcare Operations Dashboard

Standalone SQL queries written in **ANSI SQL** compatible with DuckDB, PostgreSQL, BigQuery, and Snowflake.

## Files

| File | Queries | Concepts |
|------|---------|----------|
| `01_national_kpi_summary.sql` | National KPI dashboard | Aggregations, COUNT DISTINCT |
| `02_kpis_by_tier_and_state.sql` | Tier + state scorecards | GROUP BY, multi-metric aggregation |
| `03_window_functions.sql` | Rankings, quartiles, time series | RANK(), NTILE(), LAG(), FIRST_VALUE(), rolling AVG |
| `04_ctes_and_joins.sql` | Peer benchmarking, risk scoring | Multi-step CTEs, LEFT JOIN, nested logic |
| `05_business_queries.sql` | Cohort analysis, recommendations | CASE WHEN bands, PARTITION BY, STDDEV |

## How to Run

### Option 1 — DuckDB (no install needed in Colab)
```python
import duckdb
con = duckdb.connect()
con.execute("CREATE TABLE hospitals AS SELECT * FROM read_csv_auto('healthcare_master_enriched.csv')")
result = con.execute(open('sql/01_national_kpi_summary.sql').read()).df()
```

### Option 2 — DuckDB CLI
```bash
duckdb
> .read sql/01_national_kpi_summary.sql
```

### Option 3 — PostgreSQL
Load CSVs using `COPY` or pgAdmin, then run any `.sql` file directly.

## SQL Concepts Covered

- `SELECT`, `WHERE`, `GROUP BY`, `ORDER BY`, `HAVING`
- Aggregate functions: `COUNT`, `AVG`, `SUM`, `MIN`, `MAX`, `STDDEV`, `MODE`
- Window functions: `RANK()`, `NTILE()`, `LAG()`, `FIRST_VALUE()`, `AVG() OVER()`
- `PARTITION BY` for group-wise calculations
- Common Table Expressions (CTEs) — multi-step analysis
- `JOIN` (LEFT JOIN, multi-table)
- `QUALIFY` clause for window-based filtering
- `CASE WHEN` for conditional logic and cohort creation
- Subqueries and derived tables
- `CAST` for type conversion

## Key Business Questions Answered

1. What are the national KPI benchmarks for US hospitals?
2. How do High/Average/Low Performer hospitals differ on all metrics?
3. Which states lead and lag on patient satisfaction?
4. How does a hospital rank within its state peer group?
5. Which hospitals are in the top/bottom quartile nationally?
6. Is patient satisfaction improving or declining over time?
7. How does each hospital compare to its direct peer group?
8. Which hospitals are flagged as high-risk across multiple dimensions?
9. Does area median income predict patient satisfaction?
10. How much does satisfaction drop as ER wait time increases?
11. What is the "scale penalty" for large hospitals?
12. What are the most common improvement recommendations?

---
*Data: CMS Hospital Compare 2024 + Census ACS 2023 + USDA RUCC 2023*  
*Author: Aditya · M.S. Applied Data Science · Syracuse University · 2026*
