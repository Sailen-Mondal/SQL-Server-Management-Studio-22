-- Date : 09.10.26 --
-- Topic: Recursive CTE
-- Purpose: Display employees, their managers, and hierarchy levels

DECLARE @Employee TABLE
(
    EmployeeId INT PRIMARY KEY,
    Name       VARCHAR(30),
    ManagerId  INT NULL
);

-- Insert sample hierarchy data
INSERT INTO @Employee (EmployeeId, Name, ManagerId)
VALUES
(1, 'Tom',   2),
(2, 'Josh',  NULL),
(3, 'Mike',  2),
(4, 'John',  3),
(5, 'Pam',   1),
(6, 'Mary',  3),
(7, 'James', 1),
(8, 'Sam',   5),
(9, 'Simon', 1);


-- Recursive CTE
;WITH EmployeesCTE (EmployeeId, Name, ManagerId, [Level])
AS
(
    -- 1. Anchor: Find the top-level manager
    SELECT
        EmployeeId,
        Name,
        ManagerId,
        1 AS [Level]
    FROM @Employee
    WHERE ManagerId IS NULL

    UNION ALL

    -- 2. Recursive member: Find the next level of employees
    SELECT
        e.EmployeeId,
        e.Name,
        e.ManagerId,
        c.[Level] + 1
    FROM @Employee e
    INNER JOIN EmployeesCTE c
        ON e.ManagerId = c.EmployeeId
)

-- 3. Display employee, manager, and level
SELECT
    e.Name AS EmployeeName,
    ISNULL(m.Name, 'Super Boss') AS ManagerName,
    e.[Level]
FROM EmployeesCTE e
LEFT JOIN EmployeesCTE m
    ON e.ManagerId = m.EmployeeId
ORDER BY e.[Level], e.Name
OPTION (MAXRECURSION 100);
GO


-- ========================================================
-- Bill of Materials - Table Setup
-- ========================================================

DROP TABLE IF EXISTS bill_of_materials;
DROP TABLE IF EXISTS parts;

CREATE TABLE parts (
    part_id   INT PRIMARY KEY,
    part_name VARCHAR(100) NOT NULL,
    part_type VARCHAR(20) CHECK (part_type IN ('Assembly', 'Sub-Assembly', 'Component'))
);

CREATE TABLE bill_of_materials (
    parent_part_id INT,
    child_part_id  INT,
    quantity       DECIMAL(10, 2) NOT NULL DEFAULT 1.00,
    PRIMARY KEY (parent_part_id, child_part_id)
);

INSERT INTO parts (part_id, part_name, part_type) VALUES
(100, 'Bicycle',        'Assembly'),
(200, 'Frame Assembly', 'Sub-Assembly'),
(201, 'Frame Tube',     'Component'),
(202, 'Front Fork',     'Component'),
(300, 'Wheel Assembly', 'Sub-Assembly'),
(301, 'Rim',            'Component'),
(302, 'Tire',           'Component'),
(303, 'Spoke',          'Component');

INSERT INTO bill_of_materials (parent_part_id, child_part_id, quantity) VALUES
(100, 200, 1.00),   -- 1 Frame per Bicycle
(100, 300, 2.00),   -- 2 Wheels per Bicycle
(200, 201, 1.00),   -- 1 Tube per Frame
(200, 202, 1.00),   -- 1 Fork per Frame
(300, 301, 1.00),   -- 1 Rim per Wheel
(300, 302, 1.00),   -- 1 Tire per Wheel
(300, 303, 32.00);  -- 32 Spokes per Wheel
GO


-- ========================================================
-- Q1: Recursive CTE - Sub-components of Wheel Assembly (part_id = 300)
-- ========================================================

;WITH wheel_parts AS (
    -- Anchor: Start from Wheel Assembly
    SELECT
        b.child_part_id  AS part_id,
        p.part_name,
        p.part_type,
        b.quantity,
        1 AS [Level]
    FROM bill_of_materials b
    INNER JOIN parts p ON b.child_part_id = p.part_id
    WHERE b.parent_part_id = 300

    UNION ALL

    -- Recursive: Go deeper into sub-components
    SELECT
        b.child_part_id,
        p.part_name,
        p.part_type,
        b.quantity,
        w.[Level] + 1
    FROM bill_of_materials b
    INNER JOIN parts p ON b.child_part_id = p.part_id
    INNER JOIN wheel_parts w ON b.parent_part_id = w.part_id
)
SELECT part_id, part_name, part_type, quantity, [Level]
FROM wheel_parts
ORDER BY [Level], part_name
OPTION (MAXRECURSION 100);
GO


-- ========================================================
-- Q2: Generate numbers from 1 to 10
-- ========================================================

;WITH numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numbers
    WHERE n < 10
)
SELECT n FROM numbers
OPTION (MAXRECURSION 10);
GO


-- ========================================================
-- Q3: Generate all dates for a month (October 2026)
-- ========================================================

DECLARE @start DATE = '2026-10-01';
DECLARE @end   DATE = EOMONTH(@start);

;WITH month_dates AS (
    SELECT @start AS report_date
    UNION ALL
    SELECT DATEADD(DAY, 1, report_date)
    FROM month_dates
    WHERE report_date < @end
)
SELECT report_date FROM month_dates
OPTION (MAXRECURSION 31);
GO


-- ========================================================
-- ProjectManagementDB - Table Setup
-- ========================================================

IF DB_ID('ProjectManagementDB') IS NULL
    CREATE DATABASE ProjectManagementDB;
GO

USE ProjectManagementDB;
GO

DROP TABLE IF EXISTS Tasks;
DROP TABLE IF EXISTS Projects;
GO

