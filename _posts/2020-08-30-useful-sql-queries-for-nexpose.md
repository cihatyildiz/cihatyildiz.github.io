---
title: Useful SQL Queries for Nexpose
author: Cihat Yildiz
date: 2020-08-30 20:55:00 +0800
categories: [Nexpose]
tags: [writing]
pin: false
---

Nexpose has lots of features to generate reports. But in some cases, the features in the UI may not be useful for you. You may need to create custom reports for your vulnerability management process. Also, you may need to generate a custom data related to your organization. For this purpose, nexpose allow you to access to its database  by using SQL report template. Wit this feature you can run a SQL query in the database and get the data you want.

In this post, I want to share some SQL query examples that you can use in nexpose. The SQL examples here are the ones I tested on my nexpose infrastructure. I also provided the nexpose database scheme below. You can generate your own queries. The sky is the limit :). So, you can review the database schema and create your own query. If you dont know hhow to generate SQL query, you can reach out to Rapid7 support and request a SQL query based on your needs. 

* [Nexpose Warehohuse Schema](https://help.rapid7.com/nexpose/en-us/warehouse/warehouse-schema.html)

# Authennticated scan percentage

This shows the authenticated scan percentage. This is a useful query for scan health. 

```sql
WITH
CTE AS (
SELECT DISTINCT ON (ip_address)    
     da.ip_address, da.host_name, dos.description AS operating_system,     
     fa.scan_finished AS last_scanned, aos.certainty,aos.fingerprint_source_id,
CASE
WHEN (aos.certainty = 1) then sum(2-1)
ELSE sum(1-1)
END AS authenticated,

CASE
WHEN (aos.certainty >=0) then sum(2-1)
ELSE sum(1-1)
END AS total

   
FROM fact_asset AS fa    
   JOIN dim_asset da USING (asset_id)    
   JOIN dim_operating_system dos USING (operating_system_id)    
   JOIN dim_asset_operating_system aos USING (asset_id)    
GROUP BY da.ip_address, da.host_name, dos.description, fa.scan_finished, aos.certainty, aos.fingerprint_source_id
ORDER BY da.ip_address ASC
)
SELECT sum(authenticated) as authenticated, sum(total) as total, round(sum(authenticated)/sum(total),2) AS percentage_authenticated
FROM CTE
```


# Duplicate asset information

You can see the how many duplicate assets in nexpose 

```sql
SELECT da.host_name,COUNT(*)
FROM dim_asset da
GROUP BY da.host_name
HAVING COUNT(*) > 1
```

# Vulnerabilities with proof information

This query shows the proof information of the vulnnerabilities. 

```sql
SELECT da.ip_address AS "IP Address", 
      da.host_name AS "Host Name", 
      dv.title AS " Vulnerability Title", 
      dv.description AS "Vulnerability Description", 
      fa.proof AS "Proof", 
      fa.key AS "Proof Key", 
      da.sites AS Sites, 
      dv.nexpose_id AS "NexposeID"
FROM fact_asset_vulnerability_instance fa 
JOIN dim_asset da USING(asset_id) 
JOIN dim_vulnerability dv USING(vulnerability_id)
```

# Shares on Assets

Withh this query you can use SMB shares on your assets

```sql
select da.ip_address, da.host_name, dos.description, daf.type, daf.name, da.sites
from dim_asset da
   JOIN dim_asset_file daf using (asset_id)
   JOIN dim_operating_system dos USING (operating_system_id)  
order by da.ip_address asc
```

# Daily New Vulns

```sql
WITH
   today_date AS (
      SELECT now() AS date
   ),
   asset_scans AS (
      SELECT asset_id, scanAsOfDate(asset_id, now()::date) AS scan_today, scanAsOfDate(asset_id, ((SELECT date FROM today_date) - INTERVAL '1 day')::date) AS scan_day_ago
      FROM dim_asset
   ),
   asset_scan_results AS (
      -- results from the scan on each asset for today's results
      SELECT fasvf.asset_id, fasvf.vulnerability_id, fasvf.scan_id, 2 AS state
      FROM fact_asset_scan_vulnerability_finding fasvf
         JOIN asset_scans a ON a.asset_id = fasvf.asset_id AND fasvf.scan_id = a.scan_today
      UNION ALL
      -- results from the scan on each asset for the results one day ago
      SELECT fasvf.asset_id, fasvf.vulnerability_id, fasvf.scan_id, 1 AS state
      FROM fact_asset_scan_vulnerability_finding fasvf
         JOIN asset_scans a ON a.asset_id = fasvf.asset_id AND fasvf.scan_id = a.scan_day_ago
   ),
   asset_scan_results_diff AS (
      SELECT asset_id, vulnerability_id, baselineComparison(state, 2) AS diff
      FROM asset_scan_results
      GROUP BY asset_id, vulnerability_id
   )
SELECT da.ip_address, da.host_name, da.mac_address, asrd.diff, dv.title AS vulnerability_title, to_char(now(), 'YYYY-mm-dd') AS current_date
FROM asset_scan_results_diff asrd
   JOIN dim_asset da USING (asset_id)
   JOIN dim_vulnerability dv USING (vulnerability_id)
WHERE asrd.diff = 'New'
ORDER BY da.ip_address, asrd.diff, dv.title
```



# Recources

* [Nexpose SQL queries-black3irwin](https://github.com/blak3irwin/nexpose-sql-queries)
* [Nexpose Resources - rapid7](https://github.com/rapid7/nexpose-resources)
* [SQL Query Export examples - rapid7](https://docs.rapid7.com/nexpose/sql-query-export-examples/)
* [InsightVM-SQL-Queries-Reports](https://github.com/talltechy/InsightVM-SQL-Queries-Reports)
* [Understanding Fingerprints and Vulnerability Checks](https://github.com/BrianWGray/cmty-nexpose-checks/wiki/Understanding-Fingerprints-and-Vulnerability-Checks)
