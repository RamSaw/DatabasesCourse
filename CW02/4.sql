WITH trips AS (
SELECT *
FROM seacargo JOIN seacargoprice s on seacargo.price_id = s.id
), trips_ships AS (
SELECT *
FROM trips JOIN ship on trips.ship = ship.id
), volume AS (
SELECT trips_ships.eu_port, SUM(trips_ships.capacity) as vol_port FROM trips_ships GROUP BY trips_ships.eu_port
), volume_country AS (
  SELECT country_id as c_id, SUM(volume.vol_port) as country_volume FROM volume JOIN europeanport ON volume.eu_port = europeanport.id GROUP BY country_id
), volume_with_country AS (
SELECT * FROM volume JOIN europeanport ON volume.eu_port = europeanport.id
), no_percent AS (
SELECT * FROM volume_with_country JOIN volume_country ON volume_with_country.country_id = volume_country.c_id
)
SELECT no_percent.eu_port, no_percent.c_id, no_percent.vol_port, ROUND(no_percent.vol_port / no_percent.country_volume * 100, 2) FROM no_percent