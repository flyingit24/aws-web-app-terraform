resource "random_password" "db" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "db" {
  name = "prod/db-credentials"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = "admin",
    password = random_password.db.result,
    db_name  = var.db_name
  })
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db.arn
}