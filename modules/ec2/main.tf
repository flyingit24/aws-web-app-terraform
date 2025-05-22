resource "aws_security_group" "web" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP globally
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = templatefile("${path.module}/user-data.sh", {
    db_endpoint = var.db_endpoint,
    secret_arn  = var.db_secret_arn
  })
}

output "ec2_sg_id" {
  value = aws_security_group.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}