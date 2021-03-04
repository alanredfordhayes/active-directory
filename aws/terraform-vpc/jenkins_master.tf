data "aws_ssm_parameter" "linuxAmi" {
  provider = aws
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_key_pair" "master_key" {
  provider   = aws
  key_name   = "jenkins-master"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "jenkins_sg" {
  provider    = aws
  name        = "jenkins-sg"
  description = "Allow TCP/8080 & TCP/22"
  vpc_id      = aws_vpc.vpc_active_directory.id
  ingress {
    description = "Allow 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    description = "Allow 443"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    description     = "8080"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins_master" {
  ami                         = data.aws_ssm_parameter.linuxAmi.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.master_key.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  subnet_id                   = aws_subnet.internal_a.id

  tags = {
    Name = "jenkins_master"
  }
}