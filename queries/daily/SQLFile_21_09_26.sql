CREATE DATABASE assignment;

USE assignment;
GO

CREATE SCHEMA [assignment];
GO

CREATE TABLE [assignment].[products]
(
    [product_id] INT IDENTITY(1,1) PRIMARY KEY,
    [product_name] VARCHAR(100) NOT NULL,
    [category] VARCHAR(20) NOT NULL,
    [finish_type] VARCHAR(50) NOT NULL,
    [binder_type] VARCHAR(50) NOT NULL,
    [voc_level_g_l] DECIMAL(10,2) NOT NULL,
    [created_at] DATETIME DEFAULT GETDATE(),

    CONSTRAINT [CK_products_category]
        CHECK ([category] IN ('Exterior', 'Interior', 'Dual'))
);

USE [assignment];
GO

INSERT INTO [assignment].[products]
(
    [product_name],
    [category],
    [finish_type],
    [binder_type],
    [voc_level_g_l]
)
VALUES
('Apex Shield', 'Exterior', 'Matte', 'Acrylic', 35.00),
('Weather Guard', 'Exterior', 'Gloss', 'Acrylic', 45.00),
('Ultra Protect', 'Exterior', 'Satin', 'Alkyd', 48.50),
('Interior Silk', 'Interior', 'Silk', 'Acrylic', 30.00),
('Dura Coat', 'Exterior', 'Gloss', 'Acrylic', 65.00),
('Premium Interior', 'Interior', 'Matte', 'Vinyl', 40.00),
('Dual Defense', 'Dual', 'Satin', 'Acrylic', 42.00),
('Eco Exterior', 'Exterior', 'Matte', 'Acrylic', 25.00);
GO

USE [assignment];
GO

-- 1. Create the archive table
CREATE TABLE [assignment].[exterior_premium_products]
(
    [product_id] INT PRIMARY KEY,
    [product_name] VARCHAR(100) NOT NULL,
    [category] VARCHAR(20) NOT NULL,
    [finish_type] VARCHAR(50) NOT NULL,
    [binder_type] VARCHAR(50) NOT NULL,
    [voc_level_g_l] DECIMAL(10,2) NOT NULL,
    [created_at] DATETIME
);
GO

-- Bulk insert qualifying products
INSERT INTO [assignment].[exterior_premium_products]
(
    [product_id],
    [product_name],
    [category],
    [finish_type],
    [binder_type],
    [voc_level_g_l],
    [created_at]
)
SELECT
    [product_id],
    [product_name],
    [category],
    [finish_type],
    [binder_type],
    [voc_level_g_l],
    [created_at]
FROM [assignment].[products]
WHERE [category] = 'Exterior'
  AND [voc_level_g_l] < 50.00;
GO



------------------------------------------------------------------------------------------------
--CREATING raw_materials

CREATE TABLE [assignment].[raw_materials]
(
    [material_id] INT IDENTITY(1,1) PRIMARY KEY,
    [material_name] VARCHAR(100) NOT NULL,
    [material_category] VARCHAR(50) NOT NULL,
    [unit] VARCHAR(20) NOT NULL,
    [reorder_level] DECIMAL(10,2) NOT NULL,
    [hazardous_flag] BIT NOT NULL
);
GO

--Insert some sample materials
INSERT INTO [assignment].[raw_materials]
(
    [material_name],
    [material_category],
    [unit],
    [reorder_level],
    [hazardous_flag]
)
VALUES
('Titanium Dioxide', 'Pigment', 'KG', 750.00, 0),
('Acrylic Resin', 'Binder', 'KG', 300.00, 0),
('Calcium Carbonate', 'Filler', 'KG', 600.00, 0),
('Xylene', 'Solvent', 'L', 800.00, 1),
('Talc Powder', 'Filler', 'KG', 450.00, 0),
('Iron Oxide Red', 'Pigment', 'KG', 550.00, 0);
GO

--Question 2 answer
SELECT *
INTO [assignment].[high_cost_raw_materials]
FROM [assignment].[raw_materials]
WHERE [reorder_level] > 500.00;

--SELECT INTO = create table + copy data
--INSERT INTO ... SELECT = copy data into an existing table
-----------------------------------------------------------------------------------------------------------



--Question 3

USE [assignment];
GO

BULK INSERT [assignment].[raw_materials]
FROM 'D:\Exel Data\raw_material_imports.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0d0a'    --end of a line
);
GO

-- check
SELECT *
FROM [assignment].[raw_materials];

-----------------------------------------------------------------------------------------------------------


