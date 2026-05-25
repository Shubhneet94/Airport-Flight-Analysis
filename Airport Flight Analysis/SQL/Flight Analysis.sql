create database flight_analysis;
use flight_analysis;
select*from meta_data;

## Airport , Flight, route , Paseengers and city

Create Table Airline (
AIRLINE_ID int primary key,
UNIQUE_CARRIER varchar(250),
UNIQUE_CARRIER_NAME varchar(250),
UNIQUE_CARRIER_ENTITY varchar(250)
);


select *from Airline;


drop table Airline;

create table Airport(
AIRPORT_ID int primary key ,
AIRPORT_SEQ_ID int,
CITY_MARKET_ID int, 
AIRPORT_CODE varchar(40),
CITY_NAME varchar(100),
STATE_ABR varchar(2),
STATE_FIPS int,
STATE_NM varchar(100),
WAC int
);

create table Flight(
FLIGHT_ID int auto_increment primary key,
AIRLINE_ID int,
ORIGIN_AIRPORT_ID int,
DEST_AIRPORT_ID int,
DISTANCE float,
DISTANCE_GROUP int,
YEAR int,
QUARTER int,
MONTH int,
CLASS char(1),
foreign key (AIRLINE_ID) references Airline(AIRLINE_ID),
foreign key (ORIGIN_AIRPORT_ID) references Airport(AIRPORT_ID),
foreign key (DESI_AIRPORT_ID) references Airport(AIRPORT_ID)
);

Alter table flight change column DESI_AIRPORT_ID DEST_AIRPORT_ID INT;

create table FlightMetrics(
FLIGHT_ID int, 
PASSANGERS float,
FREIGHT float,
MAIL float,
foreign key (FLIGHT_ID) references Flight(FLIGHT_ID)
);

create table City(
CITY_ID int auto_increment primary key,
CITYNAME varchar(100),
STATE_ABR varchar(2),
STATE_NM varchar(100),
unique (CITYNAME, STATE_ABR)
);

describe city;

Insert ignore into Airline(AIRLINE_ID, UNIQUE_CARRIER, UNIQUE_CARRIER_NAME, UNIQUE_CARRIER_ENTITY)
select distinct
AIRLINE_ID,
UNIQUE_CARRIER, 
UNIQUE_CARRIER_NAME,
UNIQUE_CARRIER_ENTITY
from meta_data
where AIRLINE_ID is not null;

select*from Airline;

select count(distinct airline_id)from Airline;

select * from meta_data;

-- ORGIN Airports

Insert into Airport (AIRPORT_ID, AIRPORT_SEQ_ID, CITY_MARKET_ID, AIRPORT_CODE, CITY_NAME, 
STATE_ABR, STATE_FIPS, STATE_NM, WAC)
SELECT DISTINCT 
ORIGIN_AIRPORT_ID, 
ORIGIN_AIRPORT_SEQ_ID,
ORIGIN_CITY_MARKET_ID, 
ORIGIN,
ORIGIN_CITY_NAME,
ORIGIN_STATE_ABR,
ORIGIN_STATE_FIPS,
ORIGIN_STATE_NM,
ORIGIN_WAC
from meta_data;

Insert into Airport(AIRPORT_ID, AIRPORT_SEQ_ID, CITY_MARKET_ID, AIRPORT_CODE, CITY_NAME, 
STATE_ABR, STATE_FIPS, STATE_NM, WAC)

SELECT distinct

DEST_AIRPORT_ID, 
DEST_AIRPORT_SEQ_ID,
DEST_CITY_MARKET_ID, 
DEST,
DEST_CITY_NAME,
DEST_STATE_ABR,
DEST_STATE_FIPS,
DEST_STATE_NM,
DEST_WAC
from meta_data
where DEST_AIRPORT_ID NOT IN (
SELECT AIRPORT_ID from airport
);


select*from Airport;


insert into flight (AIRLINE_ID, ORIGIN_AIRPORT_ID, DEST_AIRPORT_ID, DISTANCE,
DISTANCE_GROUP, YEAR, QUARTER, MONTH, CLASS)
SELECT
AIRLINE_ID, 
ORIGIN_AIRPORT_ID, 
DEST_AIRPORT_ID,
DISTANCE,
DISTANCE_GROUP,
YEAR,
QUARTER,
MONTH,
CLASS
from meta_data;

select*from flight;

Insert into City(CITYNAME, STATE_ABR, STATE_NM)
SELECT DISTINCT
ORIGIN_CITY_NAME, 
ORIGIN_STATE_ABR,
ORIGIN_STATE_NM
From meta_data;

