-- Day 36: CASE expressions and conditional aggregation
-- All statements are read-only.
--
-- Key rules:
-- CASE returns a value; WHERE filters rows.
-- WHEN branches are checked from top to bottom.
-- Only TRUE selects a WHEN branch.
-- Without ELSE, unmatched rows produce NULL.
-- Simple CASE compares values for equality.
-- Use IS NULL to test for missing values.
-- All result branches must have compatible types.
-- COUNT(expression) counts non-NULL values, including zero.
-- SUM ignores NULL and returns NULL for an empty input.



-- 1. Classify orders by amount.

SELECT
    id,
    amount,
    CASE
        WHEN amount IS NULL THEN 'Amount unknown'
        WHEN amount >= 10000 THEN 'Large order'
        WHEN amount >= 5000 THEN 'Medium order'
        ELSE 'Small order'
    END AS amount_category
FROM orders
ORDER BY id;


-- 2. Translate order statuses with simple CASE.
-- NULL and unlisted statuses use the ELSE branch.

SELECT
    id,
    order_status,
    CASE order_status
        WHEN 'new' THEN 'New order'
        WHEN 'paid' THEN 'Paid order'
        WHEN 'cancelled' THEN 'Cancelled order'
        ELSE 'Other status'
    END AS status_label
FROM orders
ORDER BY id;


-- 3. Compare an omitted ELSE with an explicit ELSE.

SELECT
    id,
    amount,
    CASE
        WHEN amount >= 10000 THEN amount
    END AS large_amount,
    CASE
        WHEN amount >= 10000 THEN amount
        ELSE 0
    END AS large_amount_or_zero
FROM orders
ORDER BY id;


-- 4. Put the more specific condition before the broader condition.

SELECT
    id,
    amount,
    order_status,
    CASE
        WHEN order_status = 'paid' AND amount >= 10000
            THEN 'Large paid order'
        WHEN order_status = 'paid'
            THEN 'Other paid order'
        ELSE 'Other order'
    END AS payment_category
FROM orders
ORDER BY id;


-- 5. Count orders conditionally.
-- The primary key id cannot be NULL.

SELECT
    COUNT(id) AS total_orders,
    COUNT(
        CASE WHEN order_status = 'paid' THEN 1 END
    ) AS paid_orders,
    COUNT(
        CASE
            WHEN order_status = 'paid' AND amount >= 10000
                THEN 1
        END
    ) AS large_paid_orders
FROM orders;


-- 6. Sum order amounts conditionally.

SELECT
    SUM(
        CASE
            WHEN order_status = 'paid' THEN amount
            ELSE 0
        END
    ) AS paid_amount,
    SUM(
        CASE
            WHEN order_status = 'paid' AND amount >= 10000
                THEN amount
            ELSE 0
        END
    ) AS large_paid_amount
FROM orders;


-- 7. Calculate metrics for every customer.
-- COUNT(o.id) excludes the NULL order from an unmatched LEFT JOIN.
-- A customer without orders receives zero for all three metrics.

SELECT
    c.id,
    c.full_name,
    COUNT(o.id) AS total_orders,
    COUNT(
        CASE WHEN o.order_status = 'paid' THEN 1 END
    ) AS paid_orders,
    SUM(
        CASE
            WHEN o.order_status = 'paid' THEN o.amount
            ELSE 0
        END
    ) AS paid_amount
FROM customers AS c
LEFT JOIN orders AS o
    ON o.customer_id = c.id
GROUP BY c.id, c.full_name
ORDER BY c.id;


-- 8. Check product card completeness.
-- Check both missing values before checking either value separately.

SELECT
    id,
    product_name,
    category,
    price,
    CASE
        WHEN category IS NULL AND price IS NULL
            THEN 'Category and price missing'
        WHEN category IS NULL
            THEN 'Category missing'
        WHEN price IS NULL
            THEN 'Price missing'
        ELSE 'Card complete'
    END AS data_quality
FROM products
ORDER BY id;


-- 9. Mixed practice: product sales report.
-- Revenue uses the historical order item price.
-- Quantities count units, not order item rows.

SELECT
    p.id,
    p.product_name,
    SUM(
        CASE
            WHEN o.order_status = 'paid' THEN oi.quantity
            ELSE 0
        END
    ) AS paid_quantity,
    SUM(
        CASE
            WHEN o.order_status = 'cancelled' THEN oi.quantity
            ELSE 0
        END
    ) AS cancelled_quantity,
    SUM(
        CASE
            WHEN o.order_status = 'paid'
                THEN oi.quantity * oi.price
            ELSE 0
        END
    ) AS paid_revenue
FROM products AS p
INNER JOIN order_items AS oi
    ON oi.product_id = p.id
INNER JOIN orders AS o
    ON o.id = oi.order_id
GROUP BY p.id, p.product_name
HAVING SUM(
    CASE
        WHEN o.order_status = 'paid' THEN oi.quantity
        ELSE 0
    END
) >= 3
ORDER BY paid_quantity DESC, p.id;


-- 10. Mixed practice: compare historical prices with the current catalog.
-- The counters count order item rows, not units.
-- Keep all items of paid orders before calculating group metrics.
-- HAVING selects orders with at least one item below the catalog price.

SELECT
    o.id AS order_id,
    o.customer_id,
    SUM(
        CASE WHEN oi.price < p.price THEN 1 ELSE 0 END
    ) AS below_catalog_items,
    SUM(
        CASE WHEN oi.price > p.price THEN 1 ELSE 0 END
    ) AS above_catalog_items,
    SUM(
        CASE
            WHEN oi.price < p.price
                THEN (p.price - oi.price) * oi.quantity
            ELSE 0
        END
    ) AS catalog_gap
FROM orders AS o
INNER JOIN order_items AS oi
    ON oi.order_id = o.id
INNER JOIN products AS p
    ON p.id = oi.product_id
WHERE o.order_status = 'paid'
GROUP BY o.id, o.customer_id
HAVING SUM(
    CASE WHEN oi.price < p.price THEN 1 ELSE 0 END
) >= 1
ORDER BY catalog_gap DESC, o.id;


-- 11. Verify missing-value behavior without changing table data.
-- Expected: NULL, 'Missing', 'No equality match'.
-- WHEN NULL in simple CASE does not match a NULL value.

SELECT
    CASE
        WHEN FALSE THEN 1
    END AS omitted_else_result,
    CASE
        WHEN NULL IS NULL THEN 'Missing'
        ELSE 'Present'
    END AS searched_null_result,
    CASE NULL
        WHEN NULL THEN 'Missing'
        ELSE 'No equality match'
    END AS simple_null_result;


-- 12. Verify compatible result types.
-- The string literal '2' can be converted to an integer.
-- Expected result: 1.
-- A nonnumeric literal such as 'No seats' cannot be used this way.

SELECT
    CASE
        WHEN TRUE THEN 1
        ELSE '2'
    END AS compatible_result;


-- 13. Verify aggregates over an empty input.
-- WHERE FALSE provides no input rows.
-- Expected: 0, 0, NULL.
-- ELSE 0 cannot supply values when there are no input rows.

SELECT
    COUNT(*) AS total_orders,
    COUNT(
        CASE WHEN amount >= 10000 THEN 1 END
    ) AS large_orders,
    SUM(
        CASE
            WHEN order_status = 'paid' THEN amount
            ELSE 0
        END
    ) AS paid_amount
FROM orders
WHERE FALSE;
