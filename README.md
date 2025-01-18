### Netflix Analysis 
---

## Project Overview

This project provides an in-depth analysis of Netflix's data using SQL. It covers data creation, querying, and insights derived from various operations. The main objective is to analyze Netflix content based on different attributes like type, genre, rating, and more.

---

## Table of Contents

1. **Database Setup**
2. **Data Exploration**
3. **Content-Type Analysis**
4. **Rating Insights**
5. **Year-Based Analysis**
6. **Country-Based Content Distribution**
7. **Duration-Based Insights**
8. **Genre and Actor Analysis**
9. **Categorization by Content Description**
10. **Handling Missing Data**

---

## Features and SQL Queries

### 1. **Database Setup**
- **Table Creation:**
  ```sql
  DROP TABLE IF EXISTS netflix;
  CREATE TABLE netflix
  (
      show_id       VARCHAR(5),
      type          VARCHAR(10),
      title         VARCHAR(250),
      director      VARCHAR(550),
      casts         VARCHAR(1050),
      country       VARCHAR(550),
      date_added    VARCHAR(55),
      release_year  INT,
      rating        VARCHAR(15),
      duration      VARCHAR(15),
      listed_in     VARCHAR(250),
      description   VARCHAR(550)
  );
  ```
  **Function:** Creates a table `netflix` with attributes describing various aspects of Netflix content, ensuring comprehensive data storage.

### 2. **Data Exploration**
- **View All Records:**
  ```sql
  SELECT * FROM netflix;
  ```
  **Function:** Retrieves all rows from the `netflix` table, providing an overview of the data.

### 3. **Content-Type Analysis**
- **Count Content by Type:**
  ```sql
  SELECT
      type,
      COUNT(*) AS count
  FROM netflix
  GROUP BY type;
  ```
  **Function:** Groups content by type (e.g., `Movie` or `TV Show`) and counts occurrences.

### 4. **Rating Insights**
- **Most Frequent Rating by Type:**
  ```sql
  WITH RatingCounts AS (
      SELECT
          type,
          rating,
          COUNT(*) AS rating_count
      FROM netflix
      GROUP BY type, rating
  ),
  RankedRatings AS (
      SELECT
          type,
          rating,
          rating_count,
          RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
      FROM RatingCounts
  )
  SELECT
      type,
      rating AS most_frequent_rating
  FROM RankedRatings
  WHERE rank = 1;
  ```
  **Function:** Determines the most common rating for each content type by ranking ratings based on their frequency.

### 5. **Year-Based Analysis**
- **Content Added in 2020:**
  ```sql
  SELECT *
  FROM netflix
  WHERE release_year = 2020;
  ```
  **Function:** Fetches records for content released in 2020.

- **Content Added in Last 5 Years:**
  ```sql
  SELECT *
  FROM netflix
  WHERE TRY_CAST(date_added AS DATE) >= DATEADD(YEAR, -5, GETDATE());
  ```
  **Function:** Retrieves content added within the last five years using date comparison.

### 6. **Country-Based Content Distribution**
- **Top Countries by Content:**
  ```sql
  SELECT TOP 5
      country,
      COUNT(*) AS total_content
  FROM netflix
  WHERE country IS NOT NULL
  GROUP BY country
  ORDER BY total_content DESC;
  ```
  **Function:** Identifies the top five countries producing the most content.

### 7. **Duration-Based Insights**
- **Longest Movie:**
  ```sql
  SELECT TOP 1
      *
  FROM netflix
  WHERE type = 'Movie'
  ORDER BY CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) DESC;
  ```
  **Function:** Finds the longest movie by converting the duration into an integer.

- **TV Shows with More than 5 Seasons:**
  ```sql
  SELECT *
  FROM netflix
  WHERE type = 'TV Show'
    AND CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;
  ```
  **Function:** Lists TV shows with more than five seasons.

### 8. **Genre and Actor Analysis**
- **Content by Genre:**
  ```sql
  SELECT
      genre,
      COUNT(*) AS total_content
  FROM (
      SELECT
          listed_in,
          value AS genre
      FROM netflix
      CROSS APPLY STRING_SPLIT(listed_in, ',')
  ) AS genres
  GROUP BY genre;
  ```
  **Function:** Counts content for each genre by splitting the `listed_in` column.

- **Top Actors in Indian Content:**
  ```sql
  SELECT TOP 10
      actor,
      COUNT(*) AS movie_count
  FROM (
      SELECT
          casts,
          value AS actor
      FROM netflix
      CROSS APPLY STRING_SPLIT(casts, ',')
      WHERE country = 'India'
  ) AS actors
  GROUP BY actor
  ORDER BY movie_count DESC;
  ```
  **Function:** Lists the top ten actors based on their movie count in Indian content.

### 9. **Categorization by Content Description**
- **Content Categorization:**
  ```sql
  SELECT
      category,
      type,
      COUNT(*) AS content_count
  FROM (
      SELECT
          type,
          CASE
              WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
              ELSE 'Good'
          END AS category
      FROM netflix
  ) AS categorized_content
  GROUP BY category, type
  ORDER BY type;
  ```
  **Function:** Categorizes content as "Good" or "Bad" based on keywords in the description.

### 10. **Handling Missing Data**
- **Records with Missing Director:**
  ```sql
  SELECT *
  FROM netflix
  WHERE director IS NULL;
  ```
  **Function:** Identifies rows with missing `director` information.

---

## Tools and Techniques
- **SQL Functions:** `GROUP BY`, `WITH`, `RANK()`, `CASE`, `STRING_SPLIT`
- **Data Cleaning:** Handling NULL values and transforming data.
- **Performance Optimization:** Using indices, `CROSS APPLY`, and conditional filtering.

---

## Example Insights
- **Most Common Rating by Type:** Helps content creators understand popular rating trends.
- **Top Countries:** Highlights key contributors to Netflix's content library.
- **Longest Movie:** Useful for identifying standout content in terms of runtime.

