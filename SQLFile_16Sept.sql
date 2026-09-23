--------------------- 26 SEPT ---------------------

-- CREATING NEW TABLE
CREATE TABLE [HR].[Trancate_Demo] (
    [id]   INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    [Name] VARCHAR(20) NOT NULL
);

-- INSERT DATA
INSERT INTO [HR].[Trancate_Demo]
VALUES ('Sailen');

-- VIEW DATA
SELECT *
FROM [HR].[Trancate_Demo];

-- ALTER COLUMN
ALTER TABLE [HR].[Trancate_Demo]
ALTER COLUMN [Name] NVARCHAR(50) NOT NULL;

-- VIEW TABLE INFORMATION
EXEC sp_help 'HR.Trancate_Demo';

-- REMOVE ALL DATA
TRUNCATE TABLE [HR].[Trancate_Demo];

-- INSERT NEW DATA
INSERT INTO [HR].[Trancate_Demo]
VALUES ('Arko');

-- DELETE DATA
DELETE FROM [HR].[Trancate_Demo];

--IDENTITY INSERT (ON/OFF)
SET IDENTITY_INSERT [HR].[Trancate_Demo] ON
INSERT into [HR].[Trancate_Demo] ([id], [Name]) values (69,'arko');


--Temporary Table
SELECT *
INTO #NY
FROM [BikeStores].[sales].[customers]
WHERE [state] = 'NY' collate SQL_Latin1_General_CP1_CS_AS;

-- Check the temporary table
SELECT *
FROM #NY;

--Deleting the temporary table
DROP table #ny

--Foreign Key Implimentation
-- =========================================
-- FOREIGN KEY IMPLEMENTATION
-- =========================================

-- Create schema
CREATE SCHEMA [Demo];


-- =========================================
-- MASTER / PARENT TABLE

CREATE TABLE [Demo].[Department] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [dept] VARCHAR(50),
    [location] VARCHAR(100)
);


-- CHILD TABLE

CREATE TABLE [Demo].[Employee_table] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [name] VARCHAR(50),
    [sallary] INT NOT NULL,
    [adress] VARCHAR(50),
    [Date_of_joinning] DATETIME2 NOT NULL,
    [dept_id] INT,

    FOREIGN KEY ([dept_id])
        REFERENCES [Demo].[Department]([id])
);


-- INSERT INTO MASTER TABLE FIRST


INSERT INTO [Demo].[Department]
    ([dept], [location])
VALUES
    ('IT', 'Kolkata'),
    ('HR', 'Mumbai'),
    ('Finance', 'Delhi'),
    ('Marketing', 'Bangalore'),
    ('Operations', 'Hyderabad');


-- Check Department table
SELECT *
FROM [Demo].[Department];

-- INSERT INTO CHILD TABLE


INSERT INTO [Demo].[Employee_table]
    ([name], [sallary], [adress], [Date_of_joinning], [dept_id])
VALUES
    ('Sailen', 15000, 'Kolkata', '2026-09-16', 1),
    ('Arko',   25000, 'Mumbai',  '2026-01-10', 2),
    ('Rahul',  30000, 'Delhi',   '2026-02-15', 3),
    ('Priya',  28000, 'Pune',    '2026-03-20', 4),
    ('Amit',   35000, 'Chennai', '2026-04-05', 5);


-- Check Employee table
SELECT *
FROM [Demo].[Employee_table];