<?php
error_reporting(0);
require_once 'db.php';

session_start();

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'OPTIONS') { http_response_code(200); exit(); }

$path = isset($_SERVER['PATH_INFO']) ? $_SERVER['PATH_INFO'] : '/';
$request = explode('/', trim($path, '/'));

try {
    $pdo = getDbConnection();
    $resource = array_shift($request);
    $id = array_shift($request);
    $input = json_decode(file_get_contents('php://input'), true);

    switch ($resource) {
        case 'captcha': handle_captcha($method); break;
        case 'login': handle_login($pdo, $method, $input); break;
        case 'users': handle_users($pdo, $method, $id, $input); break;
        case 'profiles': handle_profiles($pdo, $method, $id, $input); break;
        case 'tipo_cambio': handle_tipo_cambio($pdo, $method, $id, $input); break;
        case 'sunat_tipo_cambio': handle_sunat_tipo_cambio($method); break;
        default:
            header("Content-Type: application/json; charset=UTF-8");
            http_response_code(404);
            echo json_encode(['message' => 'Not Found']);
            break;
    }
} catch (Exception $e) {
    header("Content-Type: application/json; charset=UTF-8");
    http_response_code(500);
    echo json_encode(['message' => 'Server Error: ' . $e->getMessage()]);
}

function is_authenticated() {
    return isset($_SESSION['user_id']);
}

function handle_captcha($method) {
    if ($method == 'GET') {
        $num1 = rand(1, 9);
        $num2 = rand(1, 9);
        $_SESSION['captcha'] = $num1 + $num2;

        header('Content-Type: application/json');
        echo json_encode(['question' => "$num1 + $num2 = ?"]);
    } else {
        http_response_code(405);
    }
}

function handle_login($pdo, $method, $input) {
    header("Content-Type: application/json; charset=UTF-8");
    if ($method == 'POST') {
        if (!isset($input['captcha'], $_SESSION['captcha']) || strtolower($input['captcha']) != strtolower($_SESSION['captcha'])) {
            http_response_code(401);
            echo json_encode(['status' => 'error', 'message' => 'CAPTCHA incorrecto']);
            return;
        }
        $stmt = $pdo->prepare("CALL sp_get_user_by_username(?)");
        $stmt->execute([$input['username']]);
        $user = $stmt->fetch();
        if ($user && password_verify($input['password'], $user['password'])) {
            $_SESSION['user_id'] = $user['id'];
            unset($user['password']);
            echo json_encode(['status' => 'success', 'user' => $user]);
        } else {
            http_response_code(401);
            echo json_encode(['status' => 'error', 'message' => 'Credenciales inválidas']);
        }
    } else {
        http_response_code(405);
    }
}

function handle_users($pdo, $method, $id, $input) {
    header("Content-Type: application/json; charset=UTF-8");
    if (!is_authenticated()) {
        http_response_code(401);
        echo json_encode(['message' => 'Unauthorized']);
        return;
    }
    switch ($method) {
        case 'GET':
            $stmt = $id ? $pdo->prepare("CALL sp_get_user_by_id(?)") : $pdo->prepare("CALL sp_get_users()");
            $id ? $stmt->execute([$id]) : $stmt->execute();
            echo json_encode($id ? $stmt->fetch() : $stmt->fetchAll());
            break;
        case 'POST':
            $hash = password_hash($input['password'], PASSWORD_DEFAULT);
            $stmt = $pdo->prepare("CALL sp_create_user(?, ?, ?, ?)");
            $stmt->execute([$input['username'], $hash, $input['email'], $input['profile_id']]);
            http_response_code(201);
            echo json_encode($stmt->fetch());
            break;
        case 'PUT':
            $stmt = $pdo->prepare("CALL sp_update_user(?, ?, ?, ?)");
            $stmt->execute([$id, $input['username'], $input['email'], $input['profile_id']]);
            echo json_encode(['status' => 'success']);
            break;
        case 'DELETE':
            $stmt = $pdo->prepare("CALL sp_delete_user(?)");
            $stmt->execute([$id]);
            echo json_encode(['status' => 'success']);
            break;
        default:
            http_response_code(405);
            break;
    }
}

