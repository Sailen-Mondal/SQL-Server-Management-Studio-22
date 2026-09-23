/*
    INNER JOIN practice
*/

-- Create the Demo schema only if it does not already exist.
IF SCHEMA_ID(N'Demo') IS NULL
    EXEC(N'CREATE SCHEMA [Demo]');


-- These tables are only for this join exercise, so the script can be rerun.
DROP TABLE IF EXISTS [Demo].[Join_Employees];
DROP TABLE IF EXISTS [Demo].[Join_Candidates];


CREATE TABLE [Demo].[Join_Candidates]
(
    [candidate_id] INT IDENTITY(1,1) PRIMARY KEY,
    [full_name] VARCHAR(100) NOT NULL
);

CREATE TABLE [Demo].[Join_Employees]
(
    [employee_id] INT IDENTITY(1,1) PRIMARY KEY,
    [full_name] VARCHAR(100) NOT NULL
);


INSERT INTO [Demo].[Join_Candidates] ([full_name])
VALUES
    ('Riya Sharma'),
    ('Arko Das'),
    ('Sailen Mondal');


INSERT INTO [Demo].[Join_Employees] ([full_name])
VALUES
    ('Riya Sharma'),
    ('Arko Das'),
    ('Priya Sen');
GO

-- INNER JOIN: returns only names that appear in BOTH tables.
SELECT
    c.[candidate_id],
    c.[full_name] AS [candidate_name],
    e.[employee_id],
    e.[full_name] AS [employee_name]
FROM [Demo].[Join_Candidates] AS c
INNER JOIN [Demo].[Join_Employees] AS e
    ON e.[full_name] = c.[full_name]
ORDER BY c.[candidate_id];
GO

-- Optional: inspect the source tables.
SELECT * FROM [Demo].[Join_Candidates];
SELECT * FROM [Demo].[Join_Employees];


/* =========================================================
   JOIN ASSIGNMENT - using the existing Demo schema tables
   Note: In this database, sku_code is the SKU and base_type
   is used as the variant name.
   ========================================================= */

-- 1. INNER JOIN: show products that have one or more variants.
SELECT
    p.[product_name],
    pv.[sku_code] AS [sku],
    pv.[base_type] AS [variant_name]
FROM [Demo].[Products] AS p
INNER JOIN [Demo].[Product_Variants] AS pv
    ON p.[product_id] = pv.[product_id]
ORDER BY p.[product_name], pv.[sku_code];


-- 2. Count variants for each product that has at least one variant.
SELECT
    p.[product_name],
    COUNT(pv.[variant_id]) AS [total_variants]
FROM [Demo].[Products] AS p
INNER JOIN [Demo].[Product_Variants] AS pv
    ON p.[product_id] = pv.[product_id]
GROUP BY p.[product_id], p.[product_name]
HAVING COUNT(pv.[variant_id]) > 0
ORDER BY p.[product_name];


-- Setup for questions 3 and 4: this product has no variant on purpose.
-- It lets the LEFT JOIN return NULL in the SKU column as required.
--IF NOT EXISTS
--(
--    SELECT 1
--    FROM [Demo].[Products]
--    WHERE [product_name] = 'Practice Primer Without Variant'
--)
--    INSERT INTO [Demo].[Products]
--        ([product_name], [category], [finish_type], [binder_type], [voc_level_g_l])
--    VALUES
--        ('Practice Primer Without Variant', 'Interior', 'Matte', 'Acrylic', 20.00);


-- 3. LEFT JOIN: show every product, even when it has no variant.
SELECT
    p.[product_name],
    pv.[sku_code] AS [sku]
FROM [Demo].[Products] AS p
LEFT JOIN [Demo].[Product_Variants] AS pv
    ON p.[product_id] = pv.[product_id]
ORDER BY p.[product_name], pv.[sku_code];


-- 4. Products that do not yet have a matching variant.
SELECT
    p.[product_id],
    p.[product_name]
FROM [Demo].[Products] AS p
LEFT JOIN [Demo].[Product_Variants] AS pv
    ON p.[product_id] = pv.[product_id]
WHERE pv.[variant_id] IS NULL
ORDER BY p.[product_name];


-- 5. RIGHT JOIN: all variants are returned with their parent product.
SELECT
    pv.[sku_code] AS [sku],
    p.[product_name]
FROM [Demo].[Products] AS p
RIGHT JOIN [Demo].[Product_Variants] AS pv
    ON p.[product_id] = pv.[product_id]
