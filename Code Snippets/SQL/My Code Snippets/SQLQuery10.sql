--CREATE SCHEMA HR
--CREATE TABLE [HR].[jobs]
--(
--job_id INT PRIMARY KEY IDENTITY,
--applicant_id INT NOT NULL,
--decription VARCHAR(200),
--created_at DATETIME2 NOT NULL
--);
CREATE TABLE [HR].[foreign_alphablets]
(
	[id] INT PRIMARY KEY IDENTITY,
	[name] NCHAR(20)

);
INSERT INTO [HR].[foreign_alphablets] ([name]) 
VALUES (N'শৈলেন');

SELECT * from [HR].[foreign_alphablets] 

CREATE TABLE [sales].[stores]
(
    [store_id] INT IDENTITY(1,1) PRIMARY KEY,
    [store_name] VARCHAR(255) NOT NULL,
    [phone] VARCHAR(25),
    [email] VARCHAR(255),
    [street] VARCHAR(255),
    [city] VARCHAR(255),
    [state] VARCHAR(10),
    [zip_code] VARCHAR(5)
);


CREATE TABLE [sales].[visitors]
(
    [visit_id] INT IDENTITY(1,1) PRIMARY KEY,
    [first_name] VARCHAR(50) NOT NULL,
    [last_name] VARCHAR(50) NOT NULL,
    [visited_at] DATETIME,
    [phone] VARCHAR(20),
    [store_id] INT NOT NULL,
    
    FOREIGN KEY ([store_id])
        REFERENCES [sales].[stores] ([store_id])
);

UPDATE [sales].[stores]
SET
    [store_name] = 'Super Store',
    [phone] = '9876543210',
    [city] = 'Kolkata'
WHERE [store_id] = 1;






---------------------------Assignment--------------------------


CREATE TABLE [HR].[Products]
(
    [product_id] INT IDENTITY(1,1) PRIMARY KEY,

    [product_name] VARCHAR(100) NOT NULL,

    [category] VARCHAR(20) NOT NULL
        CHECK ([category] IN ('Exterior', 'Interior', 'Dual')),

    [finish_type] VARCHAR(50) NOT NULL,

    [binder_type] VARCHAR(50) NOT NULL,

    [voc_level_g_l] DECIMAL(5,2) NOT NULL,

    [created_at] DATETIME2 DEFAULT CURRENT_TIMESTAMP
);


/* =========================================================
   2. CREATE VARIANTS TABLE
   ========================================================= */

CREATE TABLE [HR].[Variants]
(
    [variant_id] INT IDENTITY(1,1) PRIMARY KEY,

    [product_id] INT NOT NULL,

    [base_type] VARCHAR(20) NOT NULL,

    [pack_size_liters] DECIMAL(5,2) NOT NULL,

    [sku_code] VARCHAR(30) UNIQUE NOT NULL,

    [unit_cost] DECIMAL(10,2) NOT NULL,

    [mrp] DECIMAL(10,2) NOT NULL,

    FOREIGN KEY ([product_id])
        REFERENCES [HR].[Products] ([product_id])
);




INSERT INTO [HR].[Products]
    ([product_name], [category], [finish_type], [binder_type], [voc_level_g_l])
VALUES
    ('Door Paint', 'Exterior', 'Matte', 'Pure Acrylic', 25.00);

INSERT INTO [HR].[Products]
    ([product_name], [category], [finish_type], [binder_type], [voc_level_g_l])
VALUES
    ('TV Room Paint', 'Interior', 'Satin', 'Styrene Acrylic', 15.00);

INSERT INTO [HR].[Products]
    ([product_name], [category], [finish_type], [binder_type], [voc_level_g_l])
VALUES
    ('Monitor Room Paint', 'Dual', 'Gloss', 'Pure Acrylic', 20.00);




INSERT INTO [HR].[Variants]
    ([product_id], [base_type], [pack_size_liters], [sku_code], [unit_cost], [mrp])
VALUES
    (7, 'Pastel/White Base', 1.00, 'DOR-WHT-001', 180.00, 250.00);

INSERT INTO [HR].[Variants]
    ([product_id], [base_type], [pack_size_liters], [sku_code], [unit_cost], [mrp])
VALUES
    (12,'Deep Base', 4.00, 'DOR-DEP-004', 620.00, 850.00);




SELECT * 
FROM [HR].[Products];

SELECT * 
FROM [HR].[Variants];

-- =========================================
-- FOREIGN KEY IMPLEMENTATION
-- =========================================

-- Create schema
CREATE SCHEMA [Demo];


-- =========================================
-- MASTER / PARENT TABLE
-- =========================================

CREATE TABLE [Demo].[Department] (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [dept] VARCHAR(50),
    [location] VARCHAR(100)
);


-- =========================================
-- CHILD TABLE
-- =========================================

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


-- =========================================
-- INSERT INTO MASTER TABLE FIRST
-- =========================================

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


-- =========================================
-- INSERT INTO CHILD TABLE
-- =========================================

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