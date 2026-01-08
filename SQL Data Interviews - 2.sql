CREATE TABLE EmployeeDetails (
    EmpID INT PRIMARY KEY,
    FName VARCHAR(50) NULL,
    LName VARCHAR(50) NULL,
    Salary INT,
    HireDate DATE
);

INSERT INTO EmployeeDetails (EmpID, FName, LName, Salary, HireDate) VALUES
(1, 'John',   'Doe',     80000, DATEADD(MONTH, -2, GETDATE())),
(2, NULL,     'Smith',   75000, DATEADD(DAY,  -20, GETDATE())),
(3, 'Alice',  'Brown',   90000, DATEADD(YEAR, -1, GETDATE())),
(4, 'Bob',    'Taylor',  60000, DATEADD(MONTH, -6, GETDATE())),
(5, NULL,     'Wilson',  70000, DATEADD(DAY,  -5, GETDATE())),
(6, 'Emma',   'Davis',   85000, DATEADD(YEAR, -3, GETDATE()));

select * from dbo.EmployeeDetails;

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


