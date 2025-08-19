resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.app_sg_id]
  associate_public_ip_address = false

   user_data = <<-EOF
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y apache2 php libapache2-mod-php php-mysql

# submit.php
cat > /var/www/html/submit.php <<'PHP'
<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$servername = "${var.db_host}";
$username   = "${var.db_username}";
$password   = "${var.db_password}";
$dbname     = "${var.db_name}";

try {
    $conn = new mysqli($servername, $username, $password, $dbname);
    if ($conn->connect_error) { die("Connection failed: " . $conn->connect_error); }

    $conn->query("CREATE TABLE IF NOT EXISTS users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      email VARCHAR(150) NOT NULL,
      password VARCHAR(255) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");

    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    $pwd = $_POST['password'] ?? '';

    $stmt = $conn->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $name, $email, $pwd);

    if ($stmt->execute()) {
        $message = "<h2>🎉 Registration Successful!</h2>
                    <p>Welcome, <strong>" . htmlspecialchars($name) . "</strong>! Your account has been created.</p>
                    <a href='index.html'>⬅ Back to Home</a>";
    } else {
        $message = "<h2 style='color:red;'>❌ Error</h2><p>" . $stmt->error . "</p>";
    }
    $stmt->close();
    $conn->close();
} catch (Exception $e) {
    $message = "<h2 style='color:red;'>⚠️ Exception</h2><p>" . $e->getMessage() . "</p>";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Registration Status</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background: #f4f7f9;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
    }
    .card {
      background: #fff;
      padding: 30px;
      border-radius: 12px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      text-align: center;
      width: 400px;
    }
    h2 {
      color: #2c3e50;
      margin-bottom: 10px;
    }
    p {
      color: #555;
      margin-bottom: 20px;
    }
    a {
      display: inline-block;
      padding: 10px 20px;
      background: #3498db;
      color: #fff;
      text-decoration: none;
      border-radius: 8px;
      transition: background 0.3s;
    }
    a:hover {
      background: #2980b9;
    }
  </style>
</head>
<body>
  <div class="card">
    <?php echo $message; ?>
  </div>
</body>
</html>
PHP

systemctl enable apache2
systemctl restart apache2
EOF


  tags = { Name = "proj5-app" }

  metadata_options {
    http_tokens = "required"
  }
}
