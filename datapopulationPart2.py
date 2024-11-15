import http.client
import json
import psycopg2
from psycopg2 import sql

# Constants
API_HOST = "imdb.iamidiotareyoutoo.com"
API_ENDPOINT = "/search"

# PostgreSQL connection details
DB_CONFIG = {
    "dbname": "moviedb",
    "user": "tina",
    "password": "123",
    "host": "localhost",
    "port": 5432
}

# Function to insert data into the database
def insert_movie_data(conn, movie_data):
    with conn.cursor() as cursor:
        # Insert into movie table
        cursor.execute("""
            INSERT INTO movie (
                tmdb_id, imdb_id, title, plot, content_rating_id, viewers_rating, release_year, akas, watchmode_id
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """, (
            None,  # No TMDB ID provided in this example
            movie_data.get("#IMDB_ID"),
            movie_data.get("#TITLE"),
            None,  # Plot is not provided in this example
            None,  # Content rating is not directly mapped in this example
            None,  # Viewers rating is not directly mapped in this example
            movie_data.get("#YEAR"),
            movie_data.get("#AKA"),
            None   # Watchmode ID is not provided in this example
        ))
        movie_id = cursor.fetchone()[0]

        # Insert actors
        actors = movie_data.get("#ACTORS", "").split(", ")
        for actor in actors:
            cursor.execute("""
                INSERT INTO actor (name)
                VALUES (%s)
                ON CONFLICT (name) DO NOTHING
                RETURNING id
            """, (actor,))
            actor_id = cursor.fetchone()[0]

            cursor.execute("""
                INSERT INTO movie_actor (movie_id, actor_id)
                VALUES (%s, %s)
            """, (movie_id, actor_id))

# Fetch data from the API
def fetch_movies():
    conn = http.client.HTTPSConnection(API_HOST)
    conn.request("GET", API_ENDPOINT)
    res = conn.getresponse()
    data = res.read()
    return json.loads(data.decode("utf-8"))

# Main script
def main():
    try:
        # Connect to PostgreSQL
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = False  # Use transactions

        # Fetch movie data from the API
        api_response = fetch_movies()
        if api_response.get("ok"):
            movies = api_response.get("description", [])
            for movie in movies:
                insert_movie_data(conn, movie)
        else:
            print(f"API Error: {api_response.get('error_code')}")

        conn.commit()  # Commit all changes
    except Exception as e:
        print(f"An error occurred: {e}")
        if conn:
            conn.rollback()  # Rollback if something fails
    finally:
        if conn:
            conn.close()

if __name__ == "__main__":
    main()
