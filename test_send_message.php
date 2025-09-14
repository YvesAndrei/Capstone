<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include db.php;

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "error" => "Connection failed: " . $conn->connect_error]));
}

$from_user = 1; // Change this to the logged-in user ID
$to_user = 2;   // Change this to the recipient user ID
$message = "Hello from the test script!";

$sql = "INSERT INTO messages (from_user, to_user, message) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("iis", $from_user, $to_user, $message);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Message sent successfully!"]);
} else {
    echo json_encode(["success" => false, "error" => "Failed to send message: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
