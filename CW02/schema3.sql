/**
 Статусы актеров
 */
CREATE TYPE ActorStatus AS ENUM('суперзвезда', 'звезда', 'массовка', 'второго плана', 'юное дарование');

/**
 * Таблица-справочник со странами, обозначенными двухбуквенными кодами: US, RU, и т.д.
 */
CREATE TABLE Country(
  id INT PRIMARY KEY,
  name TEXT UNIQUE
);

/**
 * Актеры.
 */
CREATE TABLE Actor(
  id SERIAL PRIMARY KEY,
  name TEXT,
  status ActorStatus,
  birth_year INT CHECK(birth_year > 1900)
);


/**
 * Режиссеры
 */
CREATE TABLE Director(
  id SERIAL PRIMARY KEY,
  name TEXT,
  birth_year INT CHECK(birth_year > 1900)
);

/**
 * Киностудии.
 */
CREATE TABLE Studio(
  id SERIAL PRIMARY KEY,
  name TEXT,
  country_id INT REFERENCES Country
);

/**
 * Фильмы. Наличие студии, снявшей фильм, не обязательно. Бюджет по умолчанию равен нулю, но всегда есть.
 */
CREATE TABLE Movie(
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  studio_id INT REFERENCES Studio,
  director_id INT REFERENCES Director NOT NULL,
  year INT CHECK ( year > 1900 ) NOT NULL,
  budget NUMERIC(6,2) NOT NULL DEFAULT 0
);

/**
 * Роли актеров в фильмах. Мы считаем, что актер играет только одну роль в одном фильме.
 */
CREATE TABLE ActorRole(
  actor_id INT REFERENCES Actor NOT NULL,
  movie_id INT REFERENCES Movie NOT NULL,
  role TEXT NOT NULL,
  fee NUMERIC(4,2) DEFAULT 0,
  UNIQUE (actor_id, movie_id)
);

/**
 * Категории проката
 */
CREATE TABLE MovieCategory(
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  country_id INT REFERENCES Country
);

/**
 * Прокат фильма в стране, с локализованным названием и категорией проката.
 */
CREATE TABLE CountryDistribution(
  id SERIAL PRIMARY KEY,
  movie_id INT REFERENCES Movie,
  local_name TEXT NOT NULL,
  category_id INT REFERENCES MovieCategory,
  country_id INT NOT NULL REFERENCES Country,
  UNIQUE(movie_id, country_id)
);

/**
 * Кинотеатры, их адрес в виде произвольной строки и отдельно страна, в которой кинотеатр находится
 */
CREATE TABLE Cinema(
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT,
  country_id INT NOT NULL REFERENCES Country
);

/**
 * Прокат фильма в кинотеатре, с датами проката и выручкой, которым позволительно быть неопределёнными.
 */
CREATE TABLE CinemaDistribution(
  cinema_id INT NOT NULL REFERENCES Cinema,
  movie_id INT NOT NULL  REFERENCES CountryDistribution,
  start_date DATE,
  finish_date DATE,
  box_office NUMERIC(6,2) NULL,
  CHECK(finish_date >= start_date),
  UNIQUE (cinema_id, movie_id)
);

----------------------------------------------------------
-- Заполнение таблицы Country
INSERT INTO Country(id, name) VALUES
(1, 'US'), (2, 'RU'), (3, 'FR'), (4, 'UK'), (5, 'DE'), (6, 'UA'), (7, 'CA'), (8, 'IT'), (9, 'IN'), (10, 'KO'), (11, 'ES');

----------------------------------------------------------
-- Заполнение таблицы Actor
WITH Ids AS (
  SELECT generate_series(1, 50) AS num
),
  Statuses AS (
    select enumsortorder AS status_num, enumlabel::ActorStatus AS status_value
    from pg_catalog.pg_enum
    WHERE enumtypid = 'actorstatus'::regtype
    ORDER BY enumsortorder
  ),
  RawData AS (
    SELECT
      Contest.GenNickname(
          ARRAY['Леонардо', 'Мэтт', 'Джек', 'Джонни', 'Роберт', 'Джон'],
          ARRAY['ди Каприо', 'Деймон', 'Николсон', 'Депп', 'де Ниро', 'Траволта']
        ) AS man_name,
      Contest.GenNickname(
          ARRAY['Одри', 'Вивьен', 'Софи', 'Ингрид', 'Кэтрин'],
          ARRAY['Хэпбёрн', 'Ли', 'Лорен', 'Бергман', 'Тату']
        ) AS woman_name,
      (0.5 + random() * (SELECT COUNT(*) FROM Statuses))::INT AS status_num,
      (1950 + random() * 50)::INT AS birth_year
    FROM Ids
  )
