# RDS용 보안 그룹
resource "aws_security_group" "amosa_rds_sg" {
  name_prefix = "amosa-rds-sg"
  vpc_id      = aws_vpc.amosa_vpc.id

  # EC2에서만 PostgreSQL 접근 허용 (5432번 포트)
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.amosa_ec2_sg.id]
  }

  tags = {
    Name        = "amosa-rds-sg"
    Environment = var.environment
  }
}

# RDS 서브넷 그룹 생성
resource "aws_db_subnet_group" "amosa_db_subnet_group" {
  name       = "amosa-db-subnet-group"
  subnet_ids = [aws_subnet.amosa_private_subnet_a.id, aws_subnet.amosa_private_subnet_c.id]

  tags = {
    Name        = "amosa-db-subnet-group"
    Environment = var.environment
  }
}

# RDS 인스턴스 생성
resource "aws_db_instance" "amosa_db" {
  identifier             = "amosa-db"
  allocated_storage      = 20
  max_allocated_storage  = 100
  storage_type          = "gp2"
  engine                = "postgres"
  engine_version        = "15.7"
  instance_class        = "db.t4g.micro"
  
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.amosa_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.amosa_db_subnet_group.name
  
  # Public 접근 비활성화
  publicly_accessible = false
  
  # 백업 설정
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # 삭제 보호 활성화 및 스냅샷 설정
  deletion_protection       = true   # 삭제 보호 활성화
  skip_final_snapshot      = false   # 최종 스냅샷 생성
  final_snapshot_identifier = "amosa-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  delete_automated_backups = false

  # final_snapshot_identifier의 변경사항을 무시
  lifecycle {
    ignore_changes = [
      final_snapshot_identifier
    ]
  }

  tags = {
    Name        = "amosa-db"
    Environment = var.environment
  }
} 