DROP TABLE IF EXISTS BatchOrderPies CASCADE;
DROP TABLE IF EXISTS BatchOrders CASCADE;
DROP TYPE IF EXISTS OrderStatus CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS SalesStats CASCADE;
DROP TYPE IF EXISTS StatsType CASCADE;
DROP TABLE IF EXISTS IngredientsRemaining CASCADE;
DROP TABLE IF EXISTS PieComponents CASCADE;
DROP TYPE IF EXISTS AmountUnit CASCADE;
DROP TABLE IF EXISTS Ingredients CASCADE;
DROP TABLE IF EXISTS Pies CASCADE;

/**
 * Пироговый справочник.
 *
 * Предполагается, что названия пирогов уникальны (потому что нужно понять, о чем речь,
 * когда пирог называет посетитель),
 * но для ускорения работы есть фиктивные номера. Вес указывается только в
 * килограммах (три знака после запятой - граммы), валюта оплаты - только рубли.
 *
 * Так как ассортимент меняется, пироги из старых заказов могут исчезнуть, однако
 * информацию о них терять не хочется. Поэтому пирог можно пометить как "доступный"
 * или "недоступный" для заказа.
 */
CREATE TABLE Pies (
  Id            SERIAL         NOT NULL PRIMARY KEY,
  Title         VARCHAR(100)   NOT NULL UNIQUE,
  FullWeightKg  DECIMAL(10, 3) NOT NULL CHECK(FullWeightKg > 0),
  PriceRubPerKg DECIMAL(10, 2) NOT NULL CHECK(PriceRubPerKg > 0),
  IsOffered     BOOLEAN        NOT NULL DEFAULT true
);

/**
 * Справочник существующих ингридиентов.
 *
 * Только имена. Каждый ингридиент может считаться в разных единицах в
 * разных рецептах (штуки шоколадок, граммы шоколада), но на складе должен
 * храниться только в одном виде (либо невскрытые пачки, либо суммарный вес).
 */
CREATE TABLE Ingredients (
  Id    SERIAL       NOT NULL PRIMARY KEY,
  Title VARCHAR(100) NOT NULL UNIQUE
);

/**
 * Единицы измерения в ингридиентах пирогов: кг (по массе), литр (по объёму),
 * штука.
 */
CREATE TYPE AmountUnit AS ENUM ('гр', 'шт', 'литр', 'пачка');

/**
 * Ингредиенты пирогов.
 */
CREATE TABLE PieComponents (
  PieId        INT            NOT NULL REFERENCES Pies,
  IngredientId INT            NOT NULL REFERENCES Ingredients,
  Amount       DECIMAL(10, 3) NOT NULL CHECK(Amount > 0),
  AmountUnit   AmountUnit     NOT NULL,
  PRIMARY KEY (PieId, IngredientId)
);

/**
 * Остатки на складе.
 *
 * Разные вещи может быть удобно мерять в разных единицах (литры молока,
 * килограммы мяса), но каждая должна быть измерена ровно в одной единице.
 * Нули разрешены для упрощения учёта.
 */
CREATE TABLE IngredientsRemaining (
  IngredientId INT            NOT NULL PRIMARY KEY REFERENCES Ingredients,
  Amount       DECIMAL(10, 3) NOT NULL CHECK (Amount >= 0),
  AmountUnit   AmountUnit     NOT NULL
);

/**
 * Статистика по рабочим и выходным дням
 */
CREATE TYPE StatsType AS ENUM ('holiday', 'business_day');

/**
 * Статистика о продажах.
 *
 * Для каждого пирога и периода есть не более одной записи.
 */
CREATE TABLE SalesStats (
  PieId      INT       NOT NULL REFERENCES Pies,
  StatsType  StatsType NOT NULL,
  SoldAmount INT       NOT NULL CHECK(SoldAmount >= 0),
  PRIMARY KEY (PieId, StatsType)
);


/**
 * Постоянные клиенты.
 *
 * У каждого есть уникальный номер и неуникальное имя (название организации,
 * имя-фамилия, ник). Скидка бывает нулевая, чтобы можно было давать
 * постоянным клиентам какие-то ещё бонусы, кроме денежных.
 */
CREATE Table Customers (
  Id              SERIAL       NOT NULL PRIMARY KEY,
  Name            VARCHAR(100) NOT NULL,
  DiscountPercent INT          NOT NULL CHECK(DiscountPercent BETWEEN 0 AND 100)
);

/**
 * Статус заказа.
 */
CREATE TYPE OrderStatus AS ENUM ('received', 'processing', 'shipped', 'completed');

/**
 * Мелкооптовые заказы.
 *
 * У каждого есть уникальный номер, ожидаемое время доставки, адрес доставки, статус.
 * Также может быть имя получателя (может не быть, если доставка на Reception),
 * и может быть номер постоянного покупателя.
 */
CREATE Table BatchOrders (
  Id               SERIAL                   NOT NULL  PRIMARY KEY,
  Customer         INT                      NULL      REFERENCES Customers,
  ExpectedDelivery TIMESTAMP                NOT NULL,
  ReceiverName     TEXT                     NULL,
  Address          TEXT                     NULL,
  Status           OrderStatus              NOT NULL
);

