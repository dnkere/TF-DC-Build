provider "aws" {
  alias = "us-east-2"
  region = "us-east-2"
}

provider "aws" {
  alias = "us-west-2"
  region = "us-west-2"
}

# Create VPCS
resource "aws_vpc" "vpc_us_east_2" {
    provider = aws.us-east-2
    cidr_block            = "10.3.0.0/16"
    enable_dns_support    = true
    enable_dns_hostnames  = true
    tags = {
      Name = "dn-vpc-us-east-2"
    }
  }

resource "aws_vpc" "vpc_us_west_2" {
  provider              = aws.us-west-2
  cidr_block            = "10.4.0.0/16"
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    Name = "dn-vpc-us-west-2"
  }
}


# Create Subnets
resource "aws_subnet" "subnet_east_2a" {
  provider            = aws.us-east-2
  depends_on          = [aws_vpc.vpc_us_east_2]
  vpc_id              = aws_vpc.vpc_us_east_2.id
  cidr_block          = "10.3.1.0/24"
  availability_zone   = "us-east-2a"
  tags = {
    Name = "subnet-east-2a"
  }
}

resource "aws_subnet" "subnet_east_2b" {
  provider            = aws.us-east-2
  depends_on          = [aws_vpc.vpc_us_east_2]
  vpc_id              = aws_vpc.vpc_us_east_2.id
  cidr_block          = "10.3.2.0/24"
  availability_zone   = "us-east-2b"
  tags = {
    Name = "subnet-east-2b"
  }
}

resource "aws_subnet" "subnet_west_2a" {
  depends_on          = [aws_vpc.vpc_us_west_2]
  provider            = aws.us-west-2
  vpc_id              = aws_vpc.vpc_us_west_2.id
  cidr_block          = "10.4.1.0/24"
  availability_zone   = "us-west-2a"
  tags = {
    Name = "subnet-west-2a"
  }
}

resource "aws_subnet" "subnet_west_2b" {
  depends_on          = [aws_vpc.vpc_us_west_2]
  provider            = aws.us-west-2
  vpc_id              = aws_vpc.vpc_us_west_2.id
  cidr_block          = "10.4.2.0/24"
  availability_zone   = "us-west-2b"
  tags = {
    Name = "subnet-west-2b"
  }
}

# Create EC2 Instances for Domain Controllers

resource "aws_instance" "pdc_east_2" {
  provider              = aws.us-east-2
  depends_on            = [aws_vpc.vpc_us_east_2]
  ami                   = "ami-0b54d725f940e0d1e" # Replace with actual AMI ID
  instance_type         = "t2.large"
  subnet_id             = aws_subnet.subnet_east_2a.id
  key_name              = "nkere_dc-key" # Replace with key name
  iam_instance_profile  = "AmazonSSMRoleForInstancesQuickSetup"
  tags = {
    Name = "DN-PDC-East-2"
  }
}

resource "aws_instance" "rodc_west_2" {
  depends_on            = [aws_vpc.vpc_us_west_2]
  provider              = aws.us-west-2
  ami                   = "ami-090f1243429a46b63" # Replace with actual AMI ID
  instance_type         = "t2.large"
  subnet_id             = aws_subnet.subnet_west_2a.id
  key_name              = "dn-rodc-key" # Replace with Key name
  iam_instance_profile  = "AmazonSSMRoleForInstancesQuickSetup"
  tags = {
    Name = "DN-RODC-West-2"
  }
}

# VPC Endpoints in us-east-2

resource "aws_vpc_endpoint" "ssm_east" {
  depends_on            = [aws_security_group.ssm_sg_east]
  vpc_id                = aws_vpc.vpc_us_east_2.id
  service_name          = "com.amazonaws.us-east-2.ssm"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [aws_subnet.subnet_east_2a.id, aws_subnet.subnet_east_2b.id]
  private_dns_enabled   = true
  security_group_ids    = [aws_security_group.ssm_sg_east.id]
}

resource "aws_vpc_endpoint" "ssmmessages_east" {
  depends_on            = [aws_security_group.ssm_sg_east]
  vpc_id                = aws_vpc.vpc_us_east_2.id
  service_name          = "com.amazonaws.us-east-2.ssmmessages"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [aws_subnet.subnet_east_2a.id, aws_subnet.subnet_east_2b.id]
  private_dns_enabled   = true
  security_group_ids    = [aws_security_group.ssm_sg_east.id]
}

