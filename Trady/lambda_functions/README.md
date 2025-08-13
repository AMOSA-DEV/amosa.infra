# Lambda 함수 배포 가이드

이 디렉토리에는 Terraform으로 배포할 Lambda 함수들과 EventBridge 트리거가 포함되어 있습니다.

## 포함된 Lambda 함수들

### 1. amslambda-RequestSlackBotWhenECSComplete.py
- **목적**: ECS 배포 완료 시 Slack 알림 전송
- **트리거**: EventBridge (`amsebrule-EcsDeployComplete`)
- **이벤트 패턴**:
  ```json
  {
    "source": ["aws.ecs"],
    "detail-type": ["ECS Deployment State Change"],
    "detail": {
      "eventName": ["SERVICE_DEPLOYMENT_COMPLETED"]
    }
  }
  ```
- **핸들러**: `lambda_handler`
- **런타임**: Python 3.9

### 2. amslambda-AllocatePublicIPWhenRestartEC2.py  
- **목적**: EC2 재시작 시 탄력적 IP 재할당
- **트리거**: EventBridge (`amsebrule-RunningEC2`)
- **이벤트 패턴**:
  ```json
  {
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"],
    "detail": {
      "state": ["running"]
    }
  }
  ```
- **핸들러**: `lambda_handler`
- **런타임**: Python 3.9
- **필요 권한**: EC2 관리 권한

## EventBridge 규칙

### amsebrule-RunningEC2
- EC2 인스턴스가 `running` 상태로 변경될 때 트리거
- 타겟: `amslambda-AllocatePublicIPWhenRestartEC2`

### amsebrule-EcsDeployComplete
- ECS 서비스 배포가 완료될 때 트리거
- 타겟: `amslambda-RequestSlackBotWhenECSComplete`

## 배포 방법

### 1. Terraform 초기화
```bash
cd Trady
terraform init
```

### 2. 배포 계획 확인
```bash
terraform plan
```

### 3. 배포 실행
```bash
terraform apply
```

## 자동 배포 프로세스

Terraform이 다음 과정을 자동으로 수행합니다:

1. **ZIP 파일 생성**: `archive_file` 데이터 소스가 각 Python 파일을 ZIP으로 패키징
2. **IAM 역할 생성**: Lambda 실행에 필요한 기본 권한 및 EC2 관리 권한 설정
3. **Lambda 함수 배포**: ZIP 파일을 사용하여 AWS Lambda 함수 생성
4. **EventBridge 규칙 생성**: 각 Lambda 함수에 대한 트리거 이벤트 패턴 설정
5. **Lambda 권한 설정**: EventBridge가 Lambda 함수를 호출할 수 있는 권한 부여
6. **EventBridge 타겟 연결**: 이벤트 규칙과 Lambda 함수 연결
7. **자동 업데이트**: 소스 코드 변경 시 `source_code_hash`를 통해 자동 재배포

## 파일 구조

```
lambda_functions/
├── amslambda-RequestSlackBotWhenECSComplete.py  # Slack 알림 Lambda
├── amslambda-AllocatePublicIPWhenRestartEC2.py  # IP 할당 Lambda
├── request_slack_bot.zip                        # 생성될 ZIP (자동)
├── allocate_public_ip.zip                       # 생성될 ZIP (자동)
└── README.md                                    # 이 파일
```

## 트리거 테스트

### EC2 재시작 테스트
```bash
# EC2 인스턴스 재시작 (AWS CLI)
aws ec2 reboot-instances --instance-ids i-1234567890abcdef0

# 또는 AWS 콘솔에서 EC2 인스턴스 재시작
```

### ECS 배포 테스트
```bash
# ECS 서비스 강제 배포 (AWS CLI)
aws ecs update-service --cluster cluster-name --service service-name --force-new-deployment
```

## 참고사항

- ZIP 파일들은 Terraform 실행 시 자동으로 생성됩니다
- 소스 코드 변경 시 `terraform apply`만 실행하면 자동으로 업데이트됩니다
- EventBridge 규칙들도 자동으로 생성되고 Lambda 함수와 연결됩니다
- Slack Webhook URL은 두 Lambda 함수에서 하드코딩되어 있으므로 필요시 수정하세요
- EC2 탄력적 IP 할당 ID도 하드코딩되어 있으므로 환경에 맞게 수정하세요

## 모니터링

### CloudWatch 로그
- Lambda 함수 실행 로그는 CloudWatch Logs에서 확인 가능
- 로그 그룹: `/aws/lambda/amslambda-{함수명}`

### EventBridge 메트릭
- EventBridge 규칙의 실행 횟수와 성공/실패 여부를 CloudWatch 메트릭에서 확인 가능 