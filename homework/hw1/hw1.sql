select COUNT(*)
from flight_delays;

SELECT name
FROM sqlite_master
WHERE type = 'table'
  AND name NOT LIKE 'sqlite_%';

SELECT avg(arr_delay)
from flight_delays
where year = 2017
  and month = 7;

SELECT max(arr_delay)
from flight_delays
where year = 2017
  and month = 7;

-- In the cell below, write a SQL query that returns the
-- carrier (i.e., carrier),
-- flight number,
-- origin city name,
-- arrival city name,
-- and flight date
-- for the flight with the maximum arrival delay for the entire month of July 2017. Do not hard-code the arrival delay you found above. Hint: use a subquery.

select carrier, fl_num, origin_city_name, dest_city_name, fl_date
from flight_delays
where arr_delay = (SELECT max(arr_delay)
                   from flight_delays
                   where year = 2017
                     and month = 7);

-- In the cell below, write a SQL query that returns the
-- average arrival delay time for each day of the week,
-- in descending order.
-- The schema of your relation should be of the form (weekday_name, average_delay).
--
-- Note: do not report the weekday ID. (Hint: look at the weekdays table and perform a join to obtain the weekday name.)

select *
from weekdays;
-- select Count(*) from weekdays

select avg(flight_delays.arr_delay), weekdays.weekday_name
from flight_delays
         inner join weekdays
                    on weekdays.weekday_id = flight_delays.day_of_week
group by day_of_week
order by avg(flight_delays.arr_delay) desc;

-- SELECT avg(flight_delays.arr_delay), weekdays.weekday_name
-- from flight_delays
--          inner join weekdays on weekdays.weekday_id = flight_delays.day_of_week;


-- Query 5: Which airlines that fly out of SFO are delayed least?
-- Now that I know which days to avoid, I'm curious which airline I should fly out of SFO. Since I haven't been told
-- where I'm flying, please just compute the average for the airlines that fly from SFO.
--
-- In the cell below, write a SQL query that returns the average arrival delay time (across all flights) for each
-- carrier that flew out of SFO at least once in July 2017 (i.e., in the current dataset), in descending order.
--
-- Note: do not report the airlines ID. (Hint: a subquery is helpful here; also, look at the airlines table and
-- perform a join.)


select airline_id
from flight_delays
where origin = 'SFO'
group by airline_id;

-- correct airlines but incorrect value
select airline_name, avg(arr_delay)
from flight_delays
         inner join airlines
                    on flight_delays.airline_id = airlines.airline_id
where origin = 'SFO'
  and year = 2017
  and month = 7
group by airline_name
order by avg(arr_delay) desc;

-- correct airlines but incorrect value
select avg(arr_delay)
from (
         select *
         from flight_delays
         where origin = 'SFO')
group by airline_id
order by avg(arr_delay) desc;

-- correct values but two extra airlines
select avg(arr_delay)
from flight_delays
where exists
          (
              select *
              from flight_delays
              where origin = 'SFO'
          )
group by airline_id
order by avg(arr_delay) desc;

-- correct
select airline_name, avg(arr_delay)
from flight_delays
         inner join airlines
                    on flight_delays.airline_id = airlines.airline_id
where flight_delays.airline_id in
      (
          select flight_delays.airline_id
          from flight_delays
          where origin = 'SFO'
      )
group by airline_name
order by avg(arr_delay) desc;

-- Query 6: What proportion of airlines are regularly late?
--
-- Yeesh, there are a lot of late flights! How many airlines are regularly late?
--
-- In the cell below, write a SQL query that returns the proportion of airlines (appearing in flight_delays) whose
-- flights are on average at least 10 minutes late to arrive. Do not hard-code the total number of airlines, and
-- make sure to use at least one HAVING clause in your SQL query.
--
-- Note: sqlite COUNT(*) returns integer types. Therefore, your query should likely contain at least one
-- SELECT CAST (COUNT(*) AS float) or a clause like COUNT(*)*1.0.


select count(*)
from (
         SELECT airline_id
         from flight_delays
         group by airline_id
         having avg(arr_delay) >= 10);

select CAST(count(distinct airline_id) as float)
from flight_delays;

SELECT (select count(*)
        from (
                 SELECT airline_id
                 from flight_delays
                 group by airline_id
                 having avg(arr_delay) >= 10))
           /
       (select CAST(count(distinct airline_id) as float)
        from flight_delays)
           as late_proportion;


-- Query 7: How do late departures affect late arrivals?
------------------------
-- It sure looks like my plane is likely to be delayed. I'd like to know: if my plane is delayed in taking off,
-- how will it affect my arrival time?
--
-- The [sample covariance](https://en.wikipedia.org/wiki/Covariance) provides a measure of the joint variability
-- of two variables. The higher the covariance, the more the two variables behave similarly, and negative covariance
-- indicates the variables indicate the variables tend to be inversely related. We can compute the sample covariance as:
-- $$
-- Cov(X,Y) = \frac{1}{n-1} \sum_{i=1}^n (x_i-\hat{x})(y_i-\hat{y})
-- $$
-- where $x_i$ denotes the $i$th sample of $X$, $y_i$ the $i$th sample of $Y$, and the mean of $X$ and $Y$ are denoted
-- by $\bar{x}$ and $\bar{y}$.
--
-- In the cell below, write a single SQL query that computes the covariance between the departure delay time and the
-- arrival delay time.
--
-- *Note: we could also compute a statistic like the [Pearson correlation coefficient](https://en.wikipedia.org/wiki/
-- Pearson_correlation_coefficient) here, which provides a normalized measure (i.e., on a scale from -1 to 1) of how
-- strongly two variables are related. However, sqlite doesn't natively support square roots (unlike commonly-used re
-- lational databases like PostgreSQL and MySQL!), so we're asking you to compute covariance instead.*

