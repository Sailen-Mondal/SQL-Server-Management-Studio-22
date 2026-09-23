------------ DATE : 18.09.26 -------------

-- AND OR 
SELECT *
FROM [Demo].[Department]
WHERE [dept] = 'IT'
AND [location] = 'Kolkata';

-- IN 
SELECT *
FROM [Demo].[Department]
WHERE [location] IN ('Kolkata', 'Mumbai', 'Delhi');

-- MERGE IMPLEMENTATION


-- TARGET TABLE
CREATE TABLE [Demo].[Employee_Main] (
    [emp_id] INT PRIMARY KEY,
    [name] VARCHAR(50),
    [city] VARCHAR(50),
    [salary] INT
);

-- SOURCE TABLE
CREATE TABLE [Demo].[Employee_Staging] (
    [emp_id] INT PRIMARY KEY,
    [name] VARCHAR(50),
    [city] VARCHAR(50),
    [salary] INT
);


-- INSERT DATA INTO TARGET TABLE

INSERT INTO [Demo].[Employee_Main]
(emp_id, name, city, salary)
VALUES
(1, 'Sailen', 'Kolkata', 30000),
(2, 'Arko', 'Mumbai', 35000),
(3, 'Rahul', 'Delhi', 40000),
(4, 'Priya', 'Pune', 38000),
(5, 'Amit', 'Hyderabad', 32000);


-- INSERT DATA INTO SOURCE TABLE

INSERT INTO [Demo].[Employee_Staging]
(emp_id, name, city, salary)
VALUES
(1, 'Sailen', 'Kolkata', 32000),       -- Salary updated
(2, 'Arko', 'Mumbai', 35000),          -- No change
(3, 'Rahul', 'Bangalore', 42000),      -- City + salary updated
(5, 'Amit', 'Hyderabad', 34000),        -- Salary updated
(6, 'Neha', 'Chennai', 36000);          -- New employee


-- MERGE

MERGE [Demo].[Employee_Main] AS T
USING [Demo].[Employee_Staging] AS S
ON T.emp_id = S.emp_id

-- When employee exists in both tables
WHEN MATCHED THEN
    UPDATE SET
        T.name = S.name,
        T.city = S.city,
        T.salary = S.salary

-- When employee exists only in source
WHEN NOT MATCHED BY TARGET THEN
    INSERT (emp_id, name, city, salary)
    VALUES (S.emp_id, S.name, S.city, S.salary)

-- When employee exists only in target
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;


-- CHECK FINAL RESULT

SELECT *
FROM [Demo].[Employee_Main];


CREATE SCHEMA [Demo];