-- Createing [formulas]
CREATE TABLE [assignment].[formulas]
(
    [formula_id] INT IDENTITY(1,1) PRIMARY KEY,
    [product_id] INT NOT NULL,

    CONSTRAINT [FK_formulas_products]
        FOREIGN KEY ([product_id])
        REFERENCES [assignment].[products]([product_id])
);

-- Creating [formula_items]
CREATE TABLE [assignment].[formula_items]
(
    [formula_item_id] INT IDENTITY(1,1) PRIMARY KEY,
    [formula_id] INT NOT NULL,
    [material_id] INT NOT NULL,

    CONSTRAINT [FK_formula_items_formulas]
        FOREIGN KEY ([formula_id])
        REFERENCES [assignment].[formulas]([formula_id])
);

-- Populating
INSERT INTO [assignment].[formulas]
(
    [product_id]
)
VALUES
(1),
(1),
(2),
(2),
(3),
(4);

INSERT INTO [assignment].[formula_items]
(
    [formula_id],
    [material_id]
)
VALUES
-- Product 1 → 7 distinct materials
(1, 1),
(1, 2),
(1, 3),
(1, 4),

(2, 3),
(2, 5),
(2, 6),
(2, 7),

-- Product 2 → 4 distinct materials
(3, 1),
(3, 2),
(4, 3),
(4, 4),

-- Product 3 → 6 distinct materials
(5, 1),
(5, 2),
(5, 3),
(5, 4),
(5, 5),
(5, 6),

-- Product 4 → 2 distinct materials
(6, 1),
(6, 2);
GO

-- Question 4
SELECT
    [p].[product_id],
    COUNT(DISTINCT [fi].[material_id]) AS [total_raw_materials]
FROM [assignment].[products] AS [p]
INNER JOIN [assignment].[formulas] AS [f]
    ON [p].[product_id] = [f].[product_id]
INNER JOIN [assignment].[formula_items] AS [fi]
    ON [f].[formula_id] = [fi].[formula_id]
GROUP BY
    [p].[product_id]
HAVING
    COUNT(DISTINCT [fi].[material_id]) > 5;



    -------------------------------------------------------------------------------------


CREATE TABLE [assignment].[qc_test_logs]
(
    [log_id] INT IDENTITY(1,1) PRIMARY KEY,
    [batch_id] INT NOT NULL,
    [test_parameter] VARCHAR(50) NOT NULL,
    [measured_value] VARCHAR(30) NOT NULL,
    [passed] BIT NOT NULL
);

INSERT INTO [assignment].[qc_test_logs]
(
    [batch_id],
    [test_parameter],
    [measured_value],
    [passed]
)
VALUES
-- Batch 101
(101, 'Viscosity', '120.50', 1),
(101, 'Viscosity', '118.75', 0),
(101, 'Viscosity', '121.25', 0),
(101, 'Viscosity', '119.80', 1),

(101, 'pH', '8.20', 1),
(101, 'pH', '8.10', 1),
(101, 'pH', '8.30', 0),

-- Batch 102
(102, 'Viscosity', '135.40', 0),
(102, 'Viscosity', '136.20', 0),
(102, 'Viscosity', '134.80', 1),

(102, 'pH', '7.90', 0),
(102, 'pH', '8.00', 0),
(102, 'pH', '8.10', 0),

-- Batch 103
(103, 'Density', '1.25', 1),
(103, 'Density', '1.27', 0),
(103, 'Density', '1.26', 0);


-- Question 5 answer
SELECT
    [batch_id],
    [test_parameter],
    AVG(CAST([measured_value] AS DECIMAL(10,2))) AS [average_measured_value],
    COUNT(CASE WHEN [passed] = 0 THEN 1 END) AS [failed_tests]
FROM [assignment].[qc_test_logs]
GROUP BY
    [batch_id],
    [test_parameter]
HAVING
    COUNT(CASE WHEN [passed] = 0 THEN 1 END) >= 2;


-----------------------------------------------------------------------------------------------------


CREATE TABLE [assignment].[product_variants]
(
    [variant_id] INT IDENTITY(1,1) PRIMARY KEY,
    [product_id] INT NOT NULL,
    [sku_code] VARCHAR(50) NOT NULL,
    [pack_size_liters] DECIMAL(10,2) NOT NULL,
    [mrp] DECIMAL(10,2) NOT NULL
);
GO

