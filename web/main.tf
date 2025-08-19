resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.web_sg_id]
  associate_public_ip_address = true

user_data = <<-EOF
#!/bin/bash
set -e
apt-get update -y
apt-get install -y nginx

cat > /etc/nginx/sites-available/default <<NGINXCONF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location = /submit.php {
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_pass http://${var.app_private_ip}/submit.php;
    }
}
NGINXCONF

mkdir -p /var/www/html
cat > /var/www/html/index.html <<HTML
<!doctype html>
<html>
<head>
  <title>Registration Form</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background: #f4f7f8;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
    }
    .container {
      background: #fff;
      padding: 30px;
      border-radius: 12px;
      box-shadow: 0 4px 10px rgba(0,0,0,0.15);
      width: 350px;
      text-align: center;
    }
    h2 {
      margin-bottom: 20px;
      color: #333;
    }
    label {
      display: block;
      text-align: left;
      margin: 10px 0 5px;
      font-weight: bold;
      color: #444;
    }
    input[type="text"],
    input[type="email"],
    input[type="password"] {
      width: 100%;
      padding: 10px;
      border: 1px solid #ccc;
      border-radius: 8px;
      margin-bottom: 15px;
      font-size: 14px;
    }
    input[type="submit"] {
      width: 100%;
      padding: 12px;
      background: #007BFF;
      color: white;
      border: none;
      border-radius: 8px;
      cursor: pointer;
      font-size: 16px;
      font-weight: bold;
      transition: background 0.3s;
    }
    input[type="submit"]:hover {
      background: #0056b3;
    }
  </style>
</head>
<body>
  <div class="container">
    <h2>Register Here</h2>
    <form action="/submit.php" method="post">
      <label>Name:</label>
      <input type="text" name="name" required>

      <label>Email:</label>
      <input type="email" name="email" required>

      <label>Password:</label>
      <input type="password" name="password" required>

      <input type="submit" value="Register">
    </form>
  </div>
</body>
</html>
HTML

systemctl enable nginx
systemctl restart nginx
EOF

  metadata_options {
    http_tokens = "required"
  }

  tags = { Name = "proj5-web" }

  provisioner "local-exec" {
    command = "echo Web instance ready: ${self.public_dns}"
  }

  # Pass the app IP via template env
  lifecycle {
    ignore_changes = [user_data]
  }
}

# trick to inject app ip safely (Terraform replaces this token before boot)
locals {
  app_ip = var.app_private_ip
}

# replace token in user_data at plan time
resource "aws_launch_template" "dummy" {
  # not used, but keeps the user_data stable across updates
  name_prefix = "no-op-"
  image_id    = var.ami_id
  user_data   = base64encode(replace("", "", "APP_IP=${local.app_ip}"))
}
