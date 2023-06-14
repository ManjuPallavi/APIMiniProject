/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT  * FROM `Facilities` where membercost > 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT  * FROM `Facilities` where membercost  = 0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT * FROM `Facilities` where membercost > 0 and membercost < ((monthlymaintenance * 20) /100)

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * FROM `Facilities` where facid in (1,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, case when monthlymaintenance > 100 then 'expensive' else 'cheap'end FROM `Facilities` 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
select firstname, surname from Members where joindate in (select max(joindate) from Members);

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
select distinct concat(F.Name,"  ", M.firstname, " " ,  M.surname) from `Bookings` B join `Facilities` F on B.facid = F.facid
join `Members` M on M.memid = B.memid and M.memid != 0
where F.name like 'Tennis Court%' order by M.firstname

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

select concat(name, ' ', firstname, ' ', surname) as bookings, case when memid = 0 then slots * guestcost else slots * membercost end as cost 
from Bookings join Facilities using(facid)  join Members using(memid) where cast(starttime as date)= '2012-09-14'
having cost > 30 order by cost desc;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select concat(name, ' ', firstname, ' ', surname) as bookings, case when memid = 0 then slots * guestcost else slots * membercost end as 
cost from (select * from Bookings  join Facilities using(facid)  join Members using(memid) where cast(starttime as date)= '2012-09-14' ) A having cost > 30 order by cost desc


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

import sqlite3
import os
try:
    sqliteConnection = sqlite3.connect('sqlite_db_pythonsqlite.db')
    print(sqlite3.version)
    cursor = sqliteConnection.cursor()
    sql_query = """select  name, sum(case when memid =0 then slots * guestcost else slots * membercost end) as revenue   from Bookings B join Facilities using(facid) 
group by facid, name having revenue < 1000;"""
    cursor.execute(sql_query)
    rows = cursor.fetchall()
    print("list of facilities with a total revenue less than 1000")
    print(rows)
    
    sql_query2 = """select  M.surname||","|| M.firstname as MemberName  , M2.surname ||","||M2.firstname  as RecommendedBy from  Members M  join Members M2
on M.recommendedby = M2.memid and M.recommendedby > 0 and M.recommendedby is not null 
order by  M2.surname, M2.firstName"""
    cursor.execute(sql_query2)
    print("Report of members and who recommnded them ")
    print(cursor.fetchall())
    
    sql_query3 = """select F.name, M.firstname ||" "|| M.surname as MemberName , sum(1) from Bookings B join Facilities F using (facid)
join Members M using(memid)
where memid > 0 group by F.Name, MemberName
"""
    cursor.execute(sql_query3)
    print(" Facilitgies with ther usage by member")
    print(cursor.fetchall())
    
    sql_query4 = """select strftime('%m',starttime) as month, F.name,  sum(1) as usage from Bookings B join Facilities F using (facid)
join Members M using(memid)
where memid > 0 
group by F.Name, month ,cast(starttime as date) order by month
"""
    cursor.execute(sql_query4)
    print(" Facilities with their usage by month ")
    print(cursor.fetchall())
    
except sqlite3.Error as error:
    print("failed to execute the above query",error)
finally:
    if sqliteConnection:
        sqliteConnection.close()

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

  sql_query2 = """select  M.surname||","|| M.firstname as MemberName  , M2.surname ||","||M2.firstname  as RecommendedBy from  Members M  join Members M2
on M.recommendedby = M2.memid and M.recommendedby > 0 and M.recommendedby is not null 
order by  M2.surname, M2.firstName"""
    cursor.execute(sql_query2)
    print("Report of members and who recommnded them ")
    print(cursor.fetchall())

/* Q12: Find the facilities with their usage by member, but not guests */
sql_query3 = """select F.name, M.firstname ||" "|| M.surname as MemberName , sum(1) from Bookings B join Facilities F using (facid)
join Members M using(memid)
where memid > 0 group by F.Name, MemberName
"""
    cursor.execute(sql_query3)
    print(" Facilitgies with ther usage by member")
    print(cursor.fetchall())

/* Q13: Find the facilities usage by month, but not guests */
 
    sql_query4 = """select strftime('%m',starttime) as month, F.name,  sum(1) as usage from Bookings B join Facilities F using (facid)
join Members M using(memid)
where memid > 0 
group by F.Name, month ,cast(starttime as date) order by month
"""
    cursor.execute(sql_query4)
    print(" Facilities with their usage by month ")
    print(cursor.fetchall())


