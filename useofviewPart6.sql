CREATE VIEW movie_summary AS
SELECT
    m.tmdb_id,
    m.imdb_id,
    m.title,
    m.plot,
    cr.rating AS content_rating,
    m.release_year,
    (SELECT COUNT(*) FROM movie_keyword mk WHERE mk.movie_id = m.id) AS num_keywords,
    (SELECT COUNT(*) FROM movie_country mc WHERE mc.movie_id = m.id) AS num_countries
FROM
    movie m
JOIN
    content_rating cr ON m.content_rating_id = cr.id;
