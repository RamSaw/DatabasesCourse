DROP TABLE IF EXISTS AmericanCountry CASCADE;
DROP TABLE IF EXISTS EuropeanCountry CASCADE;
DROP TABLE IF EXISTS Plantation CASCADE;
DROP TABLE IF EXISTS AmericanPort CASCADE;
DROP TABLE IF EXISTS EuropeanPort CASCADE;
DROP TABLE IF EXISTS Procurement CASCADE;
DROP TABLE IF EXISTS Ship CASCADE;
DROP TABLE IF EXISTS TransferType CASCADE;
DROP TABLE IF EXISTS SeaCargo CASCADE;
DROP TABLE IF EXISTS CoffeeCustomer CASCADE;

/**
 * Страна в Южной Америке
 */
CREATE TABLE AmericanCountry (
    id              SERIAL    PRIMARY KEY,
    name            TEXT      NOT NULL UNIQUE
);

/**
 * Страна в Европе
 */
CREATE TABLE EuropeanCountry (
    id              SERIAL    PRIMARY KEY,
    name            TEXT      NOT NULL UNIQUE
);

/**
 * Американский порт с названием и GPS координатами
 */
CREATE TABLE AmericanPort (
    id              SERIAL    PRIMARY KEY,
    name            TEXT      NOT NULL UNIQUE,
    country_id      INTEGER   NOT NULL REFERENCES AmericanCountry,
    longitude       NUMERIC(8, 5)   NULL CHECK ((longitude > -180) AND (longitude < 180)),
    latitude        NUMERIC(7, 5)   NULL CHECK ((latitude > -90) AND (latitude < 90)),
    UNIQUE(longitude, latitude)
);


/**
 * Европейский порт с названием и GPS координатами
 */
CREATE TABLE EuropeanPort (
    id              SERIAL    PRIMARY KEY,
    name            TEXT      NOT NULL UNIQUE,
    country_id      INTEGER   NOT NULL REFERENCES EuropeanCountry,
    longitude       NUMERIC(8, 5)   NULL CHECK ((longitude > -180) AND (longitude < 180)),
    latitude        NUMERIC(7, 5)   NULL CHECK ((latitude > -90) AND (latitude < 90)),
    UNIQUE(longitude, latitude)
);

/**
 * Менеджер. Он может управлять несколькими плантациями
 */
