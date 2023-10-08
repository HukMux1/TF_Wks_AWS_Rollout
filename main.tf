# some basic vars

variable "aws_region" {
    description = "AWS Region for deployment"
}

variable "aws_creds_file" {
    description = "Full path to the .aws/credentials file"
}

variable "aws_profile" {
   description = "Profile used for creds in creds file"
}

variable "aws_pem" {
    description = "The PEM file fo SSH use. This is outputted with IP for our convenience... "
}

provider "aws" {

    region                   = var.aws_region
    #shared_credentials_file = var.aws_creds_file
    profile                  = var.aws_profile
}


# extra block for grabbing our IP, use later to pump in to an SG rule
data "http" "myip" {
    url = "https://api.ipify.org"
}

# data block for determining ALL of the AWS AZs (only use with AWS Provider)
data "aws_availability_zones" "all" {}


#####################################
# Ubuntu AMI

# NOW, lets grab the latest UBUNTU image... switch this up later for cooler things
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

# using the Ubuntu owners, need to remember to adjust this laters..
  owners = ["099720109477"]
}


#####################################
# VPC

resource "aws_vpc" "tf_rollout-vpc" {
  cidr_block           = "10.0.0.0/23"
  enable_dns_support   = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  #enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name = "tf_rolloout-vpc"
  }
}

######################################
# SUBNET

resource "aws_subnet" "tf_rollout-subnet" {
  vpc_id                  = aws_vpc.tf_rollout-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true" #it makes this a public subnet
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "tf_rollout-subnet"
  }
}

####################################
# IGW

resource "aws_internet_gateway" "tf_rollout-igw" {
  vpc_id = aws_vpc.tf_rollout-vpc.id
  tags = {
    Name = "tf_rollout-igw"
  }
}

###################################
# Route Table

resource "aws_route_table" "tf_rollout-rtble" {
  vpc_id = aws_vpc.tf_rollout-vpc.id

  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0"
    //CRT uses this IGW to reach internet
    gateway_id = aws_internet_gateway.tf_rollout-igw.id
  }

  tags = {
    Name = "tf_rollout-rtble"
  }
}

resource "aws_route_table_association" "tf_rollout-rta" {
  subnet_id      = aws_subnet.tf_rollout-subnet.id
  route_table_id = aws_route_table.tf_rollout-rtble.id
}






