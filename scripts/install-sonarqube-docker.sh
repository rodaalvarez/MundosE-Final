#!/bin/bash

# Script para instalar SonarQube Community Edition con Docker
# Este script es más confiable que la descarga manual

set -e

echo "🔍 Instalando SonarQube Community Edition con Docker..."

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
else
    log "✅ Docker ya está instalado"
fi

# Verificar si Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    log "❌ Docker Compose no está instalado. Instalando..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    log "✅ Docker Compose instalado correctamente"
else
    log "✅ Docker Compose ya está instalado"
fi

# Crear directorio para SonarQube
log "📁 Creando directorio para SonarQube..."
sudo mkdir -p /opt/sonarqube
sudo chown $USER:$USER /opt/sonarqube
cd /opt/sonarqube

# Crear docker-compose.yml para SonarQube
log "🐳 Creando docker-compose.yml para SonarQube..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  sonarqube:
    image: sonarqube:community
    container_name: sonarqube
    ports:
      - "9000:9000"
    environment:
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/api/system/status"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
EOF

# Configurar firewall
log "🔥 Configurando firewall..."
sudo ufw allow 9000/tcp

# Descargar imagen de SonarQube
log "📦 Descargando imagen de SonarQube..."
docker pull sonarqube:community

# Iniciar SonarQube
log "🚀 Iniciando SonarQube..."
docker-compose up -d

# Esperar a que SonarQube esté listo
log "⏳ Esperando a que SonarQube esté listo (esto puede tomar varios minutos)..."
echo "   SonarQube se está iniciando. Puedes verificar el estado con:"
echo "   docker-compose logs -f sonarqube"

# Función para verificar si SonarQube está listo
check_sonarqube() {
    if curl -f http://localhost:9000/api/system/status > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Esperar hasta que SonarQube esté listo (máximo 10 minutos)
max_attempts=60
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if check_sonarqube; then
        log "✅ SonarQube está listo!"
        break
    else
        attempt=$((attempt + 1))
        echo "   Intento $attempt/$max_attempts - Esperando..."
        sleep 10
    fi
done

if [ $attempt -eq $max_attempts ]; then
    log "⚠️ SonarQube tardó más de lo esperado en iniciar"
    log "   Puedes verificar manualmente en: http://localhost:9000"
    log "   Usuario por defecto: admin"
    log "   Contraseña por defecto: admin"
fi

# Crear script de gestión de SonarQube
log "🔧 Creando script de gestión de SonarQube..."
cat > manage.sh << 'EOF'
#!/bin/bash

case "$1" in
    start)
        echo "🚀 Iniciando SonarQube..."
        docker-compose up -d
        ;;
    stop)
        echo "🛑 Deteniendo SonarQube..."
        docker-compose down
        ;;
    restart)
        echo "🔄 Reiniciando SonarQube..."
        docker-compose restart
        ;;
    logs)
        echo "📋 Mostrando logs de SonarQube..."
        docker-compose logs -f
        ;;
    status)
        echo "📊 Estado de SonarQube:"
        docker-compose ps
        echo ""
        echo "URL: http://localhost:9000"
        echo "Usuario por defecto: admin"
        echo "Contraseña por defecto: admin"
        ;;
    backup)
        echo "💾 Creando backup de SonarQube..."
        docker run --rm -v sonarqube_data:/data -v $(pwd):/backup alpine tar czf /backup/sonarqube_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /data .
        echo "✅ Backup creado en $(pwd)"
        ;;
    *)
        echo "Uso: $0 {start|stop|restart|logs|status|backup}"
        echo ""
        echo "Comandos disponibles:"
        echo "  start   - Iniciar SonarQube"
        echo "  stop    - Detener SonarQube"
        echo "  restart - Reiniciar SonarQube"
        echo "  logs    - Mostrar logs"
        echo "  status  - Mostrar estado"
        echo "  backup  - Crear backup"
        exit 1
        ;;
esac
EOF

chmod +x manage.sh

# Crear alias para gestión de SonarQube
log "🔧 Configurando alias para SonarQube..."
cat >> ~/.bashrc << EOF

# SonarQube Aliases
alias sonar='cd /opt/sonarqube && ./manage.sh'
alias sonar-start='cd /opt/sonarqube && ./manage.sh start'
alias sonar-stop='cd /opt/sonarqube && ./manage.sh stop'
alias sonar-logs='cd /opt/sonarqube && ./manage.sh logs'
alias sonar-status='cd /opt/sonarqube && ./manage.sh status'
EOF

# Mostrar información final
log "📋 Información de SonarQube:"
echo "   - URL: http://localhost:9000"
echo "   - Usuario por defecto: admin"
echo "   - Contraseña por defecto: admin"
echo "   - Directorio: /opt/sonarqube"
echo "   - Comando de gestión: /opt/sonarqube/manage.sh"

log "🎉 Instalación de SonarQube completada!"
log "💡 Próximos pasos:"
echo "   1. Acceder a http://localhost:9000"
echo "   2. Cambiar la contraseña por defecto"
echo "   3. Crear un token de acceso para GitHub Actions"
echo "   4. Configurar el proyecto en SonarQube"
echo "   5. Agregar SONAR_TOKEN y SONAR_HOST_URL a los secrets de GitHub" 