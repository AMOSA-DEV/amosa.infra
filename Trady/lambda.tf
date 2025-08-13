# =============================================================================
# Lambda 함수 정의
# =============================================================================

# ZIP 파일 생성을 위한 archive_file 데이터 소스
data "archive_file" "request_slack_bot_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/amslambda-RequestSlackBotWhenECSComplete.py"
  output_path = "${path.module}/lambda_functions/amslambda-RequestSlackBotWhenECSComplete.zip"
}

data "archive_file" "allocate_public_ip_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/amslambda-AllocatePublicIPWhenRestartEC2.py"
  output_path = "${path.module}/lambda_functions/amslambda-AllocatePublicIPWhenRestartEC2.zip"
}

# Lambda 함수 1: RequestSlackBotWhenECSComplete
resource "aws_lambda_function" "request_slack_bot" {
  function_name    = "amslambda-RequestSlackBotWhenECSComplete"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "amslambda-RequestSlackBotWhenECSComplete.lambda_handler"
  runtime         = "python3.12"
  timeout         = 60

  # ZIP 파일 사용
  filename         = data.archive_file.request_slack_bot_zip.output_path
  source_code_hash = data.archive_file.request_slack_bot_zip.output_base64sha256

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_execution]

  tags = {
    Name        = "amslambda-RequestSlackBotWhenECSComplete"
    Environment = var.environment
  }
}

# Lambda 함수 2: AllocatePublicIPWhenRestartEC2
resource "aws_lambda_function" "allocate_public_ip" {
  function_name    = "amslambda-AllocatePublicIPWhenRestartEC2"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "amslambda-AllocatePublicIPWhenRestartEC2.lambda_handler"
  runtime         = "python3.12"
  timeout         = 60

  # ZIP 파일 사용
  filename         = data.archive_file.allocate_public_ip_zip.output_path
  source_code_hash = data.archive_file.allocate_public_ip_zip.output_base64sha256

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_ec2_policy
  ]

  tags = {
    Name        = "amslambda-AllocatePublicIPWhenRestartEC2"
    Environment = var.environment
  }
}

# =============================================================================
# EventBridge 규칙 및 트리거 설정
# =============================================================================

# EventBridge 규칙 1: EC2 Running 상태 변경 감지
resource "aws_cloudwatch_event_rule" "ec2_running_rule" {
  name        = "amsebrule-RunningEC2"
  description = "EC2 인스턴스가 running 상태로 변경될 때 트리거"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["running"]
    }
  })

  tags = {
    Name        = "amsebrule-RunningEC2"
    Environment = var.environment
  }
}

# EventBridge 규칙 2: ECS 배포 완료 감지
resource "aws_cloudwatch_event_rule" "ecs_deploy_complete_rule" {
  name        = "amsebrule-EcsDeployComplete"
  description = "ECS 서비스 배포가 완료될 때 트리거"

  event_pattern = jsonencode({
    source      = ["aws.ecs"]
    detail-type = ["ECS Deployment State Change"]
    detail = {
      eventName = ["SERVICE_DEPLOYMENT_COMPLETED"]
    }
  })

  tags = {
    Name        = "amsebrule-EcsDeployComplete"
    Environment = var.environment
  }
}

# Lambda 권한: EventBridge가 AllocatePublicIP Lambda 호출 허용
resource "aws_lambda_permission" "allow_eventbridge_allocate_ip" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.allocate_public_ip.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_running_rule.arn
}

# Lambda 권한: EventBridge가 RequestSlackBot Lambda 호출 허용
resource "aws_lambda_permission" "allow_eventbridge_slack_bot" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.request_slack_bot.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_deploy_complete_rule.arn
}

# EventBridge 타겟 1: EC2 Running 이벤트 -> AllocatePublicIP Lambda
resource "aws_cloudwatch_event_target" "ec2_running_target" {
  rule      = aws_cloudwatch_event_rule.ec2_running_rule.name
  target_id = "AllocatePublicIPTarget"
  arn       = aws_lambda_function.allocate_public_ip.arn
}

# EventBridge 타겟 2: ECS 배포 완료 이벤트 -> RequestSlackBot Lambda
resource "aws_cloudwatch_event_target" "ecs_deploy_complete_target" {
  rule      = aws_cloudwatch_event_rule.ecs_deploy_complete_rule.name
  target_id = "RequestSlackBotTarget"
  arn       = aws_lambda_function.request_slack_bot.arn
} 