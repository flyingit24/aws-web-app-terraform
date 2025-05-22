#!/bin/bash
# Install web stack
yum update -y
amazon-linux-extras install -y php7.4
yum install -y httpd php-mysqlnd

# Fetch DB credentials from Secrets Manager
SECRET=$(aws secretsmanager get-secret-value --secret-id ${secret_arn} --region us-east-1 | jq -r '.SecretString')
DB_HOST=${db_endpoint}
DB_USER=$(echo $SECRET | jq -r '.username')
DB_PASS=$(echo $SECRET | jq -r '.password')
DB_NAME=$(echo $SECRET | jq -r '.db_name')

# Configure PHP to use RDS
cat > /var/www/html/index.php <<EOF
<?php
\$conn = new mysqli("$DB_HOST", "$DB_USER", "$DB_PASS", "$DB_NAME");
if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}
echo "Connected to database!";
?>
EOF

# Start Apache
systemctl start httpd
systemctl enable httpd
chown -R apache:apache /var/www/html