/*
SELECT category_name, CAST(ROUND(AVG(list_price),2) AS DEC(10,2)) average_product_price
FROM production.products p INNER JOIN production.categories c 
ON c.category_id = p.category_id
GROUP BY category_name
ORDER BY category_name;

SELECT brand_name, CAST(ROUND(AVG(list_price),2) AS DEC(10,2)) avg_product_price
FROM production.products p INNER JOIN production.brands c ON c.brand_id = p.brand_id
GROUP BY brand_name
HAVING AVG(list_price) > 500
ORDER BY avg_product_price;

SELECT customer_id, YEAR (order_date) order_year, COUNT (order_id) order_placed
FROM sales.orders
WHERE customer_id IN (1, 2)
GROUP BY customer_id, YEAR (order_date)
ORDER BY customer_id;

SELECT brand_name, MIN (list_price) min_price, MAX (list_price) max_price
FROM production.products p
INNER JOIN production.brands b ON b.brand_id = p.brand_id
WHERE model_year = 2018
GROUP BY brand_name
ORDER BY brand_name;

SELECT brand_name, AVG (list_price) avg_price
FROM production.products p
INNER JOIN production.brands b ON b.brand_id = p.brand_id
WHERE model_year = 2018
GROUP BY brand_name
ORDER BY brand_name;

SELECT customer_id, YEAR (order_date), COUNT (order_id) order_count
FROM sales.orders
GROUP BY customer_id, YEAR (order_date)
HAVING COUNT (order_id) >= 2
ORDER BY customer_id;

SELECT category_id, MAX (list_price) max_list_price, MIN (list_price) min_list_price
FROM production.products
GROUP BY category_id
HAVING MAX (list_price) > 4000 OR MIN (list_price) < 500;

SELECT first_name, last_name
FROM sales.staffs
UNION
SELECT first_name, last_name
FROM sales.customers;


SELECT first_name, last_name
FROM sales.staffs
UNION ALL
SELECT first_name, last_name
FROM sales.customers
ORDER BY first_name, last_name;
*/





--Question 1

SELECT
    SUM([p].[list_price] * [s].[quantity]) AS [total_inventory_value]
FROM [production].[products] AS [p]
INNER JOIN [production].[stocks] AS [s]
    ON [p].[product_id] = [s].[product_id];


-- Question 2

SELECT
    [p].[product_id],
    [p].[product_name],
    SUM([s].[quantity]) AS [total_stock_quantity]
FROM [production].[products] AS [p]
INNER JOIN [production].[stocks] AS [s]
    ON [p].[product_id] = [s].[product_id]
GROUP BY
    [p].[product_id],
    [p].[product_name];


-- Question 3

SELECT
    [product_id],
    AVG([list_price]) AS [average_selling_price]
FROM [sales].[order_items]
GROUP BY
    [product_id];


-- Question 4
SELECT
    AVG([reorder_level]) AS [average_hazardous_reorder_level]
FROM [Demo].[Raw_Materials]
WHERE [hazardous_flag] = 1;

-- Question 5
USE [BikeStores];
GO

SELECT
    [product_id],
    COUNT(*) AS [active_variant_count]
FROM [Demo].[Product_Variants]
WHERE [active] = 1
GROUP BY
    [product_id]
HAVING
    COUNT(*) > 3;

-- Question 6
SELECT
    (
        SELECT COUNT(DISTINCT [material_id])
        FROM [Demo].[Raw_Materials]
    ) AS [main_material_count],

    (
        SELECT COUNT(DISTINCT [material_id])
        FROM [Demo].[stg_raw_materials]
    ) AS [staging_material_count];

    -- Verify
    SELECT DISTINCT [material_id]
        FROM [Demo].[Raw_Materials]
        ORDER BY [material_id];

        SELECT DISTINCT [material_id]
        FROM [Demo].[stg_raw_materials]
        ORDER BY [material_id];


-- Question 7
    SELECT
        [product_id],
        MAX([list_price]) AS [maximum_selling_price]
    FROM [sales].[order_items]
    GROUP BY
        [product_id];

 -- Question 8
SELECT
    MIN([reorder_level]) AS [minimum_reorder_level]
FROM [Demo].[stg_raw_materials];


 -- Question 9
SELECT
    [product_id]
FROM [production].[products]

UNION

SELECT
    [product_id]
FROM [sales].[order_items];

-- Question 10
SELECT
    [product_name] AS [item_name]
FROM [production].[products]

UNION

SELECT
    [p].[product_name] AS [item_name]
FROM [sales].[order_items] AS [oi]
INNER JOIN [production].[products] AS [p]
    ON [oi].[product_id] = [p].[product_id];

-- Question 11
SELECT
    CAST([product_id] AS VARCHAR(20)) AS [item_identifier]
FROM [production].[products]

UNION ALL

SELECT
    CAST([order_id] AS VARCHAR(20)) AS [item_identifier]
FROM [sales].[orders];

-- Question 12
SELECT
    [reorder_level]
FROM [Demo].[Raw_Materials]

INTERSECT

SELECT
    [reorder_level]
FROM [Demo].[stg_raw_materials];

-- Question 13
SELECT
    [material_id]
FROM [Demo].[stg_raw_materials]

EXCEPT

SELECT
    [material_id]
FROM [Demo].[Raw_Materials];


-- Question 14
SELECT
    [material_id]
FROM [Demo].[Raw_Materials]

EXCEPT

SELECT
    [material_id]
FROM [Demo].[stg_raw_materials];