CREATE TABLE Projects
(
    ProjectId   INT PRIMARY KEY,
    ProjectName VARCHAR(100) NOT NULL,
    StartDate   DATE NOT NULL,
    EndDate     DATE NULL,
    Status      VARCHAR(20) NOT NULL DEFAULT 'Planned',
    CHECK (EndDate IS NULL OR EndDate >= StartDate)
);
GO

CREATE TABLE Tasks
(
    TaskId          INT PRIMARY KEY,
    ProjectId       INT NOT NULL,
    TaskName        VARCHAR(150) NOT NULL,
    ParentTaskId    INT NULL,
    DependsOnTaskId INT NULL,
    AssignedTo      VARCHAR(100) NULL,
    StartDate       DATE NOT NULL,
    EndDate         DATE NULL,
    Status          VARCHAR(20) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (ProjectId)       REFERENCES Projects(ProjectId),
    FOREIGN KEY (ParentTaskId)    REFERENCES Tasks(TaskId),
    FOREIGN KEY (DependsOnTaskId) REFERENCES Tasks(TaskId),
    CHECK (ParentTaskId    IS NULL OR ParentTaskId    <> TaskId),
    CHECK (DependsOnTaskId IS NULL OR DependsOnTaskId <> TaskId),
    CHECK (EndDate IS NULL OR EndDate >= StartDate)
);
GO

-- Sample Projects
INSERT INTO Projects (ProjectId, ProjectName, StartDate, EndDate, Status) VALUES
(1, 'E-Commerce Application',     '2026-10-01', '2026-12-31', 'In Progress'),
(2, 'Employee Management System', '2026-10-05', '2027-01-31', 'Planned');
GO

-- Sample Tasks
INSERT INTO Tasks (TaskId, ProjectId, TaskName, ParentTaskId, DependsOnTaskId, AssignedTo, StartDate, EndDate, Status) VALUES
-- Project 1: top-level tasks
(101, 1, 'Requirement Analysis',  NULL, NULL, 'Rahul', '2026-10-01', '2026-10-05', 'Completed'),
(102, 1, 'System Design',         NULL, 101,  'Amit',  '2026-10-06', '2026-10-12', 'Completed'),
(103, 1, 'Backend Development',   NULL, 102,  'Priya', '2026-10-13', '2026-10-25', 'In Progress'),
(104, 1, 'Frontend Development',  NULL, 102,  'Neha',  '2026-10-13', '2026-10-27', 'In Progress'),
(105, 1, 'Testing',               NULL, 103,  'Rohit', '2026-10-28', '2026-11-05', 'Pending'),

-- Subtasks of Backend Development (103)
(106, 1, 'Database Design',       103,  NULL, 'Amit',  '2026-10-13', '2026-10-16', 'Completed'),
(107, 1, 'Develop API',           103,  106,  'Priya', '2026-10-17', '2026-10-23', 'In Progress'),
(108, 1, 'API Unit Testing',      103,  107,  'Rohit', '2026-10-24', '2026-10-25', 'Pending'),

-- Project 2
(201, 2, 'Gather Employee Requirements', NULL, NULL, 'Sneha', '2026-10-05', '2026-10-10', 'Planned'),
(202, 2, 'Design Employee Database',     NULL, 201,  'Amit',  '2026-10-11', '2026-10-15', 'Planned');
GO

-- ========================================================
-- Q1: Retrieve all subtasks under Backend Development (TaskId = 103)
-- ========================================================

;WITH SubTasks AS (
    -- Anchor: Start from the given parent task
    SELECT TaskId, ProjectId, TaskName, ParentTaskId, Status, 1 AS [Level]
    FROM Tasks
    WHERE TaskId = 103

    UNION ALL

    -- Recursive: Find all children
    SELECT t.TaskId, t.ProjectId, t.TaskName, t.ParentTaskId, t.Status, s.[Level] + 1
    FROM Tasks t
    INNER JOIN SubTasks s ON t.ParentTaskId = s.TaskId
)
SELECT TaskId, ProjectId, TaskName, Status, [Level]
FROM SubTasks
WHERE TaskId <> 103   -- exclude the parent itself
ORDER BY [Level], TaskId
OPTION (MAXRECURSION 100);
GO


-- ========================================================
-- Q2: Complete task hierarchy for Project 1 (ProjectId = 1)
-- ========================================================

;WITH TaskHierarchy AS (
    -- Anchor: Root tasks (no parent)
    SELECT 
        TaskId, ProjectId, TaskName, ParentTaskId, Status,
        1 AS [Level],
        CAST(TaskName AS VARCHAR(500)) AS HierarchyPath
    FROM Tasks
    WHERE ParentTaskId IS NULL AND ProjectId = 1

    UNION ALL

    -- Recursive: Add child tasks
    SELECT 
        t.TaskId, t.ProjectId, t.TaskName, t.ParentTaskId, t.Status,
        h.[Level] + 1,
        CAST(h.HierarchyPath + ' > ' + t.TaskName AS VARCHAR(500))
    FROM Tasks t
    INNER JOIN TaskHierarchy h ON t.ParentTaskId = h.TaskId
)
SELECT 
    TaskId,
    REPLICATE('  ', [Level] - 1) + TaskName AS TaskName,
    [Level],
    Status,
    HierarchyPath
FROM TaskHierarchy
ORDER BY HierarchyPath
OPTION (MAXRECURSION 100);
GO


-- ========================================================
-- Q3: Find Leaf Tasks (tasks with no children)
-- ========================================================

SELECT 
    t.ProjectId,
    t.TaskId,
    t.TaskName,
    t.Status
FROM Tasks t
WHERE NOT EXISTS (
    SELECT 1 FROM Tasks child WHERE child.ParentTaskId = t.TaskId
)
ORDER BY t.ProjectId, t.TaskId;
GO