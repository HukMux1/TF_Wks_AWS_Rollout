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



