terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "dev_alpha" {
  cidr_block           = "10.150.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.dev_alpha.id
  cidr_block              = "10.150.0.0/26"
  availability_zone       = "us-west-2a" #
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.dev_alpha.id
  cidr_block              = "10.150.0.64/26"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "dev_alpha_igw" {
  vpc_id = aws_vpc.dev_alpha.id
}

resource "aws_cloudtrail" "dev_alpha_cloudtrail" {
  name                          = "dev-alpha-cloudtrail"
  s3_bucket_name                = "dev-alpha-s3-bucket" 
  enable_logging                = true
  include_global_service_events = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::dev-alpha-s3-bucket/*"] 
    }
  }

  depends_on = [aws_vpc.dev_alpha] # Ensure the VPC is created before CloudTrail
}
