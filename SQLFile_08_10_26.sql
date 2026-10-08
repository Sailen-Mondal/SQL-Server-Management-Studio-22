----- DATE : 08.10.26 -----
USE BikeStores;
GO

-- ====================================================================
-- Problem 1: Identifying Above-Average Revenue Orders
-- ====================================================================

WITH cte_order_revenue AS (
    -- First CTE: Calculate total net revenue for each order
    SELECT 
        order_id,
        SUM(quantity * list_price * (1 - discount)) AS order_revenue
    FROM sales.order_items
    GROUP BY order_id
),
cte_avg_revenue AS (
    -- Second CTE: Calculate average net revenue across all orders
    SELECT 
        AVG(order_revenue) AS avg_revenue
    FROM cte_order_revenue
)
-- Main Query: Return orders exceeding the overall average revenue
SELECT 
    r.order_id,
    CAST(r.order_revenue AS DECIMAL(10, 2)) AS order_revenue
FROM cte_order_revenue r
CROSS JOIN cte_avg_revenue a
WHERE r.order_revenue > a.avg_revenue
ORDER BY r.order_revenue DESC;
GO


-- ====================================================================
-- Problem 2: Category Rank of Most Discounted Line Items
-- ====================================================================

WITH cte_discounted_items AS (
    -- CTE: Calculate net price and rank items by discount per order
    SELECT 
        order_id,
        item_id,
        product_id,
        discount,
        CAST(quantity * list_price * (1 - discount) AS DECIMAL(10, 2)) AS net_price,
        DENSE_RANK() OVER (PARTITION BY order_id ORDER BY discount DESC) AS discount_rank
    FROM sales.order_items
)
-- Main Query: Get the top discounted line item(s) for each order
SELECT 
    order_id,
    item_id,
    product_id,
    discount,
    net_price
FROM cte_discounted_items
WHERE discount_rank = 1
ORDER BY order_id, item_id;
GO
