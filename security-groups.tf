#############################
#### Security Group for Domain Controller in Home VPC
#################################

resource "aws_security_group" "dc_home_sg" {
  name        = "dc-home-sg"
  description = "SG for DC in Home VPC"
  vpc_id      = "dc-vpc-us-east-1" # Replace with your Home VPC ID


  # Ingress Rules for Home VPC

  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp, udp"
    cidr_blocks = ["10.200.0.0/16"] # DR VPC CIDR
  }

  ingress {
    from_port   = 88
    to_port     = 88
    protocol    = "tcp,udp"
    cidr_blocks = ["10.200.0.0/16"]
  }

  ingress {
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    cidr_blocks = ["10.200.0.0/16"]
  }

  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "tcp,udp"
    cidr_blocks = ["10.200.0.0/16"]
  }

  ingress {
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["10.200.0.0/16"]
  }

  ingress {
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = ["10.200.0.0/16"]
  }

  ingress {
    from_port   = 3268
    to_port     = 3268
    protocol    = "tcp"
    cidr_blocks = ["10.200.0.0/16"]
  }

  ingress {
    from_port   = 3269
    to_port     = 3269
    protocol    = "tcp"
    cidr_blocks = ["10.200.0.0/16"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp,udp"
    cidr_blocks = ["10.200.0.0/16"]
  }

  # Ensure you add all other necessary ports following the same pattern

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Home VPC Domain Controller SG"
  }
}
################################
#### Security Group for Domain Controller in DR VPC
#################################

resource "aws_security_group" "dc_dr_sg" {
  name        = "dc-dr-sg"
  description = "SG for DC in DR VPC"
  vpc_id      = "dc-vpc-us-west-1" # Replace with your DR VPC ID

  # Ingress Rules for DR VPC, follow the same pattern as for the Home VPC
  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp, udp"
    cidr_blocks = ["10.100.0.0/16"] # Home VPC CIDR
  }

  ingress {
    from_port   = 88
    to_port     = 88
    protocol    = "tcp,udp"
    cidr_blocks = ["10.100.0.0/16"]
  }

  ingress {
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    cidr_blocks = ["10.100.0.0/16"]
  }

  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "tcp,udp"
    cidr_blocks = ["10.100.0.0/16"]
  }

  ingress {
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["10.100.0.0/16"]
  }

  ingress {
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = ["10.100.0.0/16"]
  }

  ingress {
    from_port   = 3268
    to_port     = 3268
    protocol    = "tcp"
    cidr_blocks = ["10.100.0.0/16"]
  }

  ingress {
    from_port   = 3269
    to_port     = 3269
    protocol    = "tcp"
    cidr_blocks = ["10.100.0.0/16"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp,udp"
    cidr_blocks = ["10.100.0.0/16"]
  }


  # Add any additional ports as required

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DR VPC Domain Controller SG"
  }
}
