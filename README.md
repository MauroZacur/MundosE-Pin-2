# PIN 2 Grupo 13

Este proyecto despliega infraestructura en **AWS** utilizando **Terraform** y **GitHub Actions**. A continuación, se describen los pasos realizados para configurar y desplegar un servidor Apache en una instancia EC2, así como los archivos `apply` y `destroy` para gestionar la infraestructura.

---

## 1. Configuración Inicial

1. Configuramos **Terraform** para desplegar infraestructura en AWS. También configuramos **AWS CLI** con nuestras credenciales.
2. Cargamos las credenciales de AWS como secretos en **GitHub** para utilizarlas en los workflows de Terraform `apply` y `destroy`.
3. En el archivo `create_apache.sh`, agregamos el comando `sudo yum update -y` para asegurarnos de que todos los paquetes estén actualizados. Luego, instalamos e iniciamos **Apache** y agregamos un mensaje de bienvenida para comprobar que el servidor funcione correctamente.

---

## 2. Script `create_apache.sh`

El script de inicialización de la instancia EC2 para instalar y configurar Apache.

```bash
#!/bin/bash
# Actualizar el sistema y asegurar los paquetes
sudo yum update -y

# Instalar Apache
sudo yum install -y httpd

# Iniciar y habilitar Apache para que se inicie en el arranque
sudo systemctl start httpd
sudo systemctl enable httpd

# Añadir mensaje de bienvenida
echo "<h1>Grupo 13</h1>" | sudo tee /var/www/html/index.html

```
## YAML
Apply:
```yaml

name: Terraform Apply
on:
  workflow_dispatch:

jobs:
  terraform_apply:
    runs-on: ubuntu-latest
    
    steps:
    #  Clona el repositorio donde se encuentran los archivos de Terraform.
    - name: Check out the repository
      uses: actions/checkout@v3

    # Configura Terraform usando la acción oficial de HashiCorp.
    - name: Set up Terraform
      uses: hashicorp/setup-terraform@v3

    #  Verifica qué versión de Terraform se está utilizando en el entorno.
    - name: Verify Terraform version
      run: terraform --version

    # Inicializa Terraform, descargando los proveedores y configurando el backend.
    # Se usan las credenciales de AWS almacenadas en los secretos para autenticar con el proveedor.
    - name: Terraform Init
      run: terraform init
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: ${{ secrets.AWS_REGION }}

    #  Valida la configuración de Terraform para asegurarse de que todo esté bien estructurado y sin errores de sintaxis.
    - name: Terraform Validation
      run: terraform validate

    # Genera un plan para verificar los cambios que se van a aplicar en la infraestructura.

    - name: Terraform Plan
      run: terraform plan
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: ${{ secrets.AWS_REGION }}


    # Aplica los cambios en la infraestructura de AWS de forma automática sin pedir confirmación adicional (-auto-approve). 
    - name: Terraform Apply
      run: terraform apply -auto-approve
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: ${{ secrets.AWS_REGION }}
```


Destroy:

```yaml
name: Terraform Destroy

on:
  workflow_dispatch: # Permite iniciar el flujo manualmente desde la interfaz de GitHub Actions

jobs:
  terraform_destroy:
    name: "Terraform Destroy - Grupo 13" # Nombre del trabajo que aparece en la interfaz de GitHub Actions
    runs-on: ubuntu-latest # Define el sistema operativo en el que se ejecutará el trabajo
    
    steps:
      - name: Checkout
        uses: actions/checkout@v2 # Accion de GitHub para clonar el repositorio en el entorno virtual

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1 # Utiliza la acción oficial de HashiCorp para instalar Terraform en el entorno de ejecución.


      - name: Terraform Init
        id: init
        run: terraform init # Ejecuta el comando `terraform init`, que inicializa el backend y descarga los proveedores necesarios.
        env:
            AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
            AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
            AWS_REGION: ${{ secrets.AWS_REGION }}
            

      - name: Terraform Refresh
        run: terraform refresh
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}



      - name: Terraform Destroy
        id: destroy
        run: terraform destroy -auto-approve # Ejecuta el comando `terraform destroy` con el flag `-auto-approve`, lo que elimina los recursos sin solicitar confirmación manual. 
        env:
            AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
            AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
            AWS_REGION: ${{ secrets.AWS_REGION }}
```
