#!/bin/bash

# Script para ejecutar análisis de SonarQube localmente en la VM
# Este script se ejecuta después del deploy para analizar la calidad del código

set -e

echo "🔍 Iniciando análisis de SonarQube..."

# Verificar que SonarQube esté corriendo
if ! curl -f http://localhost:9000 > /dev/null 2>&1; then
    echo "❌ SonarQube no está corriendo en http://localhost:9000"
    echo "💡 Ejecuta: docker ps | grep sonarqube"
    exit 1
fi

# Usar el directorio de trabajo actual (donde está el código del runner)
echo "📂 Usando directorio de trabajo actual: $(pwd)"

# Verificar que estamos en el directorio correcto del proyecto
if [ ! -d "app" ]; then
    echo "❌ Directorio 'app' no encontrado en $(pwd)"
    echo "💡 Asegúrate de que el script se ejecute desde la raíz del proyecto"
    exit 1
fi

# Instalar Node.js si no está disponible
if ! command -v npm &> /dev/null; then
    echo "📦 Instalando Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "✅ Node.js instalado: $(node --version)"
    echo "✅ npm instalado: $(npm --version)"
fi

cd app

# Instalar dependencias
echo "📦 Instalando dependencias..."
npm ci

# Ejecutar tests con cobertura
echo "🧪 Ejecutando tests con cobertura..."
npm test -- --coverage

# Usar el scanner que viene con SonarQube
echo "🔍 Usando scanner integrado de SonarQube..."

# Crear archivo de configuración de SonarQube
cat > sonar-project.properties << EOF
sonar.projectKey=devops-project
sonar.sources=src
sonar.host.url=http://localhost:9000
sonar.login=sqp_26d8ef99c7c2ff9fb39b94de2f088fb18f33c8b1
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.coverage.exclusions=**/*.test.tsx,**/*.test.ts,**/__tests__/**
EOF

# Ejecutar análisis usando el scanner que viene con SonarQube
echo "🔍 Ejecutando análisis de SonarQube..."

# Usar docker para ejecutar el scanner con la JVM correcta
docker run --rm \
  -e SONAR_HOST_URL=http://host.docker.internal:9000 \
  -e SONAR_LOGIN=sqp_26d8ef99c7c2ff9fb39b94de2f088fb18f33c8b1 \
  -v "$(pwd):/usr/src" \
  sonarsource/sonar-scanner-cli:latest \
  -Dsonar.projectKey=devops-project \
  -Dsonar.sources=src \
  -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
  -Dsonar.coverage.exclusions=**/*.test.tsx,**/*.test.ts,**/__tests__/**

echo "✅ Análisis de SonarQube completado"
echo "🌐 Puedes ver los resultados en: http://192.168.220.128:9000" 