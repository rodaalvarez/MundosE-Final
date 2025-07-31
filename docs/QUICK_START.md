# ⚡ Guía de Inicio Rápido - Proyecto DevOps

Esta guía te permitirá configurar y ejecutar el proyecto DevOps en menos de 30 minutos.

## 🎯 Objetivo

Configurar un pipeline DevOps completo con:
- ✅ Aplicación Next.js + TypeScript
- ✅ Pipeline CI/CD con GitHub Actions
- ✅ Análisis de calidad con SonarQube
- ✅ Despliegue automático en VM Ubuntu
- ✅ Monitoreo y mantenimiento

## 🚀 Configuración Rápida (30 minutos)

### Paso 1: Preparar VM Ubuntu (10 min)

#### 1.1 Crear VM en VMware
```bash
# Descargar Ubuntu Server 22.04.3 LTS
# Crear VM con:
# - RAM: 4GB
# - CPU: 2 cores
# - Disco: 20GB
# - Red: NAT
```

#### 1.2 Instalar Ubuntu Server
```bash
# Usuario: devops
# Contraseña: devops123
# Habilitar SSH durante instalación
```

#### 1.3 Configurar VM
```bash
# Conectar a la VM
ssh devops@IP-DE-TU-VM

# Ejecutar script de configuración
chmod +x scripts/setup-vm.sh
./scripts/setup-vm.sh
```

### Paso 2: Configurar SonarQube (5 min)

```bash
# En la VM
chmod +x scripts/setup-sonarqube.sh
./scripts/setup-sonarqube.sh

# Esperar a que SonarQube esté listo
# Acceder a http://IP-VM:9000
# Login: admin/admin
# Cambiar contraseña
# Crear proyecto: devops-project
# Generar token de acceso
```

### Paso 3: Configurar GitHub (10 min)

#### 3.1 Crear Repositorio
```bash
# En GitHub.com
# Crear repositorio: devops-project
# NO inicializar con README
```

#### 3.2 Subir Código
```bash
# En tu máquina local
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/TU-USUARIO/devops-project.git
git push -u origin main
```

#### 3.3 Configurar Secrets
```bash
# En GitHub > Settings > Secrets > Actions
# Agregar:
VM_HOST=IP-DE-TU-VM
VM_USERNAME=devops
VM_SSH_KEY=CLAVE-SSH-PRIVADA
SONAR_TOKEN=TOKEN-SONARQUBE
SONAR_HOST_URL=http://IP-VM:9000
```

### Paso 4: Verificar Pipeline (5 min)

```bash
# Hacer commit de prueba
git add .
git commit -m "test: Verificar pipeline"
git push

# Verificar en GitHub Actions
# El pipeline debería ejecutarse automáticamente
```

## 🔍 Verificación Rápida

### 1. Verificar Aplicación
```bash
# En la VM
curl http://localhost:3000
# Debería mostrar la página "¡Hola Mundo!"
```

### 2. Verificar SonarQube
```bash
# Acceder a http://IP-VM:9000
# Verificar que el proyecto esté analizado
```

### 3. Verificar Pipeline
```bash
# En GitHub > Actions
# Verificar que todos los jobs pasen:
# ✅ test
# ✅ sonarqube
# ✅ build-and-push
# ✅ deploy
```

## 📊 Comandos Útiles

### En la VM
```bash
# Estado del sistema
/opt/devops-project/monitor.sh

# Logs de la aplicación
docker logs -f nextjs-devops-app

# Estado de SonarQube
sonar status

# Reiniciar aplicación
cd /opt/devops-project && docker-compose restart
```

### En GitHub
```bash
# Ver logs del pipeline
# Ir a Actions > Workflow runs > Ver logs

# Forzar ejecución del pipeline
# Ir a Actions > CI/CD Pipeline > Run workflow
```

## 🚨 Solución Rápida de Problemas

### Pipeline no se ejecuta
```bash
# Verificar que el archivo .github/workflows/ci-cd.yml esté en el repo
# Verificar que Actions esté habilitado en Settings
```

### Aplicación no responde
```bash
# En la VM
docker ps
docker logs nextjs-devops-app
cd /opt/devops-project && docker-compose restart
```

### SonarQube no funciona
```bash
# En la VM
sonar status
sonar restart
# Verificar en http://IP-VM:9000
```

### Error de SSH
```bash
# Verificar clave SSH en GitHub
# Verificar conectividad: ssh devops@IP-VM
```

## 📋 Checklist de Verificación

- [ ] VM Ubuntu configurada y accesible
- [ ] Docker y Docker Compose instalados
- [ ] SonarQube corriendo en puerto 9000
- [ ] Repositorio GitHub creado
- [ ] Código subido al repositorio
- [ ] Secrets configurados en GitHub
- [ ] Pipeline ejecutándose correctamente
- [ ] Aplicación desplegada en puerto 3000
- [ ] Análisis de SonarQube completado

## 🎉 ¡Listo!

Tu pipeline DevOps está funcionando. Ahora puedes:

1. **Desarrollar**: Hacer cambios en el código
2. **Commit**: `git add . && git commit -m "mensaje" && git push`
3. **Verificar**: El pipeline se ejecuta automáticamente
4. **Desplegar**: La aplicación se actualiza automáticamente

## 📚 Próximos Pasos

- [Leer documentación completa](README.md)
- [Configurar monitoreo avanzado](docs/MONITORING.md)
- [Personalizar la aplicación](app/README.md)
- [Configurar notificaciones](docs/NOTIFICATIONS.md)

---

**¡Disfruta tu pipeline DevOps! 🚀** 