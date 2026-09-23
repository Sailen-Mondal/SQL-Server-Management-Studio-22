-----------------Date 17.09.26---------------

CREATE TABLE [Demo].[Orders](
[id] INT PRIMARY KEY IDENTITY(1,1),
[order_descirption] VARCHAR(100),
[order_quility] VARCHAR(50)
);

CREATE TABLE [Demo].[items](
[product_id] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,

-- MAKING PRODUCT NAME UNIQUE
[product_name] VARCHAR(50) NOT NULL UNIQUE,

[product_price] INT NOT NULL
);

-- INSERT DATA INTO ORDERS

INSERT INTO [Demo].[items]
(product_name, product_price)
VALUES
('Dell Laptop', 70001);


INSERT INTO [Demo].[Orders]
    ([order_descirption], [order_quility])
VALUES
    ('Office chairs for Kolkata branch', '10'),
    ('Dell laptops for IT department', '5'),
    ('Printer cartridges', '20'),
    ('LED monitors for employees', '8'),
    ('Office tables for Mumbai branch', '6'),
    ('Wireless keyboards', '15'),
    ('Computer mouse', '20'),
    ('HP laser printers', '3'),
    ('USB Type-C cables', '25'),
    ('Conference room projectors', '2');



-- INSERT DATA INTO ITEMS


INSERT INTO [Demo].[items]
    ([product_name], [product_price])
VALUES
    ('Office Chair', 5500),
    ('Dell Laptop', 65000),
    ('Printer Cartridge', 3200),
    ('LED Monitor', 12000),
    ('Office Table', 8500),
    ('Wireless Keyboard', 1800),
    ('Computer Mouse', 900),
    ('HP Laser Printer', 18500),
    ('USB Type-C Cable', 650),
    ('Epson Projector', 42000);


-- VIEW DATA


SELECT *
FROM [Demo].[Orders];

SELECT *
FROM [Demo].[Items];

--Compostite Key Table
CREATE TABLE[Demo].[Order_items](
[order_id] INT NOT NULL,
[product_id] INT NOT NULL,

PRIMARY KEY ([order_id],[product_id]),


);

-- VIEW DATA
SELECT * from [Demo].[Order_items]

--UNIQUE CONSTRAINT
DROP TABLE  [Demo].[items]

-- CHECK Constraint 
CREATE TABLE [Demo].[employee](
[id] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
[age] INT CHECK (age >= 18),
);

INSERT INTO [Demo].[Employee] (id, age)
VALUES
(1, 25),
(2, 30),
(3, 18);

INSERT INTO [Demo].[Employee] (age)
VALUES ( 20);

-- DEFAULT Constraint
CREATE TABLE [Demo].[Employee_2] (
    [id] INT PRIMARY KEY,
    [city] VARCHAR(50) DEFAULT 'Kolkata'
);

-- Create table
CREATE TABLE [Demo].[CSV_Data] (
    [id] INT,
    [NAME] VARCHAR(50),
    [PHONE] VARCHAR(20)
);

-- Import CSV file
BULK INSERT [Demo].[CSV_Data]
FROM 'D:\Excel\Book1.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

-- Check imported data
SELECT *
FROM [Demo].[CSV_Data];

SELECT * FROM [Demo].[Department]
SELECT * FROM [Demo].[Department]