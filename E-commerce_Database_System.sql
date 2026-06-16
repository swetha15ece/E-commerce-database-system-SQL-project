CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL
);
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    payment DECIMAL(10, 2) NOT NULL,
    order_date DATE NOT NULL,
    delivery_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
Delimiter //
create procedure sp_insert_customer_order
( IN p_customer_id int,
  In p_customer_name varchar(255),
  In p_City varchar(100),
  In p_order_id int,
  In p_payment decimal(10,2),
  In p_order_date date,
  In p_delivery_date date
  )
  BEGIN
  -- Error handler
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
   ROLLBACK;
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Insert failed due to SQL error';
END;
start transaction;
insert into customers(customer_id,customer_name,city)
values(p_customer_id,p_customer_name,p_city);
   
insert into orders(order_id,customer_id,payment,order_date,delivery_date)
values (p_order_id,p_customer_id,p_payment,p_order_date,p_delivery_date);
commit;
END //
Delimiter ;
DELIMITER $$

CREATE PROCEDURE sp_update_customer_order(
    IN p_customer_id INT,
    IN p_customer_name VARCHAR(255),
    IN p_city VARCHAR(100),
    IN p_order_id INT,
    In p_payment DECIMAL(10,2),
    IN p_order_date DATE,
    IN p_delivery_date DATE
    
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Update failed due to SQL error';
    END;

    START TRANSACTION;

    -- Update customer
    UPDATE customers
    SET customer_name = p_customer_name,
        city = p_city
    WHERE customer_id = p_customer_id;

    IF ROW_COUNT() = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Update failed: Customer not found';
    END IF;

    -- Update order
    UPDATE orders
    SET order_date = p_order_date,
        delivery_date = p_delivery_date
    WHERE order_id = p_order_id
      AND customer_id = p_customer_id;

    IF ROW_COUNT() = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Update failed: Order not found';
    END IF;

    COMMIT;
END $$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE sp_delete_customer_order(
    IN p_customer_id INT
)
BEGIN
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transaction failed due to SQL error';
    END;

    START TRANSACTION;
    DELETE FROM orders
    WHERE customer_id = p_customer_id;

    DELETE FROM customers
    WHERE customer_id = p_customer_id;

    IF ROW_COUNT() = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Delete failed: Customer not found';
    END IF;

    COMMIT;
END $$

DELIMITER ;
CREATE VIEW CustomerOrderDetails AS
SELECT c.customer_name, o.order_id, o.payment, o.order_date, o.delivery_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

select * from CustomerOrderDetails

CREATE VIEW City AS
SELECT c.city, SUM(o.payment) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city;

select * from City

CREATE VIEW Delayed_Delivery AS
SELECT order_id, customer_id, order_date, delivery_date
FROM orders
WHERE DATEDIFF(delivery_date, order_date) > 10;

select* from Delayed_Delivery

select COUNT(order_id) AS total_orders
from orders

select c.city,sum(o.payment) as total_payment
from customers c
left join orders o on c.customer_id=o.customer_id
group by c.city;

select distinct city from customers;
select customer_id,order_id,payment
from orders
where payment>any(select  payment from orders where customer_id=64);

select customer_id,order_id,payment
from orders
where payment< all(select  payment from orders where customer_id=64);






