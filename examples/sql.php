<?php

/**
 * To authenicate as a regular user use
 * username: jdoe
 * password: password
 *
 * To authenicate via injection use
 * username: ' OR 1=1 --
 * password:
 */
function getDatabase()
{
  $db = new SQLite3(':memory:');
  $password = md5('password');
  $sql  = "CREATE TABLE users (id varchar(30) primary key, username text, password text);";
  $sql .= "INSERT INTO users VALUES ('id00001', 'jdoe', '$password');";
  $sql .= "INSERT INTO users VALUES ('id00002', 'jsmith', '$password');";
  $created = $db->exec($sql);
  return $db;
}

function getUsers($db)
{
  $sql = 'SELECT * FROM users';
  $stmt = $db->prepare($sql);
  return $stmt->execute();
}

function authenicate($auth, $db)
{
  $sql  = "SELECT count(id) as count ";
  $sql .= "FROM users ";
  $sql .= "WHERE username='{$auth['username']}' ";
  $sql .= "AND password='{$auth['password']}'";

  $stmt = $db->prepare($sql);
  $result = $stmt->execute();
  $success = $result->fetchArray(SQLITE3_ASSOC);
  return $success['count'] > 0;
}

$auth = [
  'username' => isset($_POST['username']) ? $_POST['username'] : '',
  'password' => md5(isset($_POST['password']) ? $_POST['password'] : ''),
];

if (!empty($_POST)) {
  $db = getDatabase();
  $success = authenicate($auth, $db);

  echo "<section id='private-content'>\n";

  if ($success) {
    echo "<h2>Secret</h2>\n";
    $result = getUsers($db);

    echo "<ul>\n";
    while ($row = $result->fetchArray()) {
      echo "   <li>{$row['username']} - {$row['password']}</li>\n";
    }
    echo "</ul>\n";
  } else {
    echo "<h2>403</h2>\n";
  }

  echo "</section>\n";
  $db->close();
} ?>
<form method="POST">
  <div>
    <label for="username">Username</label>
    <input type="text" name="username" />
  </div>
  <div>
    <label for="password">Password</label>
    <input type="password" name="password" />
  </div>
  <button type="submit">Login</button>
</form>