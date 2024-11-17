-- Part 7: Queries for Assignment 

-- A) Find the total number of movies with and without IMDB id in the database
SELECT 
    COUNT(CASE WHEN imdb_id IS NOT NULL THEN 1 END) AS movies_with_imdb,
    COUNT(CASE WHEN imdb_id IS NULL THEN 1 END) AS movies_without_imdb
FROM movies;

-- B) Pick an actor. Find all movies by that actor released between 2000 and 2020

SELECT 
    m.tmdb_id, 
    m.imdb_id, 
    m.title, 
    m.release_date, 
    m.watchmode_id
FROM 
    movies m
JOIN 
    movie_actors ma ON m.id = ma.movie_id
JOIN 
    actors a ON ma.actor_id = a.id
WHERE 
    a.name = 'Leonardo DiCaprio' 
    AND m.release_date BETWEEN '2000-01-01' AND '2020-12-31';

-- C) Find movies with the highest number of reviews. List the top 3
SELECT 
    m.title, 
    COUNT(r.id) AS review_count
FROM 
    movies m
JOIN 
    reviews r ON m.id = r.movie_id
GROUP BY 
    m.title
ORDER BY 
    review_count DESC
LIMIT 3;

-- D) Find the number of movies that are in more than one language
SELECT 
    COUNT(m.id) AS movies_in_multiple_languages
FROM 
    movies m
JOIN 
    movie_languages ml ON m.id = ml.movie_id
GROUP BY 
    m.id
HAVING 
    COUNT(ml.language_id) > 1;

-- E) For each language, list how many movies are there in the database, ordered by highest count
SELECT 
    l.language_name, 
    COUNT(m.id) AS movie_count
FROM 
    languages l
JOIN 
    movie_languages ml ON l.id = ml.language_id
JOIN 
    movies m ON ml.movie_id = m.id
GROUP BY 
    l.language_name
ORDER BY 
    movie_count DESC;

-- F) Find top 2 comedies with the highest ratings
SELECT 
    m.title, 
    m.viewers_rating
FROM 
    movies m
JOIN 
    movie_genres mg ON m.id = mg.movie_id
JOIN 
    genres g ON mg.genre_id = g.id
WHERE 
    g.genre_name = 'Comedy'
ORDER BY 
    m.viewers_rating DESC
LIMIT 2;

-- G) Batch-update query to round up all the ratings

UPDATE 
    movies
SET 
    viewers_rating = CEIL(viewers_rating);