INSERT INTO Actor(name, status, birth_year)
SELECT CASE FLOOR(random() + 0.5) WHEN 0 THEN man_name ELSE woman_name END,
  status_value,
  birth_year
FROM RawData JOIN Statuses USING(status_num);

----------------------------------------------------------
-- Заполнение таблицы Director
INSERT INTO Director(name, birth_year)
SELECT
  Contest.GenNickname(
      ARRAY['Джеймс', 'Вуди', 'Стивен', 'Роберт', 'Квентин', 'Милош', 'Ингмар', 'Федерико'],
      ARRAY['Кэмерон', 'Аллен', 'Спилберг', 'Земекис', 'Тарантино', 'Форман', 'Бергман', 'Феллини']
    ) AS name,
  (1950 + random() * 50)::INT AS birth_year
FROM generate_series(1, 30);

----------------------------------------------------------
-- Заполнение таблицы Studio
INSERT INTO Studio(name, country_id) VALUES
       ('20th Century Fox', 1),
       ('Columbia Pictures', 1),
       ('Walt Disney Pictures', 1),
       ('Paramount Pictures', 1),
       ('Pixar', 1),
       ('Мосфильм', 2),
       ('Ленфильм', 2),
       ('Одесская киностудия', 6),
       ('Bollywood', 9),
       ('Gaumont', 3);

----------------------------------------------------------
-- Заполнение таблицы Movie
WITH Word1 AS (
  SELECT * FROM
    unnest(ARRAY['Yellow', 'Blue', 'White', 'Black', 'Red', 'Green', 'Dark', 'Bright'])
      WITH ORDINALITY T(name, id)
),
  Word2 AS (
    SELECT * FROM
      unnest(ARRAY['fast', 'slow', 'skinny', 'fat', 'curious', 'angry', 'lazy', 'greedy'])
        WITH ORDINALITY T(name, id)
  ),
  Word3 AS (
    SELECT * FROM
      unnest(ARRAY['dog', 'fox', 'cat', 'duck', 'tiger', 'elephant', 'cockroach', 'bear', 'rackoon'])
        WITH ORDINALITY T(name, id)
  ),
  Word4 AS (
    SELECT * FROM
      unnest(ARRAY['catches the', 'jumps over the', 'walks with the', 'kisses the', 'is having fun with the', 'passes by the', 'talks to the'])
        WITH ORDINALITY T(name, id)
  ),
  Word5 AS (
    SELECT * FROM
      unnest(ARRAY['dog', 'fox', 'cat', 'duck', 'tiger', 'elephant', 'cockroach', 'bear', 'rackoon'])
        WITH ORDINALITY T(name, id)
  ),
  Word6 AS (
    SELECT * FROM
      unnest(ARRAY['in big city', 'in the darkness', 'silently', 'from Russia', 'in Spain', 'in Paris', 'high in the mountains', 'on their way to the Moon'])
        WITH ORDINALITY T(name, id)
  ),
  Randoms AS (
    SELECT
      (0.5 + random() * (SELECT COUNT(*) FROM Word1))::INT AS w1_id,
      (0.5 + random() * (SELECT COUNT(*) FROM Word2))::INT AS w2_id,
      (0.5 + random() * (SELECT COUNT(*) FROM Word3))::INT AS w3_id,
      (0.5 + random() * (SELECT COUNT(*) FROM Word4))::INT AS w4_id,
      (0.5 + random() * (SELECT COUNT(*) FROM Word5))::INT AS w5_id,
      (0.5 + random() * (SELECT COUNT(*) FROM Word6))::INT AS w6_id,
      (0.5 + random() * (SELECT COUNT(*) FROM Studio))::INT AS studio_id,
      (0.5 + random() * (SELECT COUNT(*) FROM Director))::INT AS director_id,
      (2000 + random() * 20)::INT AS year,
      (Contest.GenGauss() * 50)::NUMERIC(6,2) AS budget
    FROM generate_series(1, 100)
  )
INSERT INTO Movie(name, studio_id, director_id, year, budget)
SELECT w1.name || ' ' || w2.name || ' ' || w3.name || ' ' || w4.name || ' ' || w5.name || ' ' || w6.name AS name, R.studio_id, R.director_id, R.year, R.budget
FROM Randoms R
       JOIN Word1 w1 ON R.w1_id = w1.id
       JOIN Word2 w2 ON R.w2_id = w2.id
       JOIN Word3 w3 ON R.w3_id = w3.id
       JOIN Word4 w4 ON R.w4_id = w4.id
       JOIN Word5 w5 ON R.w5_id = w5.id
       JOIN Word6 w6 ON R.w6_id = w6.id;

