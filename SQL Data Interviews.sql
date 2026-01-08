CREATE TABLE Departments (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(50)
);

CREATE TABLE Employees (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(50),
    Salary INT,
    DeptID INT,
    FOREIGN KEY (DeptID) REFERENCES Departments(DeptID)
);

INSERT INTO Departments (DeptID, DeptName) VALUES
(1, 'HR'),
(2, 'IT'),
(3, 'Finance'),
(4, 'Sales');

INSERT INTO Employees (EmpID, EmpName, Salary, DeptID) VALUES
(101, 'Alice',   90000, 2),
(102, 'Bob',     85000, 2),
(103, 'Charlie', 80000, 2),
(104, 'David',   75000, 2),

(105, 'Eva',     70000, 1),
(106, 'Frank',   65000, 1),
(107, 'Grace',   60000, 1),

(108, 'Hannah',  95000, 3),
(109, 'Ian',     90000, 3),
(110, 'Jack',    85000, 3),

(111, 'Kevin',   72000, 4),
(112, 'Laura',   68000, 4),
(113, 'Mike',    64000, 4);

select * from dbo.Departments;
select * from dbo.Employees;

-- Question 1: different ways to find second highest salary
-- Option 1: row_number() and dense_rank()
select empid from (
select empid, sum(Salary) as sal,
ROW_NUMBER() over(order by sum(Salary) desc, empid asc) as drnk
from dbo.Employees
group by EmpID
) a
where drnk = 2

-- Option 2: limit and offset 
select empid, sum(salary) as sal from dbo.Employees
group by empid
order by sal desc, empid asc
offset 1 rows fetch next 1 rows only

-- Question 2: Find 3rd Highest Salary in each department row_number(), dense_rank(), rank()
select deptname, empid from (
select d.DeptName, e.empid, sum(e.salary) as sal,
ROW_NUMBER() over(partition by d.deptname order by sum(e.salary) desc, e.empid) as rn
from dbo.Employees e
inner join dbo.Departments d on
e.DeptID = d.DeptID
group by d.DeptName, e.empid
) a
where rn = 3

-- Question 3: Find only 3rd Highest Salary 
select empid, sum(salary) as salary from dbo.Employees
group by empid
order by empid, salary desc
offset 2 rows fetch next 1 rows only

-- Question 4: Find bottom two salary employee details
select e.EmpID, e.EmpName, e.deptid, d.deptname, sum(e.salary) salary from dbo.Employees e 
inner join dbo.Departments d on 
e.DeptID = d.DeptID
group by e.EmpID, e.EmpName, e.deptid, d.deptname
order by salary, e.EmpID
offset 0 rows fetch next 2 rows only

-- Question 5: Find top two salary employee details
select e.EmpID, e.EmpName, e.deptid, d.deptname, sum(e.salary) salary from dbo.Employees e 
inner join dbo.Departments d on 
e.DeptID = d.DeptID
group by e.EmpID, e.EmpName, e.deptid, d.deptname
order by salary desc, e.EmpID
offset 0 rows fetch next 2 rows only

-- Question 6: Find lowest Salary in each department row_number()
select deptname, empid from (
select d.DeptName, e.empid, sum(e.salary) as sal,
ROW_NUMBER() over(partition by d.deptname order by sum(e.salary), e.empid) as rn
from dbo.Employees e
inner join dbo.Departments d on
e.DeptID = d.DeptID
group by d.DeptName, e.empid
) a
where rn = 1

-- Question 7: Find 3rd to 5th salaried employee
SELECT EmpID, EmpName, Salary FROM (
SELECT EmpID, EmpName, Salary, 
ROW_NUMBER() OVER (ORDER BY Salary DESC) AS rn
FROM Employees
) t
WHERE rn BETWEEN 3 AND 5;

