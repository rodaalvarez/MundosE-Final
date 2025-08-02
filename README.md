# 🚀 Proyecto Final DevOps - Next.js Pipeline ✅

Este proyecto implementa un pipeline DevOps completo para una aplicación Next.js, incluyendo CI/CD con GitHub Actions, análisis de calidad con SonarQube, y despliegue automatizado en una VM Ubuntu usando un Self-Hosted Runner.

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
│   GitHub Repo   │───▶│  GitHub Actions │───▶│ Self-Hosted     │
│                 │    │   (CI/CD)       │    │ Runner (VM)     │
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
- **Self-Hosted Runner** - Ejecuta los jobs en la VM

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
│   ├── setup-github-runner.sh   # Configuración del Self-Hosted Runner
│   └── deploy.sh                # Script de deployment
├── docs/
│   ├── SELF_HOSTED_RUNNER_SETUP.md  # Guía para configurar el runner
│   ├── GITHUB_SETUP.md              # Configuración de GitHub
│   ├── QUICK_START.md               # Inicio rápido
│   ├── SONARQUBE_SETUP.md           # Configuración de SonarQube
│   └── VMWARE_SETUP.md              # Configuración de VMware
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
ssh rodrigo@192.168.220.128

# Clonar el repositorio
git clone https://github.com/rodaalvarez/MundosE-Final.git ProyectoFinal

# Ejecutar script de configuración inicial
cd ProyectoFinal
chmod +x scripts/setup-vm.sh
./scripts/setup-vm.sh
```

#### Paso 3: Configurar Self-Hosted Runner
```bash
# Ejecutar script de configuración del runner
chmod +x scripts/setup-github-runner.sh
./scripts/setup-github-runner.sh

# Seguir las instrucciones en docs/SELF_HOSTED_RUNNER_SETUP.md
```

#### Paso 4: Configurar SonarQube
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

#### Paso 2: Configurar Self-Hosted Runner
1. Ir a `Settings > Actions > Runners`
2. Click en "New self-hosted runner"
3. Seleccionar Linux y x64
4. Copiar el token de configuración
5. Seguir las instrucciones en la VM

#### Paso 3: Configurar SonarQube
1. Acceder a `http://192.168.220.128:9000`
2. Login con `admin/admin`
3. Cambiar contraseña
4. Crear proyecto: `devops-project`
5. Generar token de acceso
6. El token ya está configurado en el workflow

## 🔄 Pipeline CI/CD

### Workflow de GitHub Actions

El pipeline se ejecuta automáticamente en:
- Push a `main` o `develop`
- Pull Request a `main`

#### Jobs del Pipeline:

1. **Test Job** (se ejecuta en GitHub)
   - Instalación de dependencias
   - Linting con ESLint
   - Type checking con TypeScript
   - Testing con Jest
   - Build de la aplicación

2. **Build & Push Job** (se ejecuta en GitHub)
   - Construcción de imagen Docker
   - Push a GitHub Container Registry
   - Solo se ejecuta en `main`

3. **Deploy Job** (se ejecuta en tu VM con Self-Hosted Runner)
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
  test:          # Testing y linting (en GitHub)
  build-and-push: # Build y push de imagen (en GitHub)
  deploy:        # Despliegue a VM (en tu Self-Hosted Runner)
```

## 🚀 Despliegue

### Despliegue Automático

El despliegue se ejecuta automáticamente cuando:
1. Se hace push a la rama `main`
2. Todos los tests pasan
3. La imagen Docker se construye exitosamente
4. El Self-Hosted Runner ejecuta el deploy

### URL de la Aplicación

**http://192.168.220.128:3000**

### Verificar Despliegue

```bash
# En la VM, verificar estado de contenedores
docker ps

# Ver logs de la aplicación
docker logs nextjs-app-new

# Verificar health check
curl http://localhost:3000
```

## 📊 Monitoreo y Mantenimiento

### Comandos Útiles

```bash
# Estado del sistema
docker ps

# Logs de la aplicación
docker logs -f nextjs-app-new

# Estado del Self-Hosted Runner
sudo systemctl status actions.runner.*

# Logs del runner
sudo journalctl -u actions.runner.* -f

# Estado de SonarQube
docker ps | grep sonarqube

# Limpieza de Docker
docker system prune -f
```

### Monitoreo Automático

- **Health Checks**: Docker verifica la salud de la aplicación
- **Log Rotation**: Configurado automáticamente
- **Cleanup**: Limpieza automática de imágenes no utilizadas
- **Self-Hosted Runner**: Se ejecuta automáticamente cuando hay jobs

### Métricas de Calidad

- **Cobertura de Tests**: Mínimo 80%
- **Code Smells**: Máximo 10
- **Bugs**: 0 críticos
- **Vulnerabilidades**: 0 críticas
- **Duplicaciones**: Máximo 3%

## 🔧 Troubleshooting

### Problemas Comunes

#### 1. Self-Hosted Runner no funciona
```bash
# Verificar que el runner esté corriendo
sudo systemctl status actions.runner.*

# Reiniciar el runner si es necesario
sudo systemctl restart actions.runner.*

# Ver logs del runner
sudo journalctl -u actions.runner.* -f
```

#### 2. Aplicación no responde
```bash
# Verificar contenedores
docker ps

# Ver logs de la aplicación
docker logs nextjs-app-new

# Reiniciar aplicación
cd /opt/devops-project
docker compose restart
```

#### 3. Problemas de Docker
```bash
# Verificar estado de Docker
sudo systemctl status docker

# Reiniciar Docker si es necesario
sudo systemctl restart docker

# Limpiar recursos Docker
docker system prune -a
```

#### 4. Problemas de permisos
```bash
# Verificar permisos del directorio
ls -la /opt/devops-project/

# Corregir permisos si es necesario
sudo chown github-runner:github-runner /opt/devops-project/
```

### Logs y Debugging

```bash
# Logs de GitHub Actions
# Ir a Actions > Workflow runs > Ver logs

# Logs de la aplicación
docker logs -f nextjs-app-new

# Logs del Self-Hosted Runner
sudo journalctl -u actions.runner.* -f

# Logs del sistema
journalctl -u docker
```

## 📚 Recursos Adicionales

### Documentación del Proyecto
- [Configuración Self-Hosted Runner](docs/SELF_HOSTED_RUNNER_SETUP.md)
- [Configuración GitHub](docs/GITHUB_SETUP.md)
- [Inicio Rápido](docs/QUICK_START.md)
- [Configuración SonarQube](docs/SONARQUBE_SETUP.md)
- [Configuración VMware](docs/VMWARE_SETUP.md)

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

**Rodrigo Alvarez** - [rodaalvarez@github.com](mailto:rodaalvarez@github.com)

---

**¡Gracias por usar este proyecto DevOps! 🚀** 