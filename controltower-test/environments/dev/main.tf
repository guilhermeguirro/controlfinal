terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-state-landingzone-010438463494"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-landingzone"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["aws-controltower-VPC"]
  }
}

# Get private subnets
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  filter {
    name   = "tag:Name"
    values = ["aws-controltower-PrivateSubnet*"]
  }
}

# For compute module - get the specific subnet
data "aws_subnet" "compute" {
  filter {
    name   = "tag:Name"
    values = ["aws-controltower-PrivateSubnet1A"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

module "security" {
  source        = "../../modules/security"
  environment   = "dev"
  vpc_id        = data.aws_vpc.existing.id
  vpc_cidr      = data.aws_vpc.existing.cidr_block
}

module "database" {
  source            = "../../modules/database"
  environment       = "dev"
  subnet_ids        = data.aws_subnets.private.ids
  security_group_id = module.security.aurora_security_group_id
  database_name     = "appdb"
  instance_class    = "db.t4g.medium"
}

module "compute" {
  source            = "../../modules/compute"
  environment       = "dev"
  subnet_id         = data.aws_subnet.compute.id
  security_group_id = module.security.ec2_security_group_id
  instance_type     = "t3.micro"
}
