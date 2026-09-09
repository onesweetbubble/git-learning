-- Day 34.1: INSERT ... ON CONFLICT DO UPDATE
-- Topics:
-- 1. Basic UPSERT
-- 2. target and EXCLUDED
-- 3. Conditional update by date
-- 4. Conditional update by version
-- 5. Composite conflict target
-- 6. INSERT ... SELECT with CTE
-- 7. Skipping unchanged updates with IS DISTINCT FROM
-- 8. Atomicity and typical errors

BEGIN;


-- ============================================================
-- 1. Basic UPSERT: replace existing values
-- ============================================================

CREATE TEMP TABLE product_stock_upsert_test (
    product_id INTEGER PRIMARY KEY,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    updated_at DATE NOT NULL
) ON COMMIT DROP;

INSERT INTO product_stock_upsert_test (
    product_id,
    quantity,
    updated_at
)
VALUES
    (10, 7, DATE '2026-09-06');

INSERT INTO product_stock_upsert_test (
    product_id,
    quantity,
    updated_at
)
VALUES
    (10, 12, DATE '2026-09-07'),
    (20, 4, DATE '2026-09-07')
ON CONFLICT (product_id) DO UPDATE
SET quantity = EXCLUDED.quantity,
    updated_at = EXCLUDED.updated_at
RETURNING
    product_id,
    quantity,
    updated_at;


-- ============================================================
-- 2. Add incoming quantity to the current stock
-- ============================================================

INSERT INTO product_stock_upsert_test AS target (
    product_id,
    quantity,
    updated_at
)
VALUES
    (10, 5, DATE '2026-09-08'),
    (30, 6, DATE '2026-09-08')
ON CONFLICT (product_id) DO UPDATE
SET quantity = target.quantity + EXCLUDED.quantity,
    updated_at = EXCLUDED.updated_at
RETURNING
    product_id,
    quantity,
    updated_at;

SELECT
    product_id,
    quantity,
    updated_at
FROM product_stock_upsert_test
ORDER BY product_id;


-- ============================================================
-- 3. Update when the stored date is older than CURRENT_DATE
-- ============================================================

INSERT INTO product_stock_upsert_test AS target (
    product_id,
    quantity,
    updated_at
)
VALUES
    (10, 25, DATE '2026-09-11')
ON CONFLICT (product_id) DO UPDATE
SET quantity = EXCLUDED.quantity,
    updated_at = EXCLUDED.updated_at
WHERE target.updated_at < CURRENT_DATE
RETURNING
    product_id,
    quantity,
    updated_at;

-- The condition above compares:
-- target.updated_at - the stored date
-- CURRENT_DATE      - the current session date
--
-- DATE '2026-09-11' is an explicit DATE literal.
--
-- To compare the stored date with the incoming date instead,
-- use:
--
-- WHERE target.updated_at < EXCLUDED.updated_at


-- ============================================================
-- 4. Update only when the incoming version is newer
-- ============================================================

CREATE TEMP TABLE supplier_offer_upsert_test (
    supplier_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    version_no INTEGER NOT NULL CHECK (version_no > 0),
    UNIQUE (supplier_id, product_id)
) ON COMMIT DROP;

INSERT INTO supplier_offer_upsert_test (
    supplier_id,
    product_id,
    unit_price,
    version_no
)
VALUES
    (1, 10, 100.00, 3),
    (2, 10, 90.00, 5);

INSERT INTO supplier_offer_upsert_test AS target (
    supplier_id,
    product_id,
    unit_price,
    version_no
)
VALUES
    (1, 10, 95.00, 4),
    (2, 10, 80.00, 4),
    (1, 20, 200.00, 1)
ON CONFLICT (supplier_id, product_id) DO UPDATE

SET unit_price = EXCLUDED.unit_price,
    version_no = EXCLUDED.version_no
WHERE target.version_no < EXCLUDED.version_no
RETURNING
    supplier_id,
    product_id,
    unit_price,

    version_no;

SELECT
    supplier_id,
    product_id,
    unit_price,
    version_no
FROM supplier_offer_upsert_test
ORDER BY supplier_id, product_id;


-- ============================================================
-- 5. Aggregate duplicate source rows before UPSERT
-- ============================================================

