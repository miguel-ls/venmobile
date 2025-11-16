<?php

// En un entorno real, usarías una librería como `vlucas/phpdotenv` para cargar
// las variables desde un archivo .env.
// require_once __DIR__ . '/vendor/autoload.php';
// $dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
// $dotenv->load();

function getDbConnection() {
    // Carga las credenciales desde variables de entorno.
    // Esto es mucho más seguro que tenerlas directamente en el código.
    $host = getenv('DB_HOST') ?: '127.0.0.1';
    $db   = getenv('DB_NAME') ?: 'app_movil_db';
    $user = getenv('DB_USER') ?: 'miguel';
    $pass = getenv('DB_PASS') ?: 'Miguel123!';
    $charset = 'utf8mb4';

    $dsn = "mysql:host=$host;dbname=$db;charset=$charset";
    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ];
    try {
        return new PDO($dsn, $user, $pass, $options);
    } catch (\PDOException $e) {
        // En producción, registra el error en un archivo de logs en lugar de mostrarlo.
        error_log($e->getMessage());
        throw new \PDOException('Error de conexión a la base de datos', 500);
    }
}
?>