CREATE TABLE Manager(
  id  SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

/**
 * Плантация находится в какой-то стране, поставляет свой кофе в какой-то порт
 * и кто-то ею управляет.
 */
CREATE TABLE Plantation (
    id              SERIAL   PRIMARY KEY,
    country_id      INTEGER   NOT NULL REFERENCES AmericanCountry,
    port_id         INTEGER   NOT NULL REFERENCES AmericanPort,
    manager_id      INTEGER   NOT NULL REFERENCES Manager
);


/**
 Поставки с плантации в порт
 */
CREATE TABLE GroundCargo (
    id              SERIAL   PRIMARY KEY,
    plantation_id   INTEGER   NOT NULL REFERENCES Plantation,
    weight          NUMERIC(8,2)      NOT NULL CHECK (weight > 0),
    delivery_date         DATE      NOT NULL,
    UNIQUE(plantation_id, delivery_date)
);

/**
 * Корабли с именем и вместимостью
 */
CREATE TABLE Ship (
    id              SERIAL    PRIMARY KEY,
    name            TEXT      NOT NULL UNIQUE,
    capacity        INT      NOT NULL CHECK (capacity > 0)
);

CREATE TABLE SeaCargoPrice (
    id              SERIAL    PRIMARY KEY,
    am_port         INTEGER   NOT NULL REFERENCES AmericanPort,
    eu_port         INTEGER   NOT NULL REFERENCES EuropeanPort,
    ship            INTEGER   NOT NULL REFERENCES Ship,
    price           NUMERIC(15,2)      NOT NULL CHECK (price > 0),
    UNIQUE (am_port, eu_port, ship)
);


/**
 * Покупатель кофе
 */
CREATE TABLE CoffeeCustomer (
    id              SERIAL    PRIMARY KEY,
    name            TEXT      NOT NULL UNIQUE ,
    price           NUMERIC (4, 2) NOT NULL CHECK (price > 0)
);

/**
  Морская перевозка, с указанием тарифа, даты отправления корабля и адресата перевозки
 */
CREATE TABLE SeaCargo (
    id              SERIAL    PRIMARY KEY,
    price_id        INTEGER   NOT NULL REFERENCES SeaCargoPrice,
    delivery_date   DATE      NOT NULL,
    customer_id     INTEGER   REFERENCES CoffeeCustomer,
    UNIQUE (price_id, delivery_date)
);

-----------------------------------------------
-- Let's have some data
INSERT INTO AmericanCountry(name) VALUES ('Бразилия'), ('Эквадор'), ('Колумбия'), ('Перу'), ('Коста-Рика'), ('Мексика');
INSERT INTO EuropeanCountry(name) VALUES ('Испания'), ('Италия'), ('Франция'), ('Великобритания'), ('Швеция'), ('Германия'), ('Финляндия');
INSERT INTO AmericanPort(name, country_id) VALUES
('Гуаякиль',2),('Картахена',  3),('Итака', 1), ('Тубаран',1), ('Сантус',1),('Сепетиба',1), ('Кальяо',4), ('Мансанильо', 6);
INSERT INTO EuropeanPort(name, country_id) VALUES
('Валенсия', 1), ('Барселона', 1), ('Триест', 2), ('Генуя', 2), ('Дюнкерк', 3), ('Марсель', 3), ('Гавр',3), ('Лондон', 4), ('Милфорд-Хейвен', 4), ('Гетеборг', 5), ('Гамбург',6);

-- Управляющие
WITH RawData AS (
  SELECT generate_series AS id, Contest.GenNickname(
    ARRAY['Ricardo', 'Joao', 'Miguel', 'Jose', 'Luis', 'Serjio'],
    ARRAY['Ramos', 'Gonsales', 'Carvalho', 'da Silva', 'Blanca', 'Rodriges']
  ) AS name
  FROM generate_series(1, 30)
)
INSERT INTO Manager(name)
SELECT DISTINCT name FROM RawData;

-- Плантации
INSERT INTO Plantation(country_id, port_id, manager_id)
SELECT (0.5 + random() * (SELECT COUNT(*) FROM AmericanCountry))::INT,
       (0.5 + Contest.GenGauss() * (SELECT COUNT(*) FROM AmericanPort))::INT,
       (0.5 + random() * (SELECT COUNT(*) FROM Manager))::INT
FROM generate_series(1, 50);


-- Перевозки Плантация->Порт
WITH Ids AS(
  SELECT generate_series(1, 250) AS id
),
RawData AS (
  SELECT (0.5 + random() * (SELECT COUNT(*) FROM Plantation))::int AS plantation_id,
      random()*100 AS weight,
    (timestamp '2018-06-01' + random() * interval '180 days')::date AS delivery_date
  FROM Ids
)
INSERT INTO GroundCargo(plantation_id, weight, delivery_date)
SELECT DISTINCT ON(plantation_id, delivery_date)
    plantation_id, weight, delivery_date
FROM RawData;


-- Корабли
WITH Ids AS(
  SELECT generate_series(1, 30) AS id
),
RawData AS (
  SELECT DISTINCT Contest.GenNickname(
    ARRAY['Святая', 'Принцесса', 'Королева', 'Принцесса', 'Святая', 'Адмирал', 'Академик'],
    ARRAY['Анна', 'Варвара', 'Каталина', 'Диана', 'Елизавета', 'Флора', 'Женевьева', 'Иветта', 'Лизетта', 'Мюзетта', 'Жанетта', 'Жоpжетта', 'Мариетта']) AS name,
      1000*(0.5 + random() * 30)::INT AS capacity
  FROM Ids
)
INSERT INTO Ship(name, capacity)
SELECT DISTINCT ON(name) name, capacity FROM RawData;

-- Тарифы на морские перевозки
WITH Ids AS(
  SELECT generate_series(1, 100) AS id
),
Triples AS (
SELECT DISTINCT
  (0.5 + random() * (SELECT COUNT(*) FROM AmericanPort))::int AS am_port,
  (0.5 + random() * (SELECT COUNT(*) FROM EuropeanPort))::int AS eu_port,
  (0.5 + random() * (SELECT COUNT(*) FROM Ship))::int AS ship_id
  FROM Ids
)
INSERT INTO SeaCargoPrice(am_port, eu_port, ship, price)
SELECT Triples.*, 0.5 + 0.5*random()*Ship.capacity
FROM Triples JOIN Ship ON Triples.ship_id = Ship.id;

-- Покупатели кофе
WITH Ids AS(
  SELECT generate_series(1, 20) AS id
),
RawData AS (
  SELECT
    Contest.GenNickname(
        ARRAY['Tasty', 'Strong', 'Sweet', 'Delicious'],
        ARRAY['Cappuccino', 'Espresso', 'Macchiato', 'Ristretto', 'Latte']) AS name,
    (20 + (random() * 3))::NUMERIC(4,2) AS price
  FROM Ids
)
INSERT INTO CoffeeCustomer(name, price)
SELECT DISTINCT ON(name) name, price FROM RawData;


-- Перевозки по морю
WITH Ids AS(
  SELECT generate_series(1, 250) AS id
),
RawData AS (
  SELECT
    (0.5 + random() * (SELECT COUNT(*) FROM SeaCargoPrice))::int AS price_id,
    (timestamp '2018-06-01' + random() * interval '180 days')::date AS delivery_date,
    (0.5 + random() * (SELECT COUNT(*) FROM CoffeeCustomer))::int AS customer_id
  FROM Ids
)
INSERT INTO SeaCargo(price_id, delivery_date, customer_id)
SELECT DISTINCT ON(price_id, delivery_date)
  price_id, delivery_date, customer_id
FROM RawData;

