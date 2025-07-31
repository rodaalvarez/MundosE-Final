#!/bin/bash

# Script de Configuración de SonarQube para VM Ubuntu
# Este script instala y configura SonarQube para análisis de calidad de código

set -e

echo "🔍 Configurando SonarQube para análisis de calidad..."

# Función para logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    log "❌ Docker no está instalado. Ejecuta primero setup-vm.sh"
    exit 1
fi

# Crear directorio para SonarQube
log "📁 Creando directorio para SonarQube..."
sudo mkdir -p /opt/sonarqube
sudo chown $USER:$USER /opt/sonarqube

# Crear docker-compose para SonarQube
log "🐳 Creando docker-compose para SonarQube..."
cat > /opt/sonarqube/docker-compose.yml << 'EOF'
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

# Configurar firewall para SonarQube
log "🔥 Configurando firewall para SonarQube..."
sudo ufw allow 9000/tcp

# Iniciar SonarQube
log "🚀 Iniciando SonarQube..."
cd /opt/sonarqube
docker-compose up -d

# Esperar a que SonarQube esté listo
log "⏳ Esperando a que SonarQube esté listo (esto puede tomar varios minutos)..."
echo "   SonarQube se está iniciando. Puedes verificar el estado con:"
echo "   cd /opt/sonarqube && docker-compose logs -f"

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
cat > /opt/sonarqube/manage.sh << 'EOF'
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

chmod +x /opt/sonarqube/manage.sh

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

log "🎉 Configuración de SonarQube completada!"
log "💡 Próximos pasos:"
echo "   1. Acceder a http://localhost:9000"
echo "   2. Cambiar la contraseña por defecto"
echo "   3. Crear un token de acceso para GitHub Actions"
echo "   4. Configurar el proyecto en SonarQube"
echo "   5. Agregar SONAR_TOKEN y SONAR_HOST_URL a los secrets de GitHub" 