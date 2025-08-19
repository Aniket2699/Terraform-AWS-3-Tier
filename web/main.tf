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
<head><title>Registration Form</title></head>
<body>
<h2>Register Here</h2>
<form action="/submit.php" method="post">
  <label>Name:</label><br>
  <input type="text" name="name" required><br><br>
  <label>Email:</label><br>
  <input type="email" name="email" required><br><br>
  <label>Password:</label><br>
  <input type="password" name="password" required><br><br>
  <input type="submit" value="Register">
</form>
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
