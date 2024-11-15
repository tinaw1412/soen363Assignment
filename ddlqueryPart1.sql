-- Table for storing main movie information
CREATE TABLE content_rating (
    id SERIAL PRIMARY KEY,
    rating VARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE movie (
    id SERIAL PRIMARY KEY,
    tmdb_id VARCHAR(20) UNIQUE NOT NULL,
    imdb_id VARCHAR(20) UNIQUE,
    title VARCHAR(255) NOT NULL,
    plot TEXT,
    content_rating_id INTEGER REFERENCES content_rating(id),
    viewers_rating NUMERIC(3, 1),
    release_year INTEGER,
    akas TEXT,
    watchmode_id VARCHAR(20),
    CONSTRAINT valid_rating CHECK (viewers_rating BETWEEN 0 AND 10)
);

CREATE TABLE genre (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE keyword (
    id SERIAL PRIMARY KEY,
    keyword VARCHAR(50) UNIQUE NOT NULL
);



CREATE TABLE country (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    short_code CHAR(2) UNIQUE NOT NULL
);

CREATE TABLE language (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE actor (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE director (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);


CREATE TABLE movie_genre (
    movie_id INTEGER REFERENCES movie(id) ON DELETE CASCADE,
    genre_id INTEGER REFERENCES genre(id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, genre_id)
);

CREATE TABLE movie_keyword (
    movie_id INTEGER REFERENCES movie(id) ON DELETE CASCADE,
    keyword_id INTEGER REFERENCES keyword(id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, keyword_id)
);

CREATE TABLE movie_country (
    movie_id INTEGER REFERENCES movie(id) ON DELETE CASCADE,
    country_id INTEGER REFERENCES country(id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, country_id)
);

CREATE TABLE movie_language (
    movie_id INTEGER REFERENCES movie(id) ON DELETE CASCADE,
    language_id INTEGER REFERENCES language(id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, language_id)
);

CREATE TABLE movie_actor (
    movie_id INTEGER REFERENCES movie(id) ON DELETE CASCADE,
    actor_id INTEGER REFERENCES actor(id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, actor_id)
);

CREATE TABLE movie_director (
    movie_id INTEGER REFERENCES movie(id) ON DELETE CASCADE,
    director_id INTEGER REFERENCES director(id) ON DELETE CASCADE,
    PRIMARY KEY (movie_id, director_id)
);
