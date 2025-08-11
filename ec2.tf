# EC2용 보안 그룹
resource "aws_security_group" "amosa_ec2_sg" {
  name_prefix = "amosa-ec2-sg"
  vpc_id      = aws_vpc.amosa_vpc.id

  # SSH 접근 (22번 포트)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP 접근 (80번 포트)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS 접근 (443번 포트)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "amosa-ec2-sg"
    Environment = var.environment
  }
}

# EC2 키 페어 생성
resource "aws_key_pair" "amosa_key" {
  key_name   = "amosa-key"
  public_key = var.ec2_public_key
}

# EC2 인스턴스 생성
resource "aws_instance" "amosa_ec2" {
  ami                     = "ami-0c76973fbe0ee100c"  # Amazon Linux 2 AMI (ap-northeast-2)
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.amosa_key.key_name
  vpc_security_group_ids = [aws_security_group.amosa_ec2_sg.id]
  subnet_id              = aws_subnet.amosa_public_subnet.id

  # 사용자 데이터 스크립트 (기본 설정)
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              EOF

  tags = {
    Name        = "amosa-ec2"
    Environment = var.environment
  }
} 