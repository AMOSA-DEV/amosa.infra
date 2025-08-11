# AMOSA Infrastructure - Terraform

이 프로젝트는 AWS 프리티어 리소스를 사용하여 AMOSA 서비스의 인프라를 구성하는 Terraform 코드입니다.

## 📋 구성 리소스

- **VPC**: 10.0.0.0/16 CIDR 블록
- **EC2**: t2.micro 인스턴스 (Public IP 포함)
- **RDS**: db.t4g.micro MySQL 인스턴스 (Private 서브넷)
- **Route53**: amosa.co.kr 도메인 호스팅
- **IAM**: admin 권한을 가진 사용자 2명 (hermes, bird)
- **Lambda**: 2개 함수 (ECS 완료 알림, EC2 재시작 시 Public IP 할당)

## 📁 파일 구조

```
├── providers.tf      # Terraform 및 AWS Provider 설정
├── main.tf           # VPC 및 네트워킹 리소스
├── ec2.tf            # EC2 인스턴스 및 보안 그룹
├── rds.tf            # RDS 인스턴스 및 관련 리소스
├── route53.tf        # Route53 호스팅 존 및 DNS 레코드
├── iam.tf            # IAM 사용자 및 권한
├── lambda.tf         # Lambda 함수 및 실행 역할
├── variables.tf      # 입력 변수 정의
├── outputs.tf        # 출력 값 정의
└── terraform.tfvars.example  # 변수 설정 예시
```

## 🚀 배포 방법

### 1. 사전 준비

1. **AWS CLI 설정**
   ```bash
   aws configure
   ```

2. **SSH 키 페어 생성**
   ```bash
   ssh-keygen -t rsa -b 2048 -f ~/.ssh/amosa-key
   ```

3. **변수 파일 설정**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   `terraform.tfvars` 파일을 편집하여 필요한 값들을 설정하세요:
   - `ec2_public_key`: SSH 공개 키 내용
   - `db_password`: RDS 마스터 패스워드

### 2. Terraform 배포

1. **초기화**
   ```bash
   terraform init
   ```

2. **계획 확인**
   ```bash
   terraform plan
   ```

3. **배포 실행**
   ```bash
   terraform apply
   ```

### 3. 배포 후 작업

1. **Route53 네임서버 설정**
   - 배포 완료 후 출력되는 네임서버 정보를 도메인 등록업체에 설정
   
2. **EC2 접속 테스트**
   ```bash
   ssh -i ~/.ssh/amosa-key ec2-user@<EC2_PUBLIC_IP>
   ```

3. **RDS 접속 테스트** (EC2에서 실행)
   ```bash
   # MySQL 클라이언트 설치
   sudo yum install -y mysql
   
   # RDS 접속
   mysql -h <RDS_ENDPOINT> -P 3306 -u admin -p amosadb
   ```

## 🔧 주요 설정

### 보안
- RDS는 Private 서브넷에 배치되어 외부 접근 차단
- EC2에서만 RDS 접근 가능 (보안 그룹 규칙)
- RDS 삭제 보호 활성화
- 최종 스냅샷 생성 옵션 활성화

### 네트워킹
- Public 서브넷: 10.0.1.0/24 (EC2용)
- Private 서브넷 A: 10.0.2.0/24 (RDS용)
- Private 서브넷 C: 10.0.3.0/24 (RDS용)
- 가용 영역: ap-northeast-2a, ap-northeast-2c

### 백업
- RDS 자동 백업: 7일 보관
- 백업 시간: 03:00-04:00 (KST 12:00-13:00)
- 유지보수 시간: 일요일 04:00-05:00 (KST 13:00-14:00)

## 📊 출력 정보

배포 완료 후 다음 정보들이 출력됩니다:
- EC2 Public IP 및 DNS
- RDS 엔드포인트 및 포트
- Route53 네임서버 목록
- SSH 및 MySQL 연결 명령어

## ⚠️ 주의사항

1. **비용 관리**: 프리티어 한도 내에서 사용하도록 설정되어 있으나, 사용량을 주기적으로 확인하세요.

2. **보안**: 
   - `terraform.tfvars` 파일은 절대 버전 관리에 포함하지 마세요.
   - SSH 키와 RDS 패스워드는 안전하게 관리하세요.

3. **삭제 시 주의**:
   - RDS는 삭제 보호가 활성화되어 있습니다.
   - 완전 삭제를 원할 경우 먼저 삭제 보호를 비활성화해야 합니다.

## 🗑️ 리소스 삭제

```bash
terraform destroy
```

**주의**: RDS 삭제 보호로 인해 오류가 발생할 수 있습니다. 이 경우 AWS 콘솔에서 RDS 삭제 보호를 먼저 비활성화하거나, `rds.tf`에서 `deletion_protection = false`로 변경 후 다시 시도하세요.

## 📞 문의

인프라 관련 문의사항이 있으시면 DevOps 팀에 연락해주세요. 