-- loadflights.sql

DROP TABLE IF EXISTS airlines;
DROP TABLE IF EXISTS airports;
DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS planes;
DROP TABLE IF EXISTS weather;

CREATE TABLE airlines (
  carrier varchar(2) PRIMARY KEY,
  name varchar(30) NOT NULL
  );
  
LOAD DATA INFILE '/var/lib/mysql-files/airlines.csv' 
INTO TABLE airlines 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE airports (
  faa char(3),
  name varchar(100),
  lat double precision,
  lon double precision,
  alt integer,
  tz integer,
  dst char(1)
  );
  
LOAD DATA INFILE '/var/lib/mysql-files/airports.csv' 
INTO TABLE airports
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE flights (
year integer,
month integer,
day integer,
dep_time integer,
dep_delay integer,
arr_time integer,
arr_delay integer,
carrier char(2),
tailnum char(6),
flight integer,
origin char(3),
dest char(3),
air_time integer,
distance integer,
hour integer,
minute integer
);

LOAD DATA INFILE '/var/lib/mysql-files/flights.csv' 
INTO TABLE flights
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(year, month, day, @dep_time, @dep_delay, @arr_time, @arr_delay,
 @carrier, @tailnum, @flight, origin, dest, @air_time, @distance, @hour, @minute)
SET
dep_time = nullif(@dep_time,''),
dep_delay = nullif(@dep_delay,''),
arr_time = nullif(@arr_time,''),
arr_delay = nullif(@arr_delay,''),
carrier = nullif(@carrier,''),
tailnum = nullif(@tailnum,''),
flight = nullif(@flight,''),
air_time = nullif(@air_time,''),
distance = nullif(@distance,''),
hour = dep_time / 100,
minute = dep_time % 100
;

CREATE TABLE planes (
tailnum char(6),
year integer,
type varchar(50),
manufacturer varchar(50),
model varchar(50),
engines integer,
seats integer,
speed integer,
engine varchar(50)
);

LOAD DATA INFILE '/var/lib/mysql-files/planes.csv' 
INTO TABLE planes
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(tailnum, @year, type, manufacturer, model, engines, seats, @speed, engine)
SET
year = nullif(@year,''),
speed = nullif(@speed,'')
;

CREATE TABLE weather (
origin char(3),
year integer,
month integer,
day integer,
hour integer,
temp double precision,
dewp double precision,
humid double precision,
wind_dir integer,
wind_speed double precision,
wind_gust double precision,
precip double precision,
pressure double precision,
visib double precision
);

LOAD DATA INFILE '/var/lib/mysql-files/weather.csv' 
INTO TABLE weather
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(origin, @year, @month, @day, @hour, @temp, @dewp, @humid, @wind_dir,
@wind_speed, @wind_gust, @precip, @pressure, @visib)
SET
year = nullif(@year,''),
month = nullif(@month,''),
day = nullif(@day,''),
hour = nullif(@hour,''),
temp = nullif(@temp,''),
dewp = nullif(@dewp,''),
humid = nullif(@humid,''),
wind_dir = FORMAT(@wind_dir, 0),
wind_speed = nullif(@wind_speed,''),
wind_gust = nullif(@wind_gust,''),
precip = nullif(@precip,''),
pressure = nullif(@pressure,''),
visib = FORMAT(@visib,0)
;

SET SQL_SAFE_UPDATES = 0;
UPDATE planes SET engine = SUBSTRING(engine, 1, CHAR_LENGTH(engine)-1);

-- SELECT 'airlines', COUNT(*) FROM airlines
--   UNION
-- SELECT 'airports', COUNT(*) FROM airports
--   UNION
-- SELECT 'flights', COUNT(*) FROM flights
--   UNION
-- SELECT 'planes', COUNT(*) FROM planes
--   UNION
-- SELECT 'weather', COUNT(*) FROM weather;

-- How many airplanes have listed speeds, what are the minimum and maximum speeds?

-- How many - 23
-- Min - 90
-- Max 432

select * from planes
where speed is not Null
order by speed desc;

-- Total distances flown january 2013 with and without tailnums.

-- Distance - 27188805
select sum(distance) from flights
where year = '2013' and month = '1';

-- Distance without tailnum - None
select sum(distance) from flights
where year = '2013' and month = '1' and tailnum is null;

-- Distances flown by manufacturer with inner and outer join statements

select planes.manufacturer, sum(flights.distance)
from planes
inner join flights
on planes.tailnum = flights.tailnum
where flights.year = '2013'
 and flights.month = '7'
 and flights.day = '5'
group by manufacturer;

select planes.manufacturer, sum(flights.distance)
from planes
left outer join flights
on planes.tailnum = flights.tailnum
where flights.year = '2013'
  and flights.month = '7'
  and flights.day = '5'
group by manufacturer;

-- Which airline had the most boeing flights on 2013/04/20?

select * from airlines;
select * from flights;
select * from planes;


