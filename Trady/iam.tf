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