<?php

$username = isset($_GET['username']) ? $_GET['username'] : '';

?>
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>xss-plz</title>
    <meta charset='utf-8'>
  </head>
  <body>
    <h2>Hello, <?php echo $username; ?></h2>
  </body>
</html>