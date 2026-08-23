-- Day 32: Multi-row and correlated subqueries
-- Database: sql_course


-- Query 1: Customers with at least one paid order using IN

SELECT
    c.id,
    c.full_name
FROM customers AS c
WHERE c.id IN (
    SELECT o.customer_id
    FROM orders AS o
    WHERE o.order_status = 'paid'
      AND o.customer_id IS NOT NULL
)
ORDER BY c.id ASC;


-- Query 2: Customers without orders using safe NOT IN

SELECT
    c.id,
    c.full_name
FROM customers AS c
WHERE c.id NOT IN (
    SELECT o.customer_id
    FROM orders AS o
    WHERE o.customer_id IS NOT NULL
)
ORDER BY c.id ASC;


-- Query 3: Customers with at least one order using EXISTS

SELECT
    c.id,
    c.full_name
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.customer_id = c.id
)
ORDER BY c.id ASC;


-- Query 4: Customers without orders using NOT EXISTS

SELECT
    c.id,
    c.full_name
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.customer_id = c.id
)
ORDER BY c.id ASC;


-- Query 5: Customers with both paid and new orders

SELECT
    c.id,
    c.full_name
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders AS paid_order
    WHERE paid_order.customer_id = c.id
      AND paid_order.order_status = 'paid'
)
AND EXISTS (
    SELECT 1
    FROM orders AS new_order
    WHERE new_order.customer_id = c.id
      AND new_order.order_status = 'new'
)
ORDER BY c.id ASC;


-- Query 6: New orders from customers who also have paid orders

SELECT
    o.id,
    o.customer_id,
    o.amount,
    o.order_status
FROM orders AS o
WHERE o.customer_id IN (
    SELECT paid_order.customer_id
    FROM orders AS paid_order
    WHERE paid_order.order_status = 'paid'
      AND paid_order.customer_id IS NOT NULL
)
  AND o.order_status = 'new'
ORDER BY o.id ASC;


-- Query 7: Orders from customers located in Moscow

SELECT
    o.id,
    o.customer_id,
    o.amount,
    o.order_status
FROM orders AS o
WHERE o.customer_id IN (
    SELECT c.id
    FROM customers AS c
    WHERE c.city = 'Moscow'
)
ORDER BY o.id ASC;


-- Query 8: Products that appear in at least one order item

SELECT
    p.id,
    p.product_name
FROM products AS p
WHERE EXISTS (
    SELECT 1
    FROM order_items AS oi
    WHERE oi.product_id = p.id
)
ORDER BY p.id ASC;


-- Query 9: Products that never appear in order items

SELECT
    p.id,
    p.product_name
FROM products AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items AS oi
    WHERE oi.product_id = p.id
)
ORDER BY p.id ASC;


-- Query 10: Products in paid orders with a quantity of at least five

SELECT
    p.id,
    p.product_name
FROM products AS p
WHERE EXISTS (
    SELECT 1
    FROM order_items AS oi
    INNER JOIN orders AS o
        ON o.id = oi.order_id
    WHERE oi.product_id = p.id
      AND o.order_status = 'paid'
      AND oi.quantity >= 5
)
ORDER BY p.id ASC;


-- Query 11: Customers with at least two paid orders

SELECT
    c.id,
    c.full_name
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.customer_id = c.id
      AND o.order_status = 'paid'
    HAVING COUNT(*) >= 2
)
ORDER BY c.id ASC;


-- Query 12: Customers with paid orders using INNER JOIN

SELECT DISTINCT
    c.id,
    c.full_name
FROM customers AS c
INNER JOIN orders AS o
    ON o.customer_id = c.id
WHERE o.order_status = 'paid'
ORDER BY c.id ASC;
