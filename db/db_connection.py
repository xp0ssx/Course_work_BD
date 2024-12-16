import psycopg2

def get_db_connection():
    connection = psycopg2.connect(
        host="*",  # Адрес твоей БД
        database="dbcw",  # Имя базы данных
        user="xpossx",  # Имя пользователя
        password="keyveybey"  # Пароль
    )
    return connection
