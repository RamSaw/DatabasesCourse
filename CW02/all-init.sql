CREATE SCHEMA IF NOT EXISTS Contest;
SET search_path=Contest;

CREATE OR REPLACE FUNCTION GenNickname(fnames TEXT[], lnames TEXT[]) RETURNS TEXT AS $$
DECLARE
    _result TEXT;
BEGIN
WITH FirstName AS (
    SELECT unnest(fnames) AS value, generate_series(1, array_length(fnames, 1)) AS id
),
LastName AS (
    SELECT unnest(lnames) AS value, generate_series(1, array_length(lnames, 1)) AS id
),
Randoms AS (
    SELECT (0.5 + random() * (SELECT MAX(id) FROM FirstName))::INT AS fname_id,
           (0.5 + random() * (SELECT MAX(id) FROM LastName))::INT AS lname_id
)
SELECT F.value || ' ' || L.value INTO _result
FROM FirstName F JOIN Randoms R ON F.id = R.fname_id JOIN LastName L ON L.id = R.lname_id;
RETURN _result;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION GenNickname() RETURNS TEXT AS $$
DECLARE
    fnames TEXT[];
    lnames TEXT[];
    _result TEXT;
BEGIN
fnames = ARRAY['admiring', 'adoring', 'agitated', 'amazing', 'angry', 'awesome',
    'backstabbing', 'berserk', 'big', 'boring', 'clever', 'cocky', 'compassionate',
    'condescending', 'cranky', 'desperate', 'determined', 'distracted', 'dreamy',
    'drunk', 'ecstatic', 'elated', 'elegant', 'evil', 'fervent', 'focused', 'furious',
    'gigantic', 'gloomy', 'goofy', 'grave', 'happy', 'high', 'hopeful', 'hungry',
    'insane', 'jolly', 'jovial', 'kickass', 'lonely', 'loving', 'mad', 'modest',
    'naughty', 'nauseous', 'nostalgic', 'pedantic', 'pensive', 'prickly', 'reverent',
    'romantic', 'sad', 'serene', 'sharp', 'sick', 'silly', 'sleepy', 'small', 'stoic',
    'stupefied', 'suspicious', 'tender', 'thirsty', 'tiny', 'trusting'];
lnames = ARRAY['albattani', 'allen', 'almeida', 'archimedes', 'ardinghelli', 'aryabhata',
    'austin', 'babbage', 'banach', 'bardeen', 'bartik', 'bassi', 'bell', 'bhabha', 'bhaskara',
    'blackwell', 'bohr', 'booth', 'borg', 'bose', 'boyd', 'brahmagupta', 'brattain', 'brown',
    'carson', 'chandrasekhar', 'colden', 'cori', 'cray', 'curie', 'darwin', 'davinci', 'dijkstra',
    'dubinsky', 'easley', 'einstein', 'elion', 'engelbart', 'euclid', 'euler', 'fermat', 'fermi',
    'feynman', 'franklin', 'galileo', 'gates', 'goldberg', 'goldstine', 'golick', 'goodall',
    'hamilton', 'hawking', 'heisenberg', 'heyrovsky', 'hodgkin', 'hoover', 'hopper', 'hugle',
    'hypatia', 'jang', 'jennings', 'jepsen', 'joliot', 'jones', 'kalam', 'kare', 'keller',
    'khorana', 'kilby', 'kirch', 'knuth', 'kowalevski', 'lalande', 'lamarr', 'leakey',
    'leavitt', 'lichterman', 'liskov', 'lovelace', 'lumiere', 'mahavira', 'mayer', 'mccarthy',
    'mcclintock', 'mclean', 'mcnulty', 'meitner', 'meninsky', 'mestorf', 'mirzakhani', 'morse',
    'newton', 'nobel', 'noether', 'northcutt', 'noyce', 'panini', 'pare', 'pasteur', 'payne',
    'perlman', 'pike', 'poincare', 'poitras', 'ptolemy', 'raman', 'ramanujan', 'ride', 'ritchie',
    'roentgen', 'rosalind', 'saha', 'sammet', 'shaw', 'shockley', 'sinoussi', 'snyder', 'spence',
    'stallman', 'swanson', 'swartz', 'swirles', 'tesla', 'thompson', 'torvalds', 'turing', 'varahamihira',
    'visvesvaraya', 'wescoff', 'williams', 'wilson', 'wing', 'wozniak', 'wright', 'yalow', 'yonath'];
SELECT Contest.GenNickname(fnames, lnames) INTO _result;
RETURN _result;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION GenGauss() RETURNS DOUBLE PRECISION AS $$
SELECT (random()+random()+random()+random()+random()) / 5::DOUBLE PRECISION;
$$ LANGUAGE SQL;
