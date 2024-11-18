-- Insert countries
INSERT INTO country (full_name, short_code) VALUES
('United States', 'US'),
('United Kingdom', 'GB'),
('Canada', 'CA'),
('France', 'FR'),
('Germany', 'DE');

-- Insert genres
INSERT INTO genre (name) VALUES
('Action'),
('Comedy'),
('Drama'),
('Horror'),
('Romance');

-- Insert content ratings
INSERT INTO content_rating (rating) VALUES
('PG'),
('PG-13'),
('R'),
('NC-17');

-- Insert keywords
INSERT INTO keyword (keyword) VALUES
('superhero'),
('love'),
('thriller'),
('adventure'),
('mystery');

-- Insert movies
INSERT INTO movie (tmdb_id, imdb_id, title, plot, content_rating_id, viewers_rating, release_year, akas, watchmode_id)
VALUES
('12345', 'tt0468569', 'The Dark Knight', 'Batman faces off against the Joker, a criminal mastermind who wants to create chaos in Gotham City.', 3, 9.0, 2008, '', '12345'),
('67890', 'tt1375666', 'Inception', 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a CEO.', 2, 8.8, 2010, '', '67890'),
('11223', 'tt0120338', 'Titanic', 'A seventeen-year-old aristocrat falls in love with a kind but poor artist aboard the luxurious, ill-fated R.M.S. Titanic.', 4, 7.8, 1997, '', '11223'),
('44556', 'tt0133093', 'The Matrix', 'A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.', 3, 8.7, 1999, '', '44556'),
('78901', 'tt4154796', 'Avengers: Endgame', 'After the devastating events of Avengers: Infinity War, the Avengers must assemble once again to undo the damage caused by Thanos.', 2, 8.4, 2019, '', '78901');

-- Insert movie genres
INSERT INTO movie_genre (movie_id, genre_id) VALUES
(1, 1),  -- The Dark Knight -> Action
(2, 1),  -- Inception -> Action
(3, 2),  -- Titanic -> Comedy
(4, 1),  -- The Matrix -> Action
(5, 1);  -- Avengers: Endgame -> Action

-- Insert movie actors
INSERT INTO movie_actor (movie_id, actor_id) VALUES
(1, (SELECT id FROM actor WHERE name = 'Christian Bale')),
(1, (SELECT id FROM actor WHERE name = 'Heath Ledger')),
(2, (SELECT id FROM actor WHERE name = 'Leonardo DiCaprio')),
(3, (SELECT id FROM actor WHERE name = 'Kate Winslet')),
(4, (SELECT id FROM actor WHERE name = 'Keanu Reeves')),
(5, (SELECT id FROM actor WHERE name = 'Robert Downey Jr.')),
(5, (SELECT id FROM actor WHERE name = 'Chris Hemsworth'));

-- Insert movie directors
INSERT INTO movie_director (movie_id, director_id) VALUES
(1, (SELECT id FROM director WHERE name = 'Christopher Nolan')),
(2, (SELECT id FROM director WHERE name = 'Christopher Nolan')),
(3, (SELECT id FROM director WHERE name = 'James Cameron')),
(4, (SELECT id FROM director WHERE name = 'The Wachowskis')),
(5, (SELECT id FROM director WHERE name = 'Anthony Russo')),
(5, (SELECT id FROM director WHERE name = 'Joe Russo'));

-- Insert movie languages
INSERT INTO movie_language (movie_id, language_id) VALUES
(1, (SELECT id FROM language WHERE name = 'English')),
(2, (SELECT id FROM language WHERE name = 'English')),
(3, (SELECT id FROM language WHERE name = 'English')),
(4, (SELECT id FROM language WHERE name = 'English')),
(5, (SELECT id FROM language WHERE name = 'English'));

-- Insert movie countries
INSERT INTO movie_country (movie_id, country_id) VALUES
(1, (SELECT id FROM country WHERE full_name = 'United States')),
(2, (SELECT id FROM country WHERE full_name = 'United States')),
(3, (SELECT id FROM country WHERE full_name = 'United States')),
(4, (SELECT id FROM country WHERE full_name = 'United States')),
(5, (SELECT id FROM country WHERE full_name = 'United States'));

-- Insert movie keywords
INSERT INTO movie_keyword (movie_id, keyword_id) VALUES
(1, (SELECT id FROM keyword WHERE keyword = 'superhero')),
(2, (SELECT id FROM keyword WHERE keyword = 'adventure')),
(3, (SELECT id FROM keyword WHERE keyword = 'love')),
(4, (SELECT id FROM keyword WHERE keyword = 'adventure')),
(5, (SELECT id FROM keyword WHERE keyword = 'superhero'));