/**
 * Состав заказов.
 */
CREATE TABLE BatchOrderPies (
  BatchOrderId INT NOT NULL REFERENCES BatchOrders,
  PieId        INT NOT NULL REFERENCES Pies,
  Amount       INT NOT NULL CHECK(Amount > 0),
  PRIMARY KEY(BatchOrderId, PieId)
);

-----------------------------------------------
-- Let's have some data

INSERT INTO Pies(Title, FullWeightKg, PriceRubPerKg) VALUES
    ('Пирог с рисом и яйцом', 0.5, 480),
    ('Пирог с картофелем, сыром и грибами', 1, 640),
    ('Пирог с кроликом и грибами', 0.5, 480);

INSERT INTO Ingredients(Title) VALUES
  ('Мука'), ('Соль'), ('Яйцо'), ('Рис'), ('Картофель'),
  ('Сыр'), ('Грибы'), ('Яблоки'), ('Кролик'), ('Капуста');

INSERT INTO PieComponents(PieId, IngredientId, Amount, AmountUnit) VALUES
-- с рисом и яйцом 0.5 kg
(1, 1, 200, 'гр'),
(1, 2, 10, 'гр'),
(1, 3, 4, 'шт'),
(1, 4, 200, 'гр'),
-- с картофелем сыром и грибами 1kg
(2, 1, 300, 'гр'),
(2, 5, 300, 'гр'),
(2, 6, 100, 'гр'),
(2, 7, 100, 'гр'),
-- с кроликом и грибами 0.5kg
(3, 1, 200, 'гр'),
(3, 2, 10, 'гр'),
(3, 9, 50, 'гр'),
(3, 6, 100, 'гр');


INSERT INTO IngredientsRemaining(IngredientId, Amount, AmountUnit) VALUES
(1, 200000, 'гр'),
(2, 2000, 'гр'),
(3, 100, 'шт'),
(4, 10000, 'гр'),
(5, 100000, 'гр'),
(6, 5000, 'гр'),
(7, 20000, 'гр'),
(8, 55000, 'гр'),
(9, 2000, 'гр'),
(10, 50000, 'гр');

INSERT INTO SalesStats(PieId, StatsType, SoldAmount) VALUES
(1, 'holiday', 20), (1, 'business_day', 28),
(2, 'holiday', 15), (2, 'business_day', 30),
(3, 'holiday', 17), (3, 'business_day', 25);

-- Постоянные покупатели
WITH Ids AS(
  SELECT generate_series(1, 100) AS id
), Customer AS (
  SELECT id, Contest.GenNickname() AS name, (0.5 + random() * 20)::int AS discount
  FROM Ids
)
INSERT INTO Customers(Name, DiscountPercent)
SELECT name, discount FROM Customer;


-- Завершенные заказы
WITH Ids AS(
  SELECT generate_series(1, 200) AS id
), BO AS (
  SELECT id,
    (0.5 + random() * (SELECT COUNT(*) FROM Customers))::int AS customer_id,
    timestamp '2018-06-01' + random() * interval '180 days' AS delivery_time
  FROM Ids
)
INSERT INTO BatchOrders(Customer, ExpectedDelivery, Status)
SELECT customer_id, delivery_time, 'completed'
FROM BO;

-- Заказы в других состояниях
WITH Ids AS(
  SELECT generate_series(200, 220) AS id
), BO AS (
  SELECT id,
    (0.5 + random() * (SELECT COUNT(*) FROM Customers))::int AS customer_id,
    timestamp '2018-12-18 12:00' + random() * interval '6 hours' AS delivery_time,
    (0.5 + random() * 3)::INT AS status_num
  FROM Ids
), Statuses AS (
  select enumsortorder AS status_num, enumlabel::OrderStatus AS status_value
  from pg_catalog.pg_enum
  WHERE enumtypid = 'orderstatus'::regtype ORDER BY enumsortorder
)
INSERT INTO BatchOrders(Customer, ExpectedDelivery, Status)
SELECT customer_id, delivery_time, status_value
FROM BO JOIN Statuses USING(status_num);

-- Заказ, сделанный непостоянным клиентом
INSERT INTO BatchOrders(ReceiverName, ExpectedDelivery, Status) VALUES ('Кадавр', '2018-12-18 12:00', 'completed');

-- Состав заказов
WITH Ids AS(
  SELECT generate_series(1, 350) AS id
), BOP AS (
  SELECT id,
    (0.5 + random() * (SELECT COUNT(*) FROM BatchOrders))::int AS order_id,
    (0.5 + Contest.GenGauss() * (SELECT COUNT(*) FROM Pies))::INT as pie_id
  FROM Ids
),
UBOP AS (
SELECT DISTINCT order_id, pie_id FROM BOP
)
INSERT INTO BatchOrderPies(BatchOrderId, PieId, Amount)
SELECT order_id, pie_id, GREATEST(1, (Contest.GenGauss()*3)::INT) as amount FROM UBOP;
