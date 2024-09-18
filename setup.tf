# Crear la tabla de rutas por defecto para permitir tráfico a Internet
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.vpc.id  # Cambiado a aws_vpc.vpc.id
}

# Obtener la tabla de rutas principal de la VPC
data "aws_route_table" "main_route_table" {
  filter {
    name   = "association.main"
    values = ["true"]
  }
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]  # Cambiado a aws_vpc.vpc.id
  }
}

# Crear la tabla de rutas por defecto para permitir tráfico a Internet
resource "aws_default_route_table" "internet_route" {
  default_route_table_id = data.aws_route_table.main_route_table.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "Terraform-RouteTable"
  }
}

# Crear un grupo de seguridad para permitir tráfico en TCP/80 (HTTP) y TCP/22 (SSH)
resource "aws_security_group" "my_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.vpc.id  # Cambiado a aws_vpc.vpc.id

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
