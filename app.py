import streamlit as st
from db.game_operations import get_games, add_game_with_developer_and_tags
from db.review_operations import get_reviews, add_review, delete_review
from db.commentary_operations import get_comments, add_commentary, delete_comment
from db.user_operations import authenticate_user, register_user
from db.utils import get_average_score

# Функция для отображения секции регистрации
def show_registration_section():
    st.header("Регистрация")
    login = st.text_input("Логин", key="register_login")
    email = st.text_input("Email", key="register_email")
    birth_date = st.date_input("Дата рождения", key="register_birth_date")
    password = st.text_input("Пароль", type="password", key="register_password")
    confirm_password = st.text_input("Подтвердите пароль", type="password", key="register_confirm_password")
    
    if st.button("Зарегистрироваться", key="register_button"):
        if password != confirm_password:
            st.error("Пароли не совпадают!")
        else:
            try:
                register_user(login, email, birth_date, password)
                st.success("Регистрация прошла успешно! Теперь вы можете войти.")
            except Exception as e:
                st.error(f"Ошибка регистрации: {e}")

# Функция для отображения секции авторизации
def show_authentication_section():
    st.header("Авторизация")
    login = st.text_input("Логин", key="auth_login")
    password = st.text_input("Пароль", type="password", key="auth_password")
    
    if st.button("Войти", key="auth_button"):
        user_data = authenticate_user(login, password)
        if user_data:
            st.session_state.user_id = user_data["user_id"]
            st.session_state.role = user_data["role"]
            st.session_state.email = user_data["email"]
            st.session_state.login = user_data["login"]  # Сохраняем логин
            st.success("Успешная авторизация!")

            # Отладочный вывод для проверки данных в сессии
            st.write(f"User ID: {st.session_state.user_id}")
            st.write(f"Role: {st.session_state.role}")
            st.write(f"Email: {st.session_state.email}")
            st.write(f"Login: {st.session_state.login}")  # Выводим логин
        else:
            st.error("Неверный логин или пароль.")

# Функция для отображения секции поиска игр и обзоров
def show_search_and_reviews_section(user_id):
    st.header("Поиск игр")
    search_query = st.text_input("Введите название игры для поиска", key="search_query")
    
    if search_query:
        games = get_games(search_query)
    else:
        games = get_games()
    
    if games:
        game_names = [game[1] for game in games]
        selected_game = st.selectbox("Выберите игру", game_names, key="selected_game")
        
        if selected_game:
            game_id = next(game[0] for game in games if game[1] == selected_game)
            st.subheader(f"Обзоры на {selected_game}")
            
            # Получаем среднюю оценку для выбранной игры
            avg_score = get_average_score(game_id)
            
            # Стильная визуализация средней оценки
            st.markdown(f"""
                <div style="font-size: 20px; color: #ff6f61; font-weight: bold; padding-bottom: 10px;">
                    Средняя оценка: <span style="font-size: 24px; color: #ffbc00;">{avg_score:.1f}/10</span>
                </div>
            """, unsafe_allow_html=True)

            # Обзоры на выбранную игру
            reviews = get_reviews(game_id)
            if reviews:
                for review in reviews:
                    review_id, reviewer_id, reviewer_login, score, text = review
                    
                    # Стильное отображение авторов и оценок
                    st.markdown(f"""
                        <div style="background-color: #222024; padding: 10px; border-radius: 5px; margin-bottom: 10px;">
                            <strong style="font-size: 18px;">Автор:</strong> <em>{reviewer_login}</em> <br>
                            <strong>Оценка:</strong> {score}/10
                        </div>
                    """, unsafe_allow_html=True)

                    st.text_area(f"Отзыв: {reviewer_login}", value=text, height=200, max_chars=2000, key=f"review_{review_id}", disabled=True)
                    
                    if st.session_state.role == "admin":
                        delete_review_key = f"delete_review_{review_id}"
                        if st.button("Удалить обзор", key=delete_review_key):
                            try:
                                delete_review(review_id)
                                st.success("Обзор удалён!")
                            except Exception as e:
                                st.error(f"Ошибка удаления обзора: {e}")
                    
                    # Комментарии к обзору
                    comments = get_comments(review_id)
                    if comments:
                        st.markdown("### Комментарии:", unsafe_allow_html=True)
                        for comment in comments:
                            comment_user_id, comment_login, comment_text, comment_created_at = comment
                            
                            # Отображение комментариев
                            st.markdown(f"""
                                <div style="background-color: #e7e7e7; padding: 8px; margin-bottom: 5px; border-radius: 5px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);">
                                    <strong style="color: #333333;">{comment_login}</strong>
                                    <span style="color: #555555;">({comment_created_at})</span> <br>
                                    <span style="color: #555555;">{comment_text}</span>
                                </div>
                            """, unsafe_allow_html=True)
                            
                            if st.session_state.role == "admin":
                                delete_key = f"delete_comment_{comment_created_at}"
                                if st.button("Удалить комментарий", key=delete_key):
                                    try:
                                        delete_comment(comment_created_at, comment_text)
                                        st.success("Комментарий удалён!")
                                    except Exception as e:
                                        st.error(f"Ошибка удаления комментария: {e}")
                    # Поле для комментария
                    comment_key = f"comment_{review_id}"
                    comment_text = st.text_area("Ваш комментарий", key=comment_key)

                    # Кнопка для добавления комментария
                    add_comment_key = f"add_comment_{review_id}"
                    if st.button("Добавить комментарий", key=add_comment_key):
                        if comment_text.strip() == "":
                            st.warning("Комментарий не может быть пустым.")
                        else:
                            add_commentary(user_id, comment_text, review_id)
                            st.success("Комментарий добавлен!")
            else:
                st.info("Нет обзоров для этой игры.")
            
            # Форма для добавления нового обзора
            st.subheader("Добавить отзыв на игру")
            score = st.slider("Оценка игры (от 1 до 10)", 1, 10, 5, key="review_score")
            review_text = st.text_area("Ваш отзыв", key="review_text")
            
            if st.button("Отправить отзыв", key="add_review_button"):
                if not review_text.strip():
                    st.warning("Отзыв не может быть пустым.")
                else:
                    try:
                        add_review(user_id, game_id, score, review_text)
                        st.success("Ваш отзыв успешно добавлен!")
                    except Exception as e:
                        if "Нельзя использовать запрещённые слова" in str(e):
                            st.error("Ваш отзыв содержит запрещённые слова. Пожалуйста, измените текст.")
                        else:
                            st.error(f"Произошла ошибка: {str(e)}")
    else:
        st.info("Игры не найдены.")


