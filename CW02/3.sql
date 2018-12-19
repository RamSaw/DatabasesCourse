WITH ship_am_port AS (
SELECT * FROM ship LEFT OUTER JOIN seacargoprice s on ship.id = s.ship
), trips AS (
SELECT seacargoprice.ship, seacargoprice.am_port, count(*) as num FROM seacargoprice JOIN seacargo on seacargo.price_id = seacargoprice.id
GROUP BY seacargoprice.ship, seacargoprice.am_port
), m as (
SELECT trips.ship, MAX(num) as max_for_ship FROM trips GROUP BY trips.ship
), res as (
    SELECT trips.ship, num, am_port
    FROM m
           JOIN trips ON trips.ship = m.ship
    WHERE m.max_for_ship = trips.num
), no_port_names AS (
    SELECT name, COALESCE(res.am_port, NULL) as port, COALESCE(res.num, 0) as num
    FROM ship
           LEFT OUTER JOIN res ON res.ship = ship.id
)
SELECT no_port_names.name as ship_name, COALESCE(americanport.name, NULL) as port_name, no_port_names.num as transfer_cnt
FROM no_port_names LEFT OUTER JOIN americanport on no_port_names.port = americanport.id