INSERT IGNORE INTO City(CITYNAME, STATE_ABR, STATE_NM)
SELECT DISTINCT
    ORIGIN_CITY_NAME,
    ORIGIN_STATE_ABR,
    ORIGIN_STATE_NM
FROM meta_data;

describe city;
SHOW INDEX FROM City;
ALTER TABLE City DROP INDEX CITYNAME;
ALTER TABLE City 
ADD UNIQUE (CITYNAME, STATE_ABR);
select* from Flight;


insert into City (CITYNAME, STATE_ABR, STATE_NM)
select distinct
DEST_CITY_NAME,
DEST_STATE_ABR,
DEST_STATE_NM
from meta_data
where DEST_CITY_NAME NOT IN (
SELECT CITYNAME from City);

select*from city;
Alter table flightmetrics change column PASSANGERS PASSENGERS float;

INSERT INTO FlightMetrics (
    FLIGHT_ID, PASSENGERS, FREIGHT, MAIL
)
SELECT
    f.FLIGHT_ID,
    m.PASSENGERS,
    m.FREIGHT,
    m.MAIL
FROM meta_data m
JOIN Flight f
  ON f.AIRLINE_ID = m.AIRLINE_ID
 AND f.ORIGIN_AIRPORT_ID = m.ORIGIN_AIRPORT_ID
 AND f.DEST_AIRPORT_ID = m.DEST_AIRPORT_ID
 AND f.YEAR = m.YEAR
 AND f.MONTH = m.MONTH
 AND f.QUARTER = m.QUARTER
 AND f.DISTANCE = m.DISTANCE;
 
 SELECT FREIGHT 
FROM meta_data 
WHERE FREIGHT NOT REGEXP '^[0-9.]+$';
SET SQL_SAFE_UPDATES = 0;
UPDATE meta_data
SET FREIGHT = NULL
WHERE FREIGHT NOT REGEXP '^[0-9.]+$';
SET SQL_SAFE_UPDATES = 1;

select*from flightmetrics;
 
select * from flight;


## Data Analysis

## Route wise flight analysis 

select 
	f.ORIGIN_AIRPORT_ID, 
	f.DEST_AIRPORT_ID,
	a1.CITY_NAME AS ORIGIN_CITY,
	a2.CITY_NAME AS DEST_CITY,
	SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS
FROM Flight f
JOIN Flightmetrics fm ON f.FLIGHT_ID =fm.FLIGHT_ID
JOIN Airport a1 ON f.ORIGIN_AIRPORT_ID = a1.AIRPORT_ID
JOIN Airport a2 ON f.DEST_AIRPORT_ID = a2.AIRPORT_ID
GROUP BY f.ORIGIN_AIRPORT_ID, f.DEST_AIRPORT_ID
ORDER BY TOTAL_PASSENGERS DESC;

select
	f.ORIGIN_AIRPORT_ID,
	f.DEST_AIRPORT_ID,
	a1.CITY_NAME AS ORIGIN_CITY,
	a2.CITY_NAME AS DEST_CITY,
	SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS
from flight f
JOIN flightmetrics fm ON f.FLIGHT_ID= fm.FLIGHT_ID
JOIN airport a1 ON  f.ORIGIN_AIRPORT_ID= a1.AIRPORT_ID
JOIN airport a2 ON f.DEST_AIRPORT_ID = a2. AIRPORT_ID
GROUP BY f.ORIGIN_AIRPORT_ID ,f.DEST_AIRPORT_ID
ORDER BY TOTAL_PASSENGERS DESC
limit 10;

# Total Passangers Served in the duration

select 
	f.YEAR,
	f.MONTH,
	round (SUM(fm.PASSENGERS)/1000000, 2) as Total_Passengers
from flight f
JOIN flightmetrics fm on f.FLIGHT_ID = fm.FLIGHT_ID
GROUP BY f.YEAR , f.MONTH
ORDER BY f.YEAR, f.MONTH;

## Determine average passangers per flight for various routes and airports

select 
	f. ORIGIN_AIRPORT_ID,
	a.CITY_NAME AS ORIGIN_CITY,
	COUNT(f.FLIGHT_ID) AS TOTAL_FLIGHTS,
	SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
	round(AVG(fm.PASSENGERS),2) AS AVG_PASSANGERS_PER_FLIGHT
from Flight f
JOIN Flightmetrics fm on fm.FLIGHT_ID = f.FLIGHT_ID
JOIN Airport a on f.ORIGIN_AIRPORT_ID = a.AIRPORT_ID
GROUP BY f.ORIGIN_AIRPORT_ID
ORDER BY AVG_PASSANGERS_PER_FLIGHT DESC;

## Average Passangers Per Destination City

