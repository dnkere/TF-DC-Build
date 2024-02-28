################################
#### Create EC2 Instances for Domain Controllers w/ SSM Agent
################################

resource "aws_instance" "pdc_east_1" {
  provider              = aws.us-east-2

  ami                   = "ami-094aa6728b151e05a" # Replace with actual AMI ID
  instance_type         = "t2.large"
  subnet_id             = aws_subnet.subnet_east_1a.id
  key_name              = "aws/ssm" # Replace with key name
  iam_instance_profile  = "AmazonSSMRoleForInstancesQuickSetup"
  security_groups       = [aws_security_group.dc_home_sg.id]

#  user_data = filebase64("${path.module}/pdc.ps1")
 
  tags = {
    Name = "PDC-East-1"
  }
}

resource "aws_instance" "rodc_west_1" {
  provider              = aws.us-west-2

  ami                   = "ami-01a7d95ecd129c2f1" # Replace with actual AMI ID
  instance_type         = "t2.large"
  subnet_id             = aws_subnet.subnet_west_1a.id

  key_name              = "aws/ssm" # Replace with Key name
  iam_instance_profile  = "AmazonSSMRoleForInstancesQuickSetup"
  security_groups       = [aws_security_group.dc_dr_sg.id]

  # user_data = filebase64("${path.module}/rodc.ps1")

  tags = {
    Name = "RODC-West-1"
  }
}