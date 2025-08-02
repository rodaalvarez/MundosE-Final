#!/bin/bash

# Script para configurar GitHub Actions Self-Hosted Runner
# Ejecutar en la VM donde quieres desplegar

set -e

echo "🚀 Configurando GitHub Actions Self-Hosted Runner..."

# Verificar que estamos en Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo "❌ Este script está diseñado para Ubuntu"
    exit 1
fi

# Instalar dependencias
echo "📦 Instalando dependencias..."
sudo apt update
sudo apt install -y curl wget git docker.io docker-compose

# Crear usuario para el runner (opcional)
if ! id "github-runner" &>/dev/null; then
    echo "👤 Creando usuario github-runner..."
    sudo useradd -m -s /bin/bash github-runner
    sudo usermod -aG docker github-runner
fi

# Crear directorio para el runner
RUNNER_DIR="/opt/github-runner"
sudo mkdir -p $RUNNER_DIR
sudo chown github-runner:github-runner $RUNNER_DIR

echo "📋 Para continuar, necesitas:"
echo "1. Ir a tu repositorio en GitHub"
echo "2. Settings → Actions → Runners → New self-hosted runner"
echo "3. Copiar el token de configuración"
echo ""
echo "4. Ejecutar estos comandos como usuario github-runner:"
echo "   sudo su - github-runner"
echo "   cd /opt/github-runner"
echo "   curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz"
echo "   tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz"
echo "   ./config.sh --url https://github.com/TU_USUARIO/TU_REPO --token TU_TOKEN"
echo "   sudo ./svc.sh install"
echo "   sudo ./svc.sh start"
echo ""
echo "5. Verificar que el runner aparece en GitHub Actions → Runners" 