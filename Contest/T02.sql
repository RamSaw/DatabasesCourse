--v1--
WITH Counts AS (
    SELECT commander_id, count(*) as flight_count,
           (count(commander_id) * 1.0 / (SELECT count(*) FROM flight))::NUMERIC(4, 2) as flight_pctg
    FROM flight
    GROUP BY commander_id
)
SELECT commander.name, COALESCE(counts.flight_count, 0), COALESCE(counts.flight_pctg, 0)
FROM commander LEFT OUTER JOIN counts ON counts.commander_id = commander.id;

--v2--
select name, count(flight.id),
(count(flight.id) * 1.0 / (select count(*) from flight))::NUMERIC(4,2)
from flight right outer join commander
on commander_id = commander.id
group by commander.name