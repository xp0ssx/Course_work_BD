from .db_connection import get_db_connection

def get_comments(review_id):
    query = """
    SELECT c.user_id, u.login, c.text, c.created_at
    FROM commentaries c
    JOIN users u ON c.user_id = u.user_id
    WHERE c.review_id = %s
    ORDER BY c.created_at ASC;
    """
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(query, (review_id,))
    comments = cursor.fetchall()
    cursor.close()
    conn.close()
    return comments

def add_commentary(user_id, text, review_id):
    if not review_id:
        raise ValueError("Комментарий должен быть связан с существующим отзывом (review_id).")
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
        INSERT INTO commentaries (user_id, text, review_id)
        VALUES (%s, %s, %s)
    """
    cursor.execute(query, (user_id, text, review_id))
    conn.commit()
    cursor.close()
    conn.close()

def delete_comment(created_at, text):
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
        DELETE FROM commentaries
        WHERE created_at = %s AND text = %s
    """
    cursor.execute(query, (created_at, text))
    conn.commit()
    cursor.close()
    conn.close()
