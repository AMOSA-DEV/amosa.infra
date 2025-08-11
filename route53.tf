# Route53 호스팅 존 생성
resource "aws_route53_zone" "amosa_zone" {
  name = var.domain_name

  tags = {
    Name        = "amosa-zone"
    Environment = var.environment
  }
}

# Route53 A 레코드 (www.amosa.co.kr -> EC2)
resource "aws_route53_record" "amosa_www" {
  zone_id = aws_route53_zone.amosa_zone.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.amosa_ec2.public_ip]
} 