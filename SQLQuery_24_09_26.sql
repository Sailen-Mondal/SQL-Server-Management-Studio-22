---------------24.09.26-----------

-- Question 1

CREATE OR ALTER FUNCTION [Demo].[fn_GetHighestPricedVariant]
(
    @product_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        [pv].[variant_id],
        [pv].[sku_code],
        [pv].[pack_size_liters],
        [pv].[mrp]
    FROM [Demo].[Product_Variants] AS [pv]
    WHERE [pv].[product_id] = @product_id
    ORDER BY
        [pv].[mrp] DESC,
        [pv].[variant_id] ASC
);
GO


-- Use CROSS APPLY

SELECT
    [p].[product_name],
    [v].[variant_id],
    [v].[sku_code],
    [v].[pack_size_liters],
    [v].[mrp]
FROM [Demo].[Products] AS [p]
CROSS APPLY
    [Demo].[fn_GetHighestPricedVariant]([p].[product_id]) AS [v];
GO


-- Question 2

CREATE OR ALTER FUNCTION [Demo].[fn_GetLowestPricedVariant]
(
    @product_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        [pv].[variant_id],
        [pv].[sku_code],
        [pv].[mrp]
    FROM [Demo].[Product_Variants] AS [pv]
    WHERE [pv].[product_id] = @product_id
    ORDER BY
        [pv].[mrp] ASC,
        [pv].[variant_id] ASC
);
GO


-- Use OUTER APPLY

SELECT
    [p].[product_name],
    [v].[sku_code],
    [v].[mrp]
FROM [Demo].[Products] AS [p]
OUTER APPLY
    [Demo].[fn_GetLowestPricedVariant]([p].[product_id]) AS [v];
GO


-- Question 3

IF COL_LENGTH('Demo.stg_raw_materials', 'tags') IS NULL
BEGIN
    ALTER TABLE [Demo].[stg_raw_materials]
    ADD [tags] VARCHAR(255);
END;
GO


-- Use CROSS APPLY with STRING_SPLIT

SELECT
    [s].[material_id],
    LTRIM(RTRIM([t].[value])) AS [tag]
FROM [Demo].[stg_raw_materials] AS [s]
CROSS APPLY
    STRING_SPLIT([s].[tags], ',') AS [t];
GO