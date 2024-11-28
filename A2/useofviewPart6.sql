CREATE VIEW moviesSummary AS
SELECT 
    m.tmdb_id AS tmdb_key,
    m.imdb_id AS imdb_key,
    m.title,
    m.plot AS description,
    cr.rating AS content_rating,
    COUNT(DISTINCT mk.keyword_id) AS number_of_keywords,
    COUNT(DISTINCT mc.country_id) AS number_of_countries
FROM movie m
LEFT JOIN content_rating cr ON m.content_rating_id = cr.id
LEFT JOIN movie_keyword mk ON m.id = mk.movie_id
LEFT JOIN movie_country mc ON m.id = mc.movie_id
GROUP BY m.id, cr.rating;