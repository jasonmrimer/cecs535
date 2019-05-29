import sqlite3
from prettytable import from_db_cursor

# copy and paste your SQL queries into each of the below variables
# note: do NOT rename variables

Q1 = '''
select avg(arr_delay) avg_delay
from flight_delays 
where year=2017 
           and month=7;
'''

Q2 = '''
SELECT max(arr_delay) max_delay
from flight_delays 
where year=2017
           and month=7;
'''

Q3 = '''
select carrier, fl_num, origin_city_name, dest_city_name, fl_date
from flight_delays
where arr_delay = (SELECT max(arr_delay)
                   from flight_delays
                   where year = 2017
                     and month = 7);
'''

Q4 = '''
select weekdays.weekday_name, avg(flight_delays.arr_delay) avg_delay
from flight_delays
         inner join weekdays
                    on weekdays.weekday_id = flight_delays.day_of_week
group by day_of_week
order by avg(flight_delays.arr_delay) desc;
'''

Q5 = '''
select airline_name, avg(arr_delay) avg_delay
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
'''

Q6 = '''
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
'''

Q7 = '''
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
           as cov;
'''

Q8 = '''
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
'''

Q9 = '''
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
'''

Q10 = '''
select distinct origin, dest, avg(arr_delay) avg_delay
from flight_delays
where crs_dep_time > 1400
  and month = 7
  and year = 2017
  and (origin = 'MDW' or origin = 'ORD')
  and (dest = 'SFO' or dest = 'SJC' or dest = 'OAK')
group by origin, dest
order by avg(arr_delay) desc;
'''


#################################
# do NOT modify below this line #
#################################

# open a database connection to our local flights database
def connect_database(database_path):
    global conn
    conn = sqlite3.connect(database_path)


def get_all_query_results(debug_print=True):
    all_results = []
    for q, idx in zip([Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10], range(1, 11)):
        result_strings = ("The result for Q%d was:\n%s\n\n" % (idx, from_db_cursor(conn.execute(q)))).splitlines()
        all_results.append(result_strings)
        if debug_print:
            for string in result_strings:
                print string
    return all_results


if __name__ == "__main__":
    connect_database('flights.db')
    query_results = get_all_query_results()