-- DATA
INSERT INTO [assignment].[product_variants]
(
    [product_id],
    [sku_code],
    [pack_size_liters],
    [mrp]
)
VALUES
(1, 'EX-001', 1.00, 450.00),
(1, 'EX-002', 2.00, 800.00),
(1, 'EX-003', 5.00, 1750.00),
(1, 'EX-004', 10.00, 3200.00),
(2, 'WG-001', 1.00, 500.00),
(2, 'WG-002', 2.00, 900.00),
(2, 'WG-003', 5.00, 1800.00),
(2, 'WG-004', 10.00, 3400.00),
(3, 'UP-001', 1.00, 475.00),
(3, 'UP-002', 2.00, 850.00),
(3, 'UP-003', 5.00, 1900.00),
(3, 'UP-004', 10.00, 3500.00),
(4, 'IS-001', 1.00, 400.00),
(4, 'IS-002', 2.00, 750.00),
(4, 'IS-003', 5.00, 1600.00),
(4, 'IS-004', 10.00, 3000.00),
(5, 'DC-001', 1.00, 525.00),
(5, 'DC-002', 2.00, 950.00),
(5, 'DC-003', 5.00, 2000.00),
(5, 'DC-004', 10.00, 3700.00),
(6, 'PI-001', 1.00, 425.00),
(6, 'PI-002', 2.00, 780.00),
(6, 'PI-003', 5.00, 1650.00),
(6, 'PI-004', 10.00, 3100.00),
(7, 'DD-001', 1.00, 550.00),
(7, 'DD-002', 2.00, 1000.00),
(7, 'DD-003', 5.00, 2100.00),
(7, 'DD-004', 10.00, 3900.00),
(8, 'EE-001', 1.00, 475.00),
(8, 'EE-002', 2.00, 820.00),
(8, 'EE-003', 5.00, 1850.00),
(8, 'EE-004', 10.00, 3600.00);
GO

-- Question 6 answer
SELECT
    [variant_id],
    [product_id],
    [sku_code],
    [pack_size_liters],
    [mrp]
FROM [assignment].[product_variants]
ORDER BY
    [mrp] DESC,
    [variant_id] ASC
OFFSET 20 ROWS
FETCH NEXT 10 ROWS ONLY;

-----------------------------------------------------------------------------------------------------



CREATE TABLE [assignment].[stg_raw_materials]
(
    [material_id] INT NOT NULL,
    [material_name] VARCHAR(100) NOT NULL,
    [material_category] VARCHAR(50) NOT NULL,
    [unit] VARCHAR(20) NOT NULL,
    [reorder_level] DECIMAL(10,2) NOT NULL,
    [hazardous_flag] BIT NOT NULL
);
GO

INSERT INTO [assignment].[stg_raw_materials]
(
    [material_id],
    [material_name],
    [material_category],
    [unit],
    [reorder_level],
    [hazardous_flag]
)
VALUES
(1, 'Titanium Dioxide', 'Pigment', 'KG', 900.00, 0),
(2, 'Acrylic Resin', 'Binder', 'KG', 450.00, 0),
(20, 'Zinc Oxide', 'Pigment', 'KG', 700.00, 1);
GO

-- Question 7 : Merge
SET IDENTITY_INSERT [assignment].[raw_materials] ON;
GO

MERGE [assignment].[raw_materials] AS [Target]
USING [assignment].[stg_raw_materials] AS [Source]
    ON [Target].[material_id] = [Source].[material_id]

WHEN MATCHED THEN
    UPDATE SET
        [Target].[reorder_level] = [Source].[reorder_level],
        [Target].[hazardous_flag] = [Source].[hazardous_flag]

WHEN NOT MATCHED BY TARGET THEN
    INSERT
    (
        [material_id],
        [material_name],
        [material_category],
        [unit],
        [reorder_level],
        [hazardous_flag]
    )
    VALUES
    (
        [Source].[material_id],
        [Source].[material_name],
        [Source].[material_category],
        [Source].[unit],
        [Source].[reorder_level],
        [Source].[hazardous_flag]
    );

GO

SET IDENTITY_INSERT [assignment].[raw_materials] OFF;
GO

-- Show 
SELECT *
FROM [assignment].[raw_materials]
ORDER BY [material_id];

----------------------------------------------------------------------------------------------------
-- Creating the table
CREATE TABLE [assignment].[color_shades]
(
    [shade_id] INT IDENTITY(1,1) PRIMARY KEY,
    [shade_name] VARCHAR(100) NOT NULL,
    [shade_code] VARCHAR(30) NOT NULL,
    [is_exterior_durable] BIT NOT NULL
);

