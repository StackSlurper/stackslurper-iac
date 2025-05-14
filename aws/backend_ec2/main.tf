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

resource "aws_route53_record" "mx1" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = ""
  type    = "MX"
  ttl     = 300
  records = [
    "10 mx1.privateemail.com",
    "10 mx2.privateemail.com",
  ]
}

resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "@"
  type    = "TXT"
  ttl     = 300
  records = [
    "v=spf1 include:spf.privateemail.com ~all"
  ]
}

resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = 300
  records = [
    "v=DMARC1; p=none; rua=mailto:you@stackslurper.xyz"
  ]
}

resource "aws_route53_record" "private_email_dkim" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "default._domainkey"
  type    = "TXT"
  ttl     = 300
  records = [
    // public key for DKIM, no need to encrypt
    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxzVluVaRDrru+dQwkaV27+wmn9EuF7L\"\"cAOrMnIyORookIkPhxKGAJqtEcEorpXFLKB9/pVenGvp76Qv0P/m8Fwy384axkUPAsAJqwJp96GttVxFjXpVAcYmW1ik\"\"c5s3AqaOXpTDZn4GGqzacOZsng3KAyOukcbQzDiuHGsv7UE6+V8xuB6ATMwHym5NHUaYXXqHTsVb66kL6NU8ij4EjcY0b/\"\"AG7fhvy6kbgDKQsfRlMCo+iaXNbBfnxf4XMx/M+s4NCraSTbNq5MWuhfgxkJiB1dioDM1B/W5InL9uisIiAuOW9OYZk4++\"\"cQrAjEJJ0e2dC6d1wyEk2ScYglLKHuwIDAQAB"
  ]
}
