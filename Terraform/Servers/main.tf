
provider "aws" {
  region = "us-east-1"
}


data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


data "terraform_remote_state" "public_subnet" { 
  backend = "s3"
  config = {
    bucket = "assignment1-rgaraween"               
    key    = "dev/networking/terraform.tfstate" 
    region = "us-east-1"                          
  }
}


data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_instance" "my_amazon" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.assignment1.key_name
  subnet_id                   = data.terraform_remote_state.public_subnet.outputs.subnet_id
  vpc_security_group_ids     = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = merge(var.default_tags,
    {
      "Name" = "${var.prefix}-Amazon-Linux"
    }
  )
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.assignment1.id
  instance_id = aws_instance.my_amazon.id
}




resource "aws_key_pair" "assignment1" {
  key_name   = "assignment1"
  public_key = file("${var.prefix}.pub")
}




resource "aws_ebs_volume" "assignment1" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 40

  tags = merge(var.default_tags,
    {
      "Name" = "${var.prefix}-EBS"
    }
  )
}

resource "aws_ecr_repository" "my_ecr_repo" {
  name                 = "assignment1-ecr"
  image_tag_mutability = "MUTABLE"  
  image_scanning_configuration {
    scan_on_push = true
  }
}


# Security Group
resource "aws_security_group" "web_sg" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.public_subnet.outputs.vpc_id

  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.default_tags,
    {
      "Name" = "${var.prefix}-EBS"
    }
  )
}