-- Day 29. Связь many-to-many: orders и products

-- 1. Количество товарных позиций в каждом заказе
SELECT
    order_id,
    COUNT(product_id) AS position_count
FROM order_items
GROUP BY order_id;

-- 2. Количество уникальных товаров в каждом заказе
SELECT
    order_id,
    COUNT(DISTINCT product_id) AS unique_products
FROM order_items
GROUP BY order_id;

-- 3. Количество уникальных заказов для каждого товара
SELECT
    product_id,
    COUNT(DISTINCT order_id) AS unique_orders
FROM order_items
GROUP BY product_id;

-- 4. Поиск повторяющихся пар order_id + product_id
SELECT
    order_id,
    product_id,
    COUNT(*) AS pair_count
FROM order_items
GROUP BY
    order_id,
    product_id
HAVING COUNT(*) > 1;

-- 5. Ограничение принято по бизнес-правилу:
-- один товар может находиться в одном заказе только в одной строке
ALTER TABLE order_items
ADD CONSTRAINT unique_order_product
UNIQUE (order_id, product_id);

