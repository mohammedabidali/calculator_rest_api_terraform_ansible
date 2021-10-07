provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "cyber94-mali-bucket"
    key = "tfstate/calculator2/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "cyber94_calculator2_mohammed_dynamodb_table_lock"
    encrypt = true
  }
}

# 1. virtual private cloud (vpc):
resource "aws_vpc" "cyber94_calculator2_mohammed_vpc_tf" {
  cidr_block       = "10.111.0.0/16"

  tags = {
    Name = "cyber94_calculator2_mohammed_vpc"
  }
}

# 2. internet gateway (ig):
resource "aws_internet_gateway" "cyber94_calculator2_mohammed_internet_gateway_tf" {
  vpc_id = aws_vpc.cyber94_calculator2_mohammed_vpc_tf.id

  tags = {
    Name = "cyber94_calculator2_mohammed_internet_gateway"
  }
}

# 3. route table:
resource "aws_route_table" "cyber94_calculator2_mohammed_route_table_tf" {
  vpc_id = aws_vpc.cyber94_calculator2_mohammed_vpc_tf.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.cyber94_calculator2_mohammed_internet_gateway_tf.id
    }


  tags = {
    Name = "cyber94_calculator2_mohammed_route_table"
  }
}

#4.1 subnet (app server):
resource "aws_subnet" "cyber94_calculator2_mohammed_subnet_app_tf" {
  vpc_id     = aws_vpc.cyber94_calculator2_mohammed_vpc_tf.id
  cidr_block = "10.111.1.0/24"

  tags = {
    Name = "cyber94_calculator2_mohammed_subnet_app"
  }
}

#4.2 subnet (database server):
resource "aws_subnet" "cyber94_calculator2_mohammed_subnet_db_tf" {
  vpc_id     = aws_vpc.cyber94_calculator2_mohammed_vpc_tf.id
  cidr_block = "10.111.2.0/24"

  tags = {
    Name = "cyber94_calculator2_mohammed_subnet_db"
  }
}

#4.3 subnet (bastion server):
resource "aws_subnet" "cyber94_calculator2_mohammed_subnet_bastion_tf" {
  vpc_id     = aws_vpc.cyber94_calculator2_mohammed_vpc_tf.id
  cidr_block = "10.111.3.0/24"

  tags = {
    Name = "cyber94_calculator2_mohammed_subnet_bastion"
  }
}

# 5.1 route table associations (app server):
resource "aws_route_table_association" "cyber94_calculator2_mohammed_route_table_association_app_tf" {
  subnet_id      = aws_subnet.cyber94_calculator2_mohammed_subnet_app_tf.id
  route_table_id = aws_route_table.cyber94_calculator2_mohammed_route_table_tf.id
}

# 5.2 route table associations (bastion server):
resource "aws_route_table_association" "cyber94_calculator2_mohammed_route_table_association_bastion_tf" {
  subnet_id      = aws_subnet.cyber94_calculator2_mohammed_subnet_bastion_tf.id
  route_table_id = aws_route_table.cyber94_calculator2_mohammed_route_table_tf.id
}

# 6.1 nacl (app server):
resource "aws_network_acl" "cyber94_calculator2_mohammed_nacl_app_tf" {
  vpc_id = aws_vpc.cyber94_calculator2_mohammed_vpc_tf.id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "86.21.170.53/32" # ip from the source
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 5000
    to_port    = 5000
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "10.111.2.0/24" # ip for the destination
    from_port  = 3306
    to_port    = 3306
  }

  egress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 600
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 700
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  subnet_ids = [aws_subnet.cyber94_calculator2_mohammed_subnet_app_tf.id]

  tags = {
    Name = "cyber94_calculator2_mohammed_nacl_app"
  }
}

# 6.2 nacl (database server):
resource "aws_network_acl" "cyber94_calculator2_mohammed_nacl_db_tf" {
  vpc_id = aws_vpc.cyber94_calculator2_mohammed_vpc_tf.id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.111.1.0/24" # ip from the source
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.111.3.0/24"
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "10.111.1.0/24" # ip for the destination
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "10.111.3.0/24"
    from_port  = 1024
    to_port    = 65535
  }

  subnet_ids = [aws_subnet.cyber94_calculator2_mohammed_subnet_db_tf.id]

  tags = {
    Name = "cyber94_calculator2_mohammed_nacl_db"
  }
}

# 6.3 nacl (bastion server):
resource "aws_network_acl" "cyber94_calculator2_mohammed_nacl_bastion_tf" {
  vpc_id = aws_vpc.cyber94_calculator2_mohammed_vpc_tf.id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "86.21.170.53/32" # ip from the source
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.111.2.0/24"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "10.111.2.0/24" # ip for the destination
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  subnet_ids = [aws_subnet.cyber94_calculator2_mohammed_subnet_bastion_tf.id]

  tags = {
    Name = "cyber94_calculator2_mohammed_nacl_bastion"
  }
}

