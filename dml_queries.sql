INSERT INTO countries (country_name, country_code) VALUES
('United States', 'US'),
('United Kingdom', 'GB'),
('Canada', 'CA'),
('France', 'FR'),
('Germany', 'DE');

INSERT INTO genres (genre_name) VALUES
('Action'),
('Comedy'),
('Drama'),
('Horror'),
('Romance');

INSERT INTO content_ratings (rating_name) VALUES
('PG'),
('PG-13'),
('R'),
('NC-17');

INSERT INTO keywords (keyword) VALUES
('superhero'),
('love'),
('thriller'),
('adventure'),
('mystery');

INSERT INTO movies (title, plot, content_rating_id, viewers_rating, release_year, watchmode_id)
VALUES
('The Dark Knight', 'Batman faces off against the Joker, a criminal mastermind who wants to create chaos in Gotham City.', 3, 9.0, 2008, '12345'),
('Inception', 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a CEO.', 2, 8.8, 2010, '67890'),
('Titanic', 'A seventeen-year-old aristocrat falls in love with a kind but poor artist aboard the luxurious, ill-fated R.M.S. Titanic.', 4, 7.8, 1997, '11223'),
('The Matrix', 'A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.', 3, 8.7, 1999, '44556'),
('Avengers: Endgame', 'After the devastating events of Avengers: Infinity War, the Avengers must assemble once again to undo the damage caused by Thanos.', 2, 8.4, 2019, '78901');

INSERT INTO movie_genres (movie_id, genre_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 1),
(5, 1);

INSERT INTO movie_actors (movie_id, actor_name) VALUES
(1, 'Christian Bale'),
(1, 'Heath Ledger'),
(2, 'Leonardo DiCaprio'),
(3, 'Kate Winslet'),
(4, 'Keanu Reeves'),
(5, 'Robert Downey Jr.'),
(5, 'Chris Hemsworth');

INSERT INTO movie_directors (movie_id, director_name) VALUES
(1, 'Christopher Nolan'),
(2, 'Christopher Nolan'),
(3, 'James Cameron'),
(4, 'The Wachowskis'),
(5, 'Anthony Russo'),
(5, 'Joe Russo');

INSERT INTO movie_languages (movie_id, language) VALUES
(1, 'English'),
(2, 'English'),
(3, 'English'),
(4, 'English'),
(5, 'English');

INSERT INTO movie_countries (movie_id, country_id) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1);

INSERT INTO movie_keywords (movie_id, keyword_id) VALUES
(1, 1),
(2, 4),
(3, 2),
(4, 4),
(5, 1);