SELECT
	f.DEST_AIRPORT_ID,
	a.CITY_NAME AS DEST_CITY,
	COUNT(f.FLIGHT_ID) AS TOTAL_FLIGHTS,
	SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS
from Flight f
 JOIN flightmetrics fm on fm. FLIGHT_ID= f.FLIGHT_ID
 JOIN Airport a on a.AIRPORT_ID= f.DEST_AIRPORT_ID
 GROUP BY f.DEST_AIRPORT_ID
 ORDER BY TOTAL_PASSENGERS DESC
 limit 10;


### Asses flight frequency and identify high-traffic corridors 
# To assess flight frequancy and identify high-traffic corridors, we will:
# 1. Count how often each route (origin --> distination) appears -thats flight frequancy.
# 2. Identify routes with the highest number of flights - these are high-traffic corridors.

Select
	f.ORIGIN_AIRPORT_ID,
	f.DEST_AIRPORT_ID,
	a1.CITY_NAME AS ORIGIN_CITY,
	a2.CITY_NAME AS DEST_CITY,
	COUNT(*) AS FLIGHT_COUNT
FROM Flight f
JOIN Airport a1 ON a1.AIRPORT_ID=f.ORIGIN_AIRPORT_ID
JOIN Airport a2 ON a2.AIRPORT_ID=f.DEST_AIRPORT_ID
GROUP BY f.ORIGIN_AIRPORT_ID, f.DEST_AIRPORT_ID
ORDER BY FLIGHT_COUNT DESC
limit 10;		

## Compare Passanger numbers across origin cities to identify top-performing airports.
## Total Passangers and Total NO. of FLights 

select 
	f.ORIGIN_AIRPORT_ID,
	a.CITY_NAME as ORIGIN_CITY,
	SUM(fm.PASSENGERS) as TOTAL_PASSENGERS,
	COUNT(f.FLIGHT_ID) AS FLIGHT_COUNT
from Flight f
Join flightmetrics fm on fm.FLIGHT_ID = f.FLIGHT_ID
Join Airport a on a.AIRPORT_ID= f.ORIGIN_AIRPORT_ID
GROUP BY ORIGIN_AIRPORT_ID
ORDER BY TOTAL_PASSENGERS DESC;

#DEST CITY

Select
	f.DEST_AIRPORT_ID,
	a.CITY_NAME as DEST_CITY,
	SUM(fm.PASSENGERS) as TOTAL_PASSENGERS,
	COUNT(f.FLIGHT_ID) as FLIGHT_COUNT
from Flight f
JOIN flightmetrics fm on fm.FLIGHT_ID=f.FLIGHT_ID
JOIN Airport a on a.Airport_ID=f.DEST_AIRPORT_ID
GROUP BY DEST_AIRPORT_ID
ORDER BY TOTAL_PASSENGERS DESC;


## Corelation between Population and Air Traffic
select*from city;
select*from  all_city_pop;

select substring_index (CITYNAME,',',1) as City_name, State_ABR,
State_NM, Population
from city c
left join all_city_pop as a
on a.city_name = c.CITYNAME;

update city
set CITYNAME= SUBSTRING_INDEX(cityname, ',',1);

SET SQl_Safe_Updates=0;

select*from city_new;



create table City_New
(select CITY_ID, substring_index (CITYNAME,',',1) as City_name, STATE_ABR,
STATE_NM, Population
from city c
left join all_city_pop AS a
on a.city_name = c.CITYNAME);


## Analyze the relation between city population and airport
## cities as ORIGIN
 
Select
	c.city_name,
	c.Population,
	SUM(fm.PASSENGERS) as Total_Passengers,
	round(SUM(fm.PASSENGERS)/c.Population,2) as Pass_Pop_Ratio
From city c
Join Airport a 
	on a.CITY_NAME=c.City_name
Join Flight f 
	on f.ORIGIN_AIRPORT_ID=a.AIRPORT_ID
Join flightmetrics fm 
	on f.FLIGHT_ID = fm.FLIGHT_ID
Group by c.City_name , c.Population
Order by Pass_Pop_Ratio DESC;

Alter table city_new rename city;

Update airport
set CITY_NAME=substring_index(city_name,',',1);

SET SQL_Safe_Updates=0;

##Cities of Destionation

Select
	c.City_name,
	c.Population,
	SUM(fm.PASSENGERS) As Total_Population,
	round(SUM(fm.PASSENGERS)/c.Population) as Pass_Pop_Ratio
from city c

join Airport a 
	on a.CITY_NAME = c.City_name

join flight f 
	on f.DEST_AIRPORT_ID=a.AIRPORT_ID

join flightmetrics fm 
	on fm.FLIGHT_ID=f.FLIGHT_ID	

