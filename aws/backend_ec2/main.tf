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
