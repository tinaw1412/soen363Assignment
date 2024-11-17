-- Part 6: Creating view 'movie_summary'

CREATE VIEW movie_summary AS
SELECT 
    m.tmdb_id, 
    m.imdb_id, 
    m.title, 
    m.plot AS description, 
    m.content_rating, 
    m.runtime,
    COUNT(k.keyword_id) AS number_of_keywords,
    COUNT(DISTINCT c.country_id) AS number_of_countries
FROM 
    movies m
LEFT JOIN 
    movie_keywords k ON m.id = k.movie_id
LEFT JOIN 
    movie_countries c ON m.id = c.movie_id
GROUP BY 
    m.tmdb_id, 
    m.imdb_id, 
    m.title, 
    m.plot, 
    m.content_rating, 
    m.runtime;
