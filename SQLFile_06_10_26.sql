USE IndexDB

-- Composite Clustered Index
CREATE CLUSTERED INDEX  idx_employee
ON [dbo].[employee](city,dept);

-- Show
SELECT * FROM [dbo].[employee]
WHERE dept = 'IT' AND City = 'delhi';

SELECT * FROM [dbo].[tblOrder]
WHERE CustomerId = 3 AND ProductName = 'Pendrive';

-- Composite Non-clustered Index
CREATE NONCLUSTERED INDEX idx_tblOrder
ON [dbo].[tblOrder](ProductID)
INCLUDE (id, CustomerId,ProductName);

-- Show 
SELECT *
FROM [dbo].[tblOrder]
WHERE [ProductID] = 'Product - 10120';

sp_helpindex '[dbo].[tblOrder]'
-------------------------------------------------------------------------------------------------
-- Create the Schema
IF NOT EXISTS(
	SELECT 1
	FROM sys.schemas
	WHERE name = 'sales'
)
	EXEC ('CREATE SCHEMA [sales]')
GO
 
-- Create table
CREATE TABLE [sales].[order_items]
(
    [order_id] INT NOT NULL,
    [item_id] INT NOT NULL,
    [product_id] INT NOT NULL,
    [quantity] INT NOT NULL,
    [list_price] DECIMAL(10,2) NOT NULL,
    [discount] DECIMAL(5,2) NOT NULL
);
GO


-- Question 1 : Composite Clustered Index

-- Frequently performed queary
SELECT [order_id], [item_id], [product_id], [quantity], [list_price], [discount] 
FROM [sales].[order_items]
WHERE [order_id] = 42;

-- Creating the cluster
CREATE CLUSTERED INDEX IDX_ORDER_ITEMS
ON [sales].[order_items]([order_id], [item_id]);
----------------------------------------------------------------------------------------------------------

-- Question : 2 
-- The reporting team frequently runs:
SELECT [order_id], [item_id], [product_id], [quantity], [list_price], [discount]
FROM [sales].[order_items]
WHERE  [order_id] BETWEEN 10000 AND 10500;

-- Create a clustered index on order_id.
-- The B-Tree is searched once to find the starting value (10000).
-- SQL Server can then scan the ordered leaf pages sequentially
-- until it reaches order_id 10500.
-- This avoids repeatedly searching for each order ID.

-- Drop the index
DROP INDEX [sales].[order_items].[IDX_ORDER_ITEMS];

-- Creating the cluster
CREATE CLUSTERED INDEX [idx_order_items_order_id]
ON [sales].[order_items]([order_id]);

-- Question 3 : Non-clustered index + Key Lookup
-- Create a non-clustered index only on product_id.
-- SQL Server can quickly find rows where product_id = 505.
-- However, the other requested columns are not in the index,
-- so SQL Server may perform Key Lookups to fetch them
-- from the clustered table.

CREATE NONCLUSTERED INDEX [IX_order_items_ProductID]
ON [sales].[order_items]([product_id]);


SELECT
    [order_id],
    [item_id],
    [product_id],
    [quantity],
    [list_price],
    [discount]
FROM [sales].[order_items]
WHERE [product_id] = 505;

-- Question 4 : Covering Non-Clustered Index
-- Create a covering non-clustered index.
-- product_id is the key column because it is used for searching.
-- The remaining SELECT columns are placed in INCLUDE.
-- This allows SQL Server to satisfy the query directly from the index
-- without looking up the base table.

CREATE NONCLUSTERED INDEX [IX_order_items_ProductID_Covering]
ON [sales].[order_items]([product_id])
INCLUDE
(
    [order_id],
    [item_id],
    [quantity],
    [list_price],
    [discount]
);


SELECT
    [order_id],
    [item_id],
    [product_id],
    [quantity],
    [list_price],
    [discount]
FROM [sales].[order_items]
WHERE [product_id] = 505;

-- Question 5 : Filtered Non-Clustered Index
-- Create a filtered non-clustered index.
-- Only rows where discount > 0 are stored in the index.
-- This reduces index size and the amount of index maintenance.
-- The index is highly selective for queries looking for discounted items.

CREATE NONCLUSTERED INDEX [IX_order_items_Discount_Filtered]
ON [sales].[order_items]([discount])
INCLUDE
(
    [order_id],
    [item_id],
    [product_id],
    [quantity],
    [list_price]
)
WHERE [discount] > 0.00;
GO


SELECT
    [order_id],
    [item_id],
    [product_id],
    [quantity],
    [list_price],
    [discount]
FROM [sales].[order_items]
WHERE [discount] = 10.00;