# Функция для отображения секции добавления новой игры (только для админа)
def show_admin_section():
    st.title("Добавление новой игры")

    # Данные об игре
    game_name = st.text_input("Название игры", key="game_name")
    developer_name = st.text_input("Имя разработчика", key="developer_name")
    country = st.text_input("Страна разработчика", key="developer_country")
    year_of_foundation = st.date_input("Год основания разработчика", key="developer_year")
    year_of_release = st.date_input("Год выпуска игры", key="game_year")

    # Теги через запятую
    tags_input = st.text_input("Теги (через запятую)", key="tags")
    tags = [tag.strip() for tag in tags_input.split(",")]

    # Кнопка добавления
    if st.button("Добавить игру"):
        if not all([game_name, developer_name, country, year_of_foundation, year_of_release, tags]):
            st.error("Все поля должны быть заполнены.")
        else:
            try:
                add_game_with_developer_and_tags(
                    game_name=game_name,
                    developer_name=developer_name,
                    country=country,
                    year_of_foundation=year_of_foundation,
                    year_of_release=year_of_release,
                    tags=tags,
                )
                st.success("Игра успешно добавлена!")
            except Exception as e:
                st.error(f"Ошибка при добавлении игры: {e}")

# Основной интерфейс приложения
def main():
    # Инициализация состояния пользователя
    if "user_id" not in st.session_state:
        st.session_state.user_id = None
        st.session_state.role = None
        st.session_state.email = None
        st.session_state.login = None  # Инициализируем login, если он не существует
    
    if st.session_state.user_id:
        # Отображение информации о пользователе в боковой панели
        st.sidebar.header("Профиль")
        st.sidebar.write(f"**ID:** {st.session_state.user_id}")
        st.sidebar.write(f"**Роль:** {st.session_state.role.capitalize()}")
        st.sidebar.write(f"**Email:** {st.session_state.email}")  # Отображаем email
        st.sidebar.write(f"**Логин:** {st.session_state.login}")  # Отображаем логин

        # Кнопка для выхода
        if st.sidebar.button("Выйти", key="logout_button"):
            st.session_state.user_id = None
            st.session_state.role = None
            st.session_state.email = None  # Очищаем email при выходе
            st.session_state.login = None  # Очищаем логин при выходе
            st.success("Вы вышли из системы.")
        
        # Если пользователь админ, показываем секцию для добавления игр
        if st.session_state.role == "admin":
            show_admin_section()
        
        # Отображение секции поиска и обзоров
        show_search_and_reviews_section(st.session_state.user_id)
    else:
        # Выбор между авторизацией и регистрацией с помощью вкладок
        tab1, tab2 = st.tabs(["Авторизация", "Регистрация"])
        
        with tab1:
            show_authentication_section()
        
        with tab2:
            show_registration_section()

if __name__ == "__main__":
    main()
