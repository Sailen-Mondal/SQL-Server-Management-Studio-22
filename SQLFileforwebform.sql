/* ==============================================================================
   File Name     : SQLFileforwebform.sql
   Database      : ADOPractice
   Description   : SQL script for ASP.NET Web Form (3-Layer Architecture)
                   - Employees table verification
                   - Stored procedure for inserting employee (usp_Employee_Insert)
                   - Stored procedure for getting all employees (usp_Employee_GetAll)
   ============================================================================== */

USE ADOPractice;
GO

-- 1. Ensure Employees Table exists
IF NOT EXISTS (
    SELECT * 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'Employees' AND TABLE_SCHEMA = 'dbo'
)
BEGIN
    CREATE TABLE dbo.Employees
    (
        [ID]            INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [LastName]      VARCHAR(255)      NOT NULL,
        [FirstName]     VARCHAR(255)      NULL,
        [Age]           INT               NULL,
        [City]          VARCHAR(255)      NULL,
        [DateOfJoining] DATE              NULL,
        [Salary]        DECIMAL(18, 2)    NULL
    );
    PRINT '>> Employees table created successfully.';
END
ELSE
BEGIN
    PRINT '>> Employees table already exists.';
END
GO

-- 2. Stored Procedure: Insert an employee
IF OBJECT_ID('dbo.usp_Employee_Insert', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Employee_Insert;
GO

CREATE PROCEDURE dbo.usp_Employee_Insert
    @LastName      NVARCHAR(100),
    @FirstName     NVARCHAR(100),
    @Age           INT,
    @City          NVARCHAR(100),
    @DateOfJoining DATE,
    @Salary        DECIMAL(18, 2)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Employees
        (LastName, FirstName, Age, City, DateOfJoining, Salary)
    VALUES
        (@LastName, @FirstName, @Age, @City, @DateOfJoining, @Salary);

    -- Return the newly inserted record ID
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END;
GO

-- 3. Stored Procedure: Fetch all employees for GridView display
IF OBJECT_ID('dbo.usp_Employee_GetAll', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Employee_GetAll;
GO

CREATE PROCEDURE dbo.usp_Employee_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ID, 
        FirstName, 
        LastName, 
        Age, 
        City, 
        DateOfJoining, 
        Salary
    FROM dbo.Employees
    ORDER BY ID DESC;
END;
GO

-- 4. Check Current Records
SELECT 
    ID, 
    FirstName, 
    LastName, 
    Age, 
    City, 
    DateOfJoining, 
    Salary
FROM dbo.Employees
ORDER BY ID DESC;
GO
