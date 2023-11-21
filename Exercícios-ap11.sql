CREATE TABLE IF NOT EXISTS customers_table (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(200) NOT NULL
);

CREATE TABLE IF NOT EXISTS orders_table (
    order_id SERIAL PRIMARY KEY,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modification_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'open',
    customer_id INT NOT NULL,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers_table(customer_id)
);

CREATE TABLE IF NOT EXISTS item_types_table (
    type_id SERIAL PRIMARY KEY,
    description VARCHAR(200) NOT NULL
);

INSERT INTO item_types_table (description) VALUES ('Drink'), ('Food');

CREATE TABLE IF NOT EXISTS items_table (
    item_id SERIAL PRIMARY KEY,
    description VARCHAR(200) NOT NULL,
    value NUMERIC(10, 2) NOT NULL,
    type_id INT NOT NULL,
    CONSTRAINT fk_item_type FOREIGN KEY (type_id) REFERENCES item_types_table(type_id)
);

INSERT INTO items_table (description, value, type_id) VALUES ('Soda', 7, 1), ('Juice', 8, 1), ('Burger', 12, 2), ('French fries', 9, 2);

CREATE TABLE IF NOT EXISTS order_item_relation (
    order_item_id SERIAL PRIMARY KEY,
    item_id INT,
    order_id INT,
    CONSTRAINT fk_item_relation FOREIGN KEY (item_id) REFERENCES items_table(item_id),
    CONSTRAINT fk_order_relation FOREIGN KEY (order_id) REFERENCES orders_table(order_id)
);

CREATE TABLE IF NOT EXISTS restaurant_log (
    log_id SERIAL PRIMARY KEY,
    register_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    procedure_name VARCHAR(200) NOT NULL
);

-- Procedures
CREATE OR REPLACE PROCEDURE create_customer (IN name VARCHAR(200), IN code INT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO restaurant_log (procedure_name) VALUES ('create_customer');
    IF code IS NULL THEN
        INSERT INTO customers_table (customer_name) VALUES (name);
    ELSE
        INSERT INTO customers_table (customer_id, customer_name) VALUES (code, name);
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE create_order (OUT order_code INT, customer_code INT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO restaurant_log (procedure_name) VALUES ('create_order');
    INSERT INTO orders_table (customer_id) VALUES (customer_code);
    SELECT LASTVAL() INTO order_code;
END;
$$;

CREATE OR REPLACE PROCEDURE add_item_to_order (IN item_code INT, IN order_code INT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO restaurant_log (procedure_name) VALUES ('add_item_to_order');
    INSERT INTO order_item_relation (item_id, order_id) VALUES (item_code, order_code);
    UPDATE orders_table SET modification_date = CURRENT_TIMESTAMP WHERE order_id = order_code;
END;
$$;


DO $$
DECLARE
    customer_code INT;
BEGIN
    CALL create_customer('João da Silva');
    CALL create_customer('Maria Santos');
END;
$$;

DO $$
DECLARE
    order_code INT;
    customer_code INT;
BEGIN
    SELECT c.customer_id FROM customers_table c WHERE customer_name LIKE 'João da Silva' INTO customer_code;
    CALL create_order(order_code, customer_code);
    RAISE NOTICE 'Newly created order code: %', order_code;
END;
$$;