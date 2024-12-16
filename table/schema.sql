--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2 (Ubuntu 17.2-1.pgdg24.04+1)
-- Dumped by pg_dump version 17.2 (Ubuntu 17.2-1.pgdg24.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: check_review_content(); Type: FUNCTION; Schema: public; Owner: xpossx
--

CREATE FUNCTION public.check_review_content() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    forbidden_words TEXT[] := ARRAY['грубое слово', 'запрещённое слово'];
    word TEXT;
BEGIN
    FOR i IN 1..array_length(forbidden_words, 1) LOOP
        word := forbidden_words[i];
        IF NEW.text ILIKE '%' || word || '%' THEN
            -- Выводим понятное сообщение
            RAISE NOTICE 'Ваш отзыв содержит запрещённые слова: %', word;
            -- Запрещаем вставку отзыва
            RAISE EXCEPTION 'Нельзя использовать запрещённые слова в отзыве.';
        END IF;
    END LOOP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_review_content() OWNER TO xpossx;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: commentaries; Type: TABLE; Schema: public; Owner: xpossx
--

CREATE TABLE public.commentaries (
    id integer NOT NULL,
    user_id integer NOT NULL,
    text text NOT NULL,
    review_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.commentaries OWNER TO xpossx;

--
-- Name: commentaries_commentary_id_seq; Type: SEQUENCE; Schema: public; Owner: xpossx
--

CREATE SEQUENCE public.commentaries_commentary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commentaries_commentary_id_seq OWNER TO xpossx;

--
-- Name: commentaries_id_seq; Type: SEQUENCE; Schema: public; Owner: xpossx
--

CREATE SEQUENCE public.commentaries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commentaries_id_seq OWNER TO xpossx;

--
-- Name: commentaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: xpossx
--

ALTER SEQUENCE public.commentaries_id_seq OWNED BY public.commentaries.id;


--
-- Name: developers; Type: TABLE; Schema: public; Owner: xpossx
--

CREATE TABLE public.developers (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    country character varying(255) NOT NULL,
    year_of_foundation timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.developers OWNER TO xpossx;

--
-- Name: developers_id_seq; Type: SEQUENCE; Schema: public; Owner: xpossx
--

CREATE SEQUENCE public.developers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.developers_id_seq OWNER TO xpossx;

--
-- Name: developers_id_seq1; Type: SEQUENCE; Schema: public; Owner: xpossx
--

CREATE SEQUENCE public.developers_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.developers_id_seq1 OWNER TO xpossx;

--
-- Name: developers_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: xpossx
--

ALTER SEQUENCE public.developers_id_seq1 OWNED BY public.developers.id;


--
-- Name: game_to_tag; Type: TABLE; Schema: public; Owner: xpossx
--

CREATE TABLE public.game_to_tag (
    game_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE public.game_to_tag OWNER TO xpossx;

--
-- Name: games; Type: TABLE; Schema: public; Owner: xpossx
--

CREATE TABLE public.games (
    game_id bigint NOT NULL,
    developer_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    year_of_release timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.games OWNER TO xpossx;

--
-- Name: games_game_id_seq; Type: SEQUENCE; Schema: public; Owner: xpossx
--

CREATE SEQUENCE public.games_game_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.games_game_id_seq OWNER TO xpossx;

--
-- Name: games_game_id_seq1; Type: SEQUENCE; Schema: public; Owner: xpossx
--

CREATE SEQUENCE public.games_game_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.games_game_id_seq1 OWNER TO xpossx;

--
-- Name: games_game_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: xpossx
--

ALTER SEQUENCE public.games_game_id_seq1 OWNED BY public.games.game_id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: xpossx
--

CREATE TABLE public.reviews (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    commentary_id bigint,
    game_id bigint NOT NULL,
    score smallint NOT NULL,
    text character varying(255) NOT NULL
);


ALTER TABLE public.reviews OWNER TO xpossx;

--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: xpossx
--

CREATE SEQUENCE public.reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reviews_id_seq OWNER TO xpossx;

--
-- Name: reviews_id_seq1; Type: SEQUENCE; Schema: public; Owner: xpossx
--

CREATE SEQUENCE public.reviews_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reviews_id_seq1 OWNER TO xpossx;

--
-- Name: reviews_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: xpossx
--

ALTER SEQUENCE public.reviews_id_seq1 OWNED BY public.reviews.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: xpossx
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.tags OWNER TO xpossx;

--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: xpossx
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tags_id_seq OWNER TO xpossx;

--
-- Name: tags_id_seq1; Type: SEQUENCE; Schema: public; Owner: xpossx
--

CREATE SEQUENCE public.tags_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tags_id_seq1 OWNER TO xpossx;

--
-- Name: tags_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: xpossx
--

ALTER SEQUENCE public.tags_id_seq1 OWNED BY public.tags.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: xpossx
--

CREATE TABLE public.users (
    user_id bigint NOT NULL,
    login character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    birth_date timestamp(0) without time zone NOT NULL,
    password character varying(255) NOT NULL,
    role character varying(50) DEFAULT 'user'::character varying NOT NULL
);


ALTER TABLE public.users OWNER TO xpossx;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: xpossx
--

CREATE SEQUENCE public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO xpossx;

--
-- Name: users_user_id_seq1; Type: SEQUENCE; Schema: public; Owner: xpossx
--

CREATE SEQUENCE public.users_user_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq1 OWNER TO xpossx;

--
-- Name: users_user_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: xpossx
--

ALTER SEQUENCE public.users_user_id_seq1 OWNED BY public.users.user_id;


--
-- Name: commentaries id; Type: DEFAULT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.commentaries ALTER COLUMN id SET DEFAULT nextval('public.commentaries_id_seq'::regclass);


--
-- Name: developers id; Type: DEFAULT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.developers ALTER COLUMN id SET DEFAULT nextval('public.developers_id_seq1'::regclass);


--
-- Name: games game_id; Type: DEFAULT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.games ALTER COLUMN game_id SET DEFAULT nextval('public.games_game_id_seq1'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq1'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq1'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq1'::regclass);


--
-- Name: commentaries commentaries_pkey; Type: CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.commentaries
    ADD CONSTRAINT commentaries_pkey PRIMARY KEY (id);


--
-- Name: developers developers_pkey; Type: CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.developers
    ADD CONSTRAINT developers_pkey PRIMARY KEY (id);


--
-- Name: game_to_tag game_to_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.game_to_tag
    ADD CONSTRAINT game_to_tag_pkey PRIMARY KEY (game_id, tag_id);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (game_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: games unique_game_developer; Type: CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT unique_game_developer UNIQUE (name, developer_id);


--
-- Name: game_to_tag unique_game_tag; Type: CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.game_to_tag
    ADD CONSTRAINT unique_game_tag UNIQUE (game_id, tag_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: idx_game_tag; Type: INDEX; Schema: public; Owner: xpossx
--

CREATE UNIQUE INDEX idx_game_tag ON public.game_to_tag USING btree (game_id, tag_id);


--
-- Name: idx_game_to_tag_game_id_tag_id; Type: INDEX; Schema: public; Owner: xpossx
--

CREATE UNIQUE INDEX idx_game_to_tag_game_id_tag_id ON public.game_to_tag USING btree (game_id, tag_id);


--
-- Name: idx_games_name_developer_id; Type: INDEX; Schema: public; Owner: xpossx
--

CREATE UNIQUE INDEX idx_games_name_developer_id ON public.games USING btree (name, developer_id);


--
-- Name: idx_tags_name; Type: INDEX; Schema: public; Owner: xpossx
--

CREATE UNIQUE INDEX idx_tags_name ON public.tags USING btree (name);


--
-- Name: reviews check_review_content_trigger; Type: TRIGGER; Schema: public; Owner: xpossx
--

CREATE TRIGGER check_review_content_trigger BEFORE INSERT OR UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.check_review_content();


--
-- Name: commentaries commentaries_review_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.commentaries
    ADD CONSTRAINT commentaries_review_id_fkey FOREIGN KEY (review_id) REFERENCES public.reviews(id) ON DELETE CASCADE;


--
-- Name: commentaries commentaries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.commentaries
    ADD CONSTRAINT commentaries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: game_to_tag game_to_tag_tag_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.game_to_tag
    ADD CONSTRAINT game_to_tag_tag_id_foreign FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- Name: games games_developer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_developer_id_foreign FOREIGN KEY (developer_id) REFERENCES public.developers(id);


--
-- Name: reviews reviews_game_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_game_id_foreign FOREIGN KEY (game_id) REFERENCES public.games(game_id);


--
-- Name: reviews reviews_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: xpossx
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- PostgreSQL database dump complete
--

