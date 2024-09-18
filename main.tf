# Proveedor de AWS
provider "aws" {
  region = "us-east-1"  # Cambia esto según tu región
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"  # Rango de direcciones IP para la VPC
  enable_dns_support = true  # Habilitar soporte para DNS
  enable_dns_hostnames = true  # Habilitar nombres de host para las instancias

  tags = {
    Name = "vpc_pin"  # Nombre de la VPC
  }
}

# Subnet: Define una subred dentro de la VPC que se utilizará para lanzar la instancia EC2.
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id  # ID de la VPC donde se creará la subred
  cidr_block              = "10.0.1.0/24"  # Rango de IPs para la subred
  availability_zone       = "us-east-1a"  # Zona de disponibilidad dentro de la región
  map_public_ip_on_launch = true  # Asignar automáticamente una IP pública
}

# Grupo de seguridad
resource "aws_security_group" "sg" {
  name        = "allow_http_ssh"  # Nombre del grupo de seguridad
  description = "Allow HTTP and SSH traffic"  # Descripción
  vpc_id      = aws_vpc.vpc.id  # ID de la VPC donde se creará el grupo de seguridad

  ingress {
    from_port   = 22  # Puerto de origen
    to_port     = 22  # Puerto de destino
    protocol    = "tcp"  # Protocolo TCP
    cidr_blocks = ["0.0.0.0/0"]  # Permitir tráfico desde cualquier dirección IP
  }

  ingress {
    from_port   = 80  # Puerto de origen
    to_port     = 80  # Puerto de destino
    protocol    = "tcp"  # Protocolo TCP
    cidr_blocks = ["0.0.0.0/0"]  # Permitir tráfico desde cualquier dirección IP
  }

  egress {
    from_port   = 0  # Desde cualquier puerto
    to_port     = 0  # Hacia cualquier puerto
    protocol    = "-1"  # Permitir cualquier protocolo
    cidr_blocks = ["0.0.0.0/0"]  # Hacia cualquier dirección IP
  }
}

# Instancia EC2
resource "aws_instance" "webserver" {
  ami                         = "ami-00c39f71452c08778"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.subnet.id
  user_data                   = "${file("create_apache.sh")}"

  key_name = "ssh-key-pin"

  depends_on = [aws_subnet.subnet, aws_security_group.sg]

  tags = {
    Name = "webserver"
  }
}
