-- Day 31. Subqueries in SELECT and FROM
-- Database: sql_course

-- 1. Display the average historical price next to each product
SELECT
    p.id,
    p.product_name,
    p.price AS current_price,
    (
        SELECT AVG(oi_avg.price)
        FROM order_items AS oi_avg
    ) AS average_historical_price
FROM products AS p
ORDER BY p.id ASC;


-- 2. Display the maximum current product price next to each order
SELECT
    o.id,
    o.amount,
    (
        SELECT MAX(p_max.price)
        FROM products AS p_max
    ) AS maximum_current_product_price
FROM orders AS o
ORDER BY o.id ASC;


-- 3. Derived table with order totals grouped by customer
SELECT
    customer_summary.customer_id,
    customer_summary.orders_count,
    customer_summary.total_amount
FROM (
    SELECT
        customer_id,
        COUNT(*) AS orders_count,
        SUM(amount) AS total_amount
    FROM orders
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) AS customer_summary
WHERE customer_summary.total_amount > 15000
ORDER BY
    customer_summary.total_amount DESC,
    customer_summary.customer_id ASC;


-- 4. Two aggregation levels: average and maximum calculated order amounts
SELECT
    AVG(order_totals.calculated_amount) AS average_calculated_amount,
    MAX(order_totals.calculated_amount) AS maximum_calculated_amount
FROM (
    SELECT
        order_id,
        SUM(quantity * price) AS calculated_amount
    FROM order_items
    GROUP BY order_id
) AS order_totals;


-- 5. Sales totals grouped by product category
SELECT
    category_summary.category,
    category_summary.total_quantity,
    category_summary.total_revenue
FROM (
    SELECT
        p.category,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.price) AS total_revenue
    FROM products AS p
    INNER JOIN order_items AS oi
        ON p.id = oi.product_id
    GROUP BY p.category
) AS category_summary
WHERE category_summary.total_revenue > 20000
ORDER BY
    category_summary.total_revenue DESC,
    category_summary.category ASC;


-- 6. FROM and SELECT subqueries in the same outer query
SELECT
    customer_totals.customer_id,
    customer_totals.total_amount,
    (
        SELECT AVG(o_avg.amount)
        FROM orders AS o_avg
    ) AS average_order_amount
FROM (
    SELECT
        customer_id,
        SUM(amount) AS total_amount
    FROM orders
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) AS customer_totals
WHERE customer_totals.total_amount > 15000
ORDER BY customer_totals.total_amount DESC;


-- 7. Final query: stored and calculated order amounts
SELECT
    o.id,
    o.amount AS stored_amount,
    order_totals.calculated_amount,
    (
        SELECT AVG(o_avg.amount)
        FROM orders AS o_avg
    ) AS average_stored_amount
FROM (
    SELECT
        order_id,
        SUM(quantity * price) AS calculated_amount
    FROM order_items
    GROUP BY order_id
) AS order_totals
INNER JOIN orders AS o
    ON o.id = order_totals.order_id
WHERE order_totals.calculated_amount > 5000
ORDER BY
    order_totals.calculated_amount DESC,
    o.id ASC;
