import bcrypt
from .db_connection import get_db_connection
from psycopg2 import sql

def authenticate_user(login, password):
    conn = get_db_connection()
    cursor = conn.cursor()
    query = sql.SQL("SELECT user_id, role, password, email, login FROM users WHERE login = %s")
    cursor.execute(query, (login,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()
    if user and bcrypt.checkpw(password.encode('utf-8'), user[2].encode('utf-8')):
        return {"user_id": user[0], "role": user[1], "email": user[3], "login": user[4]}  # Возвращаем login
    return None

def register_user(login, email, birth_date, password, role='user'):
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
        INSERT INTO users (login, email, birth_date, password, role)
        VALUES (%s, %s, %s, %s, %s)
    """
    cursor.execute(query, (login, email, birth_date, hashed_password, role))
    conn.commit()
    cursor.close()
    conn.close()
