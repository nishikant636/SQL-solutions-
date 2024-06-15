Task1

SELECT Start_Date, min(End_Date)
FROM 
 (SELECT Start_Date FROM Projects WHERE Start_Date NOT IN (SELECT End_Date FROM Projects)) a ,
 (SELECT End_Date FROM Projects WHERE End_Date NOT IN (SELECT Start_Date FROM Projects)) b
WHERE Start_Date < End_Date
GROUP BY Start_Date
ORDER BY DATEDIFF(min(End_Date), Start_Date) ASC, Start_Date ASC

Task 2

Select S.Name
From ( Students S join Friends F using(ID)
 join Packages P1 on S.ID=P1.ID
 join Packages P2 on F.Friend_ID=P2.ID)
Where P2.Salary > P1.Salary
Order By P2.Salary;

task3

SELECT f1.X, f1.Y FROM Functions AS f1 
WHERE f1.X = f1.Y AND
(SELECT COUNT(*) FROM Functions WHERE X = f1.X AND Y = f1.Y) > 1
UNION
SELECT f1.X, f1.Y from Functions AS f1
WHERE EXISTS(SELECT X, Y FROM Functions WHERE f1.X = Y AND f1.Y = X AND f1.X < X)
ORDER BY X;

task4

SELECT con.contest_id, con.hacker_id, con.name, SUM(sg.total_submissions), SUM(sg.total_accepted_submissions),
SUM(vg.total_views), SUM(vg.total_unique_views)
FROM Contests AS con 
JOIN Colleges AS col
ON con.contest_id = col.contest_id
JOIN Challenges AS cha 
ON cha.college_id = col.college_id
LEFT JOIN
(SELECT ss.challenge_id, SUM(ss.total_submissions) AS total_submissions, SUM(ss.total_accepted_submissions) AS total_accepted_submissions FROM 
Submission_Stats AS ss GROUP BY ss.challenge_id) AS sg
ON cha.challenge_id = sg.challenge_id
LEFT JOIN
(SELECT vs.challenge_id, SUM(vs.total_views) AS total_views, SUM(total_unique_views) AS total_unique_views FROM View_Stats AS vs GROUP BY vs.challenge_id) AS vg
ON cha.challenge_id = vg.challenge_id
GROUP BY con.contest_id, con.hacker_id, con.name
HAVING SUM(sg.total_submissions)+
       SUM(sg.total_accepted_submissions)+
       SUM(vg.total_views)+
       SUM(vg.total_unique_views) > 0
ORDER BY con.contest_id;

task5

with MaxSubEachDay as (
    select submission_date,
           hacker_id,
           RANK() OVER(partition by submission_date order by SubCount desc, hacker_id) as Rn
    FROM
    (select submission_date, hacker_id, count(1) as SubCount 
     from submissions
     group by submission_date, hacker_id
     ) subQuery
), DayWiseRank as (
    select submission_date,
           hacker_id,
           DENSE_RANK() OVER(order by submission_date) as dayRn
    from submissions
), HackerCntTillDate as (
select outtr.submission_date,
       outtr.hacker_id,
       case when outtr.submission_date='2016-03-01' then 1
            else 1+(select count(distinct a.submission_date)                         from submissions a where a.hacker_id = outtr.hacker_id and                              a.submission_date<outtr.submission_date)
        end as PrevCnt,
        outtr.dayRn
from DayWiseRank outtr
), HackerSubEachDay as (
    select submission_date,
    count(distinct hacker_id) HackerCnt
from HackerCntTillDate
  where PrevCnt = dayRn
group by submission_date
)
select HackerSubEachDay.submission_date,
       HackerSubEachDay.HackerCnt,
       MaxSubEachDay.hacker_id,
       Hackers.name
from HackerSubEachDay
inner join MaxSubEachDay
 on HackerSubEachDay.submission_date = MaxSubEachDay.submission_date
inner join Hackers
 on Hackers.hacker_id = MaxSubEachDay.hacker_id
where MaxSubEachDay.Rn=1

task6

select ROUND(ABS(MAX(LAT_N) - MIN(LAT_N)) + ABS(MAX(LONG_W) - MIN(LONG_W)), 4) FROM STATION;

task7

SELECT LISTAGG(PRIME_NUMBER,'&') WITHIN GROUP (ORDER BY PRIME_NUMBER)
FROM(
SELECT L PRIME_NUMBER
FROM(
SELECT LEVEL L
FROM DUAL
CONNECT BY LEVEL <= 1000),
(SELECT LEVEL M FROM DUAL CONNECT BY LEVEL <= 1000)
WHERE M <= L
GROUP BY L
HAVING COUNT(CASE WHEN L/M = TRUNC(L/M) THEN 'Y' END) = 2
ORDER BY L);

task 8

SELECT MIN(IF(Occupation = 'Doctor',Name,NULL)),MIN(IF(Occupation = 'Professor',Name,NULL)),MIN(IF(Occupation = 'Singer',Name,NULL)),MIN(IF(Occupation = 'Actor',Name,NULL)) 
FROM(
    SELECT ROW_NUMBER() OVER(PARTITION BY Occupation
                             ORDER BY Name) AS row_num,
            Name, 
            Occupation
    FROM OCCUPATIONS) AS ord
GROUP BY row_num

task 9

