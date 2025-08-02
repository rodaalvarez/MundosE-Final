# Configuración de Self-Hosted Runner para GitHub Actions

## Problema
GitHub Actions no puede acceder directamente a VMs en redes privadas (como 192.168.220.128). Para solucionarlo, usamos un **Self-Hosted Runner** que se ejecuta directamente en la VM.

## Pasos para configurar el Self-Hosted Runner

### 1. Preparar la VM

Ejecuta estos comandos en tu VM (192.168.220.128):

```bash
# Conectarse a la VM
ssh rodrigo@192.168.220.128

# Ejecutar el script de configuración
chmod +x scripts/setup-github-runner.sh
./scripts/setup-github-runner.sh
```

### 2. Configurar el Runner en GitHub

1. Ve a tu repositorio en GitHub
2. **Settings** → **Actions** → **Runners**
3. Click en **"New self-hosted runner"**
4. Selecciona **Linux** y **x64**
5. Copia el token de configuración (será algo como `AEWC2XQZ...`)

### 3. Instalar el Runner en la VM

Ejecuta estos comandos en la VM:

```bash
# Cambiar al usuario github-runner
sudo su - github-runner

# Ir al directorio del runner
cd /opt/github-runner

# Descargar el runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Extraer el archivo
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# Configurar el runner (reemplaza TU_TOKEN con el token real)
./config.sh --url https://github.com/TU_USUARIO/TU_REPO --token TU_TOKEN

# Instalar como servicio
sudo ./svc.sh install

# Iniciar el servicio
sudo ./svc.sh start
```

### 4. Verificar la instalación

1. En GitHub, ve a **Settings** → **Actions** → **Runners**
2. Deberías ver tu runner con estado **"Idle"**
3. El nombre será algo como `rodrigo-VMware-Virtual-Platform`

### 5. Configurar el directorio de la aplicación

Asegúrate de que el directorio `/opt/devops-project` existe y contiene tu `docker-compose.yml`:

```bash
# Crear el directorio si no existe
sudo mkdir -p /opt/devops-project

# Dar permisos al usuario github-runner
sudo chown github-runner:github-runner /opt/devops-project

# Copiar tu docker-compose.yml al directorio
sudo cp app/docker-compose.yml /opt/devops-project/
```

### 6. Probar el workflow

1. Haz un push a la rama `main`
2. Ve a **Actions** en GitHub
3. El job `deploy` debería ejecutarse en tu self-hosted runner

## Ventajas del Self-Hosted Runner

- ✅ Acceso directo a la VM sin problemas de red
- ✅ No necesita claves SSH
- ✅ Más rápido (no hay latencia de red)
- ✅ Más seguro (no expone la VM a internet)

## Troubleshooting

### El runner no aparece en GitHub
- Verifica que el token sea correcto
- Revisa los logs: `sudo journalctl -u actions.runner.*`

### Error de permisos
- Asegúrate de que el usuario `github-runner` esté en el grupo `docker`
- Verifica permisos en `/opt/devops-project`

### El runner no ejecuta jobs
- Verifica que esté en estado "Idle"
- Revisa los logs del runner: `sudo journalctl -u actions.runner.*`

## Comandos útiles

```bash
# Ver estado del servicio
sudo systemctl status actions.runner.*

# Ver logs del runner
sudo journalctl -u actions.runner.* -f

# Reiniciar el runner
sudo ./svc.sh restart

# Desinstalar el runner
sudo ./svc.sh stop
sudo ./svc.sh uninstall
``` 