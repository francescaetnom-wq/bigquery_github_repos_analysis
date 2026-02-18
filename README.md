# bigquery_github_repos_analysis
SQL analysis on GitHub public dataset (BigQuery) to identify top Python committers from Jan 2024 to Sep 2025. Managed nested ARRAY/STRUCT fields using UNNEST and TIMESTAMP conversion, optimized query cost (-90%), and applied regex-based filtering to exclude bots and automation noise.


# Deep Dive into GitHub's Python Ecosystem (2024-2025)

## 🎯 Project Overview
This project explores the `bigquery-public-data.github_repos` dataset (over **3TB**) to identify the most active Python contributors. The goal was to extract meaningful human insights from a massive volume of raw event logs while maintaining cost efficiency and data quality.

## 🛠️ Technical Challenges & Solutions

### 1. Navigating Complex Data Architectures (`UNNEST`)
Unlike standard relational databases, GitHub's schema uses **Arrays** for repository names. I implemented `UNNEST` to flatten these structures, enabling precise joins with language metadata without losing data integrity.

### 2. Normalizing Nested Timestamps
The `commits` table stores temporal data in a `STRUCT` (`seconds` and `nanos`). 
* **The Solution:** I used `TIMESTAMP_SECONDS` to transform raw Unix seconds into a standard `TIMESTAMP` format, allowing for accurate temporal filtering since January 1st, 2024.

### 3. FinOps & Cost Optimization (90% Efficiency Gain)
A naive query would have scanned the entire commit table (**848 GB**). 
* **The Strategy:** By combining a Common Table Expression (CTE) for language filtering and strict temporal boundaries, I reduced the scan volume to **96.1 GB**. This demonstrates a professional focus on cloud cost management.



## 🧹 Data Cleaning: Signal vs. Noise
Big Data is inherently "dirty." To ensure the analysis focused on human talent rather than machine activity, I implemented:
* **Advanced Regex Filtering:** Used `REGEXP_CONTAINS` to exclude common bot patterns (`bot`, `helper`, `automated`, etc.).
* **Activity Thresholds:** Applied a `HAVING` clause to filter out sporadic contributors, focusing on users with sustained impact (>5 commits).

## 📊 Insights & Observations
* **Data Recency:** The analysis reflects data up to **September 23, 2025** (the latest snapshot available in the public dataset).
* **Automation Identification:** High-volume accounts like *Matthew Martin* (>60k commits) were identified as outliers. In a business context, identifying these "Automation Profiles" is crucial to avoid skewing engagement metrics.
* **Talent Discovery:** The query successfully surfaced high-profile maintainers (e.g., *Jelmer Vernooij*), validating the logic's ability to identify real-world technical leaders.

## 📂 Repository Structure
* `/sql`: `top_python_contributors.sql` (The core extraction logic).
* `/data`: `top_contributors_sample.csv` (Cleaned output sample).
* **Persistence:** Results were materialized into a permanent BigQuery table to optimize read performance for downstream BI tools (Looker/Tableau).
