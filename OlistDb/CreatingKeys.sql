UPDATE customer SET customer_city=TRIM(LOWER(customer_city)), customer_state=TRIM(UPPER(customer_state));

ALTER TABLE customer ADD COLUMN id SERIAL;
DELETE FROM customer WHERE id IN (
    SELECT id FROM (
        SELECT customer_id,
                id,
                ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id) AS rn
        FROM customer
    ) AS duplicates WHERE rn > 1
);
ALTER TABLE customer DROP COLUMN id;
ALTER TABLE customer DROP COLUMN customer_unique_id;

SELECT customer_id FROM (
    SELECT customer_id,
            ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id) AS rn
    FROM customer
) AS duplicates WHERE rn > 1;

ALTER TABLE customer ADD CONSTRAINT pk_customer PRIMARY KEY(customer_id);

UPDATE geo_location SET geolocation_city = TRIM(LOWER(geolocation_city)), geolocation_state=TRIM(UPPER(geolocation_state));

ALTER TABLE geo_location ADD COLUMN id SERIAL;
DELETE FROM geo_location
WHERE id IN (
    SELECT id
    FROM (
        SELECT id, geolocation_zip_code_prefix, geolocation_city, geolocation_state,
               ROW_NUMBER() OVER (PARTITION BY geolocation_zip_code_prefix, geolocation_city, geolocation_state ORDER BY geolocation_zip_code_prefix, geolocation_city, geolocation_state) AS rn
        FROM geo_location
    ) AS subquery
   WHERE rn > 1
);
ALTER TABLE geo_location DROP COLUMN id;

ALTER TABLE geo_location ADD CONSTRAINT pk_geo_location PRIMARY KEY(geolocation_zip_code_prefix, geolocation_city, geolocation_state);

CREATE VIEW vw_customer_without_geo_location AS (
    SELECT DISTINCT c.customer_zip_code_prefix as prefix, c.customer_city as city, c.customer_state as state
    FROM customer c
        WHERE NOT EXISTS (
            SELECT 1
            FROM geo_location g
            WHERE c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
            AND c.customer_state = g.geolocation_state
            AND c.customer_city = g.geolocation_city
        ) AND c.customer_zip_code_prefix IS NOT NULL AND c.customer_city  IS NOT NULL AND c.customer_state IS NOT NULL
);

INSERT INTO geo_location(geolocation_zip_code_prefix, geolocation_city, geolocation_state) 
SELECT prefix, city, state
FROM vw_customer_without_geo_location;

DROP VIEW vw_customer_without_geo_location;

ALTER TABLE customer
ADD CONSTRAINT fk_customer_geo_location
FOREIGN KEY (customer_zip_code_prefix, customer_city, customer_state)
REFERENCES geo_location (geolocation_zip_code_prefix, geolocation_city, geolocation_state);

ALTER TABLE seller ADD COLUMN id SERIAL;
DELETE FROM seller
WHERE id IN (
    SELECT id
    FROM (
        SELECT seller_id,
                id,
                ROW_NUMBER() OVER (PARTITION BY seller_id ORDER BY seller_id) AS rn
        FROM seller
    ) AS subquery
    WHERE rn > 1
);
ALTER TABLE seller DROP COLUMN id;
ALTER TABLE seller ADD CONSTRAINT pk_seller PRIMARY KEY(seller_id);
ALTER TABLE order_item ADD CONSTRAINT fk_order_item_seller FOREIGN KEY(seller_id) REFERENCES seller(seller_id);

CREATE VIEW vw_seller_without_geo_location AS (
    SELECT DISTINCT c.seller_zip_code_prefix as prefix, c.seller_city as city, c.seller_state as state
    FROM seller c
        WHERE NOT EXISTS (
            SELECT 1
            FROM geo_location g
            WHERE c.seller_zip_code_prefix = g.geolocation_zip_code_prefix
            AND c.seller_state = g.geolocation_state
            AND c.seller_city = g.geolocation_city
        ) AND c.seller_zip_code_prefix IS NOT NULL AND c.seller_city  IS NOT NULL AND c.seller_state IS NOT NULL
);

INSERT INTO geo_location(geolocation_zip_code_prefix, geolocation_city, geolocation_state) 
SELECT prefix, city, state
FROM vw_seller_without_geo_location;

DROP VIEW vw_seller_without_geo_location;

ALTER TABLE seller
ADD CONSTRAINT fk_seller_geo_location
FOREIGN KEY (seller_zip_code_prefix, seller_city, seller_state)
REFERENCES geo_location (geolocation_zip_code_prefix, geolocation_city, geolocation_state);

ALTER TABLE product ADD COLUMN id SERIAL;
DELETE FROM product
WHERE id IN (
    SELECT id
    FROM (
        SELECT product_id,
                id,
                ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_id) AS rn
        FROM product
    ) AS subquery
    WHERE rn > 1
);
ALTER TABLE product DROP COLUMN id;
ALTER TABLE product ADD CONSTRAINT pk_product PRIMARY KEY(product_id);

ALTER TABLE olist.order ADD COLUMN id SERIAL;
DELETE FROM olist.order WHERE id IN (
    SELECT id FROM (
        SELECT order_id,
                id,
                ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_id) AS rn
        FROM olist.order
    ) AS duplicates WHERE rn > 1
);
ALTER TABLE olist.order DROP COLUMN id;
ALTER TABLE olist.order ADD CONSTRAINT pk_order PRIMARY KEY(order_id);
ALTER TABLE olist.order ADD CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id);


ALTER TABLE order_item ADD COLUMN id SERIAL;
DELETE FROM order_item WHERE id IN (
    SELECT id FROM (
        SELECT order_id,
               product_id,
               id,
               ROW_NUMBER() OVER (PARTITION BY order_id,product_id ORDER BY order_id,product_id) AS rn
        FROM order_item
    ) AS duplicates WHERE rn > 1
);
ALTER TABLE order_item DROP COLUMN id;
ALTER TABLE order_item ADD CONSTRAINT pk_order_item PRIMARY KEY(order_id, product_id);
ALTER TABLE order_item ADD CONSTRAINT fk_order_item_order FOREIGN KEY(order_id) REFERENCES olist.order(order_id);
ALTER TABLE order_item ADD CONSTRAINT fk_order_item_product FOREIGN KEY(product_id) REFERENCES product(product_id);

ALTER TABLE order_payment ADD CONSTRAINT fk_order_payment_order FOREIGN KEY(order_id) REFERENCES olist.order(order_id);
ALTER TABLE order_payment ADD COLUMN order_payment_id VARCHAR(36);
UPDATE order_payment SET order_payment_id = UUID() WHERE order_payment_id IS NULL;
ALTER TABLE order_payment ADD CONSTRAINT pk_order_payment PRIMARY KEY(order_payment_id);

ALTER TABLE order_review ADD COLUMN id SERIAL;
DELETE FROM order_review WHERE id IN (
    SELECT id FROM (
        SELECT order_id,
               review_id,
               id,
               ROW_NUMBER() OVER (PARTITION BY order_id,review_id ORDER BY order_id,review_id) AS rn
        FROM order_review
    ) AS duplicates WHERE rn > 1
);
ALTER TABLE order_review DROP COLUMN id;
ALTER TABLE order_review ADD CONSTRAINT fk_order_review_order FOREIGN KEY(order_id) REFERENCES olist.order(order_id);
ALTER TABLE order_review ADD CONSTRAINT pk_order_review PRIMARY KEY(review_id, order_id);