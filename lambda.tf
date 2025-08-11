# Lambda 실행 역할
resource "aws_iam_role" "lambda_execution_role" {
  name = "amosa-lambda-execution-role"

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
    Name        = "amosa-lambda-execution-role"
    Environment = var.environment
  }
}

# Lambda 기본 실행 정책 연결
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda 함수 1: RequestSlackBotWhenECSComplete
resource "aws_lambda_function" "request_slack_bot" {
  filename         = "request_slack_bot.zip"
  function_name    = "amslambda-RequestSlackBotWhenECSComplete"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 60

  # 임시 코드 파일 생성이 필요 (별도로 생성 예정)
  depends_on = [aws_iam_role_policy_attachment.lambda_basic_execution]

  tags = {
    Name        = "amslambda-RequestSlackBotWhenECSComplete"
    Environment = var.environment
  }
}

# Lambda 함수 2: AllocatePublicIPWhenRestartEC2
resource "aws_lambda_function" "allocate_public_ip" {
  filename         = "allocate_public_ip.zip"
  function_name    = "amslambda-AllocatePublicIPWhenRestartEC2"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 60

  # 임시 코드 파일 생성이 필요 (별도로 생성 예정)
  depends_on = [aws_iam_role_policy_attachment.lambda_basic_execution]

  tags = {
    Name        = "amslambda-AllocatePublicIPWhenRestartEC2"
    Environment = var.environment
  }
} 