CREATE TABLE [assignment].[shade_recipes]
(
    [recipe_id] INT IDENTITY(1,1) PRIMARY KEY,
    [shade_id] INT NOT NULL,
    [material_id] INT NOT NULL,

    CONSTRAINT [FK_shade_recipes_shades]
        FOREIGN KEY ([shade_id])
        REFERENCES [assignment].[color_shades]([shade_id]),

    CONSTRAINT [FK_shade_recipes_materials]
        FOREIGN KEY ([material_id])
        REFERENCES [assignment].[raw_materials]([material_id])
);

-- Populating
INSERT INTO [assignment].[color_shades]
(
    [shade_name],
    [shade_code],
    [is_exterior_durable]
)
VALUES
('Ocean Blue', 'OB-101', 1),
('Sunset Red', 'SR-202', 1),
('Forest Green', 'FG-303', 1),
('Soft Cream', 'SC-404', 0),
('Deep Yellow', 'DY-505', 1);

INSERT INTO [assignment].[shade_recipes]
(
    [shade_id],
    [material_id]
)
VALUES
(1, 1),   -- Ocean Blue -> Pigment
(1, 2),   -- Ocean Blue -> Binder

(2, 3),   -- Sunset Red -> Filler
(2, 4),   -- Sunset Red -> Solvent

(3, 6),   -- Forest Green -> Pigment

(4, 1),   -- Soft Cream -> Pigment

(5, 7);   -- Deep Yellow -> Pigment


-- Question 8 — Answer using EXISTS
SELECT
    [cs].[shade_name],
    [cs].[shade_code]
FROM [assignment].[color_shades] AS [cs]
WHERE [cs].[is_exterior_durable] = 1
  AND EXISTS
  (
      SELECT 1
      FROM [assignment].[shade_recipes] AS [sr]
      INNER JOIN [assignment].[raw_materials] AS [rm]
          ON [sr].[material_id] = [rm].[material_id]
      WHERE [sr].[shade_id] = [cs].[shade_id]
        AND [rm].[material_category] = 'Pigment'
  );

-------------------------------------------------------------------------------------------------

DROP TABLE [assignment].[formula_items];

-- Question 9 
CREATE TABLE [assignment].[formula_items]
(
    [formula_item_id] INT IDENTITY(1,1) PRIMARY KEY,
    [formula_id] INT NOT NULL,
    [material_id] INT NOT NULL,
    [quantity_required] DECIMAL(10,2) NOT NULL,

    CONSTRAINT [FK_formula_items_formulas]
        FOREIGN KEY ([formula_id])
        REFERENCES [assignment].[formulas]([formula_id])
        ON DELETE CASCADE,

    CONSTRAINT [FK_formula_items_raw_materials]
        FOREIGN KEY ([material_id])
        REFERENCES [assignment].[raw_materials]([material_id])
        ON UPDATE CASCADE
        ON DELETE NO ACTION 
);
-- Show
SELECT *
FROM [assignment].[formula_items];

---------------------------------------------------------------------------------------------------
-- Question 10

CREATE TABLE [assignment].[batch_production]
(
    [batch_id] INT IDENTITY(1,1) PRIMARY KEY,
    [batch_number] VARCHAR(50) NOT NULL,
    [formula_id] INT NULL,
    [quantity_produced] DECIMAL(10,2) NOT NULL,
    [manufacture_date] DATE NOT NULL,

    CONSTRAINT [FK_batch_production_formulas]
        FOREIGN KEY ([formula_id])
        REFERENCES [assignment].[formulas]([formula_id])
        ON DELETE SET NULL
);

--------------------------------------------------------------------------------------------------------------

-- Testing --
USE [assignment];
GO

DECLARE @TestFormulaID INT;

INSERT INTO [assignment].[formulas]
(
    [product_id]
)
VALUES
(1);

SET @TestFormulaID = SCOPE_IDENTITY();

SELECT @TestFormulaID AS [TestFormulaID];
GO


INSERT INTO [assignment].[batch_production]
(
    [batch_number],
    [formula_id],
    [quantity_produced],
    [manufacture_date]
)
VALUES
('BATCH-001', 13, 1000.00, '2026-09-20'),
('BATCH-002', 13, 750.00, '2026-09-21'),
('BATCH-003', 1, 500.00, '2026-09-22');


SELECT
    [batch_id],
    [batch_number],
    [formula_id],
    [quantity_produced],
    [manufacture_date]
FROM [assignment].[batch_production]
ORDER BY [batch_id];

DELETE FROM [assignment].[formulas]
WHERE [formula_id] = 13;

SELECT
    [batch_id],
    [batch_number],
    [formula_id],
    [quantity_produced],
    [manufacture_date]
FROM [assignment].[batch_production]
ORDER BY [batch_id];
