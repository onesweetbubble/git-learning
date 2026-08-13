-- Day 30: scalar subqueries

-- 1. Orders with an amount above the average amount of all orders
SELECT
    id,
    customer_id,
    amount,
    order_status
FROM orders
WHERE amount > (
    SELECT AVG(amount)
    FROM orders
)
ORDER BY amount DESC, id ASC;

-- 2. New orders above the average amount of paid orders
SELECT
    id,
    customer_id,
    amount,
    order_status
FROM orders
WHERE order_status = 'new'
  AND amount > (
      SELECT AVG(amount)
      FROM orders
      WHERE order_status = 'paid'
  )
ORDER BY amount DESC;

-- 3. Products above the average historical price of positions
-- with a quantity of at least 3
SELECT
    id,
    product_name,
    category,
    price
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM order_items
    WHERE quantity >= 3
)
ORDER BY price DESC, id ASC;

-- 4. COALESCE replaces an empty AVG result with 0
SELECT
    id,
    product_name,
    price
FROM products
WHERE price > COALESCE(
    (
        SELECT AVG(price)
        FROM order_items
        WHERE quantity >= 1000
    ),
    0
)
ORDER BY id ASC;
