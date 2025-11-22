
--
-- Create table `tipo_documento_identidad`
--
CREATE TABLE tipo_documento_identidad (
  id int(11) NOT NULL AUTO_INCREMENT,
  codigo varchar(2) NOT NULL,
  nombre varchar(100) NOT NULL,
  descripcion text DEFAULT NULL,
  estado tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 8,
AVG_ROW_LENGTH = 2730,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_general_ci,
ROW_FORMAT = DYNAMIC;

--
-- Create index `codigo` on table `tipo_documento_identidad`
--
ALTER TABLE tipo_documento_identidad
ADD UNIQUE INDEX codigo (codigo);

--
-- Create table `clientes`
--
CREATE TABLE clientes (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_tipo_documento_identidad int(11) NOT NULL,
  numero_documento varchar(20) NOT NULL,
  nombres_apellidos varchar(200) NOT NULL,
  direccion varchar(255) DEFAULT NULL,
  codigo_ubigeo varchar(10) DEFAULT NULL,
  email varchar(100) DEFAULT NULL,
  telefono varchar(20) DEFAULT NULL,
  estado enum ('Activado', 'Desactivado') NOT NULL DEFAULT 'Activado',
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 16,
AVG_ROW_LENGTH = 2730,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_unicode_ci,
ROW_FORMAT = DYNAMIC;

--
-- Create index `idx_unique_cliente_documento` on table `clientes`
--
ALTER TABLE clientes
ADD UNIQUE INDEX idx_unique_cliente_documento (id_tipo_documento_identidad, numero_documento);

--
-- Create foreign key
--
ALTER TABLE clientes
ADD CONSTRAINT fk_clientes_tipo_documento_identidad FOREIGN KEY (id_tipo_documento_identidad)
REFERENCES tipo_documento_identidad (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Dumping data for table tipo_documento_identidad
--
INSERT INTO tipo_documento_identidad VALUES
  (1, '1', 'DNI', 'Documento Nacional de Identidad', 1),
  (2, '6', 'RUC', 'Registro Unico de Contribuyentes', 1);

DELIMITER $$

--
-- Create procedure `sp_create_cliente`
--
CREATE PROCEDURE sp_create_cliente(IN p_id_tipo_documento_identidad int, IN p_numero_documento varchar(20), IN p_nombres_apellidos varchar(200), IN p_direccion varchar(255), IN p_codigo_ubigeo varchar(10), IN p_email varchar(100), IN p_telefono varchar(20))
BEGIN
INSERT INTO clientes (id_tipo_documento_identidad, numero_documento, nombres_apellidos, direccion, codigo_ubigeo, email, telefono)
    VALUES (p_id_tipo_documento_identidad, p_numero_documento, p_nombres_apellidos, p_direccion, p_codigo_ubigeo, p_email, p_telefono);
SELECT
  LAST_INSERT_ID() AS id;
END
$$

--
-- Create procedure `sp_delete_cliente`
--
CREATE PROCEDURE sp_delete_cliente(IN p_id int)
BEGIN
    UPDATE
      clientes
    SET
      estado = 'Desactivado'
    WHERE
      id = p_id;
END
$$

--
-- Create procedure `sp_get_cliente_by_id`
--
CREATE PROCEDURE sp_get_cliente_by_id(IN p_id int)
BEGIN
SELECT
  *
FROM
  clientes
WHERE
  id = p_id;
END
$$

--
-- Create procedure `sp_get_clientes`
--
CREATE PROCEDURE sp_get_clientes()
BEGIN
SELECT
  c.id,
  t.nombre AS tipo_documento,
  c.numero_documento,
  c.nombres_apellidos,
  c.direccion,
  c.email,
  c.telefono,
  c.estado
FROM
  clientes c
  JOIN tipo_documento_identidad t ON c.id_tipo_documento_identidad = t.id;
END
$$

--
-- Create procedure `sp_update_cliente`
--
CREATE PROCEDURE sp_update_cliente(IN p_id int, IN p_id_tipo_documento_identidad int, IN p_numero_documento varchar(20), IN p_nombres_apellidos varchar(200), IN p_direccion varchar(255), IN p_codigo_ubigeo varchar(10), IN p_email varchar(100), IN p_telefono varchar(20), IN p_estado enum ('Activado', 'Desactivado'))
BEGIN
UPDATE
  clientes
SET
  id_tipo_documento_identidad = p_id_tipo_documento_identidad,
  numero_documento = p_numero_documento,
  nombres_apellidos = p_nombres_apellidos,
  direccion = p_direccion,
  codigo_ubigeo = p_codigo_ubigeo,
  email = p_email,
  telefono = p_telefono,
  estado = p_estado
WHERE
  id = p_id;
END
$$

DELIMITER;
