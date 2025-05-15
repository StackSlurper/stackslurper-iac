resource "aws_instance" "backend_server" {
  ami             = "ami-0a5fa1b3c2f9851fc"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.backend_security_group.name]
  tags = {
    Name = "backend-server"
  }

  # basic Hello World server
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras enable nginx1
              sudo yum install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "<h1>Hello, World - test changes!</h1>" | sudo tee /usr/share/nginx/html/index.html
              sudo systemctl restart nginx
              EOF
}

resource "aws_security_group" "backend_security_group" {
  name        = "backend-security-group"
  description = "Firewall rules for the backend server"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow any outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_zone" "primary" {
  name = "stackslurper.xyz"
}

resource "aws_route53_record" "root_a_record" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "stackslurper.xyz"
  type    = "A"
  ttl     = 300
  records = [aws_instance.backend_server.public_ip]
}

resource "aws_route53_record" "www_cname" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.stackslurper.xyz"
  type    = "CNAME"
  ttl     = 300
  records = ["stackslurper.xyz"]
}

resource "aws_acm_certificate" "cert" {
  # Your domain name — SSL will protect this
  domain_name = "stackslurper.xyz"

  # ACM will ask you to verify ownership via a DNS record
  validation_method = "DNS"

  # Optional: also protect www.stackslurper.xyz
  subject_alternative_names = ["www.stackslurper.xyz"]

  # This ensures Terraform creates the new cert before deleting an old one (helps with updates)
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  # This loops through each domain ACM asks us to verify
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name  # The name of the DNS record ACM wants
      record = dvo.resource_record_value # The value ACM wants in that record
      type   = dvo.resource_record_type  # Usually "CNAME"
    }
  }

  # This is what actually creates the validation record in Route 53
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  zone_id = aws_route53_zone.primary.zone_id
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "cert" {
  # Which certificate to validate (from step 1)
  certificate_arn = aws_acm_certificate.cert.arn

  # Which DNS records we just created for validation
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}
