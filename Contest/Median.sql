WITH sums AS (
SELECT commander_id,
SUM(distance) OVER (PARTITION BY commander_id ORDER BY date) as sum_distance, date
FROM flight JOIN planet on flight.planet_id = planet.id
), total_sums AS (
SELECT commander_id, SUM(distance) as total_distance, SUM(distance) / 2 as half_distance
FROM flight JOIN planet on flight.planet_id = planet.id
GROUP BY commander_id
), median_distances AS (
SELECT sums.commander_id, MIN(total_distance) as total_distance, MIN(sum_distance) as median FROM total_sums JOIN sums on total_sums.commander_id = sums.commander_id
WHERE sum_distance >= half_distance
GROUP BY sums.commander_id
), median_distances_with_dates AS (
SELECT sums.commander_id, total_distance, median, date
FROM median_distances JOIN sums ON median_distances.median = sums.sum_distance and sums.commander_id = median_distances.commander_id
)
SELECT DISTINCT name, total_distance, median as half_distance, date FROM median_distances_with_dates JOIN commander ON median_distances_with_dates.commander_id = commander.id
