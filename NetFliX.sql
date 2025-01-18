
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

SELECT * FROM netflix;

SELECT 
    type,
    COUNT(*) AS count
FROM netflix
GROUP BY type;

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
SELECT * 
FROM netflix
WHERE release_year = 2020;

SELECT TOP 5 
    country,
    COUNT(*) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC;

SELECT TOP 1
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) DESC;

SELECT *
FROM netflix
WHERE TRY_CAST(date_added AS DATE) >= DATEADD(YEAR, -5, GETDATE());

SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;

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

SELECT TOP 5
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        CAST(COUNT(show_id) AS FLOAT) / (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY release_year
ORDER BY avg_release DESC;

SELECT *
FROM netflix
WHERE listed_in LIKE '%Documentaries%';

SELECT *
FROM netflix
WHERE director IS NULL;

SELECT *
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > YEAR(GETDATE()) - 10;
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
