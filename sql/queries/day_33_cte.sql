-- Day 33: Common Table Expressions (CTEs)

-- Query 1: Select paid orders through a basic CTE
WITH paid_orders AS (
    SELECT
        id AS order_id,
        customer_id,
        amount
    FROM orders
    WHERE order_status = 'paid'
)
SELECT
    order_id,
    customer_id,
    amount
FROM paid_orders
ORDER BY amount DESC, order_id ASC;


-- Query 2: Calculate order statistics for each status
WITH status_statistics AS (
    SELECT
        order_status,
        COUNT(*) AS order_count,
        SUM(amount) AS total_amount,
        AVG(amount) AS average_amount
    FROM orders
    GROUP BY order_status
)
SELECT
    order_status,
    order_count,
    total_amount,
    average_amount
FROM status_statistics
WHERE total_amount > 10000
ORDER BY total_amount DESC, order_status ASC;


-- Query 3: Calculate item totals per order and then per customer
WITH order_calculated_totals AS (
    SELECT
        order_id,
        SUM(quantity * price) AS calculated_amount
    FROM order_items
    GROUP BY order_id
),
customer_calculated_totals AS (
    SELECT
        o.customer_id,
        COUNT(o.id) AS order_count,
        SUM(oct.calculated_amount) AS customer_calculated_amount
    FROM orders AS o
    INNER JOIN order_calculated_totals AS oct
        ON oct.order_id = o.id
    WHERE o.customer_id IS NOT NULL
    GROUP BY o.customer_id
)
SELECT
    cct.customer_id,
    c.full_name,
    cct.order_count,
    cct.customer_calculated_amount
FROM customer_calculated_totals AS cct
INNER JOIN customers AS c
    ON c.id = cct.customer_id
WHERE cct.customer_calculated_amount > 10000
ORDER BY cct.customer_calculated_amount DESC, cct.customer_id ASC;


-- Query 4: Reuse one CTE under two different aliases
WITH customer_orders AS (
    SELECT
        id AS order_id,
        customer_id,
        amount
    FROM orders
    WHERE customer_id IS NOT NULL
)
SELECT
    first_order.customer_id,
    first_order.order_id AS first_order_id,
    first_order.amount AS first_order_amount,
    second_order.order_id AS second_order_id,
    second_order.amount AS second_order_amount
FROM customer_orders AS first_order
INNER JOIN customer_orders AS second_order
    ON second_order.customer_id = first_order.customer_id
    AND second_order.order_id > first_order.order_id
    AND second_order.amount <> first_order.amount
ORDER BY
    first_order.customer_id ASC,
    first_order.order_id ASC,
    second_order.order_id ASC;


-- Query 5: Find products that were never included in paid orders
WITH paid_products AS (
    SELECT DISTINCT
        oi.product_id
    FROM orders AS o
    INNER JOIN order_items AS oi
        ON oi.order_id = o.id
    WHERE o.order_status = 'paid'
)
SELECT
    p.id AS product_id,
    p.product_name,
    p.category,
    p.price
FROM products AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM paid_products AS pp
    WHERE pp.product_id = p.id
)
ORDER BY p.category ASC, p.product_name ASC;


-- Query 6: Compare each customer's paid total with the customer average
WITH customer_paid_totals AS (
    SELECT
        c.id AS customer_id,
        c.full_name AS customer_name,
        COUNT(o.id) AS paid_order_count,
        COALESCE(SUM(o.amount), 0) AS total_paid_amount
    FROM customers AS c
    LEFT JOIN orders AS o
        ON o.customer_id = c.id
        AND o.order_status = 'paid'
    GROUP BY c.id, c.full_name
),
paid_customer_average AS (
    SELECT
        AVG(total_paid_amount) AS average_customer_paid_amount
    FROM customer_paid_totals
    WHERE paid_order_count >= 1
)
SELECT
    customer_id,
    customer_name,
    paid_order_count,
    total_paid_amount
FROM customer_paid_totals
WHERE total_paid_amount > (
    SELECT average_customer_paid_amount
    FROM paid_customer_average
)
ORDER BY total_paid_amount DESC, customer_id ASC;
