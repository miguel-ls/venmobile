-- Creación de la tabla de usuarios
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Para almacenar la contraseña hasheada
    email VARCHAR(100) NOT NULL UNIQUE,
    profile_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creación de la tabla de perfiles
CREATE TABLE profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --- PROCEDIMIENTOS ALMACENADOS PARA USUARIOS ---

-- Login (obtiene el usuario por su nombre de usuario)
DELIMITER $$
CREATE PROCEDURE sp_get_user_by_username(IN p_username VARCHAR(50))
BEGIN
    SELECT id, username, password, profile_id FROM users WHERE username = p_username;
END$$
DELIMITER ;

-- Obtener todos los usuarios
DELIMITER $$
CREATE PROCEDURE sp_get_users()
BEGIN
    SELECT id, username, email, profile_id FROM users;
END$$
DELIMITER ;

-- Obtener un usuario por ID
DELIMITER $$
CREATE PROCEDURE sp_get_user_by_id(IN p_user_id INT)
BEGIN
    SELECT id, username, email, profile_id FROM users WHERE id = p_user_id;
END$$
DELIMITER ;

-- Crear un usuario
DELIMITER $$
CREATE PROCEDURE sp_create_user(IN p_username VARCHAR(50), IN p_password_hash VARCHAR(255), IN p_email VARCHAR(100), IN p_profile_id INT)
BEGIN
    INSERT INTO users (username, password, email, profile_id) VALUES (p_username, p_password_hash, p_email, p_profile_id);
    SELECT LAST_INSERT_ID() as id;
END$$
DELIMITER ;

-- Actualizar un usuario
DELIMITER $$
CREATE PROCEDURE sp_update_user(IN p_user_id INT, IN p_username VARCHAR(50), IN p_email VARCHAR(100), IN p_profile_id INT)
BEGIN
    UPDATE users SET username = p_username, email = p_email, profile_id = p_profile_id WHERE id = p_user_id;
END$$
DELIMITER ;

-- Eliminar un usuario
DELIMITER $$
CREATE PROCEDURE sp_delete_user(IN p_user_id INT)
BEGIN
    DELETE FROM users WHERE id = p_user_id;
END$$
DELIMITER ;

-- --- PROCEDIMIENTOS ALMACENADOS PARA PERFILES ---

-- Obtener todos los perfiles
DELIMITER $$
CREATE PROCEDURE sp_get_profiles()
BEGIN
    SELECT id, name FROM profiles;
END$$
DELIMITER ;

-- Obtener un perfil por ID
DELIMITER $$
CREATE PROCEDURE sp_get_profile_by_id(IN p_profile_id INT)
BEGIN
    SELECT id, name FROM profiles WHERE id = p_profile_id;
END$$
DELIMITER ;

-- Crear un perfil
DELIMITER $$
CREATE PROCEDURE sp_create_profile(IN p_name VARCHAR(50))
BEGIN
    INSERT INTO profiles (name) VALUES (p_name);
    SELECT LAST_INSERT_ID() as id;
END$$
DELIMITER ;

-- Actualizar un perfil
DELIMITER $$
CREATE PROCEDURE sp_update_profile(IN p_profile_id INT, IN p_name VARCHAR(50))
BEGIN
    UPDATE profiles SET name = p_name WHERE id = p_profile_id;
END$$
DELIMITER ;

-- Eliminar un perfil
DELIMITER $$
CREATE PROCEDURE sp_delete_profile(IN p_profile_id INT)
BEGIN
    DELETE FROM profiles WHERE id = p_profile_id;
END$$
DELIMITER ;
