/* ==============================================================================
   File Name     : SQLFile_for_console.sql
   Author        : Sailen Mondal
   Creation Date : 07.10.26
   Updated By    : Sailen Mondal
   Updated Date  : 07.10.26
   Database      : ADOPractice
   Description   : Creates the Employees table and stored procedures for 
                   CRUD operations (Insert, GetAll, GetById, Update, Delete).
                   Data is consumed via IEmployeeRepository interface in the
                   C# console application.
   ============================================================================== */

USE ADOPractice;
GO

-- ============================================================
-- TABLE: Employees
-- ============================================================
IF NOT EXISTS (
    SELECT * 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'Employees'
)
BEGIN
    CREATE TABLE Employees
    (
        [ID]            [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [LastName]      [varchar](255)      NOT NULL,
        [FirstName]     [varchar](255)      NULL,
        [Age]           [int]               NULL,
        [City]          [varchar](255)      NULL,
        [DateOfJoining] [date]              NULL,
        [Salary]        [decimal](18, 2)    NULL
    );
END
GO

-- ============================================================
-- PROCEDURE: sp_InsertEmployee
-- Inserts a new employee and returns the generated ID
-- ============================================================
IF OBJECT_ID('sp_InsertEmployee', 'P') IS NOT NULL
    DROP PROCEDURE sp_InsertEmployee;
GO

CREATE PROCEDURE sp_InsertEmployee
    @LastName       VARCHAR(255),
    @FirstName      VARCHAR(255)  = NULL,
    @Age            INT           = NULL,
    @City           VARCHAR(255)  = NULL,
    @DateOfJoining  DATE          = NULL,
    @Salary         DECIMAL(18,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Employees
    (
        LastName,
        FirstName,
        Age,
        City,
        DateOfJoining,
        Salary
    )
    VALUES
    (
        @LastName,
        @FirstName,
        @Age,
        @City,
        @DateOfJoining,
        @Salary
    );

    -- Return the auto-generated ID of the new row
    DECLARE @NewID INT = SCOPE_IDENTITY();

    PRINT '>> Employee inserted successfully. New ID: ' + CAST(@NewID AS VARCHAR(10));

    SELECT @NewID AS NewID;
END
GO

-- ============================================================
-- PROCEDURE: sp_GetAllEmployees
-- Returns all employee records
-- ============================================================
IF OBJECT_ID('sp_GetAllEmployees', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetAllEmployees;
GO

CREATE PROCEDURE sp_GetAllEmployees
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RecordCount INT;

    SELECT
        ID,
        LastName,
        FirstName,
        Age,
        City,
        DateOfJoining,
        Salary
    FROM Employees;

    SET @RecordCount = @@ROWCOUNT;

    PRINT '>> Retrieved ' + CAST(@RecordCount AS VARCHAR(10)) + ' employee record(s).';
END
GO

-- ============================================================
-- PROCEDURE: sp_GetEmployeeById
-- Returns a single employee matching the given ID
-- ============================================================
IF OBJECT_ID('sp_GetEmployeeById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetEmployeeById;
GO

CREATE PROCEDURE sp_GetEmployeeById
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ID,
        LastName,
        FirstName,
        Age,
        City,
        DateOfJoining,
        Salary
    FROM Employees
    WHERE ID = @ID;

    IF @@ROWCOUNT = 0
        PRINT '>> No employee found with ID: ' + CAST(@ID AS VARCHAR(10));
    ELSE
        PRINT '>> Employee with ID: ' + CAST(@ID AS VARCHAR(10)) + ' retrieved successfully.';
END
GO

-- ============================================================
-- PROCEDURE: sp_UpdateEmployee
-- Updates an existing employee record by ID
-- ============================================================
IF OBJECT_ID('sp_UpdateEmployee', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateEmployee;
GO

CREATE PROCEDURE sp_UpdateEmployee
    @ID             INT,
    @LastName       VARCHAR(255),
    @FirstName      VARCHAR(255)  = NULL,
    @Age            INT           = NULL,
    @City           VARCHAR(255)  = NULL,
    @DateOfJoining  DATE          = NULL,
    @Salary         DECIMAL(18,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Employees
    SET
        LastName      = @LastName,
        FirstName     = @FirstName,
        Age           = @Age,
        City          = @City,
        DateOfJoining = @DateOfJoining,
        Salary        = @Salary
    WHERE ID = @ID;

    DECLARE @Affected INT = @@ROWCOUNT;

    IF @Affected = 0
        PRINT '>> Update failed. No employee found with ID: ' + CAST(@ID AS VARCHAR(10));
    ELSE
        PRINT '>> Employee with ID: ' + CAST(@ID AS VARCHAR(10)) + ' updated successfully.';

    SELECT @Affected AS RowsAffected;
END
GO

-- ============================================================
-- PROCEDURE: sp_DeleteEmployee
-- Deletes an employee record by ID
-- ============================================================
IF OBJECT_ID('sp_DeleteEmployee', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteEmployee;
GO

CREATE PROCEDURE sp_DeleteEmployee
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Employees
    WHERE ID = @ID;

    DECLARE @Affected INT = @@ROWCOUNT;

    IF @Affected = 0
        PRINT '>> Delete failed. No employee found with ID: ' + CAST(@ID AS VARCHAR(10));
    ELSE
        PRINT '>> Employee with ID: ' + CAST(@ID AS VARCHAR(10)) + ' deleted successfully.';

    SELECT @Affected AS RowsAffected;
END
GO
