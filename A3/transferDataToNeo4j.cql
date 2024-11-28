LOAD CSV WITH HEADERS FROM 'file:///content_ratingTable.csv' AS row
CREATE (:ContentRating {id: toInteger(row.id), rating: row.rating});

LOAD CSV WITH HEADERS FROM 'file:///movieTable.csv' AS row
MATCH (cr:ContentRating {id: toInteger(row.content_rating_id)})  // Connect to content ratings
CREATE (:Movie {
    id: toInteger(row.id),
    tmdb_id: row.tmdb_id,
    imdb_id: row.imdb_id,
    title: row.title,
    plot: row.plot,
    viewers_rating: toFloat(row.viewers_rating),
    release_year: toInteger(row.release_year),
    akas: row.akas,
    watchmode_id: row.watchmode_id
})-[:HAS_CONTENT_RATING]->(cr);

// Create Genre nodes
LOAD CSV WITH HEADERS FROM 'file:///genreTable.csv' AS row
CREATE (:Genre {id: toInteger(row.id), name: row.name});


// Link Movies to Genres
LOAD CSV WITH HEADERS FROM 'file:///movie_genreTable.csv' AS row
MATCH (m:Movie {id: toInteger(row.movie_id)}), (g:Genre {id: toInteger(row.genre_id)})
CREATE (m)-[:HAS_GENRE]->(g);


// Create Keyword nodes
LOAD CSV WITH HEADERS FROM 'file:///keywordTable.csv' AS row
CREATE (:Keyword {id: toInteger(row.id), keyword: row.keyword});


// Link Movies to Keywords
LOAD CSV WITH HEADERS FROM 'file:///movie_keywordTable.csv' AS row
MATCH (m:Movie {id: toInteger(row.movie_id)}), (k:Keyword {id: toInteger(row.keyword_id)})
CREATE (m)-[:HAS_KEYWORD]->(k);


// Create Country nodes
LOAD CSV WITH HEADERS FROM 'file:///countryTable.csv' AS row
CREATE (:Country {id: toInteger(row.id), full_name: row.full_name, short_code: row.short_code});


// Link Movies to Countries
LOAD CSV WITH HEADERS FROM 'file:///movie_country.csv' AS row
MATCH (m:Movie {id: toInteger(row.movie_id)}), (c:Country {id: toInteger(row.country_id)})
CREATE (m)-[:PRODUCED_IN]->(c);

// Create Language nodes
LOAD CSV WITH HEADERS FROM 'file:///languageTable.csv' AS row
CREATE (:Language {id: toInteger(row.id), name: row.name});

// Link Movies to Languages
LOAD CSV WITH HEADERS FROM 'file:///movie_languageTable.csv' AS row
MATCH (m:Movie {id: toInteger(row.movie_id)}), (l:Language {id: toInteger(row.language_id)})
CREATE (m)-[:IN_LANGUAGE]->(l);

// Create Actor nodes
LOAD CSV WITH HEADERS FROM 'file:///actorTable.csv' AS row
CREATE (:Actor {id: toInteger(row.id), name: row.name});


// Link Movies to Actors
LOAD CSV WITH HEADERS FROM 'file:///movie_actorTable.csv' AS row
MATCH (m:Movie {id: toInteger(row.movie_id)}), (a:Actor {id: toInteger(row.actor_id)})
CREATE (a)-[:ACTED_IN]->(m);

// Create Director nodes
LOAD CSV WITH HEADERS FROM 'file:///directorTable.csv' AS row
CREATE (:Director {id: toInteger(row.id), name: row.name});


// Link Movies to Directors
LOAD CSV WITH HEADERS FROM 'file:///movie_directorTable.csv' AS row
MATCH (m:Movie {id: toInteger(row.movie_id)}), (d:Director {id: toInteger(row.director_id)})
CREATE (d)-[:DIRECTED]->(m);