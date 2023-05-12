resource "aws_vpc" "jfred_jenkins_vpc" {
  cidr_block = "10.48.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "jfred-jenkins-vpc-test"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.jfred_jenkins_vpc.id
  tags = {
    Name = "jfred-jenkins-igw-test"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.jfred_jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  tags = {
    Name = "public_route_table-test"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.jfred_jenkins_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "jfred_jenkins_subnet" {
  vpc_id            = aws_vpc.jfred_jenkins_vpc.id
  cidr_block        = "10.48.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "jfred-jenkins-subnet-test"
  }
}

resource "aws_key_pair" "jfred_key" {
  key_name   = "jfred-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9Ie4lmKm8uZkk10+NYTMRiF9Cx0Cjd+Hq9MTKgKIVMff8cArH30rfiFkUKbqM6Qp3qTEa9kgr7aXpXPbp8DCZ3QQpEaQMLeZbrCa78G20uKfqUDXoZ4zMx9AFQryuP8TVs7YXQFvVXezLbVlhizrlxsXhcg+rr1fhG5PoqjAPNNM1YTq2NEz7jBQn7NsRw6vShLYNGt8XQCgPJkJmqeNASEon+03BlBnFYjyo9zOA9Ju3QHBAYqBulhTCfBh55szrlWiAXVJBB2hc3BVn89QzdVDB4Xya7PyhnvnxPTEwwY2Brik9pCeLN7c5hZIzo+oYS/vYFKHsx7z8yFRRMAvfQwzp7CoL5+BT6HirlZ9llzvz12m3QO9L3CT11/QGYkEfLKDQeRuU7xoSHM5RkW5EI4mpWKVPRLrOUeuXuB27gOhUep1Nzslt2Y16zyTv0QHeXwkIgsq+33MVUe1y/ICaeX17FOZ9eTVO0GjElxhWbKxxPyQ+503OT03GqSuFJEE= nixos@LAPTOP-BFN575U3"
}

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "jfred-jenkins-vm" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = "t3a.small"
  subnet_id                   = aws_subnet.jfred_jenkins_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_https.id]
  key_name                    = aws_key_pair.jfred_key.key_name

  tags = {
    Name = "jfred-jenkins-vm-test"
  }
}

resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.jfred_jenkins_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_https"
  }
}
