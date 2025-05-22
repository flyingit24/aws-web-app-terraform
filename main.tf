# Configure remote backend (bonus)
terraform {
  backend "s3" {
    bucket         = "your-tfstate-bucket"
    key            = "webapp/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}

# Instantiate modules
module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]
}

module "secrets" {
  source    = "./modules/secrets"
  db_name   = "webappdb"
}

module "ec2" {
  source          = "./modules/ec2"
  vpc_id         = module.vpc.vpc_id
  public_subnet  = module.vpc.public_subnets[0]
  db_endpoint    = module.rds.db_endpoint
  db_secret_arn  = module.secrets.db_secret_arn
}

module "rds" {
  source         = "./modules/rds"
  vpc_id         = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  db_secret_arn  = module.secrets.db_secret_arn
  ec2_sg_id      = module.ec2.ec2_sg_id
}