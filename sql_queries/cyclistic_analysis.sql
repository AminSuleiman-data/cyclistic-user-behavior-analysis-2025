-- Cyclistic SQL Analysis Queries
-- Author: Amin Suleiman
-- Project: Cyclistic User Behavior Analysis

-------------------------------------------------
-- 1. Missing Values Check
-- Purpose: Validate dataset completeness
-------------------------------------------------

SELECT
COUNTIF(ride_id IS NULL) AS m_ride_id,
COUNTIF(rideable_type IS NULL) AS m_rideable_type,
COUNTIF(started_at IS NULL) AS m_started_at,
COUNTIF(ended_at IS NULL) AS m_ended_at,
COUNTIF(start_station_name IS NULL) AS m_start_station_name,
COUNTIF(start_station_id IS NULL) AS m_start_station_id,
COUNTIF(end_station_name IS NULL) AS m_end_station_name,
COUNTIF(end_station_id IS NULL) AS m_end_station_id,
COUNTIF(start_lat IS NULL) AS m_start_lat,
COUNTIF(start_lng IS NULL) AS m_start_lng,
COUNTIF(end_lat IS NULL) AS m_end_lat,
COUNTIF(end_lng IS NULL) AS m_end_lng,
COUNTIF(member_casual IS NULL) AS m_member_casual
FROM `cyclistic-project-488013.Cyclistic_full_year.cleaned_trips_2025`;

-------------------------------------------------
-- 2. Duplicate Check
-- Purpose: Ensure ride_id uniqueness
-------------------------------------------------

SELECT
COUNT(*) AS total_rows,
COUNT(DISTINCT ride_id) AS unique_ride_ids,
COUNT(*) - COUNT(DISTINCT ride_id) AS duplicate_count
FROM `cyclistic-project-488013.Cyclistic_full_year.cleaned_trips_2025`;

-------------------------------------------------
-- 3. Data Validation Check
-- Purpose: Detect invalid ride durations
-------------------------------------------------

SELECT
ride_id,
started_at,
ended_at,
TIMESTAMP_DIFF(ended_at, started_at, SECOND) AS ride_length_seconds
FROM `cyclistic-project-488013.Cyclistic_full_year.cleaned_trips_2025`
WHERE ended_at < started_at;

-------------------------------------------------
-- 4. Monthly Ride Analysis
-- Purpose: Identify seasonal patterns
-------------------------------------------------

SELECT
FORMAT_DATE('%B', started_at) AS month_name,
EXTRACT(MONTH FROM started_at) AS month_number,
member_casual,
COUNT(*) AS total_trips,
AVG(TIMESTAMP_DIFF(ended_at, started_at, SECOND) / 60) AS avg_ride_duration_minutes
FROM `cyclistic-project-488013.Cyclistic_full_year.cleaned_trips_2025`
GROUP BY
month_name, month_number, member_casual
ORDER BY
month_number, member_casual DESC;

-------------------------------------------------
-- 5. Hourly Ride Behavior
-- Purpose: Identify peak usage hours
-------------------------------------------------

SELECT
EXTRACT(HOUR FROM started_at) AS hour_of_day,
member_casual,
COUNT(ride_id) AS total_trips,
ROUND(AVG(TIMESTAMP_DIFF(ended_at, started_at, SECOND) / 60),2) AS avg_ride_length_mins
FROM `cyclistic-project-488013.Cyclistic_full_year.cleaned_trips_2025`
GROUP BY
hour_of_day, member_casual
ORDER BY
hour_of_day, member_casual;

-------------------------------------------------
-- 6. Bike Type Usage
-- Purpose: Compare bike preferences
-------------------------------------------------

SELECT
rideable_type,
member_casual,
trip_count,
CONCAT(CAST(percentage AS STRING),'%') AS percentage_label
FROM (
SELECT
rideable_type,
member_casual,
COUNT(*) AS trip_count,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY member_casual),2) AS percentage
FROM `cyclistic-project-488013.Cyclistic_full_year.cleaned_trips_2025`
GROUP BY
rideable_type, member_casual
)
ORDER BY
rideable_type, member_casual;

-------------------------------------------------
-- 7. Top 10 Stations (Casual Riders)
-- Purpose: Identify high-demand locations
-------------------------------------------------

SELECT
start_station_name,
COUNTIF(member_casual = 'member') AS member_trips,
COUNTIF(member_casual = 'casual') AS casual_trips,
COUNT(*) AS total_trips
FROM `cyclistic-project-488013.Cyclistic_full_year.cleaned_trips_2025`
WHERE start_station_name IS NOT NULL
GROUP BY
start_station_name
ORDER BY
casual_trips DESC
LIMIT 10;
