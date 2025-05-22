resource "aws_security_group" "db" {
  vpc_id = var.vpc_id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_sg_id]  # Only allow EC2
  }
}

resource "aws_db_subnet_group" "main" {
  subnet_ids = var.private_subnets
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  db_name                = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["db_name"]
  username               = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["username"]
  password               = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["password"]
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = var.db_secret_arn
}