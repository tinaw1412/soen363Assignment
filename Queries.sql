-- Part 7: Queries for Assignment

-- A) Find the total number of movies with and without IMDB id in the database
SELECT 
    COUNT(CASE WHEN imdb_id IS NOT NULL THEN 1 END) AS movies_with_imdb,
    COUNT(CASE WHEN imdb_id IS NULL THEN 1 END) AS movies_without_imdb
FROM movie;

-- B) Pick an actor. Find all movies by that actor released between 2000 and 2020
SELECT 
    m.tmdb_id, 
    m.imdb_id, 
    m.title, 
    m.release_year,  -- Adjusted to 'release_year' based on your schema
    m.watchmode_id
FROM 
    movie m
JOIN 
    movie_actor ma ON m.id = ma.movie_id
JOIN 
    actor a ON ma.actor_id = a.id
WHERE 
    a.name = 'Leonardo DiCaprio' 
    AND m.release_year BETWEEN 2000 AND 2020;

-- C) Find movies with the highest number of viewers ratings. List the top 3
SELECT 
    m.title, 
    COUNT(m.viewers_rating) AS rating_count
FROM 
    movie m
GROUP BY 
    m.title
ORDER BY 
    rating_count DESC
LIMIT 3;

-- D) Find the number of movies that are in more than one language
SELECT 
    COUNT(m.id) AS movies_in_multiple_languages
FROM 
    movie m
JOIN 
    movie_language ml ON m.id = ml.movie_id
GROUP BY 
    m.id
HAVING 
    COUNT(ml.language_id) > 1;

-- E) For each language, list how many movies are there in the database, ordered by highest count
SELECT 
    l.name AS language_name,  -- Adjusted to 'name' from 'language_name'
    COUNT(m.id) AS movie_count
FROM 
    language l
JOIN 
    movie_language ml ON l.id = ml.language_id
JOIN 
    movie m ON ml.movie_id = m.id
GROUP BY 
    l.name
ORDER BY 
    movie_count DESC;

-- F) Find top 2 comedies with the highest ratings
SELECT 
    m.title, 
    m.viewers_rating
FROM 
    movie m
JOIN 
    movie_genre mg ON m.id = mg.movie_id
JOIN 
    genre g ON mg.genre_id = g.id
WHERE 
    g.name = 'Comedy'  -- Adjusted to 'name' from 'genre_name'
ORDER BY 
    m.viewers_rating DESC
LIMIT 2;

-- G) Batch-update query to round up all the ratings
UPDATE 
    movie
SET 
    viewers_rating = CEIL(viewers_rating);
