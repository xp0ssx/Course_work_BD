from .db_connection import get_db_connection

def get_average_score(game_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
        SELECT AVG(score)
        FROM reviews
        WHERE game_id = %s
    """
    cursor.execute(query, (game_id,))
    avg_score = cursor.fetchone()[0]
    cursor.close()
    conn.close()
    return avg_score if avg_score is not None else 0
