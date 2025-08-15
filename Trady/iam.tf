# IAM 사용자 생성 - hermes
resource "aws_iam_user" "hermes" {
  name = "hermes"
  path = "/"

  tags = {
    Name        = "hermes"
    Environment = var.environment
  }
}

# IAM 사용자 생성 - bird
resource "aws_iam_user" "bird" {
  name = "bird"
  path = "/"

  tags = {
    Name        = "bird"
    Environment = var.environment
  }
}

# IAM 사용자에 Administrator 권한 부여 - hermes
resource "aws_iam_user_policy_attachment" "hermes_admin" {
  user       = aws_iam_user.hermes.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# IAM 사용자에 Administrator 권한 부여 - bird
resource "aws_iam_user_policy_attachment" "bird_admin" {
  user       = aws_iam_user.bird.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# =============================================================================
# Lambda 관련 IAM 리소스
# =============================================================================

# Lambda 실행 역할
resource "aws_iam_role" "lambda_execution_role" {
  name = "amsrole-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "amsrole-lambda"
    Environment = var.environment
  }
}

# Lambda 기본 실행 정책 연결
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# EC2 관리 권한 (AllocatePublicIP Lambda용)
resource "aws_iam_role_policy" "lambda_ec2_policy" {
  name = "amspolicy-lambda"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress",
          "ec2:DescribeAddresses",
          "ec2:DescribeNetworkInterfaces"
        ]
        Resource = "*"
      }
    ]
  })
}

# =============================================================================
# EC2 SSM 접속을 위한 IAM 리소스
# =============================================================================

# EC2용 SSM 접속 역할
resource "aws_iam_role" "ec2_ssm_role" {
  name = "amsrole-ec2-ssm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "amsrole-ec2-ssm"
    Environment = var.environment
  }
}

# SSM 관리 인스턴스 코어 정책 연결
resource "aws_iam_role_policy_attachment" "ec2_ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 인스턴스 프로파일 생성
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "amsprofile-ec2-ssm"
  role = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name        = "amsprofile-ec2-ssm"
    Environment = var.environment
  }
} 