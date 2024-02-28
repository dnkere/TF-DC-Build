provider "aws" {
  alias = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias = "us-west-1"
  region = "us-west-1"
}
################################
#### Create VPCS
################################

resource "aws_vpc" "vpc_us_east_1" {
    provider = aws.us-east-1
    cidr_block            = "10.3.0.0/16"
    enable_dns_support    = true
    enable_dns_hostnames  = true
    tags = {
      Name = "dc-vpc-us-east-1"
    }
  }

resource "aws_vpc" "vpc_us_west_1" {
  provider              = aws.us-west-1
  cidr_block            = "10.4.0.0/16"
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    Name = "dc-vpc-us-west-1"
  }
}

################################
#### Create Subnets
################################

resource "aws_subnet" "subnet_east_1a" {
  provider            = aws.us-east-1
  vpc_id              = aws_vpc.vpc_us_east_1.id
  cidr_block          = "10.3.1.0/24"
  availability_zone   = "us-east-1a"
  tags = {
    Name = "subnet-east-1a"
  }
}

resource "aws_subnet" "subnet_east_1b" {
  provider            = aws.us-east-1
  vpc_id              = aws_vpc.vpc_us_east_1.id
  cidr_block          = "10.3.2.0/24"
  availability_zone   = "us-east-1b"
  tags = {
    Name = "subnet-east-1b"
  }
}

resource "aws_subnet" "subnet_west_1a" {
  provider            = aws.us-west-1
  vpc_id              = aws_vpc.vpc_us_west_1.id
  cidr_block          = "10.4.1.0/24"
  availability_zone   = "us-west-1a"
  tags = {
    Name = "subnet-west-1a"
  }
}

resource "aws_subnet" "subnet_west_1b" {
  provider            = aws.us-west-1
  vpc_id              = aws_vpc.vpc_us_west_1.id
  cidr_block          = "10.4.2.0/24"
  availability_zone   = "us-west-1b"
  tags = {
    Name = "subnet-west-1b"
  }
}

################################
#### VPC Endpoints in us-east-1
################################

resource "aws_vpc_endpoint" "ssm_east" {
  provider              = aws.us-east-1
  
  vpc_id                = aws_vpc.vpc_us_east_1.id
  service_name          = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [aws_subnet.subnet_east_1a.id, aws_subnet.subnet_east_1b.id]
  private_dns_enabled   = true
  security_group_ids    = [aws_security_group.ssm_sg_east.id]
}

resource "aws_vpc_endpoint" "ssmmessages_east" {
  provider              = aws.us-east-1

  vpc_id                = aws_vpc.vpc_us_east_1.id
  service_name          = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [aws_subnet.subnet_east_1a.id, aws_subnet.subnet_east_1b.id]
  private_dns_enabled   = true
  security_group_ids    = [aws_security_group.ssm_sg_east.id]
}

resource "aws_vpc_endpoint" "ec2messages_east" {
  provider              = aws.us-east-1

  vpc_id                = aws_vpc.vpc_us_east_1.id
  service_name          = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [aws_subnet.subnet_east_1a.id, aws_subnet.subnet_east_1b.id]
  private_dns_enabled   = true
  security_group_ids    = [aws_security_group.ssm_sg_east.id]
}

################################
#### Security Groups for us-east-1
################################

resource "aws_security_group" "ssm_sg_east" {
  provider              = aws.us-east-1
  name                  = "ssm-sg-east"
  description           = "Security group for SSM endpoints in us-east-1"
  vpc_id                = aws_vpc.vpc_us_east_1.id

  ingress {
    from_port           = 0
    to_port             = 0
    protocol            = "-1"  # Allows all protocols
    cidr_blocks         = ["0.0.0.0/0"]
  }

  egress {
    from_port           = 0
    to_port             = 0
    protocol            = "-1"  # Allows all protocols
    cidr_blocks         = ["0.0.0.0/0"]
  }
}

################################
#### VPC Endpoints for us-west-1
################################

resource "aws_vpc_endpoint" "ssm_west" {
  provider              = aws.us-west-1
  vpc_id                = aws_vpc.vpc_us_west_1.id
  service_name          = "com.amazonaws.us-west-1.ssm"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [aws_subnet.subnet_west_1a.id, aws_subnet.subnet_west_1b.id]
  private_dns_enabled   = true
  security_group_ids    = [aws_security_group.ssm_sg_west.id]
}

resource "aws_vpc_endpoint" "ssmmessages_west" {
  provider              = aws.us-west-1
  vpc_id                = aws_vpc.vpc_us_west_1.id
  service_name          = "com.amazonaws.us-west-1.ssmmessages"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [aws_subnet.subnet_west_1a.id, aws_subnet.subnet_west_1b.id]
  private_dns_enabled   = true
  security_group_ids    = [aws_security_group.ssm_sg_west.id]
}

resource "aws_vpc_endpoint" "ec2messages_west" {
  provider              = aws.us-west-1
  vpc_id                = aws_vpc.vpc_us_west_1.id
  service_name          = "com.amazonaws.us-west-1.ec2messages"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [aws_subnet.subnet_west_1a.id, aws_subnet.subnet_west_1b.id]
  private_dns_enabled   = true
  security_group_ids    = [aws_security_group.ssm_sg_west.id]
}

################################
#### Security Groups for us-west-1
################################

resource "aws_security_group" "ssm_sg_west" {
  provider              = aws.us-west-1
  name                  = "ssm-sg-west"
  description           = "Security group for SSM endpoints in us-west-1"
  vpc_id                = aws_vpc.vpc_us_west_1.id

  ingress {
    from_port           = 0
    to_port             = 0
    protocol            = "-1"  # Allows all protocols
    cidr_blocks         = ["0.0.0.0/0"]
  }

  egress {
    from_port           = 0
    to_port             = 0
    protocol            = "-1"  # Allows all protocols
    cidr_blocks         = ["0.0.0.0/0"]
  }
}

################################
#### VPC Peering Connection initiated in us-west-1
################################

resource "aws_vpc_peering_connection" "peer" {
  provider              = aws.us-west-1

  vpc_id                = aws_vpc.vpc_us_west_1.id
  peer_vpc_id           = aws_vpc.vpc_us_east_1.id
  peer_region           = "us-east-1"
  auto_accept           = false
  
  tags = {
    Name = "cross-region-vpc-peering"
  }
}

################################
#### Accept the VPC Peering Connection in us-east-1
################################

resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  provider                  = aws.us-east-1

  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true
  
  tags = {
    Name = "cross-region-vpc-peering"
  }
}

################################
#### Update route tables for each VPC to route traffic to the peered VPC
################################

resource "aws_route" "route_from_east_to_west" {
  provider                  = aws.us-east-1
  
  route_table_id            = aws_vpc.vpc_us_east_1.main_route_table_id
  destination_cidr_block    = aws_vpc.vpc_us_west_1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "route_from_west_to_east" {
  provider                  = aws.us-west-1
  
  route_table_id            = aws_vpc.vpc_us_west_1.main_route_table_id
  destination_cidr_block    = aws_vpc.vpc_us_east_1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

