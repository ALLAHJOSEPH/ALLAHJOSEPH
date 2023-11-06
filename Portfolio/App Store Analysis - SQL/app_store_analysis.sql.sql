-- App Store Analysis
-- Augustinus Joseph
-- 2023-10-06


CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FRom appleStore_description4


**EXPLORATORY DATA ANLYSIS**

-- check the number of unique apps in both tables.

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
From AppleStore

-- unqiue app IDs 7197

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
From appleStore_description_combined

-- unique app IDs 7197

-- Running both queries we can see that there is no missing data between 
-- the two tables.

-- Check for any missing values in key fields

SELECT COUNT(*) AS MisssingValues
FROM AppleStore
WHERE track_name IS null OR user_rating IS null OR prime_genre IS NULL

-- Running this query we can see that there are no missing values considering 
-- the conditions set. We'll do the same thing for the 
-- appleStore_description_combined.

SELECT COUNT(*) AS MisssingValues
FROM appleStore_description_combined
WHERE app_desc IS NULL

-- Running this query we can see that the combined table is also clean.

-- Find out the number of apps per genreAppleStore

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

-- This query shoes us that Games, Entertainment, and Education apps are some of the most
-- widely available. This may insinuate the markets are a bit saturated, if the goal was to
-- make any kind of app.

-- Get an overview of the apps' ratingsAppleStore

SELECT min(user_rating) AS MinRating,
	   max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating,
      mode(user_rating) AS ModRating
FROM AppleStore

-- With this query we can understand minimum, maximum, average, and most common 
-- ratings.

-- Now, let's discovery insights

-- Determine whether paid apps have higher ratings than free apps

SELECT CASE
		    WHEN price > 0 THEN 'Paid'
            ELSE 'Free'
       END AS App_Type,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type

-- Running this query the insight extracted is that the rating of paid apps is
-- slightly higher in comparison to free apps.

-- Check if apps with more supported languages have higher ratings

SELECT CASE
		    WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            ELSE '>30 languages'
       END AS language_batch,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_batch
Order By Avg_rating DESC

-- Through this query we can see that apps that have 10-30 languages have the highest 
-- average ratings.

-- Check genre with lowest rating

SELECT prime_genre,
	   avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating ASC
LIMIT 10

-- Through this query we can see that catalogs, finance, and book apps (among others)
-- have the lowest average ratings. This shows that users are not satisfied in this space
-- and it may prove to be a good opportunity to create an app withtin these genres. 

-- Check if there is correlation between the length of the app description and the user
-- rating 

SELECT CASE
			WHEN length(AppSD.app_desc) <500 THEN 'Short'
            WHEN length(AppSD.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
            ELSE 'Long'
       End AS description_length_batch,
       avg(AppS.user_rating) AS average_rating
FROM
	  AppleStore AS AppS
JOIN 
	  appleStore_description_combined AS AppSD
ON 
	  AppS.id = AppSD.id
GROUP BY description_length_batch
ORDER BY average_rating DESC

-- Through this query we are shown the longer the description length, the higher 
-- the average user rating of the app. 

-- Checking top-rated app for each genre 

SELECT
	prime_genre,
    track_name,
    user_rating
From (
  	  SELECT
  	  prime_genre,
  	  track_name,
  	  user_rating,
  	  RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
      FROM
      AppleStore
    ) AS app_rank
  WHERE
  app_rank.rank = 1
  
  -- With this query, we get the result of all of the top performing apps- defined by
  -- highest total user rating counts for each genre; highest number of ratings and the best rating. 
  
  -- This would be a great insight for our stakeholder to check these apps as the top performers; ones
  -- that ideally could/should be emulated. 