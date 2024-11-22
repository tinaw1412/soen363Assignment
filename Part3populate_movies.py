import psycopg2
import requests

DB_HOST = "localhost"
DB_NAME = "moviedb"
DB_USER = "tina"
DB_PASS = "123"

#API_KEY = "your_api_key"
url = "https://api.themoviedb.org/3/search/movie?query={query}&page=1"

headers = {
    "accept": "application/json",
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5N2UzMmRhZWYwZDAxNTU5ZmJiODM5MDhkMGI3ZDAxOCIsIm5iZiI6MTczMjI0MDM4My4xODcyNjgzLCJzdWIiOiI2NzNmZTJiZjMyYTlhYWY0M2Q5NjcwODkiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.ZeB4kOPhSLmv294gVX1wArXo95jIh0trbk_KpxJwVuw"
}

response = requests.get(url, headers=headers)

print(response.text)
conn = psycopg2.connect(
    host=DB_HOST,
    database=DB_NAME,
    user=DB_USER,
    password=DB_PASS
)
cur = conn.cursor()

def fetch_movie_data(movie_id):
    """Fetch movie data from TMDB API."""
    url = f"{BASE_URL}{movie_id}?api_key={API_KEY}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Failed to fetch data for movie ID {movie_id}")
        return None

def insert_movie_data(movie_data):
    """Insert fetched movie data into the database."""
    try:
        content_rating = movie_data.get("adult")  
        cur.execute("""
            INSERT INTO content_rating (rating) 
            VALUES (%s) 
            ON CONFLICT (rating) DO NOTHING 
            RETURNING id
        """, (content_rating,))
        content_rating_id = cur.fetchone()[0]

        cur.execute("""
            INSERT INTO movie (tmdb_id, imdb_id, title, plot, content_rating_id, viewers_rating, release_year, watchmode_id) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """, (
            movie_data.get("id"),
            movie_data.get("imdb_id"),
            movie_data.get("title"),
            movie_data.get("overview"),
            content_rating_id,
            movie_data.get("vote_average"),
            movie_data.get("release_date").split("-")[0],
            movie_data.get("watchmode_id")
        ))
        movie_id = cur.fetchone()[0]

        genres = movie_data.get("genres", [])
        for genre in genres:
            cur.execute("""
                INSERT INTO movie_genre (movie_id, genre_id)
                VALUES (%s, %s)
            """, (movie_id, genre["id"]))

        countries = movie_data.get("production_countries", [])
        for country in countries:
            cur.execute("""
                INSERT INTO movie_country (movie_id, country_id)
                VALUES (%s, %s)
            """, (movie_id, country["iso_3166_1"]))

        languages = movie_data.get("spoken_languages", [])
        for language in languages:
            cur.execute("""
                INSERT INTO movie_language (movie_id, language_id)
                VALUES (%s, %s)
            """, (movie_id, language["iso_639_1"]))

        keywords_response = requests.get(f"{BASE_URL}{movie_data.get('id')}/keywords?api_key={API_KEY}")
        if keywords_response.status_code == 200:
            keywords_data = keywords_response.json()
            for keyword in keywords_data.get("keywords", []):
                cur.execute("""
                    INSERT INTO movie_keyword (movie_id, keyword_id)
                    VALUES (%s, %s)
                """, (movie_id, keyword["id"]))

        conn.commit()
        print(f"Inserted data for movie: {movie_data.get('title')}")
    except Exception as e:
        conn.rollback()
        print(f"Failed to insert movie data: {e}")

for movie_id in range(1, 51):
    movie_data = fetch_movie_data(movie_id)
    if movie_data:
        insert_movie_data(movie_data)

cur.close()
conn.close()
