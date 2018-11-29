WITH day AS (
    SELECT spacecraft_id,
           COALESCE(lag(flight.date) OVER (PARTITION BY spacecraft_id ORDER BY date DESC) - date, 0) as day_delay
    FROM flight
)
SELECT spacecraft_id, spacecraft.name::TEXT, day_delay::INT
FROM day JOIN spacecraft ON spacecraft.id = spacecraft_id
WHERE day_delay = (SELECT MAX(day_delay) FROM day);