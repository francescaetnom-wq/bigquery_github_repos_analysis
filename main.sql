-- PROJECT: Python Power Contributor Analysis (2024-2025)
-- DATASET: bigquery-public-data.github_repos
-- OBJECTIVE: Identify high-impact human contributors while filtering out automated accounts and CI/CD noise.

WITH python_repos AS (
  SELECT 
    DISTINCT l.repo_name
  FROM 
    `bigquery-public-data.github_repos.languages` AS l,
    UNNEST(language) as lang
  WHERE 
    lang.name = 'Python'
)
SELECT
  c.committer.name AS committer_name,
  COUNT(*) as commit_count
FROM
  `bigquery-public-data.github_repos.commits` AS c,
  UNNEST(c.repo_name) AS single_repo_name
INNER JOIN
  python_repos AS pr 
  ON single_repo_name = pr.repo_name
WHERE
  -- Handling nested timestamps and applying temporal partition filter
  TIMESTAMP_SECONDS(c.committer.date.seconds) > TIMESTAMP('2024-01-01 00:00:00')
  AND c.committer.name IS NOT NULL
  AND c.committer.name != ''
  -- Advanced noise reduction: filtering out bots and system accounts using Regex
  AND NOT REGEXP_CONTAINS(LOWER(c.committer.name), r'(bot|nodes|engine|helper|automated|github|root)')
GROUP BY
  1
HAVING 
  commit_count > 5 -- Focusing on consistent contributors only
ORDER BY
  commit_count DESC
LIMIT 20;