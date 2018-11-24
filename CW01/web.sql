DROP TABLE IF EXISTS Visitors CASCADE;
DROP TABLE IF EXISTS Sites CASCADE;
DROP TABLE IF EXISTS Pages CASCADE;
DROP TABLE IF EXISTS Sessions CASCADE;
DROP TABLE IF EXISTS Movements CASCADE;
DROP TABLE IF EXISTS Countries CASCADE;

CREATE TABLE Visitors (
  --id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  id UUID PRIMARY KEY,
  ip_first_part INT NOT NULL CHECK(ip_first_part >= 0 AND ip_first_part <= 255),
  ip_second_part INT NOT NULL CHECK(ip_second_part >= 0 AND ip_second_part <= 255),
  ip_third_part INT NOT NULL CHECK(ip_third_part >= 0 AND ip_third_part <= 255),
  ip_fourth_part INT NOT NULL CHECK(ip_fourth_part >= 0 AND ip_fourth_part <= 255),
  cookie VARCHAR(512) UNIQUE,
  UNIQUE(ip_first_part, ip_second_part, ip_third_part, ip_fourth_part)
);

CREATE TABLE Sites (
  client_id VARCHAR(200) PRIMARY KEY,
  domain VARCHAR(200) UNIQUE NOT NULL
);

CREATE TABLE Pages (
  id      UUID PRIMARY KEY,
  site_id VARCHAR(200) REFERENCES Sites (client_id) NOT NULL,
  address VARCHAR(1000) NOT NULL,
  UNIQUE(site_id, address) -- так как в примерах относительные адреса: /about/tos, а значит они могут повторяться для разных сайтов
);

CREATE TABLE Sessions (
  id INT PRIMARY KEY, -- сказано в условии INT, но кажется лучше UUID
  start_page_id UUID REFERENCES Pages(id) NOT NULL,
  user_id UUID REFERENCES Visitors(id) NOT NULL,
  search_system VARCHAR(200),
  request VARCHAR(200),
  domain VARCHAR(200),
  address VARCHAR(1000)
);

CREATE TABLE Movements (
  page_id UUID REFERENCES Pages(id) NOT NULL,
  time TIMESTAMPTZ                  NOT NULL,
  came_from UUID REFERENCES Pages(id),
  session_id INT REFERENCES Sessions (id) NOT NULL,
  UNIQUE(page_id, time)
);

CREATE TABLE Countries (
  country VARCHAR(200),
  ip_first_part INT NOT NULL CHECK(ip_first_part >= 0 AND ip_first_part <= 255),
  ip_second_part INT NOT NULL CHECK(ip_second_part >= 0 AND ip_second_part <= 255),
  ip_third_part INT NOT NULL CHECK(ip_third_part >= 0 AND ip_third_part <= 255),
  ip_fourth_part INT NOT NULL CHECK(ip_fourth_part >= 0 AND ip_fourth_part <= 255),
  ip_meaning_bits_number INT NOT NULL CHECK(ip_meaning_bits_number >= 0 AND ip_meaning_bits_number <= 32),
  UNIQUE(ip_first_part, ip_second_part, ip_third_part, ip_fourth_part)
);