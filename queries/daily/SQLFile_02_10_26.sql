-- =================================================================================================
-- File: SQLFile_02_10_26.sql
-- Date: 02-Oct-2026
-- Topic: Stored Procedures in SQL Server (BikeStores Database Assignments)
-- =================================================================================================

USE BikeStores;
GO

-- -------------------------------------------------------------------------------------------------
-- PART 1: CLASSROOM DEMO - INSERT STORED PROCEDURE
-- -------------------------------------------------------------------------------------------------

-- Create Course table
IF OBJECT_ID('[Course]', 'U') IS NULL
BEGIN
    CREATE TABLE [Course]
    (
        [course_id] INT IDENTITY(1,1) PRIMARY KEY,
        [name] VARCHAR(100) NOT NULL,
        [description] VARCHAR(500),
        [course_launch_date] DATE
    );
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[InsertCourse]
(
    @name VARCHAR(100),
    @description VARCHAR(500),
    @course_launch_date DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [Course]
    (
        [name],
        [description],
        [course_launch_date]
    )
    VALUES
    (
        @name,
        @description,
        @course_launch_date
    );

    PRINT 'Course data is inserted successfully.';
END;
GO

-- Execution Demo for InsertCourse
EXEC [dbo].[InsertCourse]
    @name = 'SQL Server',
    @description = 'Complete SQL Server training course',
    @course_launch_date = '2026-10-02';

SELECT * FROM [Course];
GO


-- =================================================================================================
-- PART 2: BIPLAB SIR (MCC) ASSIGNMENTS - STORED PROCEDURES
-- =================================================================================================

----------------------------------------------------------------------------------------------------
-- Task 1:
-- [1:28 pm, 2/10/2026] BIPLAB Sir (MCC): 
-- Create a stored procedure to input store and display product count for each product.
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[usp_GetProductStockByStore]
    @store_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verify store existence
    IF NOT EXISTS (SELECT 1 FROM sales.stores WHERE store_id = @store_id)
    BEGIN
        PRINT 'Store ID ' + CAST(@store_id AS VARCHAR(10)) + ' does not exist.';
        RETURN;
    END;

    SELECT 
        st.store_id,
        st.store_name,
        p.product_id,
        p.product_name,
        ISNULL(s.quantity, 0) AS stock_quantity
    FROM production.stocks s
    INNER JOIN production.products p ON s.product_id = p.product_id
    INNER JOIN sales.stores st ON s.store_id = st.store_id
    WHERE s.store_id = @store_id
    ORDER BY p.product_name;
END;
GO

-- Test Task 1:
EXEC [dbo].[usp_GetProductStockByStore] @store_id = 1;
GO


----------------------------------------------------------------------------------------------------
-- Task 2:
-- [1:51 pm, 2/10/2026] BIPLAB Sir (MCC): 
-- Get Orders by Customer (Basic Input Parameter)
-- Goal: Retrieve all orders placed by a specific customer.
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[usp_GetOrdersByCustomer]
    @customer_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verify customer existence
    IF NOT EXISTS (SELECT 1 FROM sales.customers WHERE customer_id = @customer_id)
    BEGIN
        PRINT 'Customer ID ' + CAST(@customer_id AS VARCHAR(10)) + ' does not exist.';
        RETURN;
    END;

    SELECT 
        o.order_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.email,
        c.phone,
        o.order_date,
        o.required_date,
        o.shipped_date,
        CASE o.order_status
            WHEN 1 THEN 'Pending'
            WHEN 2 THEN 'Processing'
            WHEN 3 THEN 'Rejected'
            WHEN 4 THEN 'Completed'
            ELSE 'Unknown'
        END AS order_status_name,
        o.store_id
    FROM sales.orders o
    INNER JOIN sales.customers c ON o.customer_id = c.customer_id
    WHERE o.customer_id = @customer_id
    ORDER BY o.order_date DESC;
END;
GO

-- Test Task 2:
EXEC [dbo].[usp_GetOrdersByCustomer] @customer_id = 1;
GO


----------------------------------------------------------------------------------------------------
-- Task 3:
-- [1:51 pm, 2/10/2026] BIPLAB Sir (MCC): 
-- Get Order Details & Line Items (JOIN Query)
-- Goal: Return a combined view of an order along with its itemized list and total price per item.
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[usp_GetOrderDetailsAndItems]
    @order_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verify order existence
    IF NOT EXISTS (SELECT 1 FROM sales.orders WHERE order_id = @order_id)
    BEGIN
        PRINT 'Order ID ' + CAST(@order_id AS VARCHAR(10)) + ' does not exist.';
        RETURN;
    END;

    SELECT 
        o.order_id,
        o.order_date,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        oi.item_id,
        p.product_id,
        p.product_name,
        oi.quantity,
        oi.list_price,
        oi.discount,
        CAST((oi.quantity * oi.list_price * (1 - oi.discount)) AS DECIMAL(10,2)) AS total_item_price
    FROM sales.orders o
    INNER JOIN sales.customers c ON o.customer_id = c.customer_id
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    INNER JOIN production.products p ON oi.product_id = p.product_id
    WHERE o.order_id = @order_id
    ORDER BY oi.item_id;
END;
GO

-- Test Task 3:
EXEC [dbo].[usp_GetOrderDetailsAndItems] @order_id = 1;
GO


----------------------------------------------------------------------------------------------------
-- Task 4:
-- [1:51 pm, 2/10/2026] BIPLAB Sir (MCC): 
-- Get Total Revenue for an Order (OUTPUT Parameter)
-- Goal: Calculate the net total price of an entire order and return it as an output variable 
--       for use in other scripts.
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[usp_GetTotalRevenueByOrder]
    @order_id INT,
    @total_revenue DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Calculate total net revenue for the order
    SELECT 
        @total_revenue = ISNULL(SUM(quantity * list_price * (1 - discount)), 0.00)
    FROM sales.order_items
    WHERE order_id = @order_id;
END;
GO

-- Test Task 4 (Executing with OUTPUT parameter):
DECLARE @order_revenue DECIMAL(10,2);

EXEC [dbo].[usp_GetTotalRevenueByOrder]
    @order_id = 1,
    @total_revenue = @order_revenue OUTPUT;

SELECT 
    1 AS order_id, 
    @order_revenue AS total_order_revenue;
PRINT 'Net Total Revenue for Order 1: $' + CAST(@order_revenue AS VARCHAR(20));
GO


----------------------------------------------------------------------------------------------------
-- Task 5:
-- [1:52 pm, 2/10/2026] BIPLAB Sir (MCC): 
-- Update Order Shipping Date (DML Statement)
-- Goal: Update the shipped_date and status of an order safely.
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateOrderShippingDate]
    @order_id INT,
    @shipped_date DATE,
    @order_status TINYINT = 4 -- Default: 4 = Completed
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if order exists
        IF NOT EXISTS (SELECT 1 FROM sales.orders WHERE order_id = @order_id)
        BEGIN
            RAISERROR('Order ID %d does not exist in sales.orders.', 16, 1, @order_id);
            RETURN;
        END;

        -- Validate that shipped_date is not earlier than order_date
        DECLARE @order_date DATE;
        SELECT @order_date = order_date FROM sales.orders WHERE order_id = @order_id;

        IF (@shipped_date < @order_date)
        BEGIN
            DECLARE @error_msg NVARCHAR(200) = FORMATMESSAGE('Shipped date (%s) cannot be earlier than order date (%s).', 
                                                             CONVERT(VARCHAR(10), @shipped_date, 120), 
                                                             CONVERT(VARCHAR(10), @order_date, 120));
            RAISERROR(@error_msg, 16, 1);
            RETURN;
        END;

        -- Safe DML Transaction
        BEGIN TRANSACTION;

            UPDATE sales.orders
            SET shipped_date = @shipped_date,
                order_status = @order_status
            WHERE order_id = @order_id;

        COMMIT TRANSACTION;

        PRINT 'Order ' + CAST(@order_id AS VARCHAR(10)) + ' updated successfully. Shipped Date: ' + CONVERT(VARCHAR(10), @shipped_date, 120) + ', Status: ' + CAST(@order_status AS VARCHAR(5)) + '.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Rethrow error details
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- Test Task 5:
-- Safe test: View before update, update shipped date, and view after update
SELECT order_id, order_date, shipped_date, order_status 
FROM sales.orders 
WHERE order_id = 1;

