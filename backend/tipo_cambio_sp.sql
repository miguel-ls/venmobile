-- Stored Procedure to get a tipo de cambio by ID
DELIMITER $$
CREATE PROCEDURE sp_get_tipo_cambio_by_id(IN p_id INT)
BEGIN
    SELECT * FROM tipo_cambio WHERE id = p_id;
END$$
DELIMITER ;

-- Stored Procedure to get tipo de cambio by year and month
DELIMITER $$
CREATE PROCEDURE sp_get_tipo_cambio_by_year_month(IN p_year INT, IN p_month INT)
BEGIN
    SELECT * FROM tipo_cambio WHERE YEAR(fecha) = p_year AND MONTH(fecha) = p_month;
END$$
DELIMITER ;

-- Stored Procedure to create a new tipo de cambio
DELIMITER $$
CREATE PROCEDURE sp_create_tipo_cambio(
    IN p_fecha DATETIME,
    IN p_compra DECIMAL(14,3),
    IN p_venta DECIMAL(14,3),
    IN p_moneda CHAR(3)
)
BEGIN
    INSERT INTO tipo_cambio (fecha, compra, venta, moneda) VALUES (p_fecha, p_compra, p_venta, p_moneda);
    SELECT * FROM tipo_cambio WHERE id = LAST_INSERT_ID();
END$$
DELIMITER ;

-- Stored Procedure to update a tipo de cambio
DELIMITER $$
CREATE PROCEDURE sp_update_tipo_cambio(
    IN p_id INT,
    IN p_fecha DATETIME,
    IN p_compra DECIMAL(14,3),
    IN p_venta DECIMAL(14,3),
    IN p_moneda CHAR(3)
)
BEGIN
    UPDATE tipo_cambio SET fecha = p_fecha, compra = p_compra, venta = p_venta, moneda = p_moneda WHERE id = p_id;
END$$
DELIMITER ;

-- Stored Procedure to delete a tipo de cambio
DELIMITER $$
CREATE PROCEDURE sp_delete_tipo_cambio(IN p_id INT)
BEGIN
    DELETE FROM tipo_cambio WHERE id = p_id;
END$$
DELIMITER ;