CREATE TABLE [Demo].[Products] (
    [product_id] INT IDENTITY PRIMARY KEY,
    [product_name] VARCHAR(100) NOT NULL,
    [category] VARCHAR(20) NOT NULL
        CHECK ([category] IN ('Exterior', 'Interior', 'Dual')),
    [finish_type] VARCHAR(50) NOT NULL,
    [binder_type] VARCHAR(50) NOT NULL,
    [voc_level_g_l] DECIMAL(5,2) NOT NULL,
    [created_at] DATETIME2 DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE [Demo].[Product_Variants] (
    [variant_id] INT IDENTITY PRIMARY KEY,
    [product_id] INT NOT NULL,
    [base_type] VARCHAR(20) NOT NULL,
    [pack_size_liters] DECIMAL(5,2) NOT NULL,
    [sku_code] VARCHAR(30) UNIQUE NOT NULL,
    [unit_cost] DECIMAL(10,2) NOT NULL,
    [mrp] DECIMAL(10,2) NOT NULL,
    FOREIGN KEY ([product_id]) REFERENCES [Demo].[Products]([product_id])
);

CREATE TABLE [Demo].[Raw_Materials] (
    [material_id] INT IDENTITY PRIMARY KEY,
    [material_name] VARCHAR(100) NOT NULL,
    [type] VARCHAR(20) NOT NULL
        CHECK ([type] IN ('Pigment', 'Binder', 'Solvent', 'Additive')),
    [unit_of_measure] VARCHAR(10) NOT NULL,
    [reorder_level] DECIMAL(10,2) NOT NULL,
    [hazardous_flag] BIT DEFAULT 0
);

CREATE TABLE [Demo].[Formulas] (
    [formula_id] INT IDENTITY PRIMARY KEY,
    [product_id] INT NOT NULL,
    [base_type] VARCHAR(20) NOT NULL,
    [yield_liters] DECIMAL(10,2) NOT NULL,
    [version] VARCHAR(10) NOT NULL,
    FOREIGN KEY ([product_id]) REFERENCES [Demo].[Products]([product_id])
);

CREATE TABLE [Demo].[Formula_Items] (
    [formula_item_id] INT IDENTITY PRIMARY KEY,
    [formula_id] INT NOT NULL,
    [material_id] INT NOT NULL,
    [quantity] DECIMAL(10,4) NOT NULL,
    [addition_stage] VARCHAR(50) NOT NULL,
    FOREIGN KEY ([formula_id]) REFERENCES [Demo].[Formulas]([formula_id]),
    FOREIGN KEY ([material_id]) REFERENCES [Demo].[Raw_Materials]([material_id])
);

CREATE TABLE [Demo].[Color_Shades] (
    [shade_id] INT IDENTITY PRIMARY KEY,
    [shade_code] VARCHAR(20) UNIQUE NOT NULL,
    [shade_name] VARCHAR(100) NOT NULL,
    [hex_value] VARCHAR(7) NOT NULL,
    [is_exterior_durable] BIT NOT NULL
);

CREATE TABLE [Demo].[Shade_Recipes] (
    [recipe_id] INT IDENTITY PRIMARY KEY,
    [shade_id] INT NOT NULL,
    [product_id] INT NOT NULL,
    [colorant_id] INT NOT NULL,
    [shots_per_liter] DECIMAL(8,4) NOT NULL,
    FOREIGN KEY ([shade_id]) REFERENCES [Demo].[Color_Shades]([shade_id]),
    FOREIGN KEY ([product_id]) REFERENCES [Demo].[Products]([product_id]),
    FOREIGN KEY ([colorant_id]) REFERENCES [Demo].[Raw_Materials]([material_id])
);

CREATE TABLE [Demo].[Batch_Production] (
    [batch_id] INT IDENTITY PRIMARY KEY,
    [batch_number] VARCHAR(30) UNIQUE NOT NULL,
    [formula_id] INT NOT NULL,
    [quantity_produced] DECIMAL(10,2) NOT NULL,
    [manufacture_date] DATE NOT NULL,
    [qc_status] VARCHAR(20) DEFAULT 'Pending'
        CHECK ([qc_status] IN ('Pending', 'Approved', 'Rejected')),
    FOREIGN KEY ([formula_id]) REFERENCES [Demo].[Formulas]([formula_id])
);

CREATE TABLE [Demo].[QC_Test_Logs] (
    [log_id] INT IDENTITY PRIMARY KEY,
    [batch_id] INT NOT NULL,
    [test_parameter] VARCHAR(50) NOT NULL,
    [measured_value] VARCHAR(50) NOT NULL,
    [passed] BIT NOT NULL,
    [tested_by] INT NOT NULL,
    FOREIGN KEY ([batch_id]) REFERENCES [Demo].[Batch_Production]([batch_id])
);

INSERT INTO [Demo].[Products]
(product_name, category, finish_type, binder_type, voc_level_g_l)
VALUES
('Apex Shield Exterior', 'Exterior', 'Semi-Gloss', 'Pure Acrylic', 28.50),
('Velvet Interior Pure', 'Interior', 'Matte', 'Vinyl Acetate', 18.20),
('Monsoon Guard Premium', 'Dual', 'Satin', 'Styrene Acrylic', 24.80);

INSERT INTO [Demo].[Product_Variants]
(product_id, base_type, pack_size_liters, sku_code, unit_cost, mrp)
VALUES
(1, 'White Base', 4.00, 'APEX-W-04', 620.00, 850.00),
(1, 'Deep Base', 20.00, 'APEX-D-20', 2850.00, 3900.00),
(2, 'White Base', 10.00, 'VELV-W-10', 1150.00, 1650.00),
(3, 'Clear Base', 4.00, 'MON-C-04', 700.00, 980.00),
(3, 'Pastel Base', 20.00, 'MON-P-20', 3100.00, 4250.00);

INSERT INTO [Demo].[Raw_Materials]
(material_name, type, unit_of_measure, reorder_level, hazardous_flag)
VALUES
('Titanium Dioxide', 'Pigment', 'KG', 150, 0),
('Calcium Carbonate', 'Pigment', 'KG', 300, 0),
('Pure Acrylic Binder', 'Binder', 'L', 200, 0),
('Coalescing Solvent', 'Solvent', 'L', 100, 1),
('Yellow Iron Oxide', 'Pigment', 'KG', 50, 0);

INSERT INTO [Demo].[Formulas]
(product_id, base_type, yield_liters, version)
VALUES
(1, 'White Base', 1000, 'v1.0'),
(2, 'White Base', 1000, 'v2.1'),
(3, 'Clear Base', 500, 'v1.2');

INSERT INTO [Demo].[Formula_Items]
(formula_id, material_id, quantity, addition_stage)
VALUES
(1, 1, 180.0000, 'Grinding'),
(1, 2, 250.0000, 'Grinding'),
(1, 3, 220.0000, 'Letting Down'),
(2, 1, 150.0000, 'Grinding'),
(2, 3, 280.0000, 'Letting Down'),
(3, 3, 160.0000, 'Letting Down');

INSERT INTO [Demo].[Color_Shades]
(shade_code, shade_name, hex_value, is_exterior_durable)
VALUES
('RAL-5015', 'Sky Blue', '#4F81BD', 1),
('RAL-7016', 'Anthracite Grey', '#383E42', 1),
('IND-WB-101', 'Warm Terracotta', '#C96F56', 1),
('IND-KO-205', 'Kolkata Green', '#4F7942', 0);

INSERT INTO [Demo].[Shade_Recipes]
(shade_id, product_id, colorant_id, shots_per_liter)
VALUES
(1, 1, 1, 0.8500),
(2, 1, 2, 0.6500),
(3, 3, 5, 0.4200),
(4, 2, 5, 0.3000);

INSERT INTO [Demo].[Batch_Production]
(batch_number, formula_id, quantity_produced, manufacture_date, qc_status)
VALUES
('KOL-SEP-26001', 1, 980.00, '2026-09-10', 'Approved'),
('KOL-SEP-26002', 2, 995.00, '2026-09-11', 'Approved'),
('KOL-SEP-26003', 3, 490.00, '2026-09-12', 'Pending'),
('KOL-SEP-26004', 1, 975.00, '2026-09-14', 'Approved');

INSERT INTO [Demo].[QC_Test_Logs]
(batch_id, test_parameter, measured_value, passed, tested_by)
VALUES
(1, 'Viscosity (KU)', '108 KU', 1, 101),
(1, 'pH', '8.4', 1, 101),
(2, 'Scrub Cycles', '12000', 1, 102),
(2, 'Drying Time', '45 min', 1, 102),
(3, 'Viscosity (KU)', '112 KU', 0, 101),
(4, 'Weathering', 'Pass', 1, 103);

SELECT * FROM [Demo].[Products];
SELECT * FROM [Demo].[Product_Variants];
SELECT * FROM [Demo].[Raw_Materials];
SELECT * FROM [Demo].[Formulas];
SELECT * FROM [Demo].[Formula_Items];
SELECT * FROM [Demo].[Color_Shades];
SELECT * FROM [Demo].[Shade_Recipes];
SELECT * FROM [Demo].[Batch_Production];
SELECT * FROM [Demo].[QC_Test_Logs];