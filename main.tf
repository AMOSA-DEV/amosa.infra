# VPC 생성
resource "aws_vpc" "amosa_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "amosa-vpc"
    Environment = var.environment
  }
}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "amosa_igw" {
  vpc_id = aws_vpc.amosa_vpc.id

  tags = {
    Name        = "amosa-igw"
    Environment = var.environment
  }
}

# Public 서브넷 생성 (EC2용)
resource "aws_subnet" "amosa_public_subnet" {
  vpc_id                  = aws_vpc.amosa_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "amosa-public-subnet"
    Environment = var.environment
  }
}

# Private 서브넷 생성 (RDS용) - AZ a
resource "aws_subnet" "amosa_private_subnet_a" {
  vpc_id            = aws_vpc.amosa_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name        = "amosa-private-subnet-a"
    Environment = var.environment
  }
}

# Private 서브넷 생성 (RDS용) - AZ c (DB 서브넷 그룹을 위해 최소 2개 필요)
resource "aws_subnet" "amosa_private_subnet_c" {
  vpc_id            = aws_vpc.amosa_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name        = "amosa-private-subnet-c"
    Environment = var.environment
  }
}

# 라우팅 테이블 생성 (Public용)
resource "aws_route_table" "amosa_public_rt" {
  vpc_id = aws_vpc.amosa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.amosa_igw.id
  }

  tags = {
    Name        = "amosa-public-rt"
    Environment = var.environment
  }
}

# Public 서브넷과 라우팅 테이블 연결
resource "aws_route_table_association" "amosa_public_rta" {
  subnet_id      = aws_subnet.amosa_public_subnet.id
  route_table_id = aws_route_table.amosa_public_rt.id
} 