select 1 / (select cast(count(*) as float) - 1 from flight_delays);

select arr_delay - (
    select avg(arr_delay)
    from flight_delays)
from flight_delays;

select dep_delay - (
    select avg(dep_delay)
    from flight_delays)
from flight_delays;

select sum(all
           (
                   arr_delay - (
                   select avg(arr_delay)
                   from flight_delays)
               )
               *
           (
                   dep_delay - (
                   select avg(dep_delay)
                   from flight_delays)
               )
           )
from flight_delays;

select 1
           / (select cast(count(*) as float) - 1 from flight_delays)
           * (select sum(all
                         (
                                 arr_delay - (
                                 select avg(arr_delay)
                                 from flight_delays)
                             )
                             *
                         (
                                 dep_delay - (
                                 select avg(dep_delay)
                                 from flight_delays)
                             )
                         )
              from flight_delays)
           as covariance;

-- Query 8: It was a bad week...
--
-- Which airlines had the largest absolute increase in average arrival delay in the last week of
-- July (i.e., flights on or after July 24th) compared to the previous days (i.e. flights before July 24th)?
--
-- In the cell below, write a single SQL query that returns the airline name (not ID) with the maximum absolute
-- increase in average arrival delay between the first 23 days of the month and days 24-31. Report both the
-- airline name and the absolute increase.
--
-- Note: due to sqlite's handling of dates, it may be easier to query using day_of_month.
--
-- Note 2: This is probably the hardest query of the assignment; break it down into subqueries that you can run
-- one-by-one and build up your answer subquery by subquery.
--
-- Hint: You can compute two subqueries, one to compute the average arrival delay for flights on or after July
-- 24th, and one to compute the average arrival delay for flights before July 24th, and then join the two to
-- calculate the increase in delay.

select airline_id, avg(arr_delay)
from flight_delays
where day_of_month >= 1
  and day_of_month < 24
  and month = 7
  and year = 2017
group by airline_id;

select airline_id, avg(arr_delay)
from flight_delays
where day_of_month >= 24
  and day_of_month <= 31
  and month = 7
  and year = 2017
group by airline_id;

-- get last average
-- subtract first average when id = id

select avg(a.arr_delay), avg(b.arr_delay)
from flight_delays a,
     flight_delays b
where a.day_of_month >= 1
  and a.day_of_month < 24
  and a.month = 7
  and a.year = 2017
  and b.day_of_month >= 24
  and b.day_of_month <= 31
  and b.month = 7
  and b.year = 2017
group by a.airline_id;

select b
from (
         select airline_id, avg(arr_delay) b
         from flight_delays
         where day_of_month >= 24
           and day_of_month <= 31
           and month = 7
           and year = 2017
         group by airline_id
     ) a
where b >
      (
          select avg(arr_delay)
          from flight_delays
          where day_of_month >= 1
            and day_of_month < 24
            and month = 7
            and year = 2017
          group by airline_id
      );

--one right answer, no airline, many mismatches
select (b - a)
from (
         select airline_id, avg(arr_delay) b
         from flight_delays
         where day_of_month >= 24
           and day_of_month <= 31
           and month = 7
           and year = 2017
         group by airline_id
     ) eom
        ,
     (
         select airline_id, avg(arr_delay) a
         from flight_delays
         where day_of_month >= 1
           and day_of_month < 24
           and month = 7
           and year = 2017
         group by airline_id
     ) bom
where eom.airline_id = bom.airline_id;

select (end_of_month_avg - beginning_of_month_avg) delay_change, airline_name, airlines.airline_id
from (
         select airline_id, avg(arr_delay) end_of_month_avg
         from flight_delays
         where day_of_month >= 24
           and day_of_month <= 31
           and month = 7
           and year = 2017
         group by airline_id
     ) end_of_month
        ,
     (
         select airline_id, avg(arr_delay) beginning_of_month_avg
         from flight_delays
         where day_of_month >= 1
           and day_of_month < 24
           and month = 7
           and year = 2017
         group by airline_id
     ) beginning_of_month
         inner join airlines
                    on end_of_month.airline_id = airlines.airline_id
where end_of_month.airline_id = beginning_of_month.airline_id
group by end_of_month.airline_id
order by delay_change desc;