CREATE TEMP TABLE receipt_items_upsert_test (
    receipt_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0)
) ON COMMIT DROP;

CREATE TEMP TABLE product_stock_summary_upsert_test (
    product_id INTEGER PRIMARY KEY,
    quantity INTEGER NOT NULL CHECK (quantity >= 0)
) ON COMMIT DROP;

INSERT INTO receipt_items_upsert_test (
    receipt_id,
    product_id,
    quantity
)
VALUES
    (100, 1, 3),
    (100, 1, 4),
    (100, 3, 5),
    (101, 2, 7);

INSERT INTO product_stock_summary_upsert_test (
    product_id,
    quantity
)
VALUES
    (1, 10),
    (2, 20);

WITH receipt_totals AS (
    SELECT
        product_id,
        SUM(quantity) AS received_quantity
    FROM receipt_items_upsert_test
    WHERE receipt_id = 100
    GROUP BY product_id
)
INSERT INTO product_stock_summary_upsert_test AS target (
    product_id,
    quantity
)
SELECT
    rt.product_id,
    rt.received_quantity
FROM receipt_totals AS rt
ON CONFLICT (product_id) DO UPDATE
SET quantity = target.quantity + EXCLUDED.quantity
RETURNING
    product_id,
    quantity;

SELECT
    product_id,
    quantity
FROM product_stock_summary_upsert_test
ORDER BY product_id;


-- ============================================================
-- 6. Skip UPDATE when incoming values are unchanged
-- ============================================================

CREATE TEMP TABLE popular_product_summary_upsert_test (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    paid_order_count INTEGER NOT NULL,
    sold_quantity INTEGER NOT NULL,
    sales_amount NUMERIC(12, 2) NOT NULL
) ON COMMIT DROP;

INSERT INTO popular_product_summary_upsert_test (
    product_id,
    product_name,
    paid_order_count,
    sold_quantity,
    sales_amount
)
VALUES
    (1, 'Keyboard', 3, 25, 25000.00);

INSERT INTO popular_product_summary_upsert_test AS target (
    product_id,
    product_name,
    paid_order_count,
    sold_quantity,
    sales_amount
)
VALUES
    (1, 'Keyboard', 3, 25, 25000.00),
    (2, 'Mouse', 4, 30, 15000.00)
ON CONFLICT (product_id) DO UPDATE
SET product_name = EXCLUDED.product_name,
    paid_order_count = EXCLUDED.paid_order_count,
    sold_quantity = EXCLUDED.sold_quantity,
    sales_amount = EXCLUDED.sales_amount
WHERE ROW(
    target.product_name,
    target.paid_order_count,
    target.sold_quantity,
    target.sales_amount
) IS DISTINCT FROM ROW(
    EXCLUDED.product_name,
    EXCLUDED.paid_order_count,
    EXCLUDED.sold_quantity,
    EXCLUDED.sales_amount
)
RETURNING
    product_id,
    product_name,
    paid_order_count,
    sold_quantity,
    sales_amount;


-- ============================================================
-- 7. Typical errors
-- These examples are commented out so the file runs successfully
-- ============================================================

-- Error: quantity has no UNIQUE constraint.
--
-- INSERT INTO product_stock_upsert_test (
--     product_id,
--     quantity,
--     updated_at
-- )
-- VALUES
--     (40, 5, CURRENT_DATE)
-- ON CONFLICT (quantity) DO UPDATE
-- SET updated_at = EXCLUDED.updated_at;


-- Error: one command cannot update the same target row twice.
--
-- INSERT INTO product_stock_upsert_test (
--     product_id,
--     quantity,
--     updated_at
-- )
-- VALUES
--     (10, 2, CURRENT_DATE),
--     (10, 3, CURRENT_DATE)
-- ON CONFLICT (product_id) DO UPDATE
-- SET quantity = EXCLUDED.quantity;


-- Error: ON CONFLICT does not handle CHECK violations.
-- The whole multi-row command is atomic.
--
-- INSERT INTO product_stock_upsert_test (
--     product_id,
--     quantity,
--     updated_at
-- )
-- VALUES
--     (40, 5, CURRENT_DATE),
--     (50, -2, CURRENT_DATE)
-- ON CONFLICT (product_id) DO NOTHING;


ROLLBACK;
