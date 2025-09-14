<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type");

include db.php;

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["success" => false, "error" => "Connection failed: " . $conn->connect_error]));
}

// Check messages table structure
$sql = "DESCRIBE messages";
$result = $conn->query($sql);

$tableStructure = [];
while ($row = $result->fetch_assoc()) {
    $tableStructure[] = $row;
}

// Check if there are any messages
$sql = "SELECT COUNT(*) as total_messages FROM messages";
$countResult = $conn->query($sql);
$totalMessages = $countResult->fetch_assoc()['total_messages'];

// Get sample messages
$sql = "SELECT * FROM messages ORDER BY timestamp DESC LIMIT 10";
$messagesResult = $conn->query($sql);
$sampleMessages = [];
while ($row = $messagesResult->fetch_assoc()) {
    $sampleMessages[] = $row;
}

echo json_encode([
    "success" => true,
    "table_structure" => $tableStructure,
    "total_messages" => $totalMessages,
    "sample_messages" => $sampleMessages
]);

$conn->close();
?>
