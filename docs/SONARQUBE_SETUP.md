# 🔍 Configuración de SonarQube Gratuito

Esta guía te ayudará a configurar SonarQube **completamente gratis** para tu proyecto DevOps.

## 🆓 **Opciones Gratuitas Disponibles**

### 1. **SonarQube Community Edition (Recomendado)**
- ✅ **100% Gratuito**
- ✅ **Sin límites de proyectos**
- ✅ **Análisis completo de código**
- ✅ **Quality Gates**
- ✅ **Reportes detallados**
- ✅ **Instalación local en tu VM**

### 2. **SonarCloud (Alternativa)**
- ✅ **Plan gratuito disponible**
- ✅ **Hosted en la nube**
- ✅ **Fácil configuración**
- ✅ **Integración directa con GitHub**

## 🚀 **Opción 1: SonarQube Community Edition (Local) - Docker**

### Paso 1: Instalar con Docker (Recomendado)

```bash
# En tu VM Ubuntu
cd /opt
sudo mkdir sonarqube
sudo chown $USER:$USER sonarqube
cd sonarqube

# Crear docker-compose.yml para SonarQube
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
sudo ufw allow 9000/tcp
```

### Paso 2: Iniciar SonarQube

```bash
# Iniciar SonarQube con Docker
docker-compose up -d

# Verificar estado
docker-compose ps

# Ver logs
docker-compose logs -f sonarqube
```

### Paso 3: Acceder a SonarQube

1. **Abrir navegador**: `http://IP-DE-TU-VM:9000`
2. **Login por defecto**: `admin/admin`
3. **Cambiar contraseña** cuando se solicite
http://192.168.220.128:9000
### Paso 4: Crear Proyecto

1. **Click en "Create new project"**
2. **Project key**: `devops-project`
3. **Display name**: `DevOps Project`
4. **Click en "Set Up"**

### Paso 5: Generar Token

1. **Ir a "My Account" > "Security"**
2. **Generate Tokens**
3. **Token name**: `github-actions`
4. **Copy el token generado**

## ☁️ **Opción 2: SonarCloud (Nube)**

### Paso 1: Crear Cuenta Gratuita

1. **Ir a [sonarcloud.io](https://sonarcloud.io)**
2. **Click en "Get Started for Free"**
3. **Sign up with GitHub**
4. **Seleccionar plan gratuito**

### Paso 2: Crear Organización

1. **Crear nueva organización**
2. **Nombre**: `tu-usuario-devops`
3. **Plan**: Free

### Paso 3: Crear Proyecto

1. **Click en "Create new project"**
2. **Seleccionar repositorio de GitHub**
3. **Configurar análisis automático**

### Paso 4: Obtener Token

1. **Ir a "My Account" > "Security"**
2. **Generate Tokens**
3. **Copy el token**

## 🔧 **Configurar GitHub Actions**

### Para SonarQube Local

1. **Agregar secrets en GitHub**:
   ```
   SONAR_TOKEN=tu-token-generado
   SONAR_HOST_URL=http://IP-DE-TU-VM:9000
   ```

2. **Descomentar el job en .github/workflows/ci-cd.yml**:
   ```yaml
   sonarqube:
     needs: test
     runs-on: ubuntu-latest
     
     steps:
     - name: Checkout code
       uses: actions/checkout@v4
       with:
         fetch-depth: 0
         
     - name: Setup Node.js
       uses: actions/setup-node@v4
       with:
         node-version: '18'
         cache: 'npm'
         cache-dependency-path: app/package-lock.json
         
     - name: Install dependencies
       run: |
         cd app
         npm ci
         
     - name: Run tests with coverage
       run: |
         cd app
         npm test -- --coverage
         
     - name: SonarQube Scan
       uses: SonarSource/sonarqube-quality-gate-action@v1.1.0
       env:
         GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
         SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
       with:
         args: >
           -Dsonar.projectKey=devops-project
           -Dsonar.sources=app/src
           -Dsonar.host.url=${{ secrets.SONAR_HOST_URL }}
           -Dsonar.login=${{ secrets.SONAR_TOKEN }}
           -Dsonar.javascript.lcov.reportPaths=app/coverage/lcov.info
   ```

### Para SonarCloud

1. **Agregar secrets en GitHub**:
   ```
   SONAR_TOKEN=tu-token-sonarcloud
   SONAR_HOST_URL=https://sonarcloud.io
   ```

2. **Usar el mismo job pero con URL de SonarCloud**

## 📊 **Configurar Quality Gates**

### SonarQube Community Edition

1. **Ir a "Quality Gates"**
2. **Click en "Create"**
3. **Configurar métricas**:
   - **Coverage**: >= 80%
   - **Duplicated Lines**: <= 3%
   - **Bugs**: 0
   - **Vulnerabilities**: 0
   - **Code Smells**: <= 10

### SonarCloud

1. **Ir a "Quality Gates"**
2. **Usar "Sonar way" por defecto**
3. **Personalizar según necesidades**

## 🚨 **Troubleshooting**

### Problema: Error 403 al descargar SonarQube

Si obtienes error 403 al intentar descargar SonarQube manualmente:

**Solución**: Usar Docker (recomendado)
```bash
# Docker es la forma más fácil y confiable
docker pull sonarqube:community
docker-compose up -d
```

### Problema: SonarQube no inicia

```bash
# Verificar memoria disponible
free -h

# Verificar puerto 9000
netstat -tlnp | grep 9000

# Verificar logs (Docker)
docker-compose logs -f sonarqube

# Verificar estado del contenedor
docker-compose ps
```

### Problema: Error de conexión

```bash
# Verificar firewall
sudo ufw status

# Abrir puerto si es necesario
sudo ufw allow 9000/tcp
```

### Problema: Token inválido

1. **Regenerar token en SonarQube**
2. **Actualizar secret en GitHub**
3. **Verificar formato del token**

## 📋 **Checklist de Configuración**

- [ ] SonarQube instalado y corriendo
- [ ] Proyecto creado en SonarQube
- [ ] Token generado y copiado
- [ ] Secrets configurados en GitHub
- [ ] Job descomentado en workflow
- [ ] Quality Gate configurado
- [ ] Pipeline ejecutándose correctamente

## 💡 **Ventajas de SonarQube Gratuito**

- **Análisis completo**: Bugs, vulnerabilidades, code smells
- **Métricas de calidad**: Cobertura, duplicación, complejidad
- **Quality Gates**: Control automático de calidad
- **Historial**: Seguimiento de mejoras en el tiempo
- **Integración**: Funciona perfectamente con GitHub Actions

---

**¡SonarQube Community Edition es completamente gratuito y perfecto para tu proyecto! 🎉** 