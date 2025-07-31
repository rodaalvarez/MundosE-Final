#!/bin/bash

# Script de Deployment para VM Ubuntu
# Este script se ejecuta en la VM para desplegar la aplicación

set -e

echo "🚀 Iniciando deployment de la aplicación DevOps..."

# Variables
APP_NAME="nextjs-devops-app"
DOCKER_IMAGE="ghcr.io/$GITHUB_REPOSITORY:latest"
COMPOSE_FILE="/opt/devops-project/docker-compose.yml"

# Función para logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    log "❌ Docker no está instalado. Instalando..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    log "✅ Docker instalado correctamente"
fi

# Verificar si Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    log "❌ Docker Compose no está instalado. Instalando..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    log "✅ Docker Compose instalado correctamente"
fi

# Crear directorio del proyecto si no existe
if [ ! -d "/opt/devops-project" ]; then
    log "📁 Creando directorio del proyecto..."
    sudo mkdir -p /opt/devops-project
    sudo chown $USER:$USER /opt/devops-project
fi

# Detener contenedores existentes
if [ -f "$COMPOSE_FILE" ]; then
    log "🛑 Deteniendo contenedores existentes..."
    cd /opt/devops-project
    docker-compose down || true
fi

# Limpiar imágenes no utilizadas
log "🧹 Limpiando imágenes Docker no utilizadas..."
docker system prune -f

# Crear docker-compose.yml si no existe
if [ ! -f "$COMPOSE_FILE" ]; then
    log "📝 Creando archivo docker-compose.yml..."
    cat > "$COMPOSE_FILE" << EOF
version: '3.8'

services:
  nextjs-app:
    image: $DOCKER_IMAGE
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    container_name: $APP_NAME
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
EOF
fi

# Actualizar la imagen
log "📦 Actualizando imagen Docker..."
cd /opt/devops-project
docker-compose pull

# Iniciar la aplicación
log "🚀 Iniciando la aplicación..."
docker-compose up -d

# Esperar a que la aplicación esté lista
log "⏳ Esperando a que la aplicación esté lista..."
sleep 10

# Verificar el estado de la aplicación
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    log "✅ Aplicación desplegada correctamente en http://localhost:3000"
else
    log "❌ Error: La aplicación no responde"
    docker-compose logs
    exit 1
fi

# Mostrar información del deployment
log "📊 Información del deployment:"
echo "   - Aplicación: $APP_NAME"
echo "   - Puerto: 3000"
echo "   - URL: http://localhost:3000"
echo "   - Estado: $(docker-compose ps)"

log "🎉 Deployment completado exitosamente!" 