-------------------- DATE : 28.09.26 ----------------

DECLARE @Counter INT , @MaxId INT, 
@CountryName NVARCHAR(100)
SELECT @Counter = min(emp_id) , @MaxId = max(emp_id) 
FROM [Demo].[Employee_Main]
WHILE(@Counter IS NOT NULL
AND @Counter <= @MaxId)
BEGIN
SELECT @CountryName = city
FROM  [Demo].[Employee_Main] WHERE emp_id = @Counter
PRINT CONVERT(VARCHAR,@Counter) + '. City name is ' + @CountryName
SET @Counter = @Counter + 1 
END

CREATE TABLE bikeshop ( 
Id INT PRIMARY KEY IDENTITY, 
bike_name VARCHAR (50) NOT NULL, 
price FLOAT );

DECLARE @count INT; 
SET @count = 1; 
WHILE @count <= 10 
BEGIN 
INSERT INTO bikeshop VALUES('Bike-' + CAST(@count as varchar), @count*5000) 
SET @count = @count + 1; 
END; 

SELECT * from bikeshop

DROP TABLE IF EXISTS #dates;
CREATE TABLE #dates ( report_date DATE);
DECLARE @date_start DATE;
DECLARE @date_end DATE;
DECLARE @loop_date DATE;
SET @date_start = '2020/11/11';
SET @date_end = '2020/12/12';
SET @loop_date = @date_start;
WHILE @loop_date <= @date_end
BEGIN
INSERT INTO #dates (report_date) VALUES (@loop_date);
SET @loop_date = DATEADD(DAY, 1, @loop_date);
END;
SELECT * FROM #dates;
DROP TABLE IF EXISTS #dates;

----Pattrn Printing----
-- * Pattern
DECLARE @i INT = 1;

WHILE @i <= 4
BEGIN
    PRINT REPLICATE('* ', @i);
    SET @i = @i + 1;
END


-- ABCD Pattern
DECLARE @Row INT = 1;
DECLARE @Pattern VARCHAR(5) = '';

WHILE @Row <= 5
BEGIN
    -- Append the next character based on the current row number
    SET @Pattern = @Pattern + CHAR(64 + @Row);
    
    -- Print the current state of the pattern
    PRINT @Pattern;
    
    SET @Row = @Row + 1;
END;


-- Question 3 : Prime Number
DECLARE @Number INT = 18; --> Input
DECLARE @IsPrime BIT = 1; --> 1 means Prime, 0 means Not Prime
DECLARE @Counter1 INT = 2;

-- Edge cases
IF @Number <= 1
    SET @IsPrime = 0;
ELSE
    BEGIN
        -- Loop only up to the square root of the number for efficiency
        WHILE @Counter1 <= SQRT(@Number)
        BEGIN
            IF @Number % @Counter1 = 0
            BEGIN
                SET @IsPrime = 0;
                BREAK; -- Exit loop early if a factor is found
            END
            SET @Counter1 = @Counter1 + 1;
        END
    END

-- Print the result
IF @IsPrime = 1
    PRINT CAST(@Number AS VARCHAR) + ' is a PRIME number.';
ELSE
    PRINT CAST(@Number AS VARCHAR) + ' is NOT a PRIME number.';


-- Question 4 : Display students having same student's name and father's name
CREATE TABLE #Students (
    StudentName VARCHAR(50),
    FatherName VARCHAR(50)
);

INSERT INTO #Students (StudentName, FatherName) VALUES
('Rajiv Kumar', 'Arvind Kumar'),
('Asish Roy', 'Ashim Roy'),
('Bipin Gupta', 'Rajiv Gupta'),
('Rajiv Kumar', 'Arvind Kumar'),
('Sourav Patra', 'Asish Patra'),
('Asish Roy', 'Ashim Roy');

-- Using GROUP BY and HAVING to find duplicates
SELECT StudentName, FatherName, COUNT(*) AS DuplicateCount
FROM #Students
GROUP BY StudentName, FatherName
HAVING COUNT(*) > 1;

DROP TABLE IF EXISTS #Students;


-- Table for Questions 5, 6, 7, 8
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    manager_id INT NULL,
    salary INT NULL,
    hire_date DATE NULL,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- Sample data for testing
INSERT INTO employees VALUES
(1, 'Mohan', 'CEO', NULL, 90000, '2025-01-10'),
(2, 'Sarah', 'Manager', 1, 80000, '2025-06-15'),
(3, 'Manish', 'Team Lead', 2, 70000, '2026-01-20'),
(4, 'David', 'Senior Dev', 3, 60000, '2026-04-10'),
(5, 'Mayank', 'Developer', 3, 50000, '2026-07-05'),
(6, 'Rahul', 'Developer', 2, 45000, '2026-08-15'),
(7, 'Amit', 'Tester', 2, 40000, '2026-09-01'),
(8, 'Priya', 'Intern', 3, 30000, '2026-09-20');


-- Question 5 : Employees hired in last n months
DECLARE @n INT = 6; -- e.g. last 6 months

SELECT * 
FROM employees
WHERE hire_date >= DATEADD(MONTH, -@n, GETDATE());


-- Question 6 : Organization hierarchy using self join
SELECT 
    e.employee_name AS EmployeeName,
    e.job_title AS JobTitle,
    m.employee_name AS ManagerName
FROM employees e
LEFT JOIN employees m 
    ON e.manager_id = m.employee_id;


-- Question 7 : Select all names that start with 'M' without using LIKE
-- Method 1: Using LEFT()
SELECT employee_name 
FROM employees 
WHERE LEFT(employee_name, 1) = 'M';

-- Method 2: Using SUBSTRING()
SELECT employee_name 
FROM employees 
WHERE SUBSTRING(employee_name, 1, 1) = 'M';


-- Question 8 : Find the 6th highest salary from Employee table
-- Method 1: Using DENSE_RANK()
WITH SalaryRank AS (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employees
)
SELECT salary 
FROM SalaryRank 
WHERE rnk = 6;

-- Method 2: Using OFFSET FETCH
SELECT DISTINCT salary 
FROM employees 
ORDER BY salary DESC 
OFFSET 5 ROWS FETCH NEXT 1 ROW ONLY;



