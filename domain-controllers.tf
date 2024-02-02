# Create EC2 Instances for Domain Controllers w/ SSM Agent


resource "aws_instance" "pdc_east_2" {
  provider              = aws.us-east-2

  ami                   = "ami-094aa6728b151e05a" # Replace with actual AMI ID
  instance_type         = "t2.large"
  subnet_id             = aws_subnet.subnet_east_2a.id
  key_name              = "nkere_dc-key" # Replace with key name
  iam_instance_profile  = "AmazonSSMRoleForInstancesQuickSetup"

 user_data = filebase64("${path.module}/pdc.ps1")
 
  tags = {
    Name = "DN-PDC-East-2"
  }
}

resource "aws_instance" "rodc_west_2" {
  provider              = aws.us-west-2

  ami                   = "ami-01a7d95ecd129c2f1" # Replace with actual AMI ID
  instance_type         = "t2.large"
  subnet_id             = aws_subnet.subnet_west_2a.id

  key_name              = "dn-rodc-key" # Replace with Key name
  iam_instance_profile  = "AmazonSSMRoleForInstancesQuickSetup"

  user_data = filebase64("${path.module}/rodc.ps1")

  tags = {
    Name = "DN-RODC-West-2"
  }
}