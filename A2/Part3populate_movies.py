import requests
import psycopg2
import json

# Database configuration
DB_CONFIG = {
    "host": "localhost",
    "dbname": "moviedb",
    "user": "tina",
    "password": "123",
    "port": 5432
}

# TMDB API configuration
API_KEY = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5N2UzMmRhZWYwZDAxNTU5ZmJiODM5MDhkMGI3ZDAxOCIsIm5iZiI6MTczMjI0MDM4My4xODcyNjgzLCJzdWIiOiI2NzNmZTJiZjMyYTlhYWY0M2Q5NjcwODkiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.ZeB4kOPhSLmv294gVX1wArXo95jIh0trbk_KpxJwVuw"
API_URL = "https://api.themoviedb.org/3/search/movie"

# Database connection setup
conn = psycopg2.connect(**DB_CONFIG)
cur = conn.cursor()

# Fetch movie data from TMDB API
def fetch_movie_data(query):
    try:
        url = f"{API_URL}?query={query}&page=1"
        headers = {
            "accept": "application/json",
            "Authorization": f"Bearer {API_KEY}"
        }
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            return response.json().get("results", [])
        else:
            print(f"Error fetching data: {response.status_code}")
            return []
    except Exception as e:
        print(f"Exception during API call: {e}")
        return []

# Helper function to insert data into a table
def get_or_create(table, field, value):
    try:
        cur.execute(f"SELECT id FROM {table} WHERE {field} = %s", (value,))
        result = cur.fetchone()
        if result:
            return result[0]
        else:
            cur.execute(f"INSERT INTO {table} ({field}) VALUES (%s) RETURNING id", (value,))
            conn.commit()
            return cur.fetchone()[0]
    except Exception as e:
        conn.rollback()
        print(f"Error in get_or_create for {table}: {e}")
        return None

# Insert movie data into the database
def insert_movie_data(movie):
    try:
        # Insert content rating if available
        content_rating_id = None
        if "content_rating" in movie:
            content_rating_id = get_or_create("content_rating", "rating", movie["content_rating"])

        # Insert main movie data
        cur.execute("""
            INSERT INTO movie (tmdb_id, title, plot, viewers_rating, release_year, content_rating_id, akas, watchmode_id)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """, (
            movie["id"],
            movie["title"],
            movie.get("overview", ""),
            movie.get("vote_average", 0),
            movie.get("release_date", "1900-01-01").split("-")[0],
            content_rating_id,
            movie.get("aka", ""),
            movie.get("watchmode_id", "")
        ))
        movie_id = cur.fetchone()[0]        

        # Insert additional fields like actors, directors, countries, etc.
        for actor in movie.get("actors", []):
            actor_id = get_or_create("actor", "name", actor)
            cur.execute("INSERT INTO movie_actor (movie_id, actor_id) VALUES (%s, %s) ON CONFLICT DO NOTHING", (movie_id, actor_id))

        for director in movie.get("directors", []):
            director_id = get_or_create("director", "name", director)
            cur.execute("INSERT INTO movie_director (movie_id, director_id) VALUES (%s, %s) ON CONFLICT DO NOTHING", (movie_id, director_id))

        for keyword in movie.get("keywords", []):
            keyword_id = get_or_create("keyword", "keyword", keyword)
            cur.execute("INSERT INTO movie_keyword (movie_id, keyword_id) VALUES (%s, %s) ON CONFLICT DO NOTHING", (movie_id, keyword_id))

        conn.commit()
        print(f"Inserted movie: {movie['title']} with ID: {movie_id}")
    except Exception as e:
        conn.rollback()
        print(f"Error inserting movie data: {e}")

# Main processing function
def process_movies(query):
    movies = fetch_movie_data(query)
    if not movies:
        print("No movies found for the query.")
        return
    for movie in movies:
        insert_movie_data(movie)

# Main function
def main():
    query = input("Enter a movie search query: ")
    process_movies(query)
    cur.close()
    conn.close()

if __name__ == "__main__":
    main()

