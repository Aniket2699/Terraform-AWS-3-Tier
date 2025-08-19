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
        echo "<h2>Registration Successful!</h2>";
    } else {
        echo "Error: " . $stmt->error;
    }
    $stmt->close();
    $conn->close();
} catch (Exception $e) {
    echo "Exception: " . $e->getMessage();
}
?>
PHP

systemctl enable apache2
systemctl restart apache2
EOF

  tags = { Name = "proj5-app" }

  metadata_options {
    http_tokens = "required"
  }
}
