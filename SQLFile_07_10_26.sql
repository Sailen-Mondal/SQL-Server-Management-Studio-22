----- Date : 07.10.26 -----

----- Topic : Curosrs -----

-- Variables
DECLARE 
    @Cus_productID VARCHAR(MAX),
    @status VARCHAR(20);

-- Declare cursor
DECLARE cursor_aps CURSOR
FOR
SELECT [patient_id], [status]
FROM [dbo].[Appointments];

-- Open cursor
OPEN cursor_aps;

-- Get first row
FETCH NEXT FROM cursor_aps
INTO @Cus_productID, @status;

-- Process rows
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @Cus_productID + ' - ' + @status;

    FETCH NEXT FROM cursor_aps
    INTO @Cus_productID, @status;
END;

-- Close and remove cursor
CLOSE cursor_aps;
DEALLOCATE cursor_aps;

-------------------------------------------------------------------------------------------------------
--- Topic : Trigger

USE [IndexDB];
GO

/* =========================================================
   Create Audit Table
   ========================================================= */

DROP TABLE IF EXISTS [dbo].[EmployeeAudit];
GO

CREATE TABLE [dbo].[EmployeeAudit]
(
    [ID] INT IDENTITY(1,1) PRIMARY KEY,
    [AuditData] VARCHAR(MAX),
    [AuditDate] DATETIME
);
GO


/* =========================================================
   Remove old triggers if they already exist
   ========================================================= */

DROP TRIGGER IF EXISTS [dbo].[trInsertEmployee];
GO

DROP TRIGGER IF EXISTS [dbo].[trDeleteEmployee];
GO


/* =========================================================
   STEP 3: AFTER INSERT Trigger
   ========================================================= */

CREATE TRIGGER [dbo].[trInsertEmployee]
ON [dbo].[Employee]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[EmployeeAudit]
        ([AuditData], [AuditDate])
    SELECT
        CONCAT(
            'New employee added with ID = ',
            [Id],
            ' and Name = ',
            [Name]
        ),
        GETDATE()
    FROM INSERTED;
END;
GO


/* =========================================================
   AFTER DELETE Trigger
   ========================================================= */

CREATE TRIGGER [dbo].[trDeleteEmployee]
ON [dbo].[Employee]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[EmployeeAudit]
        ([AuditData], [AuditDate])
    SELECT
        CONCAT(
            'Employee deleted with ID = ',
            [Id],
            ' and Name = ',
            [Name]
        ),
        GETDATE()
    FROM DELETED;
END;
GO

-- TEST : INSERT
INSERT INTO [dbo].[Employee]
    ([Id], [Name], [Salary], [Gender], [DepartmentId])
VALUES
    (8, 'Sailen', 15000, 'Male', 2);
GO

SELECT *
FROM [dbo].[Employee]
WHERE [Id] = 8;

-- Test : DELETE 
DELETE FROM [dbo].[Employee]
WHERE [Id] = 8;
GO

SELECT *
FROM [dbo].[Employee]
WHERE [Id] = 8;

-- Create a backup table, Upon deleting any data it should reflect on the backup table

CREATE TABLE backup_of_tblOrder(
        [id] INT,
        [CustomerId] INT,
        [ProductID] VARCHAR(50),
        [ProductName] VARCHAR(50)
    );

    -- Trigger
CREATE OR ALTER TRIGGER [dbo].[trBackupOrder]
ON [dbo].[tblOrder]
AFTER DELETE
AS BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[backup_of_tblOrder](
        [id],
        [CustomerId],
        [ProductID],
        [ProductName]
        )
    SELECT
        [id],
        [CustomerId],
        [ProductID],
        [ProductName]
    FROM deleted;
END;
GO

-- TEST : DELETE
DELETE FROM [dbo].[tblOrder]
WHERE [Id] = 8;

