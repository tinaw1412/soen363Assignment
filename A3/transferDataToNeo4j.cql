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

//new data inserting after finding that genre and language has to be attributes of movie

LOAD CSV WITH HEADERS FROM 'file:///movie_genreTable.csv' AS row
CREATE (:MovieGenre {movie_id: toInteger(row.movie_id), genre_name: row.genre_name});

LOAD CSV WITH HEADERS FROM 'file:///movie_languageTable.csv' AS row
CREATE (:MovieLanguage {movie_id: toInteger(row.movie_id), language_name: row.language_name});

LOAD CSV WITH HEADERS FROM 'file:///movieTable.csv' AS row
MATCH (cr:ContentRating {id: toInteger(row.content_rating_id)}) // Link to ContentRating
// Collect genres for the movie
CALL {
    WITH row
    MATCH (mg:MovieGenre) WHERE mg.movie_id = toInteger(row.id)
    RETURN collect(mg.genre_name) AS genres
}
// Collect languages for the movie
CALL {
    WITH row
    MATCH (ml:MovieLanguage) WHERE ml.movie_id = toInteger(row.id)
    RETURN collect(ml.language_name) AS languages
}
// Create the Movie node
CREATE (:Movie {
    id: toInteger(row.id),
    tmdb_id: row.tmdb_id,
    imdb_id: row.imdb_id,
    title: row.title,
    plot: row.plot,
    content_rating: cr.rating,
    viewers_rating: toFloat(row.viewers_rating),
    release_year: toInteger(row.release_year),
    akas: row.akas,
    watchmode_id: row.watchmode_id,
    genres: genres,                     // Array attribute for genres
    languages: languages                // Array attribute for languages
});


MATCH (n:Genre)
DETACH DELETE n;

MATCH (n:Language)
DETACH DELETE n;

MATCH ()-[r:HAS_GENRE]->()
DELETE r;

MATCH ()-[r:IN_LANGUAGE]->()
DELETE r;

// Collect genres as an attribute of Movie
MATCH (m:Movie)
OPTIONAL MATCH (mg:MovieGenre {movie_id: m.id})
WITH m, collect(mg.genre_name) AS genres
SET m.genres = genres;

// Collect languages as an attribute of Movie
MATCH (m:Movie)
OPTIONAL MATCH (ml:MovieLanguage {movie_id: m.id})
WITH m, collect(ml.language_name) AS languages
SET m.languages = languages;

// Remove unnecessary MovieGenre and MovieLanguage nodes
MATCH (n:MovieGenre)
DETACH DELETE n;

MATCH (n:MovieLanguage)
DETACH DELETE n;

LOAD CSV WITH HEADERS FROM 'file:///movieTable.csv' AS row
OPTIONAL MATCH (cr:ContentRating {id: toInteger(row.content_rating_id)})  // Match the content rating, but make it optional
MERGE (m:Movie {tmdb_id: row.tmdb_id})  // Ensure the movie with tmdb_id is unique
SET 
    m.id = toInteger(row.id),
    m.imdb_id = CASE 
                    WHEN row.imdb_id IS NOT NULL AND row.imdb_id <> "" THEN row.imdb_id 
                    ELSE null 
                END,
    m.title = row.title,
    m.plot = row.plot,
    m.content_rating = CASE 
                         WHEN cr IS NOT NULL THEN cr.rating 
                         ELSE null 
                       END,  // Set content_rating to null if no ContentRating is matched
    m.viewers_rating = CASE 
                          WHEN row.viewers_rating IS NOT NULL AND toFloat(row.viewers_rating) >= 0 AND toFloat(row.viewers_rating) <= 10 
                          THEN toFloat(row.viewers_rating)
                          ELSE null 
                      END,
    m.release_year = toInteger(row.release_year),
    m.akas = row.akas,
    m.watchmode_id = CASE 
                        WHEN row.watchmode_id IS NOT NULL AND row.watchmode_id <> "NULL" THEN row.watchmode_id
                        ELSE null 
                    END,
    m.genres = CASE 
                  WHEN row.genres IS NOT NULL THEN split(row.genres, "|")
                  ELSE [] 
               END,
    m.languages = CASE 
                    WHEN row.languages IS NOT NULL THEN split(row.languages, "|")
                    ELSE [] 
                  END;

