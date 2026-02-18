# bigquery_github_repos_analysis
SQL analysis on GitHub public dataset (BigQuery) to identify top Python committers from Jan 2024 to Sep 2025. Managed nested ARRAY/STRUCT fields using UNNEST and TIMESTAMP conversion, optimized query cost (-90%), and applied regex-based filtering to exclude bots and automation noise.


GitHub Python Ecosystem Analysis: 2024-2025
## 1. Project Context
This analysis targets the bigquery-public-data.github_repos dataset. The goal was to isolate high-impact human contributors within the Python ecosystem while minimizing cloud compute costs and filtering automated noise.

## 2. Technical Implementation & Constraints
2.1 Schema Navigation
The GitHub dataset uses a non-normalized, nested architecture.

Arrays: Repository names are stored as arrays, requiring UNNEST operations to perform joins with language metadata.

Structs: Committer timestamps are stored as STRUCT<seconds INT64, nanos INT64>. I used TIMESTAMP_SECONDS for normalization to enable temporal filtering.

2.2 Cost Management (FinOps)
A standard scan of the commits table involves 848 GB.

Optimization: By using a CTE to pre-identify Python-specific repos and applying a 2024-2025 temporal boundary, I reduced the scan volume to 96.1 GB.

Persistence: Final results were materialized into a permanent table to avoid redundant scan costs for future BI consumption.

## 3. Data Integrity & Noise Reduction
Raw GitHub data is heavily saturated with automated activity. I implemented a multi-stage filtering strategy:

Regex Filtering: Used REGEXP_CONTAINS to strip out common CI/CD and system patterns (bot, helper, engine, etc.).

Thresholding: Applied HAVING commit_count > 5 to remove transient contributors and focus on consistent maintainers.

## 4. Observations
Timeline: The dataset snapshot used is current as of September 23, 2025.

Outliers: Despite filtering, high-volume automated accounts (e.g., Matthew Martin) remain in the top tier. This confirms that simple string matching is insufficient for full bot-detection and requires further behavioral analysis.

Validation: The presence of established maintainers (e.g., Jelmer Vernooij) validates the extraction logic.

## 5. Repository Structure
/sql: top_python_contributors.sql - Optimized extraction script.

/data: results_sample.csv - Sample output of the processed dataset.