----------------------------------------------------------
-- Заполнение таблицы Roles
WITH Word1 AS (
  SELECT * FROM
    unnest(ARRAY['Fast', 'Slow', 'Skinny', 'Fat', 'Curious', 'Angry', 'Lazy', 'Greedy', 'Blind', 'Dangerous', 'Lovely', 'Great', 'Furious', 'Crying', 'Funny', 'Brave', 'Awful', 'Crazy'])
      WITH ORDINALITY T(name, id)
),
  Word2 AS (
    SELECT * FROM
      unnest(ARRAY['dog', 'fox', 'cat', 'duck', 'tiger', 'elephant', 'cockroach', 'bear', 'rackoon', 'tramp', 'dictator', 'bride', 'hero', 'killer', 'monster', 'doctor', 'princess', 'dragon'])
        WITH ORDINALITY T(name, id)
  ),
  Randoms AS (
    SELECT
      (0.5 + random() * (SELECT COUNT(*) FROM Word1))::INT AS w1_id,
      (0.5 + random() * (SELECT COUNT(*) FROM Word2))::INT AS w2_id,
      (0.5 + random() * (SELECT COUNT(*) FROM Actor))::INT AS actor_id,
      (0.5 + random() * (SELECT COUNT(*) FROM Movie))::INT AS movie_id,
      (Contest.GenGauss() * 2)::NUMERIC(4,2) AS fee
    FROM generate_series(1, 300)
  )
INSERT INTO ActorRole(actor_id, movie_id, role, fee)
SELECT DISTINCT ON(actor_id, movie_id) actor_id, movie_id, w1.name || ' ' || w2.name, fee
FROM Randoms R
       JOIN Word1 w1 ON R.w1_id = w1.id
       JOIN Word2 w2 ON R.w2_id = w2.id;

----------------------------------------------------------
-- Заполнение таблицы MovieCategory
INSERT INTO MovieCategory(name, country_id)
VALUES ('0+', 2), ('6+', 2), ('12+', 2), ('18+', 2), ('12+', 6), ('45+', 3), ('75-', 1);

----------------------------------------------------------
-- Заполнение таблицы CountryDistribution
WITH Randoms AS (
  SELECT
    (0.5 + random() * (SELECT COUNT(*) FROM Movie))::INT AS movie_id,
    (0.5 + random() * (SELECT COUNT(*) FROM Country))::INT AS country_id
  FROM generate_series(1, 500)
)
INSERT INTO CountryDistribution(movie_id, country_id, category_id, local_name)
SELECT DISTINCT ON (M.id, R.country_id)
  M.id as movie_id, R.country_id,  MC.id AS category_id, M.name
FROM Randoms R JOIN Movie M ON R.movie_id = M.id
       LEFT JOIN MovieCategory MC ON R.country_id = MC.country_id
ORDER BY M.id, R.country_id, random();

----------------------------------------------------------
-- Заполнение таблицы Cinema
WITH Cities(name, country_id) AS (
  SELECT * FROM (VALUES ('Нью-Йорк', 1), ('Сан-Франциско', 1), ('лос-Анджелес', 1),
                 ('Москва', 2), ('Санкт-Петербург', 2), ('Омск', 2), ('Париж', 3), ('Лондон', 4), ('Берлин', 5), ('Мюнхен', 5), ('Киев', 6), ('Одесса', 6), ('Монреаль', 7), ('Ванкувер', 7), ('Рим', 8), ('Милан', 8), ('Мумбай', 9), ('Дели', 9), ('Сеул', 10), ('Мадрид', 11)) T
),
  Randoms AS (
    SELECT (0.5 + random() * (SELECT COUNT(1) FROM Country))::INT AS country_id, num
    FROM generate_series(1, 75) WITH ORDINALITY T(num)
  )
INSERT INTO Cinema(country_id, name, address)
SELECT country_id, 'Cinema ' || R.num::TEXT, address
FROM Randoms R JOIN LATERAL (
  SELECT DISTINCT ON (country_id) country_id, name AS address FROM Cities WHERE Cities.country_id = R.country_id
  ORDER BY country_id, random()
  ) C USING(country_id);

----------------------------------------------------------
-- Заполнение таблицы CinemaDistribution
WITH CandidateDistros AS (
  SELECT CD.id AS movie_id,
         C.id AS cinema_id,
         random() AS rnd,
        (timestamp '2018-01-01' + random()*interval '365 days')::DATE AS start_date,
    (random() * 50)::NUMERIC(6,2) AS box_office
         FROM
  CountryDistribution CD JOIN Cinema C USING (country_id)
)
INSERT INTO CinemaDistribution(cinema_id, movie_id, start_date, finish_date, box_office)
SELECT cinema_id,
       movie_id,
       start_date,
  (start_date + random() * interval '14 days')::DATE AS finish_date,
       box_office
FROM CandidateDistros
WHERE rnd > 0.5;