ORDER BY pv.[sku_code];


-- 6. SELF JOIN setup: add an optional parent material column once.
IF COL_LENGTH(N'Demo.Raw_Materials', N'parent_material_id') IS NULL
    ALTER TABLE [Demo].[Raw_Materials]
        ADD [parent_material_id] INT NULL;


-- Add the self-referencing foreign key once.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE [name] = N'FK_Raw_Materials_Parent'
      AND [parent_object_id] = OBJECT_ID(N'Demo.Raw_Materials')
)
    ALTER TABLE [Demo].[Raw_Materials]
        ADD CONSTRAINT [FK_Raw_Materials_Parent]
        FOREIGN KEY ([parent_material_id])
        REFERENCES [Demo].[Raw_Materials]([material_id]);
GO

-- Example parent row and child links for the self-join exercise.
IF NOT EXISTS
(
    SELECT 1
    FROM [Demo].[Raw_Materials]
    WHERE [material_name] = 'Pigment Family'
)
    INSERT INTO [Demo].[Raw_Materials]
        ([material_name], [type], [unit_of_measure], [reorder_level], [hazardous_flag])
    VALUES
        ('Pigment Family', 'Pigment', 'KG', 0, 0);
GO

UPDATE child_material
SET [parent_material_id] = parent_material.[material_id]
FROM [Demo].[Raw_Materials] AS child_material
INNER JOIN [Demo].[Raw_Materials] AS parent_material
    ON parent_material.[material_name] = 'Pigment Family'
WHERE child_material.[type] = 'Pigment'
  AND child_material.[material_name] <> 'Pigment Family'
  AND child_material.[parent_material_id] IS NULL;
GO

-- 6. SELF JOIN: a material is joined to its parent material in the same table.
SELECT
    child_material.[material_name] AS [material_name],
    parent_material.[material_name] AS [parent_material_name]
FROM [Demo].[Raw_Materials] AS child_material
LEFT JOIN [Demo].[Raw_Materials] AS parent_material
    ON child_material.[parent_material_id] = parent_material.[material_id]
ORDER BY child_material.[material_name];


-- 7. SELF JOIN: pairs of variants from the same product with different prices.
-- sku_1 < sku_2 prevents returning the same pair twice.
SELECT
    pv1.[product_id],
    pv1.[sku_code] AS [sku_1],
    pv2.[sku_code] AS [sku_2]
FROM [Demo].[Product_Variants] AS pv1
INNER JOIN [Demo].[Product_Variants] AS pv2
    ON pv1.[product_id] = pv2.[product_id]
   AND (pv1.[unit_cost] <> pv2.[unit_cost]
        OR pv1.[mrp] <> pv2.[mrp])
   AND pv1.[sku_code] < pv2.[sku_code]
ORDER BY pv1.[product_id], [sku_1], [sku_2];


-- 8. CROSS JOIN: every possible product and material combination.
SELECT
    p.[product_name],
    rm.[material_name]
FROM [Demo].[Products] AS p
CROSS JOIN [Demo].[Raw_Materials] AS rm
ORDER BY p.[product_name], rm.[material_name];


-- 9. Create a small staging table because it does not exist in the current schema.
DROP TABLE IF EXISTS [Demo].[stg_raw_materials];

CREATE TABLE [Demo].[stg_raw_materials]
(
    [material_id] INT PRIMARY KEY,
    [stock_quantity] DECIMAL(10,2) NOT NULL,
    [last_stock_check] DATE NOT NULL
);

-- Sample stock data. Some materials are deliberately absent from staging.
INSERT INTO [Demo].[stg_raw_materials]
    ([material_id], [stock_quantity], [last_stock_check])
SELECT TOP (3)
    [material_id],
    [reorder_level] * 2,
    CAST(GETDATE() AS DATE)
FROM [Demo].[Raw_Materials]
ORDER BY [material_id];
GO

-- LEFT JOIN materials to staged stock, then CROSS JOIN every product.
SELECT
    p.[product_name],
    rm.[material_id],
    rm.[material_name],
    srm.[stock_quantity],
    srm.[last_stock_check]
FROM [Demo].[Raw_Materials] AS rm
LEFT JOIN [Demo].[stg_raw_materials] AS srm
    ON rm.[material_id] = srm.[material_id]
CROSS JOIN [Demo].[Products] AS p
ORDER BY p.[product_name], rm.[material_name];
