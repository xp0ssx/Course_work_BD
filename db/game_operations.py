from .db_connection import get_db_connection
from psycopg2 import sql

def get_games(search_query=None):
    conn = get_db_connection()
    cursor = conn.cursor()
    if search_query:
        query = "SELECT game_id, name FROM games WHERE name ILIKE %s"
        cursor.execute(query, ('%' + search_query + '%',))
    else:
        query = "SELECT game_id, name FROM games"
        cursor.execute(query)
    games = cursor.fetchall()
    cursor.close()
    conn.close()
    return games

def add_game_with_developer_and_tags(game_name, developer_name, country, year_of_foundation, year_of_release, tags):
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT id FROM developers WHERE name = %s", (developer_name,))
    developer_id = cursor.fetchone()

    if not developer_id:
        cursor.execute("""
            INSERT INTO developers (name, country, year_of_foundation)
            VALUES (%s, %s, %s)
            RETURNING id;
        """, (developer_name, country, year_of_foundation))
        developer_id = cursor.fetchone()[0]
    else:
        developer_id = developer_id[0]  # Используем существующий id

    cursor.execute("""
        INSERT INTO games (name, developer_id, year_of_release)
        VALUES (%s, %s, %s)
        RETURNING game_id;
    """, (game_name, developer_id, year_of_release))
    
    game_id = cursor.fetchone()[0]

    for tag in tags:
        cursor.execute("SELECT id FROM tags WHERE name = %s", (tag,))
        tag_id = cursor.fetchone()
        
        if not tag_id:
            cursor.execute("INSERT INTO tags (name) VALUES (%s) RETURNING id;", (tag,))
            tag_id = cursor.fetchone()[0]
        else:
            tag_id = tag_id[0]

        cursor.execute("INSERT INTO game_to_tag (game_id, tag_id) VALUES (%s, %s);", (game_id, tag_id))

    conn.commit()
    cursor.close()
    conn.close()
