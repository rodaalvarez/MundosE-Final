# 🚀 Proyecto Final DevOps - Next.js Pipeline ✅

Este proyecto implementa un pipeline DevOps completo para una aplicación Next.js, incluyendo CI/CD con GitHub Actions, análisis de calidad con SonarQube, y despliegue automatizado en una VM Ubuntu.

## 📋 Tabla de Contenidos

- [Arquitectura del Proyecto](#arquitectura-del-proyecto)
- [Tecnologías Utilizadas](#tecnologías-utilizadas)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Configuración Inicial](#configuración-inicial)
- [Pipeline CI/CD](#pipeline-cicd)
- [Despliegue](#despliegue)
- [Monitoreo y Mantenimiento](#monitoreo-y-mantenimiento)
- [Troubleshooting](#troubleshooting)

## 🏗️ Arquitectura del Proyecto

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions │───▶│   VM Ubuntu     │
│                 │    │   (CI/CD)       │    │   (Production)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   SonarQube     │
                       │  (Code Quality) │
                       └─────────────────┘
```

### Flujo del Pipeline:

1. **Desarrollo**: Código en Next.js + TypeScript
2. **Testing**: Jest + ESLint + TypeScript checks
3. **Análisis**: SonarQube para calidad de código
4. **Build**: Docker image creation
5. **Deploy**: Automático a VM Ubuntu
6. **Monitoreo**: Health checks y logs

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Next.js 14** - Framework de React
- **React 18** - Biblioteca de UI
- **TypeScript** - Tipado estático
- **CSS Modules** - Estilos modulares

### DevOps & CI/CD
- **GitHub Actions** - Pipeline de CI/CD
- **Docker** - Containerización
- **Docker Compose** - Orquestación de contenedores
- **SonarQube** - Análisis de calidad de código

### Testing & Quality
- **Jest** - Framework de testing
- **ESLint** - Linting de código
- **TypeScript Compiler** - Type checking

### Infrastructure
- **VMware Workstation 16** - Virtualización
- **Ubuntu Server** - Sistema operativo
- **SSH** - Conexión remota

## 📁 Estructura del Proyecto

```
ProyectoFinal/
├── app/                          # Aplicación Next.js
│   ├── src/
│   │   ├── pages/               # Páginas de Next.js
│   │   ├── styles/              # Estilos CSS
│   │   └── __tests__/           # Tests
│   ├── Dockerfile               # Configuración Docker
│   ├── docker-compose.yml       # Orquestación Docker
│   ├── package.json             # Dependencias Node.js
│   ├── tsconfig.json            # Configuración TypeScript
│   ├── jest.config.js           # Configuración Jest
│   ├── .eslintrc.json           # Configuración ESLint
│   └── sonar-project.properties # Configuración SonarQube
├── .github/
│   └── workflows/
│       └── ci-cd.yml            # Pipeline GitHub Actions
├── scripts/
│   ├── setup-vm.sh              # Configuración inicial VM
│   ├── setup-sonarqube.sh       # Configuración SonarQube
│   └── deploy.sh                # Script de deployment
└── README.md                    # Documentación principal
```

## 🚀 Configuración Inicial

### 1. Configuración de la VM Ubuntu

#### Paso 1: Crear VM en VMware Workstation
1. Abrir VMware Workstation 16
2. Crear nueva máquina virtual
3. Seleccionar Ubuntu Server 22.04 LTS
4. Asignar recursos mínimos:
   - CPU: 2 cores
   - RAM: 4GB
   - Disco: 20GB
   - Red: NAT

#### Paso 2: Configurar VM
```bash
# Conectar a la VM via SSH o terminal
ssh usuario@ip-vm

# Ejecutar script de configuración inicial
chmod +x scripts/setup-vm.sh
./scripts/setup-vm.sh
```

#### Paso 3: Configurar SonarQube
```bash
# Ejecutar script de configuración de SonarQube
chmod +x scripts/setup-sonarqube.sh
./scripts/setup-sonarqube.sh
```

### 2. Configuración de GitHub

#### Paso 1: Crear repositorio
1. Crear nuevo repositorio en GitHub
2. Subir el código del proyecto
3. Configurar branch protection para `main`

#### Paso 2: Configurar Secrets
Ir a `Settings > Secrets and variables > Actions` y agregar:

```
VM_HOST=ip-de-tu-vm
VM_USERNAME=usuario-vm
VM_SSH_KEY=clave-ssh-privada
SONAR_TOKEN=token-sonarqube
SONAR_HOST_URL=http://ip-vm:9000
```

#### Paso 3: Configurar SonarQube
1. Acceder a `http://ip-vm:9000`
2. Login con `admin/admin`
3. Cambiar contraseña
4. Crear proyecto: `devops-project`
5. Generar token de acceso
6. Agregar token a GitHub Secrets

## 🔄 Pipeline CI/CD

### Workflow de GitHub Actions

El pipeline se ejecuta automáticamente en:
- Push a `main` o `develop`
- Pull Request a `main`

#### Jobs del Pipeline:

1. **Test Job**
   - Instalación de dependencias
   - Linting con ESLint
   - Type checking con TypeScript
   - Testing con Jest
   - Build de la aplicación

2. **SonarQube Job**
   - Análisis de calidad de código
   - Generación de reportes de cobertura
   - Verificación de Quality Gate

3. **Build & Push Job**
   - Construcción de imagen Docker
   - Push a GitHub Container Registry
   - Solo se ejecuta en `main`

4. **Deploy Job**
   - Despliegue automático a VM
   - Health check de la aplicación
   - Solo se ejecuta en `main`

### Configuración del Pipeline

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:          # Testing y linting
  sonarqube:     # Análisis de calidad
  build-and-push: # Build y push de imagen
  deploy:        # Despliegue a VM
```

## 🚀 Despliegue

### Despliegue Automático

El despliegue se ejecuta automáticamente cuando:
1. Se hace push a la rama `main`
2. Todos los tests pasan
3. SonarQube Quality Gate pasa
4. La imagen Docker se construye exitosamente

### Despliegue Manual

```bash
# En la VM
cd /opt/devops-project
./deploy.sh
```

### Verificar Despliegue

```bash
# Verificar estado de contenedores
docker ps

# Ver logs de la aplicación
docker logs nextjs-devops-app

# Verificar health check
curl http://localhost:3000
```

## 📊 Monitoreo y Mantenimiento

### Comandos Útiles

```bash
# Estado del sistema
/opt/devops-project/monitor.sh

# Logs de la aplicación
docker logs -f nextjs-devops-app

# Estado de SonarQube
sonar status

# Backup de SonarQube
sonar backup

# Limpieza de Docker
docker system prune -f
```

### Monitoreo Automático

- **Health Checks**: Docker verifica la salud de la aplicación
- **Log Rotation**: Configurado automáticamente
- **Cleanup**: Limpieza automática de imágenes no utilizadas
- **Backup**: Scripts de backup para SonarQube

### Métricas de Calidad

- **Cobertura de Tests**: Mínimo 80%
- **Code Smells**: Máximo 10
- **Bugs**: 0 críticos
- **Vulnerabilidades**: 0 críticas
- **Duplicaciones**: Máximo 3%

## 🔧 Troubleshooting

### Problemas Comunes

#### 1. Pipeline falla en SonarQube
```bash
# Verificar que SonarQube esté corriendo
sonar status

# Verificar logs de SonarQube
sonar logs

# Reiniciar SonarQube si es necesario
sonar restart
```

#### 2. Aplicación no responde
```bash
# Verificar contenedores
docker ps

# Ver logs de la aplicación
docker logs nextjs-devops-app

# Reiniciar aplicación
cd /opt/devops-project
docker-compose restart
```

#### 3. Problemas de SSH
```bash
# Verificar conectividad SSH
ssh usuario@ip-vm

# Verificar clave SSH en GitHub
# Ir a Settings > SSH and GPG keys
```

#### 4. Problemas de Docker
```bash
# Verificar estado de Docker
sudo systemctl status docker

# Reiniciar Docker si es necesario
sudo systemctl restart docker

# Limpiar recursos Docker
docker system prune -a
```

### Logs y Debugging

```bash
# Logs de GitHub Actions
# Ir a Actions > Workflow runs > Ver logs

# Logs de la aplicación
docker logs -f nextjs-devops-app

# Logs de SonarQube
sonar logs

# Logs del sistema
journalctl -u docker
```

## 📚 Recursos Adicionales

### Documentación Oficial
- [Next.js Documentation](https://nextjs.org/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [Docker Documentation](https://docs.docker.com/)

### Enlaces Útiles
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [VMware Workstation Documentation](https://docs.vmware.com/en/VMware-Workstation-Pro/)

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👨‍💻 Autor

**Tu Nombre** - [tu-email@ejemplo.com](mailto:tu-email@ejemplo.com)

---

**¡Gracias por usar este proyecto DevOps! 🚀** 