WITH TIME AS (
    SELECT planet_id, count(planet_id) as times
    FROM flight
    GROUP BY planet_id
), VISITS AS (
    SELECT TIME.planet_id, commander_id
    FROM TIME JOIN flight ON TIME.planet_id = flight.planet_id
    WHERE times = 1
), COUNTED AS (
    SELECT commander_id, count(commander_id) as cnt
    FROM VISITS
    GROUP BY VISITS.commander_id
)
SELECT commander_id, commander.name, cnt
FROM COUNTED JOIN commander ON COUNTED.commander_id = commander.id;