EXEC [dbo].[usp_UpdateOrderShippingDate]
    @order_id = 1,
    @shipped_date = '2016-01-03',
    @order_status = 4;

SELECT order_id, order_date, shipped_date, order_status 
FROM sales.orders 
WHERE order_id = 1;
GO


----------------------------------------------------------------------------------------------------
-- Task 6:
-- Store Inventory Search & Low-Stock Alert
-- Goal: Retrieve all stock levels for a specific store, filtering by items that are below a reorder threshold, while including store contact information.
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[usp_GetLowStockByStore]
    @store_id INT,
    @threshold INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    -- Verify store existence
    IF NOT EXISTS (SELECT 1 FROM sales.stores WHERE store_id = @store_id)
    BEGIN
        PRINT 'Store ID ' + CAST(@store_id AS VARCHAR(10)) + ' does not exist.';
        RETURN;
    END;

    SELECT 
        st.store_id,
        st.store_name,
        st.phone,
        st.email,
        p.product_id,
        p.product_name,
        ISNULL(s.quantity, 0) AS stock_quantity
    FROM production.stocks s
    INNER JOIN production.products p ON s.product_id = p.product_id
    INNER JOIN sales.stores st ON s.store_id = st.store_id
    WHERE s.store_id = @store_id
      AND ISNULL(s.quantity, 0) < @threshold
    ORDER BY s.quantity ASC;
