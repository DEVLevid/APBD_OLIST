CREATE INDEX idx_order_payment_value ON order_payment(order_id, payment_value);
CREATE INDEX idx_order_date ON `order`(order_purchase_timestamp);
CREATE INDEX idx_order_product_date ON order_item(order_id, product_id);
CREATE INDEX idx_order_delivery_date ON `order`(order_delivered_customer_date);

EXPLAIN ANALYZE
SELECT s.seller_id, SUM(op.payment_value) AS total_vendas
FROM seller s
JOIN order_item oi ON s.seller_id = oi.seller_id
JOIN order_payment op ON oi.order_id = op.order_id
GROUP BY s.seller_id
ORDER BY total_vendas DESC;

EXPLAIN ANALYZE
SELECT c.customer_id, SUM(op.payment_value) AS total_gasto
FROM customer c
JOIN `order` o ON c.customer_id = o.customer_id
JOIN order_payment op ON o.order_id = op.order_id
WHERE o.order_purchase_timestamp >= '2017-01-01' 
      AND o.order_purchase_timestamp < '2017-06-30'  -- Melhor para índice
GROUP BY c.customer_id
ORDER BY total_gasto DESC
LIMIT 10;

EXPLAIN ANALYZE
SELECT oi.seller_id, AVG(orw.review_score) AS media_avaliacao
FROM order_review orw
JOIN `order` o ON orw.order_id = o.order_id
JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY oi.seller_id
ORDER BY media_avaliacao DESC;

EXPLAIN ANALYZE
SELECT o.order_id, c.customer_id, o.order_status, op.payment_value AS total_pago
FROM `order` o
JOIN customer c ON o.customer_id = c.customer_id
JOIN order_payment op ON o.order_id = op.order_id
WHERE o.order_purchase_timestamp >= '2017-01-01' 
      AND o.order_purchase_timestamp < '2018-01-01'; 

EXPLAIN ANALYZE
SELECT oi.product_id, COUNT(*) AS total_vendas
FROM order_item oi
JOIN `order` o ON oi.order_id = o.order_id
WHERE o.order_purchase_timestamp >= '2017-01-01' 
      AND o.order_purchase_timestamp < '2017-06-30'
GROUP BY oi.product_id
ORDER BY total_vendas DESC
LIMIT 5;

EXPLAIN ANALYZE
SELECT o.order_id, 
       TIMESTAMPDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) AS atraso_dias
FROM `order` o
WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
ORDER BY atraso_dias DESC
LIMIT 10;

EXPLAIN ANALYZE
SELECT o.customer_id, SUM(op.payment_value) AS total_gasto
FROM `order` o
JOIN order_payment op ON o.order_id = op.order_id
GROUP BY o.customer_id
ORDER BY total_gasto DESC
LIMIT 10;

EXPLAIN ANALYZE
SELECT c.customer_state, 
       AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS media_tempo_entrega
FROM customer c
JOIN `order` o ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY media_tempo_entrega DESC;