select N,
       case when P is null then 'Root'
            when (select count(*) from BST where P = B.N) > 0 then  
            'Inner'
            else 'Leaf'
       end
from BST as B 
order by N
;

task 10

select c.company_code, c.founder,
       count(distinct l.lead_manager_code),
       count(distinct s.senior_manager_code),
       count(distinct m.manager_code),
       count(distinct e.employee_code)
from Company as c 
join Lead_Manager as l 
on c.company_code = l.company_code
join Senior_Manager as s
on l.lead_manager_code = s.lead_manager_code
join Manager as m 
on m.senior_manager_code = s.senior_manager_code
join Employee as e
on e.manager_code = m.manager_code
group by c.company_code, c.founder
order by c.company_code;

task11

Select S.Name
From ( Students S join Friends F using(ID)
 join Packages P1 on S.ID=P1.ID
 join Packages P2 on F.Friend_ID=P2.ID)
Where P2.Salary > P1.Salary
Order By P2.Salary;

task12

select job_family, country,
       sum(ctc) * 1.0 / sum(case when country = 'India' then sum(ctc) end) over (partition by job_family) as ratio
from t
group by job_family, country;

task13

SELECT 
    BU,
    Month,
    Cost,
    Revenue,
    Cost / Revenue AS Cost_Revenue_Ratio
FROM 
    Financials
ORDER BY 
    BU, 
    Month;

task14

SELECT 
    Sub_Band,
    COUNT(*) AS Headcount,
    ROUND(100.0 * COUNT() / SUM(COUNT()) OVER (), 2) AS Percentage_Headcount
FROM 
    Employees
GROUP BY 
    Sub_Band
ORDER BY 
    Sub_Band;

task15

WITH RankedSalaries AS (
    SELECT 
        Employee_ID,
        Name,
        Salary,
        ROW_NUMBER() OVER (ORDER BY Salary DESC) AS Rank
    FROM 
        Employees
)
SELECT 
    Employee_ID,
    Name,
    Salary
FROM 
    RankedSalaries
WHERE 
    Rank <= 5;

### Task 16: Swap Values of Two Columns in a Table Without Using a Third Variable or Table

Assuming you have a table named Employees with columns ColumnA and ColumnB that you want to swap, you can do this with a single UPDATE statement by using a mathematical trick (addition and subtraction) or the XOR bitwise operation.

#### Using Addition and Subtraction (for numeric values):
sql
UPDATE Employees
SET ColumnA = ColumnA + ColumnB,
    ColumnB = ColumnA - ColumnB,
    ColumnA = ColumnA - ColumnB;


#### Using XOR (for integer values):
sql
UPDATE Employees
SET ColumnA = ColumnA ^ ColumnB,
    ColumnB = ColumnA ^ ColumnB,
    ColumnA = ColumnA ^ ColumnB;


Note: These methods work under the assumption that the values in ColumnA and ColumnB are numeric (in the case of addition/subtraction) or integers (in the case of XOR).

### Task 17: Create a User, Create a Login for That User, Provide DB_owner Permissions

To create a user, create a login for that user, and provide DB_owner permissions, follow these steps:

1. *Create a Login:*
    sql
    CREATE LOGIN NewUserLogin 
    WITH PASSWORD = 'YourStrongPassword';


2. *Create a User for the Database:*
    sql
    USE YourDatabaseName;
    CREATE USER NewUser 
    FOR LOGIN NewUserLogin;


3. **Add the User to the DB_owner Role:**
    sql
    ALTER ROLE db_owner 
    ADD MEMBER NewUser;


### Task 18: Find Weighted Average Cost of Employees Month on Month in a BU

Assuming you have a table named EmployeeCosts with the following columns:
- BU (VARCHAR)
- Month (DATE or VARCHAR in the format 'YYYY-MM')
- Employee_ID (INT)
- Cost (DECIMAL)
- Weight (DECIMAL)

You can calculate the weighted average cost month on month using the following query:

sql
SELECT 
    BU,
    Month,
    SUM(Cost * Weight) / SUM(Weight) AS Weighted_Average_Cost
FROM 
    EmployeeCosts
GROUP BY 
    BU,
    Month
ORDER BY 
    BU,
    Month;


### Explanation:

1. *SELECT Clause:*
   - BU: Select the Business Unit.
   - Month: Select the month.
   - SUM(Cost * Weight) / SUM(Weight) AS Weighted_Average_Cost: Calculate the weighted average cost.

2. *FROM Clause:*
   - Specify the EmployeeCosts table.

3. *GROUP BY Clause:*
   - Group the results by BU and Month to get month on month data for each BU.

4. *ORDER BY Clause:*
   - Order the results by BU and Month for better readability.

This query calculates the weighted average cost of employees month on month for each Business Unit.

task 19

SELECT
CAST(CEILING(AVG(CAST(salary AS float)) -
AVG(CAST(REPLACE(salary, 0, '') AS float))) AS int)
FROM employees

task 20

INSERT INTO DestinationTable (ID, Column1, Column2, Column3)
SELECT 
    s.ID, 
    s.Column1, 
    s.Column2, 
    s.Column3
FROM 
    SourceTable s
WHERE 
    NOT EXISTS (
        SELECT 1
        FROM DestinationTable d
        WHERE d.ID = s.ID
    );