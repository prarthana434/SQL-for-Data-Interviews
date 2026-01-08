-- select * from dbo.EmployeeDetails;

-- Question 1: Find employees who were hired in the last 2 months
select *,
datediff(month, hiredate, getdate()) as month_diff 
from dbo.employeedetails
where datediff(month, hiredate, getdate()) between 0 and 2

-- Question 2: Find employees hired in last 90 days
select *,
DATEDIFF(day, hiredate, getdate()) as days_diff
from dbo.employeedetails
where DATEDIFF(day, hiredate, getdate()) between 0 and 90

-- Question 3: Find employees hired in last 2 years
select *, 
DATEDIFF(year, hiredate, getdate()) as year_diff
from dbo.employeedetails
where DATEDIFF(year, hiredate, getdate()) between 0 and 2

-- Question 4: Find out employee name and salary details 
-- note (if first name is null then consider last name)

select empid, ISNULL(fname, lname) as fname, lname, salary, hiredate from dbo.employeedetails