select airline_name, max(delay_change) delay_increase
from (
         select (end_of_month_avg - beginning_of_month_avg) delay_change, end_of_month.airline_id airId
         from (
                  select airline_id, avg(arr_delay) end_of_month_avg
                  from flight_delays
                  where day_of_month >= 24
                    and day_of_month <= 31
                    and month = 7
                    and year = 2017
                  group by airline_id
              ) end_of_month
                 ,
              (
                  select airline_id, avg(arr_delay) beginning_of_month_avg
                  from flight_delays
                  where day_of_month >= 1
                    and day_of_month < 24
                    and month = 7
                    and year = 2017
                  group by airline_id
              ) beginning_of_month
         where end_of_month.airline_id = beginning_of_month.airline_id
     )
         inner join airlines
                    on airId = airlines.airline_id;



-- Query 9: Of Hipsters and Anarchists
-- ------------------------
-- I'm keen to visit both Portland (PDX) and Eugene (EUG), but I can't fit both into the same trip.
-- To maximize my frequent flier mileage, I'd like to use the same flight for each.
-- Which airlines fly both SFO -> PDX and SFO -> EUG?
--
-- In the cell below, write a single SQL query that returns the distinct airline names
-- (_not_ ID, and with no duplicates) that flew both SFO -> PDX and SFO -> EUG in July 2017.

;
select airline_name,

       (
           select distinct airline_id
           from flight_delays
           where origin = 'SFO'
             and dest = 'PDX'
           intersect
           select distinct airline_id
           from flight_delays
           where origin = 'SFO'
             and dest = 'EUG'
       )
from flight_delays
         inner join airlines
                    on flight_delays.airline_id = airlines.airline_id;


SELECT airline_name
from (select distinct flight_delays.airline_id, airlines.airline_name
      from flight_delays
               inner join airlines
                          on flight_delays.airline_id = airlines.airline_id
      where origin = 'SFO'
        and dest = 'PDX'
      intersect
      select distinct flight_delays.airline_id, airlines.airline_name
      from flight_delays
               inner join airlines
                          on flight_delays.airline_id = airlines.airline_id
      where origin = 'SFO'
        and dest = 'EUG');

select distinct airlines.airline_name
from flight_delays
         inner join airlines
                    on flight_delays.airline_id = airlines.airline_id
where origin = 'SFO'
  and dest = 'PDX'
intersect
select distinct airlines.airline_name
from flight_delays
         inner join airlines
                    on flight_delays.airline_id = airlines.airline_id
where origin = 'SFO'
  and dest = 'EUG';


-- Query 10: Decision Fatigue and Equidistance
-- ------------------------
-- I'm flying back to Stanford from Chicago later this month, and I can fly out of
-- either Midway (MDW) or O'Hare (ORD) and can fly into either San Francisco (SFO), San Jose (SJC), or Oakland (OAK).
-- If this month is like July, which leg will have the shortest arrival delay for
-- flights leaving Chicago after 2PM local time?
--
-- In the cell below, write a single SQL query that returns the average arrival delay of flights
-- departing either MDW or ORD after 2PM local time (`crs_dep_time`) and arriving at one of
-- SFO, SJC, or OAK.
-- Group by departure and arrival airport and return results descending by arrival delay.
--
-- Note: the `crs_dep_time` field is an integer formatted as hhmm (e.g. 4:15pm is 1615)

select *
from flight_delays
where crs_dep_time > 1400;

select *
from flight_delays
where crs_dep_time > 1400
intersect
select *
from flight_delays
where origin = 'MDW'
   or 'ORD';

select origin, dest, arr_delay
from flight_delays
where crs_dep_time > 1400
intersect
select origin, dest, arr_delay
from flight_delays
where origin = 'MDW'
   or origin = 'ORD'
intersect
select origin, dest, arr_delay
from flight_delays
where dest = 'SFO'
   or origin = 'SJC'
   or origin = 'OAK';

select distinct dest, origin
from flight_delays
where crs_dep_time > 1400
  and month = 7
  and year = 2017
  and (origin = 'MDW' or origin = 'ORD')
  and (dest = 'SFO' or dest = 'SJC' or dest = 'OAK');

select origin, dest, avg(arr_delay)
from flight_delays
where crs_dep_time > 1400
  and month = 7
  and year = 2017
  and origin = 'MDW'
  and dest = 'SFO';
--
-- select distinct origin, dest, avg(arr_delay)
-- from (
--          select origin, dest, arr_delay
--          from flight_delays
--          where month = 7
--            and year = 2017
--          intersect
--          select origin, dest, arr_delay
--          from flight_delays
--          where crs_dep_time > 1400
--          intersect
--          select origin, dest, arr_delay
--          from flight_delays
--          where origin = 'MDW'
--             or origin = 'ORD'
--          intersect
--          select origin, dest, arr_delay
--          from flight_delays
--          where dest = 'SFO'
--             or dest = 'SJC'
--             or dest = 'OAK'
--      )
-- group by origin, dest
-- order by avg(arr_delay) desc;

select distinct origin, dest, avg(arr_delay)
from flight_delays
where crs_dep_time > 1400
  and month = 7
  and year = 2017
  and (origin = 'MDW' or origin = 'ORD')
  and (dest = 'SFO' or dest = 'SJC' or dest = 'OAK')
group by origin, dest
order by avg(arr_delay) desc;