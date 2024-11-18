import http.client
import json
import psycopg2 
from psycopg2 import sql
import random 

# Constants
API_HOST = "imdb.iamidiotareyoutoo.com"
API_ENDPOINT = "/search?q={query}"

# PostgreSQL connection details
DB_CONFIG = {
    "dbname": "moviedb",
    "user": "tina",
    "password": "123",
    "host": "localhost",
    "port": 5432
}

# Function to fetch movie data using http.client
def fetch_movie_data(query):
    # Connect to the API via HTTPS
    conn = http.client.HTTPSConnection("imdb.iamidiotareyoutoo.com")
    
    # Create the request URL with the query parameter
    url = f"/search?q={query}"
    
    # Send the request
    conn.request("GET", url)
    
    # Get the response
    res = conn.getresponse()
    
    # Read and decode the response
    data = res.read()
    
    # Check for valid response
    if res.status != 200:
        print(f"Error fetching data: {res.status}")
        return None
    
    # Convert the response to JSON and return it
    return json.loads(data.decode("utf-8"))

# Function to insert content rating (use placeholder for now)
def insert_content_rating(conn, rating="PG-13"):
    with conn.cursor() as cursor:
        cursor.execute("""
            INSERT INTO content_rating (rating)
            VALUES (%s)
            RETURNING id 
        """, (rating,))
        result = cursor.fetchone()  # Get the ID of the inserted rating
        conn.commit()
        return result[0] 
       

# Function to insert movie data
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
                movie.get("#TMDB_ID", random.randint(1, 100)),
                movie.get("#IMDB_ID"),
                movie.get("#TITLE"),
                movie.get("#PLOT", " "),  # Assuming there's a "#PLOT" key
                content_rating_id,
                None,  # No viewers rating in this response
                movie.get("#YEAR", None),
                movie.get("#AKA", ""),
                None  # No watchmode_id in this response
            ))
            return cursor.fetchone()[0]  # Return movie id
        except Exception as e:
            print(f"Error inserting movie data: {e}")
            return None

# Function to insert actors
def insert_actors(conn, movie_id, actors):
    with conn.cursor() as cursor:
        for actor in actors:
            cursor.execute("""
                INSERT INTO actor (name)
                VALUES (%s)
                ON CONFLICT (name) DO NOTHING
                RETURNING id
            """, (actor.strip(),))
            actor_id = cursor.fetchone()[0]
            cursor.execute("""
                INSERT INTO movie_actor (movie_id, actor_id)
                VALUES (%s, %s)
            """, (movie_id, actor_id))

# Main script to process movies from API response
def process_movies(query):
    conn = psycopg2.connect(**DB_CONFIG)
    conn.autocommit = False  # Use transaction for bulk operationss
    data = fetch_movie_data(query)

    try:
        # Fetch movie data from API using http.client

        # Check if data is valid
        if not data:
            print("No valid data fetched from the API.")
            return
        
        if not data.get("description") or not isinstance(data["description"], list):
            print("No valid movie descriptions found in API response.")
            return

        # Debug print to check the data structure
        print(json.dumps(data, indent=2))

        # Process the data if response is valid
        if data.get("ok"):
            descriptions = data.get("description", [])
            if not descriptions:
                print("No movie descriptions found.")
                return

            for movie in descriptions:
                try:
                    # Insert content rating
                    content_rating_id = insert_content_rating(conn)
                    if not content_rating_id:
                        raise ValueError("Failed to insert content rating.")

                    # Insert movie data
                    movie_id = insert_movie_data(conn, movie, content_rating_id)
                    if not movie_id:
                        print(f"Skipping movie due to insert failure: {movie.get('#TITLE', 'Unknown')}")
                        continue

                    # Insert actors
                    actors = movie.get("#ACTORS", " ").split(",") if "#ACTORS" in movie else []
                    insert_actors(conn, movie_id, actors)

                except Exception as e:
                    print(f"Error processing movie: {movie.get('#TITLE', 'Unknown')}. Error: {e}")
                    conn.rollback()
                    continue  
            # Commit after all movies are processed
            conn.commit()
            print("Data successfully committed.")
        else:
            print("No valid data found.")
    except Exception as e:
        print(f"Error: {e}")
        conn.rollback()
    finally:
        conn.close()

# Main function
def main():
    query = input("Enter search query: ")
    process_movies(query)

if __name__ == "__main__":
    main()

