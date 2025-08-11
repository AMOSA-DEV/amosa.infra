# AWS 리전 설정
variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"  # 서울 리전
}

# 환경 설정
variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# VPC CIDR 블록
variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

# EC2 관련 변수
variable "ec2_public_key" {
  description = "EC2 인스턴스 접근용 공개 키"
  type        = string
  # 실제 배포 시 terraform.tfvars 파일에서 설정하거나 환경 변수로 전달
}

# RDS 관련 변수
variable "db_name" {
  description = "RDS 데이터베이스 이름"
  type        = string
  default     = "amosadb"
}

variable "db_username" {
  description = "RDS 마스터 사용자명"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS 마스터 패스워드"
  type        = string
  sensitive   = true
  # 실제 배포 시 terraform.tfvars 파일에서 설정하거나 환경 변수로 전달
}

# Route53 도메인 설정
variable "domain_name" {
  description = "Route53에서 관리할 도메인 이름"
  type        = string
  default     = "amosa.co.kr"
} 