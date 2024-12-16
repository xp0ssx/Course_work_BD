from .db_connection import get_db_connection
from psycopg2 import errors
import streamlit as st

def get_reviews(game_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
        SELECT r.id, r.user_id, u.login, r.score, r.text
        FROM reviews r
        JOIN users u ON r.user_id = u.user_id
        WHERE r.game_id = %s
    """
    cursor.execute(query, (game_id,))
    reviews = cursor.fetchall()
    cursor.close()
    conn.close()
    return reviews

def add_review(user_id, game_id, score, text):
    """
    Добавляет отзыв в базу данных. Обрабатывает ошибки, связанные с запрещёнными словами.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = """
            INSERT INTO reviews (user_id, game_id, score, text)
            VALUES (%s, %s, %s, %s)
        """
        cursor.execute(query, (user_id, game_id, score, text))
        conn.commit()
    finally:
        # Гарантированно закрываем соединение и курсор
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()

def delete_review(review_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM commentaries WHERE review_id = %s", (review_id,))
    cursor.execute("DELETE FROM reviews WHERE id = %s", (review_id,))
    conn.commit()
    cursor.close()
    conn.close()
