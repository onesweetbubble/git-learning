-- Day 34: INSERT INTO ... SELECT
-- All target tables are temporary, and all changes are rolled back.

BEGIN;

-- ============================================================
-- Part 1. Create a temporary archive for paid orders
-- ============================================================

CREATE TEMP TABLE paid_order_archive (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_amount NUMERIC(10, 2) NOT NULL
        CHECK (order_amount >= 0),
    archived_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP
) ON COMMIT DROP;

-- Preview the source rows before insertion

SELECT
    id AS order_id,
    customer_id,
    amount AS order_amount
FROM orders
WHERE order_status = 'paid'
  AND customer_id IS NOT NULL
ORDER BY id;

-- Insert filtered rows and show the rows actually inserted

INSERT INTO paid_order_archive (
    order_id,
    customer_id,
    order_amount
)
SELECT
    id,
    customer_id,
    amount
FROM orders
WHERE order_status = 'paid'
  AND customer_id IS NOT NULL
RETURNING
    order_id,
    customer_id,
    order_amount,
    archived_at;

-- ============================================================
-- Part 2. Test a repeat-safe load
-- ============================================================

-- Existing rows are filtered by NOT EXISTS.
-- ON CONFLICT provides an additional uniqueness safeguard.

INSERT INTO paid_order_archive (
    order_id,
    customer_id,
    order_amount
)
SELECT
    o.id,
    o.customer_id,
    o.amount
FROM orders AS o
WHERE o.order_status = 'paid'
  AND o.customer_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM paid_order_archive AS poa
      WHERE poa.order_id = o.id
  )
ON CONFLICT (order_id) DO NOTHING
RETURNING
    order_id,
    customer_id,
    order_amount,
    archived_at;

-- Check the archive inside the transaction

SELECT
    order_id,
    customer_id,
    order_amount,
    archived_at
FROM paid_order_archive
ORDER BY order_id;

-- ============================================================
-- Part 3. Insert an aggregated CTE result
-- ============================================================

CREATE TEMP TABLE customer_paid_summary_test (
    customer_id INTEGER UNIQUE NOT NULL,
    customer_name TEXT NOT NULL,
    paid_order_count BIGINT NOT NULL
        CHECK (paid_order_count > 0),
    total_paid_amount NUMERIC NOT NULL
        CHECK (total_paid_amount >= 5000),
    created_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP
) ON COMMIT DROP;

WITH paid_customer_summary AS (
    SELECT
        c.id AS customer_id,
        c.full_name AS customer_name,
        COUNT(o.id) AS paid_order_count,
        SUM(o.amount) AS total_paid_amount
    FROM customers AS c
    INNER JOIN orders AS o
        ON o.customer_id = c.id
    WHERE o.order_status = 'paid'
    GROUP BY
        c.id,
        c.full_name
    HAVING SUM(o.amount) >= 5000
)
INSERT INTO customer_paid_summary_test (
    customer_id,
    customer_name,
    paid_order_count,
    total_paid_amount
)
SELECT
    customer_id,
    customer_name,
    paid_order_count,
    total_paid_amount
FROM paid_customer_summary
ON CONFLICT (customer_id) DO NOTHING
RETURNING
    customer_id,
    customer_name,
    paid_order_count,
    total_paid_amount,
    created_at;

-- Check the aggregated rows inside the transaction

SELECT
    customer_id,
    customer_name,
    paid_order_count,
    total_paid_amount,
    created_at
FROM customer_paid_summary_test
ORDER BY customer_id;

-- Undo all training changes

ROLLBACK;
