# Отчет по реализации Redis в проекте

## 1. Выделение данных для быстрого доступа

### 1.1 Токены авторизации
В проекте реализовано хранение токенов авторизации в Redis для быстрого доступа и автоматического управления временем жизни. 

Пример структуры:
```
token:{token_id} -> { user_data }
session:{session_id} -> { session_data }
user_sessions:{user_id} -> [session_ids]
```

Реальный пример из системы:
```bash
$ redis-cli KEYS "session:*"
1) "session:7ea2e7af-43c0-40a5-8cc5-d20a48f4ec94"
2) "session:73dc510f-f137-4ab4-a2d3-fe33be195158"
```

### 1.2 Сессионные данные
Реализовано хранение сессий пользователей с привязкой к их ID для быстрого доступа и управления множественными сессиями.

Пример активных сессий пользователя:
```bash
$ redis-cli SMEMBERS "user_sessions:1"
# Возвращает список активных сессий администратора
```

### 1.3 Часто запрашиваемые данные
Реализовано кеширование:
- Популярных игр
- Рейтингов игр
- Последних обзоров

Структура хранения и реальные примеры:
```bash
# Данные игры
$ redis-cli GET game:4
"{\"id\": 4, \"name\": \"Doom\", \"review_count\": 1, \"rating\": 10.0}"

# Последние обзоры
$ redis-cli LRANGE game:4:recent_reviews 0 -1
1) "{\"review_id\": 1, \"user_login\": \"Xpossx\", \"score\": 10, \"text\": \"RIP AND TEAR\", \"created_at\": \"2025-05-23 01:22:36\"}"

# Рейтинг в списке популярных игр
$ redis-cli ZSCORE popular_games 4
"110"
```

### 1.4 Данные для мгновенного обновления
Реализована система уведомлений через Redis PubSub для следующих событий:
- Регистрация новых пользователей
- Авторизация пользователей
- Добавление новых игр

Пример уведомления об авторизации:
```json
{
    "user_id": 2,
    "login": "Vlad",
    "email": "vlad@example.com",
    "role": "user",
    "login_time": "2025-05-23 01:11:22"
}
```

## 2. Реализация хранения токенов авторизации

### 2.1 Настройка TTL
Время жизни токенов настраивается через константы в конфигурации:
```python
TOKEN_TTL = 3600  # Время жизни токена (1 час)
SESSION_TTL = 86400  # Время жизни сессии (24 часа)
CACHE_TTL = 3600  # Время жизни кеша (1 час)
```

### 2.2 Автоматическое удаление
Redis автоматически удаляет просроченные токены и сессии благодаря установленному TTL. 

Пример проверки TTL:
```bash
$ redis-cli TTL "session:7ea2e7af-43c0-40a5-8cc5-d20a48f4ec94"
# Возвращает оставшееся время жизни в секундах
```

## 3. Структуры данных Redis

### 3.1 Строки (Strings)
Используются для хранения:
- Токенов авторизации
- Данных отдельных игр
- Рейтингов

Реальный пример данных игры:
```bash
$ redis-cli GET game:4
"{\"id\": 4, \"name\": \"Doom\", \"review_count\": 1, \"rating\": 10.0}"
```

### 3.2 Списки (Lists)
Используются для хранения:
- Последних обзоров
- Комментариев

Реальный пример обзоров:
```bash
$ redis-cli LRANGE game:4:recent_reviews 0 -1
1) "{\"review_id\": 1, \"user_login\": \"Xpossx\", \"score\": 10, \"text\": \"RIP AND TEAR\", \"created_at\": \"2025-05-23 01:22:36\"}"
```

### 3.3 Сортированные множества (Sorted Sets)
Используются для:
- Рейтинга популярных игр
- Сортировки по количеству обзоров

Реальный пример рейтинга:
```bash
$ redis-cli ZREVRANGE popular_games 0 -1 WITHSCORES
1) "4"
2) "110"
# Игра Doom имеет наивысший рейтинг 110 (1 обзор * 100 + 10.0 рейтинг)
```

## 4. Система оповещений (PubSub)

### 4.1 Реализованные каналы
- `new_game` - уведомления о новых играх
- `new_user` - уведомления о регистрации пользователей
- `user_login` - уведомления об авторизации

### 4.2 Пример работы
```python
# Публикация события
RedisPubSub.publish_event("user_login", {
    "user_id": 2,
    "login": "Vlad",
    "email": "vlad@example.com",
    "role": "user",
    "login_time": "2025-05-23 01:11:22"
})

# Подписка на события
pubsub = RedisPubSub.get_pubsub()
pubsub.subscribe("new_game", "new_user", "user_login")
```

## 5. Объяснение работы системы

### 5.1 Кеширование игр
1. При первом запросе данные берутся из PostgreSQL
2. Сохраняются в Redis с соответствующей структурой:
```python
# Пример кеширования игры
game_data = {
    'id': game[0],
    'name': game[1],
    'review_count': game[2],
    'rating': float(game[3])
}
RedisCache.cache_popular_games([game_data])
```

### 5.2 Система рейтингов
1. Рейтинг рассчитывается на основе обзоров
2. Сохраняется в Redis для быстрого доступа
3. Обновляется при добавлении/удалении обзоров
4. Используется формула: `score = review_count * 100 + rating`

Пример из системы:
```bash
$ redis-cli ZSCORE popular_games 4
"110"  # 1 обзор * 100 + 10.0 рейтинг
```

### 5.3 Обработка обзоров
1. Новые обзоры сохраняются в PostgreSQL
2. Кеш обзоров инвалидируется
3. При следующем запросе кеш обновляется:
```python
reviews_data = [
    {
        'review_id': review[0],
        'user_login': review[2],
        'score': review[3],
        'text': review[4],
        'created_at': datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    for review in reviews
]
RedisCache.add_recent_reviews(game_id, reviews_data)
```

### 5.4 Уведомления
1. События публикуются через Redis PubSub
2. Клиенты подписываются на каналы
3. Уведомления доставляются в реальном времени
4. Поддерживается масштабирование

Пример работы уведомлений:
```python
# Публикация
RedisPubSub.publish_event("new_game", {
    "game_id": game_id,
    "name": game_name,
    "developer": developer_name
})

# Получение
message = RedisPubSub.get_message()
if message and message['type'] == 'message':
    print(f"Новое уведомление: {message['data']}") 