Group by c.City_name, c.Population
Order by Pass_Pop_Ratio;



CREATE VIEW route_summary AS
SELECT
    f.ORIGIN_AIRPORT_ID,
    f.DEST_AIRPORT_ID,
    a1.CITY_NAME AS ORIGIN_CITY,
    a2.CITY_NAME AS DEST_CITY,
    SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,
    COUNT(f.FLIGHT_ID) AS TOTAL_FLIGHTS
FROM Flight f

JOIN FlightMetrics fm
	ON f.FLIGHT_ID = fm.FLIGHT_ID

JOIN Airport a1
	ON a1.AIRPORT_ID = f.ORIGIN_AIRPORT_ID

JOIN Airport a2
	ON a2.AIRPORT_ID = f.DEST_AIRPORT_ID

GROUP BY
	f.ORIGIN_AIRPORT_ID,
	f.DEST_AIRPORT_ID;


-- Identifying Top Airline By Passengers

SELECT
	a.UNIQUE_CARRIER_NAME,
	SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS
FROM Flight f

JOIN Airline a
	ON a.AIRLINE_ID = f.AIRLINE_ID

JOIN FlightMetrics fm
	ON fm.FLIGHT_ID = f.FLIGHT_ID

GROUP BY a.UNIQUE_CARRIER_NAME
ORDER BY TOTAL_PASSENGERS DESC;


-- Monthly Growth  Rate of Passangers 

WITH monthly_data AS 
(
	SELECT
		YEAR,
		MONTH,
		SUM(fm.PASSENGERS) AS passengers
FROM Flight f

JOIN FlightMetrics fm
	ON f.FLIGHT_ID = fm.FLIGHT_ID

GROUP BY YEAR, MONTH
)

SELECT
	YEAR,
	MONTH,
	passengers,
	LAG(passengers) OVER(ORDER BY YEAR, MONTH) AS prev_month,
	ROUND(
			((passengers -
			LAG(passengers) OVER(ORDER BY YEAR, MONTH))
			/
			LAG(passengers) OVER(ORDER BY YEAR, MONTH))*100,2
			) AS growth_percentage
FROM monthly_data;


-- Ranking Airports by Traffic

SELECT
	a.CITY_NAME,
	SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS,

RANK() OVER(
	ORDER BY SUM(fm.PASSENGERS) DESC
	) AS airport_rank
FROM Flight f

JOIN FlightMetrics fm
	ON fm.FLIGHT_ID = f.FLIGHT_ID

JOIN Airport a
	ON a.AIRPORT_ID = f.ORIGIN_AIRPORT_ID

GROUP BY a.CITY_NAME;


-- Indentifying Busiest Quarter


SELECT
	QUARTER,
	SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS
FROM Flight f

JOIN FlightMetrics fm
	ON fm.FLIGHT_ID = f.FLIGHT_ID

GROUP BY QUARTER
ORDER BY TOTAL_PASSENGERS DESC;

-- Do Frieght vs Passangers Analysis 

SELECT
	a.CITY_NAME,
	SUM(fm.PASSENGERS) AS passengers,
	SUM(fm.FREIGHT) AS freight
FROM Flight f

JOIN FlightMetrics fm
	ON fm.FLIGHT_ID = f.FLIGHT_ID

JOIN Airport a
	ON a.AIRPORT_ID = f.ORIGIN_AIRPORT_ID

GROUP BY a.CITY_NAME
ORDER BY freight DESC;

-- Add Indexing (Very Important)

CREATE INDEX idx_flight_airline
	ON Flight(AIRLINE_ID);

CREATE INDEX idx_origin_dest
	ON Flight(ORIGIN_AIRPORT_ID, DEST_AIRPORT_ID);

CREATE INDEX idx_flightmetrics
	ON FlightMetrics(FLIGHT_ID);

-- Create Stored Procedure

DELIMITER //

CREATE PROCEDURE GetTopRoutes()
BEGIN
	SELECT
		a1.CITY_NAME AS ORIGIN_CITY,
		a2.CITY_NAME AS DEST_CITY,
		SUM(fm.PASSENGERS) AS TOTAL_PASSENGERS
FROM Flight f

JOIN FlightMetrics fm
	ON fm.FLIGHT_ID = f.FLIGHT_ID

JOIN Airport a1
	ON a1.AIRPORT_ID = f.ORIGIN_AIRPORT_ID

JOIN Airport a2
	ON a2.AIRPORT_ID = f.DEST_AIRPORT_ID

GROUP BY
	a1.CITY_NAME,
	a2.CITY_NAME
	ORDER BY TOTAL_PASSENGERS DESC

LIMIT 10;
END //

DELIMITER ;


select * from meta_data;

use airport_data ;


