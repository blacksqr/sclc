<?php
include 'lib/config.php';
require_once 'lib/fbconfig.php';
include 'iHackyFunctions.php';


$userId = $_POST['id'];
$classId = $_POST['class'];
$classRank = $_POST['rank'];

$conn = getDbConn();

$queryChangeRank = "UPDATE CLASS_USERS SET class_rank = $classRank 
    WHERE CLASS_USERS.facebook_id = $userId AND CLASS_USERS.class_id = $classId";
    
mysql_query($queryChangeRank);

closeDb($conn);

echo "<a href=\"profile.php\">Return to your Profile</a>"
?>