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

cd app

# Instalar dependencias
echo "📦 Instalando dependencias..."
npm ci

# Ejecutar tests con cobertura
echo "🧪 Ejecutando tests con cobertura..."
npm test -- --coverage

# Descargar SonarQube Scanner si no existe
if [ ! -d "sonar-scanner-4.8.0.2856-linux" ]; then
    echo "📥 Descargando SonarQube Scanner..."
    wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
    unzip sonar-scanner-cli-4.8.0.2856-linux.zip
    rm sonar-scanner-cli-4.8.0.2856-linux.zip
fi

# Configurar PATH
export PATH=$PATH:$(pwd)/sonar-scanner-4.8.0.2856-linux/bin

# Ejecutar análisis de SonarQube
echo "🔍 Ejecutando análisis de SonarQube..."
sonar-scanner \
    -Dsonar.projectKey=devops-project \
    -Dsonar.sources=src \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.login=sqp_26d8ef99c7c2ff9fb39b94de2f088fb18f33c8b1 \
    -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
    -Dsonar.coverage.exclusions=**/*.test.tsx,**/*.test.ts,**/__tests__/**

echo "✅ Análisis de SonarQube completado"
echo "🌐 Puedes ver los resultados en: http://192.168.220.128:9000" 