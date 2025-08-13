# VPC 정보
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.amosa_vpc.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR 블록"
  value       = aws_vpc.amosa_vpc.cidr_block
}

# 서브넷 정보
output "public_subnet_id" {
  description = "Public 서브넷 ID"
  value       = aws_subnet.amosa_public_subnet.id
}

output "private_subnet_a_id" {
  description = "Private 서브넷 A ID"
  value       = aws_subnet.amosa_private_subnet_a.id
}

output "private_subnet_c_id" {
  description = "Private 서브넷 C ID"
  value       = aws_subnet.amosa_private_subnet_c.id
}

# EC2 정보
output "ec2_instance_id" {
  description = "EC2 인스턴스 ID"
  value       = aws_instance.amosa_ec2.id
}

output "ec2_public_ip" {
  description = "EC2 Public IP 주소"
  value       = aws_instance.amosa_ec2.public_ip
}

output "ec2_public_dns" {
  description = "EC2 Public DNS"
  value       = aws_instance.amosa_ec2.public_dns
}

output "ec2_private_ip" {
  description = "EC2 Private IP 주소"
  value       = aws_instance.amosa_ec2.private_ip
}

# RDS 정보
output "rds_endpoint" {
  description = "RDS 엔드포인트"
  value       = aws_db_instance.amosa_db.endpoint
}

output "rds_port" {
  description = "RDS 포트"
  value       = aws_db_instance.amosa_db.port
}

output "rds_database_name" {
  description = "RDS 데이터베이스 이름"
  value       = aws_db_instance.amosa_db.db_name
}

# Route53 정보
output "route53_zone_id" {
  description = "Route53 호스팅 존 ID"
  value       = aws_route53_zone.amosa_zone.zone_id
}

output "route53_name_servers" {
  description = "Route53 네임서버 목록"
  value       = aws_route53_zone.amosa_zone.name_servers
}

output "www_domain_name" {
  description = "www 도메인 이름"
  value       = aws_route53_record.amosa_www.name
}

# IAM 사용자 정보
output "iam_user_hermes_arn" {
  description = "IAM 사용자 hermes ARN"
  value       = aws_iam_user.hermes.arn
}

output "iam_user_bird_arn" {
  description = "IAM 사용자 bird ARN"
  value       = aws_iam_user.bird.arn
}

# Lambda 함수 정보
output "lambda_request_slack_bot_arn" {
  description = "Lambda 함수 RequestSlackBot ARN"
  value       = aws_lambda_function.request_slack_bot.arn
}

output "lambda_allocate_public_ip_arn" {
  description = "Lambda 함수 AllocatePublicIP ARN"
  value       = aws_lambda_function.allocate_public_ip.arn
}

# 보안 그룹 정보
output "ec2_security_group_id" {
  description = "EC2 보안 그룹 ID"
  value       = aws_security_group.amosa_ec2_sg.id
}

output "rds_security_group_id" {
  description = "RDS 보안 그룹 ID"
  value       = aws_security_group.amosa_rds_sg.id
}

# 연결 정보 (참고용)
output "ssh_connection" {
  description = "EC2 SSH 연결 명령어"
  value       = "ssh -i ~/.ssh/amosa-key.pem ec2-user@${aws_instance.amosa_ec2.public_ip}"
}

output "postgresql_connection" {
  description = "RDS PostgreSQL 연결 정보 (EC2에서 실행)"
  value       = "psql -h ${aws_db_instance.amosa_db.endpoint} -p ${aws_db_instance.amosa_db.port} -U ${var.db_username} -d ${var.db_name}"
  sensitive   = false
} 