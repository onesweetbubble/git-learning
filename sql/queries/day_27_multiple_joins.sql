-- Day 27: multiple JOINs in one query
-- All customers, only paid orders,
-- only order items with quantity >= 3.

SELECT
    c.full_name,
    o.id AS order_id,
    oi.id AS order_item_id,
    p.product_name,
    oi.quantity,
    oi.price,
    oi.quantity * oi.price AS line_total
FROM customers AS c
LEFT JOIN orders AS o
    ON c.id = o.customer_id
    AND o.order_status = 'paid'
LEFT JOIN order_items AS oi
    ON o.id = oi.order_id
    AND oi.quantity >= 3
LEFT JOIN products AS p
    ON p.id = oi.product_id;
