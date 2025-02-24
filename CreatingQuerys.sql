SELECT s.seller_id, SUM(op.payment_value) AS total_vendas
FROM seller s
JOIN order_item oi ON s.seller_id = oi.seller_id
JOIN `order` o ON oi.order_id = o.order_id
JOIN order_payment op ON o.order_id = op.order_id
GROUP BY s.seller_id
ORDER BY total_vendas DESC;

SELECT c.customer_id, COUNT(o.order_id) AS total_pedidos, SUM(op.payment_value) AS total_gasto
FROM customer c
JOIN `order` o ON c.customer_id = o.customer_id
JOIN order_payment op ON o.order_id = op.order_id
WHERE o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2017-06-30'
GROUP BY c.customer_id
ORDER BY total_gasto DESC
LIMIT 10;

SELECT s.seller_id, AVG(orw.review_score) AS media_avaliacao
FROM seller s
JOIN order_item oi ON s.seller_id = oi.seller_id
JOIN `order` o ON oi.order_id = o.order_id
JOIN order_review orw ON o.order_id = orw.order_id
GROUP BY s.seller_id
ORDER BY media_avaliacao DESC;

SELECT o.order_id, c.customer_id, o.order_status, SUM(op.payment_value) AS total_pago
FROM `order` o
JOIN customer c ON o.customer_id = c.customer_id
JOIN order_payment op ON o.order_id = op.order_id
WHERE o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2017-12-31'
GROUP BY o.order_id, c.customer_id, o.order_status;

SELECT oi.product_id, COUNT(oi.order_id) AS total_vendas
FROM order_item oi
JOIN `order` o ON oi.order_id = o.order_id
WHERE o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2017-06-30'
GROUP BY oi.product_id
ORDER BY total_vendas DESC
LIMIT 5;

SELECT o.order_id, (o.order_delivered_customer_date - o.order_estimated_delivery_date) AS atraso_dias
FROM `order` o
WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
ORDER BY atraso_dias DESC
LIMIT 10;

SELECT c.customer_id, SUM(op.payment_value) AS total_gasto
FROM customer c
JOIN `order` o ON c.customer_id = o.customer_id
JOIN order_payment op ON o.order_id = op.order_id
GROUP BY c.customer_id
ORDER BY total_gasto DESC
LIMIT 10;

SELECT c.customer_state, AVG(o.order_delivered_customer_date - o.order_purchase_timestamp) AS media_tempo_entrega
FROM customer c
JOIN `order` o ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY media_tempo_entrega DESC;
