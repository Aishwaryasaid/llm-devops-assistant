resource "aws_security_group" "llm_sg" {
  name        = "llm-devops-sg"
  description = "Allow SSH and app traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "llm-devops-sg"
  }
}

resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.llm_sg.id]
  key_name               = var.key_name
 root_block_device {
  volume_size = 100
}


  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    mkdir -p /app
    cat > /app/docker-compose.yml <<'COMPOSE'
    services:
      ollama:
        image: ollama/ollama
        ports:
          - "11434:11434"
        volumes:
          - ollama_data:/root/.ollama

      app:
        image: ash392/llm-devops-assistant:latest
        ports:
          - "8000:8000"
        environment:
          - OLLAMA_HOST=http://ollama:11434
        depends_on:
          - ollama

    volumes:
      ollama_data:
    COMPOSE

    cd /app && docker-compose up -d
  EOF

  tags = {
    Name = "llm-devops-assistant"
  }
}
