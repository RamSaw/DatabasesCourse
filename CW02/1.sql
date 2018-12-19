--почему-то не зашло у робота--
WITH only_the_same as (
SELECT plantation.country_id, count(*) as num FROM plantation JOIN americanport ON plantation.port_id = americanport.id WHERE americanport.country_id = plantation.country_id
GROUP BY plantation.country_id
), together as (
SELECT country_id, count(*) as number FROM plantation GROUP BY country_id
), countries as (
  SELECT only_the_same.country_id, number, num FROM only_the_same JOIN together ON only_the_same.country_id = together.country_id WHERE together.number = only_the_same.num
)
SELECT name FROM americancountry JOIN countries ON countries.country_id = americancountry.id;

--зашло у робота--
SELECT americancountry.name FROM (SELECT americancountry.id FROM americancountry EXCEPT (
    SELECT plantation.country_id FROM plantation JOIN americanport ON plantation.port_id = americanport.id
    WHERE americanport.country_id != plantation.country_id
    GROUP BY plantation.country_id
)) as true_contries JOIN americancountry ON true_contries.id = americancountry.id;