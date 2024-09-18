#!/bin/bash
# Actualizar el sistema y asegurar los paquetes
sudo yum update -y

# Instalar Apache
sudo yum install -y httpd

# Iniciar y habilitar Apache para que se inicie en el arranque
sudo systemctl start httpd
sudo systemctl enable httpd

# Crear una página de inicio sencilla
echo "<h1>Bienvenido a apache</h1>" | sudo tee /var/www/html/index.html
