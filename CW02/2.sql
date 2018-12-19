WITH sh AS (
SELECT eu_port, count(*) as pop FROM seacargo JOIN seacargoprice s on seacargo.price_id = s.id GROUP BY eu_port
), ports AS (
    SELECT * FROM sh WHERE sh.pop = (SELECT MAX(pop) FROM sh)
)
SELECT europeanport.name, pop FROM ports JOIN europeanport on ports.eu_port = europeanport.id