END;
GO

-- Test Task 6:
EXEC [dbo].[usp_GetLowStockByStore] @store_id = 1, @threshold = 10;
GO


----------------------------------------------------------------------------------------------------
-- Task 7:
-- Multi-Store Product Stock Aggregation
-- Goal: Summarize the distribution of a given product across all stores, returning store details alongside inventory numbers and total global stock as an OUTPUT parameter.
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[usp_GetProductStockDistribution]
    @product_id INT,
    @total_global_stock INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verify product existence
    IF NOT EXISTS (SELECT 1 FROM production.products WHERE product_id = @product_id)
    BEGIN
        PRINT 'Product ID ' + CAST(@product_id AS VARCHAR(10)) + ' does not exist.';
        SET @total_global_stock = 0;
        RETURN;
    END;

    -- Calculate total global stock for the output parameter
    SELECT @total_global_stock = ISNULL(SUM(quantity), 0)
    FROM production.stocks
    WHERE product_id = @product_id;

    -- Return distribution across all stores
    SELECT 
        st.store_id,
        st.store_name,
        st.city,
        st.state,
        p.product_id,
        p.product_name,
        ISNULL(s.quantity, 0) AS stock_quantity
    FROM sales.stores st
    INNER JOIN production.products p ON p.product_id = @product_id
    LEFT JOIN production.stocks s ON st.store_id = s.store_id AND s.product_id = p.product_id
    ORDER BY st.store_id;
END;
GO

-- Test Task 7 (Executing with OUTPUT parameter):
DECLARE @global_stock INT;

EXEC [dbo].[usp_GetProductStockDistribution]
    @product_id = 1,
    @total_global_stock = @global_stock OUTPUT;

SELECT 1 AS product_id, @global_stock AS total_global_stock;
PRINT 'Total Global Stock across all stores: ' + CAST(@global_stock AS VARCHAR(10));
GO


