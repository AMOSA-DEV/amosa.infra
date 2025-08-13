# terraform.tfvars 예시 파일
# 실제 배포 시 이 파일을 terraform.tfvars로 복사하고 값을 설정하세요.
# 보안상 terraform.tfvars 파일은 .gitignore에 추가하여 버전 관리에서 제외하세요.

# AWS 리전 (기본값: ap-northeast-2)
aws_region = "ap-northeast-2"

# 환경 설정 (기본값: prd)
environment = "prd"

# VPC CIDR 블록 (기본값: 10.0.0.0/16)
vpc_cidr = "10.0.0.0/16"

# EC2 SSH 접근용 공개 키 (필수)
# SSH 키 페어를 생성한 후 공개 키 내용을 여기에 입력하세요.
# 예: ssh-keygen -t rsa -b 2048 -f ~/.ssh/amosa-key
# 그 후 ~/.ssh/amosa-key.pub 파일의 내용을 복사하여 아래에 입력
ec2_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqAEQ/Gd6/zy0DeMvqEP8/4HQjqYZpKFUjBcWl4OKnqyad2Pc7UFxA1Dwn5GXrgOSRMPP7D5bxhZMrEKM8KM5mjYuDEp2sEVAFpSTEGzjXuFnKD5qeb/KH5NsY6VU7HRK64tv3cHFukSuS2ThtTVaTG7NnZDcttR6KAMKLHKzRg1+jOfuGXBzk7gPh+DhravBL7NjJDq9aCQxkWoKhkFEEX+3jNM+iF0pWDtbzLGNmXI9wNUEvhpv85Cy4Kb7S4bkMexEmQoCj5vM7dlREEsqRDwT5cRK0AVjPs7nEntQ2NSMhaEnFwP8HAHmQi3ePfW2t3+JRjMzciSj0hn4fxnr/"

# RDS 데이터베이스 이름 (기본값: amosa_prd)
db_name = "amosa_prd"

# RDS 마스터 사용자명 (기본값: amsadmin)
db_username = "amsadmin"

# RDS 마스터 패스워드 (필수, 최소 8자 이상)
db_password = "amsroqkf"

# Route53 도메인 이름 (기본값: amosa.co.kr)
domain_name = "amosa.co.kr" 