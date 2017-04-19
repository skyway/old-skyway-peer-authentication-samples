<?php

/************************************************
 *            Config section start              *
 *         replace with your own values         *
 ************************************************/

define('SECRETKEY', 'YourSecretKey'); // replace with your own secretkey from the dashboard
define('CREDENTIALTTL', 3600); // 1 hour

/************************************************
 *            Config section finished           *
 ************************************************/

header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

$peerId = $_POST['peerId'];
$sessionToken = $_POST['sessionToken'];

if ($_SERVER["REQUEST_URI"] == '/authenticate' &&
    $_SERVER['REQUEST_METHOD'] == 'POST') {

    $peerId = $_POST['peerId'];
    $sessionToken = $_POST['sessionToken'];

    if (checkSessionToken($peerId, $sessionToken)) {
        $timestamp = time();

        $authToken = calculateAuthToken($peerId, $timestamp);

        $returnJSON = array(
            'timestamp' => $timestamp,
            'ttl' => CREDENTIALTTL,
            'authToken' => $authToken
        );

        echo json_encode($returnJSON);
    } else {
        http_response_code(401);
        echo 'Authentication Failed';
    }

    exit();
} else {
    header('HTTP/1.0 404 Not Found');
    echo "The page that you have requested could not be found.";
    http_response_code(404);
    exit();
}

function checkSessionToken($peerId, $token) {
    // Implement checking whether the session is valid or not.
    // Return true if the session token is valid.
    // Return false if it is invalid.
    return true;
}

function calculateAuthToken($peerId, $timestamp) {
    $message = "$timestamp:" . CREDENTIALTTL . ":$peerId";
    return base64_encode(hash_hmac('sha256', $message, SECRETKEY, true));
}