function handle_profiles($pdo, $method, $id, $input) {
    header("Content-Type: application/json; charset=UTF-8");
    if (!is_authenticated()) {
        http_response_code(401);
        echo json_encode(['message' => 'Unauthorized']);
        return;
    }
    switch ($method) {
        case 'GET':
            $stmt = $id ? $pdo->prepare("CALL sp_get_profile_by_id(?)") : $pdo->prepare("CALL sp_get_profiles()");
            $id ? $stmt->execute([$id]) : $stmt->execute();
            echo json_encode($id ? $stmt->fetch() : $stmt->fetchAll());
            break;
        case 'POST':
            $stmt = $pdo->prepare("CALL sp_create_profile(?)");
            $stmt->execute([$input['name']]);
            http_response_code(201);
            echo json_encode($stmt->fetch());
            break;
        case 'PUT':
            $stmt = $pdo->prepare("CALL sp_update_profile(?, ?)");
            $stmt->execute([$id, $input['name']]);
            echo json_encode(['status' => 'success']);
            break;
        case 'DELETE':
            $stmt = $pdo->prepare("CALL sp_delete_profile(?)");
            $stmt->execute([$id]);
            echo json_encode(['status' => 'success']);
            break;
        default:
            http_response_code(405);
            break;
    }
}

function handle_tipo_cambio($pdo, $method, $id, $input) {
    header("Content-Type: application/json; charset=UTF-8");
    if (!is_authenticated()) {
        http_response_code(401);
        echo json_encode(['message' => 'Unauthorized']);
        return;
    }

    switch ($method) {
        case 'GET':
            if ($id) {
                $stmt = $pdo->prepare("CALL sp_get_tipo_cambio_by_id(?)");
                $stmt->execute([$id]);
                echo json_encode($stmt->fetch());
            } else {
                $year = isset($_GET['year']) ? $_GET['year'] : date('Y');
                $month = isset($_GET['month']) ? $_GET['month'] : date('m');
                $stmt = $pdo->prepare("CALL sp_get_tipo_cambio_by_year_month(?, ?)");
                $stmt->execute([$year, $month]);
                echo json_encode($stmt->fetchAll());
            }
            break;
        case 'POST':
            $stmt = $pdo->prepare("CALL sp_create_tipo_cambio(?, ?, ?, ?)");
            $stmt->execute([$input['fecha'], $input['compra'], $input['venta'], $input['moneda']]);
            http_response_code(201);
            echo json_encode($stmt->fetch());
            break;
        case 'PUT':
            $stmt = $pdo->prepare("CALL sp_update_tipo_cambio(?, ?, ?, ?, ?)");
            $stmt->execute([$id, $input['fecha'], $input['compra'], $input['venta'], $input['moneda']]);
            echo json_encode(['status' => 'success']);
            break;
        case 'DELETE':
            $stmt = $pdo->prepare("CALL sp_delete_tipo_cambio(?)");
            $stmt->execute([$id]);
            echo json_encode(['status' => 'success']);
            break;
        default:
            http_response_code(405);
            break;
    }
}

function handle_sunat_tipo_cambio($method) {
    if ($method == 'GET') {
        $fecha = isset($_GET['fecha']) ? $_GET['fecha'] : date('Y-m-d');
        require_once 'config.php';

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, "https://api.apis.net.pe/v1/tipo-cambio-sunat?fecha=$fecha");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array(
            'Authorization: Bearer ' . 'apis-token-1.aTSI1U7KEuT-6bbbCguH-4Y8TI6KS73N'
        ));

        $response = curl_exec($ch);
        $httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        header("Content-Type: application/json; charset=UTF-8");
        http_response_code($httpcode);
        echo $response;
    } else {
        http_response_code(405);
    }
}
?>
