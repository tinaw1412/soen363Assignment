
// A) Find all movies played by a specific actor
MATCH (a:Actor)-[:ACTED_IN]->(m:Movie)
WHERE a.name = "Armie Hammer"
RETURN m.title AS MovieTitle;

// B) Find the number of movies with and without a watch-mode info
MATCH (m:Movie)
RETURN 
    COUNT(CASE WHEN m.watchmode_id IS NOT NULL THEN 1 END) AS WithWatchMode,
    COUNT(CASE WHEN m.watchmode_id IS NULL THEN 1 END) AS WithoutWatchMode;
// Another Way: 48 movies in total: 5 with watchmode, rest do not have watchmode     
MATCH (m:Movie)
RETURN 
    COUNT(CASE 
            WHEN m.watchmode_id IS NOT NULL AND m.watchmode_id <> "NULL" AND toFloat(m.watchmode_id) <> 0 THEN 1 
         END) AS WithWatchMode,
    COUNT(CASE 
            WHEN m.watchmode_id IS NULL OR m.watchmode_id = "NULL" THEN 1 
         END) AS WithoutWatchMode;

// C) Find all movies that are released after 2023 and have a viewer rating of at least 5
MATCH (m:Movie)
WHERE m.release_year > 2023 AND m.viewers_rating >= 5
RETURN m.title AS MovieTitle, m.viewers_rating AS ViewerRating, m.release_year AS ReleaseYear;

// D) Find all movies produced in two specific countries
MATCH (m:Movie)-[:PRODUCED_IN]->(c:Country)
WHERE c.full_name IN ["United States", "United Kingdom"]
RETURN m.title AS MovieTitle, c.full_name AS CountryName;

// E) Find the top 2 movies with the largest number of keywords
MATCH (m:Movie)-[:HAS_KEYWORD]->(k:Keyword)
WITH m, COUNT(k) AS KeywordCount
ORDER BY KeywordCount DESC
LIMIT 2
RETURN m.title AS MovieTitle, KeywordCount;

// F) Find the top 5 movies (ordered by rating) in a language of your choice
MATCH (m:Movie)
WHERE "English" IN m.languages
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