resource "aws_vpc_endpoint" "ec2messages_east" {
  depends_on            = [aws_security_group.ssm_sg_east]
  vpc_id                = aws_vpc.vpc_us_east_2.id
  service_name          = "com.amazonaws.us-east-2.ec2messages"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [aws_subnet.subnet_east_2a.id, aws_subnet.subnet_east_2b.id]
  private_dns_enabled   = true
  security_group_ids    = [aws_security_group.ssm_sg_east.id]
}

# Security Groups for us-east-2
resource "aws_security_group" "ssm_sg_east" {
  provider              = aws.us-east-2
  depends_on            = [ aws_vpc.vpc_us_east_2 ]
  name                  = "dn-ssm-sg-east"
  description           = "Security group for SSM endpoints in us-east-2"
  vpc_id                = aws_vpc.vpc_us_east_2.id

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

# VPC Endpoints for us-west-2

resource "aws_vpc_endpoint" "ssm_west" {
  depends_on            = [aws_security_group.ssm_sg_west]
  provider              = aws.us-west-2
  vpc_id                = aws_vpc.vpc_us_west_2.id
  service_name          = "com.amazonaws.us-west-2.ssm"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [aws_subnet.subnet_west_2a.id, aws_subnet.subnet_west_2b.id]
  private_dns_enabled   = true
  security_group_ids    = [aws_security_group.ssm_sg_west.id]
}

resource "aws_vpc_endpoint" "ssmmessages_west" {
  depends_on            = [aws_security_group.ssm_sg_west]
  provider              = aws.us-west-2
  vpc_id                = aws_vpc.vpc_us_west_2.id
  service_name          = "com.amazonaws.us-west-2.ssmmessages"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [aws_subnet.subnet_west_2a.id, aws_subnet.subnet_west_2b.id]
  private_dns_enabled   = true
  security_group_ids    = [aws_security_group.ssm_sg_west.id]
}

resource "aws_vpc_endpoint" "ec2messages_west" {
  depends_on            = [aws_security_group.ssm_sg_west]
  provider              = aws.us-west-2
  vpc_id                = aws_vpc.vpc_us_west_2.id
  service_name          = "com.amazonaws.us-west-2.ec2messages"
  vpc_endpoint_type     = "Interface"
  subnet_ids            = [aws_subnet.subnet_west_2a.id, aws_subnet.subnet_west_2b.id]
  private_dns_enabled   = true
  security_group_ids    = [aws_security_group.ssm_sg_west.id]
}

# Security Groups for us-west-2

resource "aws_security_group" "ssm_sg_west" {
  depends_on            = [aws_vpc.vpc_us_west_2]
  provider              = aws.us-west-2
  name                  = "dn-ssm-sg-west"
  description           = "Security group for SSM endpoints in us-west-2"
  vpc_id                = aws_vpc.vpc_us_west_2.id

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

# VPC Peering Connection initiated in us-west-2
resource "aws_vpc_peering_connection" "peer" {
  depends_on                = [ aws_vpc.vpc_us_east_2, aws_vpc.vpc_us_west_2 ]
  provider              = aws.us-west-2
  vpc_id                = aws_vpc.vpc_us_west_2.id
  peer_vpc_id           = aws_vpc.vpc_us_east_2.id
  peer_region           = "us-east-2"
  auto_accept           = false
  tags = {
    Name = "cross-region-vpc-peering"
  }
}

# Accept the VPC Peering Connection in us-east-2
resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  depends_on                = [ aws_vpc.vpc_us_east_2, aws_vpc.vpc_us_west_2 ]
  provider                  = aws.us-east-2
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true
  tags = {
    Name = "cross-region-vpc-peering"
  }
}

# Update route tables for each VPC to route traffic to the peered VPC
resource "aws_route" "route_from_east_to_west" {
  depends_on                = [ aws_vpc.vpc_us_east_2.main_route_table_id, aws_vpc.vpc_us_west_2.main_route_table_id]
  provider                  = aws.us-west-2
  route_table_id            = aws_vpc.vpc_us_east_2.main_route_table_id
  destination_cidr_block    = aws_vpc.vpc_us_west_2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "route_from_west_to_east" {
  depends_on                = [ aws_vpc.vpc_us_east_2, aws_vpc.vpc_us_west_2 ]
  provider                  = aws.us-west-2
  route_table_id            = aws_vpc.vpc_us_west_2.main_route_table_id
  destination_cidr_block    = aws_vpc.vpc_us_east_2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
