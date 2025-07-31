#!/bin/bash

# Script de Configuración Inicial para VM Ubuntu
# Este script configura la VM para el deployment de la aplicación DevOps

set -e

echo "🔧 Configurando VM Ubuntu para DevOps..."

# Función para logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Actualizar el sistema
log "📦 Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar dependencias básicas
log "📦 Instalando dependencias básicas..."
sudo apt install -y \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Instalar Docker
log "🐳 Instalando Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    log "✅ Docker instalado correctamente"
else
    log "✅ Docker ya está instalado"
fi

# Instalar Docker Compose
log "🐳 Instalando Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    log "✅ Docker Compose instalado correctamente"
else
    log "✅ Docker Compose ya está instalado"
fi

# Configurar firewall
log "🔥 Configurando firewall..."
sudo ufw allow ssh
sudo ufw allow 3000/tcp
sudo ufw --force enable

# Crear directorio del proyecto
log "📁 Creando directorio del proyecto..."
sudo mkdir -p /opt/devops-project
sudo chown $USER:$USER /opt/devops-project

# Configurar variables de entorno
log "⚙️ Configurando variables de entorno..."
cat >> ~/.bashrc << EOF

# DevOps Project Environment Variables
export DEVOPS_PROJECT_HOME=/opt/devops-project
export DOCKER_HOST=unix:///var/run/docker.sock
EOF

# Configurar alias útiles
log "🔧 Configurando alias útiles..."
cat >> ~/.bashrc << EOF

# DevOps Project Aliases
alias dps='docker ps'
alias dlogs='docker logs'
alias dcompose='docker-compose'
alias devops-status='cd /opt/devops-project && docker-compose ps'
alias devops-logs='cd /opt/devops-project && docker-compose logs -f'
alias devops-restart='cd /opt/devops-project && docker-compose restart'
EOF

# Configurar logrotate para Docker
log "📝 Configurando logrotate para Docker..."
sudo tee /etc/logrotate.d/docker > /dev/null << EOF
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    size=1M
    missingok
    delaycompress
    copytruncate
}
EOF

# Configurar monitoreo básico
log "📊 Configurando monitoreo básico..."
sudo apt install -y htop

# Crear script de monitoreo
cat > /opt/devops-project/monitor.sh << 'EOF'
#!/bin/bash
echo "=== Estado del Sistema ==="
echo "Uso de CPU y Memoria:"
htop -t -d 1 -n 1

echo -e "\n=== Contenedores Docker ==="
docker ps

echo -e "\n=== Uso de Disco ==="
df -h

echo -e "\n=== Estado de la Aplicación ==="
if [ -f "/opt/devops-project/docker-compose.yml" ]; then
    cd /opt/devops-project
    docker-compose ps
else
    echo "Aplicación no desplegada aún"
fi
EOF

chmod +x /opt/devops-project/monitor.sh

# Configurar crontab para limpieza automática
log "⏰ Configurando limpieza automática..."
(crontab -l 2>/dev/null; echo "0 2 * * * docker system prune -f") | crontab -

# Configurar SSH para GitHub Actions
log "🔑 Configurando SSH para GitHub Actions..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "devops-vm" -f ~/.ssh/id_rsa -N ""
    log "✅ Clave SSH generada"
    echo "🔑 Clave pública SSH (agregar a GitHub Actions):"
    cat ~/.ssh/id_rsa.pub
else
    log "✅ Clave SSH ya existe"
fi

# Mostrar información final
log "📋 Información de configuración:"
echo "   - Usuario: $USER"
echo "   - IP de la VM: $(hostname -I | awk '{print $1}')"
echo "   - Directorio del proyecto: /opt/devops-project"
echo "   - Puerto de la aplicación: 3000"
echo "   - Comando de monitoreo: /opt/devops-project/monitor.sh"

log "🎉 Configuración de la VM completada!"
log "💡 Recuerda:"
echo "   1. Reiniciar la sesión para aplicar los cambios de grupo Docker"
echo "   2. Agregar la clave SSH pública a los secrets de GitHub"
echo "   3. Configurar los secrets de GitHub Actions (VM_HOST, VM_USERNAME, VM_SSH_KEY)" 