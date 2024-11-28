import http.client
import json
import psycopg2 
from psycopg2 import sql
import random 

API_HOST = "imdb.iamidiotareyoutoo.com"
API_ENDPOINT = "/search?q={query}"

DB_CONFIG = {
    "dbname": "moviedb",
    "user": "tina",
    "password": "123",
    "host": "localhost",
    "port": 5432
}

def fetch_movie_data(query):
    conn = http.client.HTTPSConnection("imdb.iamidiotareyoutoo.com")
    url = f"/search?q={query}"
    conn.request("GET", url)
    res = conn.getresponse()
    data = res.read()
    if res.status != 200:
        print(f"Error fetching data: {res.status}")
        return None
    return json.loads(data.decode("utf-8"))

def insert_content_rating(conn, rating="PG-13"):
    with conn.cursor() as cursor:
        cursor.execute("""
            INSERT INTO content_rating (rating)
            VALUES (%s)
            RETURNING id 
        """, (rating,))
        result = cursor.fetchone()
        conn.commit()
        return result[0] 

def insert_movie_data(conn, movie, content_rating_id):
    with conn.cursor() as cursor:
        try:
            cursor.execute("""
                INSERT INTO movie (
                    tmdb_id, imdb_id, title, plot, content_rating_id, viewers_rating, 
                    release_year, akas, watchmode_id
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
            """, (
                movie.get("#TMDB_ID", random.randint(5000, 10000)),
                movie.get("#IMDB_ID"),
                movie.get("#TITLE"),
                movie.get("#PLOT", " "),
                content_rating_id,
                None,
                movie.get("#YEAR", None),
                movie.get("#AKA", ""),
                None
            ))
            return cursor.fetchone()[0]
        except Exception as e:
            print(f"Error inserting movie data: {e}")
            return None

def insert_actors(conn, movie_id, actors):
    with conn.cursor() as cursor:
        for actor in actors:
            actor_name = actor.strip()
            # Check if the actor already exists
            cursor.execute("""
                SELECT id FROM actor WHERE name = %s
            """, (actor_name,))
            actor_id = cursor.fetchone()

            if actor_id is None:
                # If the actor does not exist, insert it
                cursor.execute("""
                    INSERT INTO actor (name)
                    VALUES (%s)
                    RETURNING id
                """, (actor_name,))
                actor_id = cursor.fetchone()[0]
            else:
                actor_id = actor_id[0]  # Get the existing actor's ID

            # Insert the movie-actor relationship
            cursor.execute("""
                INSERT INTO movie_actor (movie_id, actor_id)
                VALUES (%s, %s)
            """, (movie_id, actor_id))

def process_movies(query):
    conn = psycopg2.connect(**DB_CONFIG)
    conn.autocommit = False  
    data = fetch_movie_data(query)

    try:
        if not data:
            print("No valid data fetched from the API.")
            return
        
        if not data.get("description") or not isinstance(data["description"], list):
            print("No valid movie descriptions found in API response.")
            return

        print(json.dumps(data, indent=2))

        if data.get("ok"):
            descriptions = data.get("description", [])
            if not descriptions:
                print("No movie descriptions found.")
                return

            for movie in descriptions:
                try:
                    content_rating_id = insert_content_rating(conn)
                    if not content_rating_id:
                        raise ValueError("Failed to insert content rating.")

                    movie_id = insert_movie_data(conn, movie, content_rating_id)
                    if not movie_id:
                        print(f"Skipping movie due to insert failure: {movie.get('#TITLE', 'Unknown')}")
                        continue

                    actors = movie.get("#ACTORS", " ").split(",") if "#ACTORS" in movie else []
                    insert_actors(conn, movie_id, actors)

                except Exception as e:
                    print(f"Error processing movie: {movie.get('#TITLE', 'Unknown')}. Error: {e}")
                    conn.rollback()
                    continue  
            conn.commit()
            print("Data successfully committed.")
        else:
            print("No valid data found.")
    except Exception as e:
        print(f"Error: {e}")
        conn.rollback()
    finally:
        conn.close()

def main():
    query = input("Enter search query: ")
    process_movies(query)

if __name__ == "__main__":
    main()