# 7.1 security group (app server):
resource "aws_security_group" "cyber94_calculator2_mohammed_sg_app_tf" {
  name = "cyber94_calculator2_mohammed_sg_app_server" #defining security group name
  vpc_id = aws_vpc.cyber94_calculator2_mohammed_vpc_tf.id

  #inbound rules:
  ingress {
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 5000
    to_port    = 5000
  }

  ingress {
    protocol   = "tcp"
    cidr_blocks = ["86.21.170.53/32"]
    from_port  = 22
    to_port    = 22
  }

  #outbound rules:
  egress {
    protocol   = "tcp"
    cidr_blocks = ["10.111.2.0/24"]
    from_port  = 3306
    to_port    = 3306
  }

  egress {
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "cyber94_calculator2_mohammed_sg_app"
  }
}

# 7.2 security group (database server):
resource "aws_security_group" "cyber94_calculator2_mohammed_sg_database_tf" {
  name = "cyber94_calculator2_mohammed_sg_database_server" #defining security group name
  vpc_id = aws_vpc.cyber94_calculator2_mohammed_vpc_tf.id

  #inbound rules:
  ingress {
    protocol   = "tcp"
    cidr_blocks = ["10.111.1.0/24"]
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    protocol   = "tcp"
    cidr_blocks = ["10.111.3.0/24"]
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "cyber94_calculator2_mohammed_sg_database"
  }
}

# 7.3 security group (bastion server):
resource "aws_security_group" "cyber94_calculator2_mohammed_sg_bastion_tf" {
  name = "cyber94_calculator2_mohammed_sg_bastion_server" #defining security group name
  vpc_id = aws_vpc.cyber94_calculator2_mohammed_vpc_tf.id

  #inbound rules:
  ingress {
    protocol   = "tcp"
    cidr_blocks = ["86.21.170.53/32"]
    from_port  = 22
    to_port    = 22
  }

  #outbound rules:
  egress {
    protocol   = "tcp"
    cidr_blocks = ["10.111.2.0/24"]
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "cyber94_calculator2_mohammed_sg_bastion"
  }
}

# 8.1 aws instance (app server):
resource "aws_instance" "cyber94_calculator2_mohammed_app_server_tf" {
  ami = "ami-0943382e114f188e8"
  instance_type = "t2.micro"
  key_name = "cyber94-mali"

  associate_public_ip_address = true # can add this to the subnet itself if you dont want to apply a public address to all of them

  subnet_id = aws_subnet.cyber94_calculator2_mohammed_subnet_app_tf.id
  vpc_security_group_ids = [aws_security_group.cyber94_calculator2_mohammed_sg_app_tf.id] # [name of the resource.the name of the resources.id]

  count = 1 # define the number of servers you want to create

  tags = {
    Name = "cyber94_calculator2_mohammed_app_server"
  }

  # lifecycle {
  #   create_before_destroy = true
  # }

  # Just to make sure that terraform will not continue to local-exec before the server is up
  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
    private_key = file("/home/kali/.ssh/cyber94-mali.pem")
  }

  # Just to make sure that terraform will not continue to local-exec before the server is up
  provisioner "remote-exec" {
    inline = [
      "pwd"
    ]
  }

  provisioner "local-exec" {
    working_dir = "../ansible"
    command = "ansible-playbook -i ${self.public_ip}, -u ubuntu playbook.yml"
  }
}


resource "aws_instance" "cyber94_calculator2_mohammed_database_server_tf" {
  ami = "ami-0d1c7c4de1f4cdc9a"
  instance_type = "t2.micro"
  key_name = "cyber94-mali"

  associate_public_ip_address = false # can add this to the subnet itself if you dont want to apply a public address to all of them

  subnet_id = aws_subnet.cyber94_calculator2_mohammed_subnet_db_tf.id
  vpc_security_group_ids = [aws_security_group.cyber94_calculator2_mohammed_sg_database_tf.id] # [name of the resource.the name of the resources.id]

  count = 1

  tags = {
    Name = "cyber94_calculator2_mohammed_db_server"
  }

  # lifecycle {
  #   create_before_destroy = true
  # }
}

resource "aws_instance" "cyber94_calculator2_mohammed_bastion_server_tf" {
  ami = "ami-0943382e114f188e8"
  instance_type = "t2.micro"
  key_name = "cyber94-mali"

  associate_public_ip_address = true # can add this to the subnet itself if you dont want to apply a public address to all of them

  subnet_id = aws_subnet.cyber94_calculator2_mohammed_subnet_bastion_tf.id
  vpc_security_group_ids = [aws_security_group.cyber94_calculator2_mohammed_sg_bastion_tf.id] # [name of the resource.the name of the resources.id]

  count = 1

  tags = {
    Name = "cyber94_calculator2_mohammed_bastion_server"
  }

  # lifecycle {
  #   create_before_destroy = true
  # }
}
