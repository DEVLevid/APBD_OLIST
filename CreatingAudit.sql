
CREATE TABLE order_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    user_action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    modified_by VARCHAR(255) NOT NULL,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_status VARCHAR(50),
    new_status VARCHAR(50)
);

DELIMITER $$

CREATE TRIGGER trigger_audit_order
AFTER UPDATE ON `order`
FOR EACH ROW
BEGIN
    INSERT INTO order_audit (
        order_id, user_action, modified_by, modified_at, 
        old_status, new_status
    )
    VALUES (
        OLD.order_id, 'UPDATE', USER(), NOW(),
        OLD.order_status, NEW.order_status
    );
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trigger_audit_orders_delete
AFTER DELETE ON `order`
FOR EACH ROW
BEGIN
    INSERT INTO order_audit (
        order_id, user_action, modified_by, modified_at, 
        old_status, new_status
    )
    VALUES (
        OLD.order_id, 'DELETE', USER(), NOW(),
        OLD.order_status, NULL
    );
END $$

DELIMITER ;

UPDATE `order` 
SET order_status = 'delivered'
WHERE order_id = '0010dedd556712d7bb69a19cb7bbd37a';

SELECT * FROM order_audit;
