#!/bin/bash

# Script para ejecutar análisis de SonarQube localmente en la VM
# Este script se ejecuta después del deploy para analizar la calidad del código

set -e

echo "🔍 Iniciando análisis de SonarQube..."

# Verificar que estamos en el directorio correcto
if [ ! -d "/opt/devops-project" ]; then
    echo "❌ Directorio /opt/devops-project no encontrado"
    exit 1
fi

cd /opt/devops-project

# Verificar que SonarQube esté corriendo
if ! curl -f http://localhost:9000 > /dev/null 2>&1; then
    echo "❌ SonarQube no está corriendo en http://localhost:9000"
    echo "💡 Ejecuta: docker ps | grep sonarqube"
    exit 1
fi

# Verificar si ya existe el directorio del proyecto
if [ -d "ProyectoFinal" ]; then
    echo "📂 Usando directorio existente ProyectoFinal"
    cd ProyectoFinal
    # Actualizar el repositorio
    git pull origin main
else
    echo "📥 Clonando repositorio..."
    # Intentar clonar en el directorio actual
    git clone https://github.com/rodaalvarez/MundosE-Final.git ProyectoFinal
    cd ProyectoFinal
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