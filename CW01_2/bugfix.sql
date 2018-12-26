DROP TABLE IF EXISTS Position CASCADE;
DROP TABLE IF EXISTS Engineer CASCADE;
DROP TABLE IF EXISTS Project CASCADE;
DROP TABLE IF EXISTS Bug CASCADE;
DROP TABLE IF EXISTS Status CASCADE;
DROP TABLE IF EXISTS BugStatusHistory CASCADE;

CREATE TABLE Position(
  id INT PRIMARY KEY,
  name TEXT NOT NULL,
  min_salary INT CHECK(min_salary > 0),
  max_salary INT,
  CHECK (max_salary >= min_salary)
);

CREATE TABLE Engineer(
  id INT primary key,
  name TEXT NOT NULL,
  position_id INT REFERENCES Position(id),
  salary INT NOT NULL CHECK (salary > 0) -- check for min and max ??
);

CREATE TABLE Project(
  id INT PRIMARY KEY,
  title TEXT,
  manager_id INT REFERENCES Engineer(id) UNIQUE
);

CREATE TABLE Bug(
  id INT PRIMARY KEY,
  num INT NOT NULL UNIQUE,
  owner_id INT REFERENCES Engineer(id),
  project_id INT REFERENCES Project(id)
);

CREATE TABLE Status(
  id INT PRIMARY KEY,
  value TEXT UNIQUE
);

CREATE TABLE BugStatusHistory(
  bug_id INT REFERENCES Bug(id),
  change_ts INT CHECK (change_ts > 0),
  change_author_id INT REFERENCES Engineer(id),
  status_id INT REFERENCES Status(id),
  UNIQUE (bug_id, change_ts)
);