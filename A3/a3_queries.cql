
// A) Find all movies that are played by a sample actor
MATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
WHERE a.name = "Sample Actor Name"
RETURN m.title AS MovieTitle;

// B) Find the number of movies with and without a watch-mode info
MATCH (m:Movie)
RETURN 
    COUNT(CASE WHEN m.watchmode_id IS NOT NULL THEN 1 END) AS WithWatchMode,
    COUNT(CASE WHEN m.watchmode_id IS NULL THEN 1 END) AS WithoutWatchMode;

// C) Find all movies that are released after 2023 and have a viewer rating of at least 5
MATCH (m:Movie)
WHERE m.release_year > 2023 AND m.viewers_rating >= 5
RETURN m.title AS MovieTitle, m.viewers_rating AS ViewerRating, m.release_year AS ReleaseYear;

// D) Find all movies with two countries of your choice
MATCH (m:Movie)-[:PRODUCED_IN]->(c:Country)
WHERE c.name IN ["Country1", "Country2"]
RETURN m.title AS MovieTitle, c.name AS CountryName;

// E) Find the top 2 movies with the largest number of keywords
MATCH (m:Movie)-[:HAS_KEYWORD]->(k:Keyword)
WITH m, COUNT(k) AS KeywordCount
ORDER BY KeywordCount DESC
LIMIT 2
RETURN m.title AS MovieTitle, KeywordCount;

// F) Find the top 5 movies (ordered by rating) in a language of your choice
MATCH (m:Movie)-[:IN_LANGUAGE]->(l:Language)
WHERE l.name = "LanguageName"
RETURN m.title AS MovieTitle, m.viewers_rating AS ViewerRating
ORDER BY m.viewers_rating DESC
LIMIT 5;

// G) Build a full-text search index to query movie plots
CALL db.index.fulltext.createNodeIndex("MoviePlots", ["Movie"], ["plot"]);

// H) Write a full-text search query and search for sample text
CALL db.index.fulltext.queryNodes("MoviePlots", "Sample Text") 
YIELD node, score
RETURN node.title AS MovieTitle, score
ORDER BY score DESC;
