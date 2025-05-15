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

              # Add dev SSH keys
              mkdir -p /home/ec2-user/.ssh
              chmod 700 /home/ec2-user/.ssh
              touch /home/ec2-user/.ssh/authorized_keys
              chmod 600 /home/ec2-user/.ssh/authorized_keys
              chown -R ec2-user:ec2-user /home/ec2-user/.ssh

              ${join("\n", formatlist("echo '%s' >> /home/ec2-user/.ssh/authorized_keys", var.dev_ssh_keys))}

              sudo yum update -y
              sudo amazon-linux-extras enable nginx1
              sudo yum install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "<h1>Hello, World - with SSH!</h1>" | sudo tee /usr/share/nginx/html/index.html
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


# 🔍 Look up the default VPC in this region (ap-southeast-1)
data "aws_vpc" "default" {
  default = true
}

# 🔍 Get all subnets in the default VPC.
# We'll assume they're public, since AWS marks default subnets as public by default.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 🔍 Look for your ACM certificate (must already be validated and in "ISSUED" status)
data "aws_acm_certificate" "stackslurper" {
  domain      = "stackslurper.xyz" # your domain name
  statuses    = ["ISSUED"]         # only use active certificates
  most_recent = true               # if there are multiple, pick the latest
}

# 🔐 Create a Security Group for the ALB
# Allows inbound HTTP (80) and HTTPS (443) from the world
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP and HTTPS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80 # HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow all IPs
  }

  ingress {
    from_port   = 443 # HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0 # allow all outbound traffic
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🌐 Create the Application Load Balancer
resource "aws_lb" "app" {
  name               = "stackslurper-alb"
  internal           = false         # public ALB (internet-facing)
  load_balancer_type = "application" # layer 7 (HTTP/HTTPS)
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb_sg.id]
}

# 🧑‍🍳 Target Group — where the ALB forwards traffic to
# In this case, your EC2 instance on port 80
resource "aws_lb_target_group" "backend" {
  name     = "stackslurper-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path     = "/" # ping this path to check if healthy
    protocol = "HTTP"
    matcher  = "200" # expect a 200 OK
  }
}

# 🔗 Attach your EC2 instance to the Target Group
# This connects your instance to the ALB
resource "aws_lb_target_group_attachment" "backend_instance" {
  target_group_arn = aws_lb_target_group.backend.arn
  target_id        = aws_instance.backend_server.id
  port             = 80
}

# 🔒 HTTPS Listener (port 443) using ACM cert
# This is where your HTTPS traffic is terminated
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.stackslurper.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# ↪️ Optional: HTTP Listener (port 80) to redirect to HTTPS
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301" # permanent redirect
    }
  }
}


resource "aws_route53_record" "root_a_record" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "stackslurper.xyz"
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}
