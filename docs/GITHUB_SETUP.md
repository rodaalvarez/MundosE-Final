# 🔧 Configuración de GitHub para el Proyecto DevOps

Esta guía te ayudará a configurar GitHub para el pipeline CI/CD del proyecto.

## 📋 Prerrequisitos

- Cuenta de GitHub
- Acceso a la VM Ubuntu configurada
- Conocimientos básicos de Git

## 🚀 Paso a Paso

### 1. Crear Repositorio en GitHub

1. **Ir a GitHub.com** y hacer login
2. **Crear nuevo repositorio**:
   - Click en "New repository"
   - Nombre: `devops-project` (o el que prefieras)
   - Descripción: "Proyecto Final DevOps - Next.js Pipeline"
   - Público o Privado (recomendado: privado)
   - **NO** inicializar con README (ya tenemos uno)
   - Click en "Create repository"

### 2. Subir Código al Repositorio

```bash
# En tu máquina local, en la carpeta del proyecto
git init
git add .
git commit -m "Initial commit: Proyecto DevOps completo"

# Agregar el repositorio remoto
git remote add origin https://github.com/TU-USUARIO/devops-project.git

# Subir código
git branch -M main
git push -u origin main
```

### 3. Configurar Branch Protection

1. **Ir a Settings > Branches**
2. **Agregar rule para `main`**:
   - Branch name pattern: `main`
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Include administrators
   - ✅ Restrict pushes that create files that are larger than 100 MB

### 4. Configurar GitHub Actions

#### Habilitar Actions
1. **Ir a Settings > Actions > General**
2. **Seleccionar**: "Allow all actions and reusable workflows"
3. **Click en "Save"**

#### Configurar Permisos
1. **Ir a Settings > Actions > General**
2. **Workflow permissions**: "Read and write permissions"
3. **Click en "Save"**

### 5. Configurar Secrets

#### Obtener Información de la VM

```bash
# En la VM Ubuntu
echo "IP de la VM: $(hostname -I | awk '{print $1}')"
echo "Usuario: $USER"
echo "Clave SSH pública:"
cat ~/.ssh/id_rsa.pub
```

#### Agregar Secrets

1. **Ir a Settings > Secrets and variables > Actions**
2. **Click en "New repository secret"**
3. **Agregar cada secret**:

```
VM_HOST=192.168.220.128          # IP de tu VM
VM_USERNAME=rodrigo         # Usuario de la VM
VM_SSH_KEY=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCFj1Q8dlUeMk4nDdVNs/CLPDVRyjklpl3VQjz+Ce0WWCEFFpWNpu/HVVbE+9d21iJhTCROaK3Bdf+WpIy3dZDfBrSCPgb18i1wpqK24yB07PNPuKikMaNNvojkR0xN2k0V8Slmo4F/xppqBWIDzntsi/wOehf2Bc7YRdDhE4TYI1st+DQH+kFQKVg4fa1rZ2taPfNNTFExdVaJLToWOGMJFoeNe05Q2pR43J1YSNx0vaBT+6Kkvc8N1UG0Mk56D0S8lTQY4bx5LgGewPf11dNdcixkIpZpLlBZMu+VlngrMo/W37jYlmaTrFyBW2x2V1VQQulYfP3uFN0WvnbE35dLgZpbigXcnPc4EbCmwpeNVLt09cyrlHWrnvLj3UyELsopHDU2FEYN1uqua92rgFP3s/lxZ+8C4y/G2SGL6cVnTRlbVHxtVIIIGGcQZv+CQQnVQ/2C6eOeOcUDInb4tRb9+XSPPvGoPYbe4xXaKEEMYG3hM6lBEfz9Vyd8fFknBGdyTZQL+limbk8B3RFB+TzA3JJkCCI/h3MSVsKXYjFUWgQEfn4JCvI6H9agl2LajpGpOByO8NSFbydRV6Ihp/gp5f+K5jFzzJOigF31YGUc/W5ifCFnV1qRp1O63+sps74bgw3Y/tV2CAHSS+mtD11bS/l26B3iL2NrhcYM+X2cfQ== github-deploy
SONAR_TOKEN=sqp_xxxxxxxxxxxxx  # Token de SonarQube
SONAR_HOST_URL=http://192.168.1.100:9000  # URL de SonarQube
```

### 6. Configurar Container Registry

#### Habilitar Packages
1. **Ir a Settings > Packages**
2. **Verificar que esté habilitado**

#### Configurar Permisos
1. **Ir a Settings > Actions > General**
2. **Workflow permissions**: "Read and write permissions"
3. **Click en "Save"**

### 7. Configurar Webhooks (Opcional)

Para notificaciones en tiempo real:

1. **Ir a Settings > Webhooks**
2. **Click en "Add webhook"**
3. **Payload URL**: URL de tu sistema de notificaciones
4. **Content type**: `application/json`
5. **Seleccionar eventos**: `Push`, `Pull requests`
6. **Click en "Add webhook"**

## 🔑 Configuración de SSH

### Generar Clave SSH (si no existe)

```bash
# En la VM Ubuntu
ssh-keygen -t rsa -b 4096 -C "devops-vm@github.com"
# Presionar Enter para usar ubicación por defecto
# Presionar Enter para no usar passphrase
```

### Agregar Clave Pública a GitHub

1. **Copiar la clave pública**:
```bash
cat ~/.ssh/id_rsa.pub
```

2. **Ir a GitHub > Settings > SSH and GPG keys**
3. **Click en "New SSH key"**
4. **Title**: "DevOps VM"
5. **Key**: Pegar la clave pública
6. **Click en "Add SSH key"**

### Obtener Clave Privada para Secrets

```bash
# En la VM Ubuntu
cat ~/.ssh/id_rsa
```

**Copiar TODO el contenido** (incluyendo las líneas `-----BEGIN OPENSSH PRIVATE KEY-----` y `-----END OPENSSH PRIVATE KEY-----`)

## 🔍 Verificación de Configuración

### 1. Verificar Secrets

```bash
# En GitHub, ir a Settings > Secrets and variables > Actions
# Verificar que todos los secrets estén configurados:
# ✅ VM_HOST
# ✅ VM_USERNAME  
# ✅ VM_SSH_KEY
# ✅ SONAR_TOKEN
# ✅ SONAR_HOST_URL
```

### 2. Verificar SSH

```bash
# En la VM Ubuntu
ssh -T git@github.com
# Debería mostrar: "Hi username! You've successfully authenticated..."
```

### 3. Verificar Actions

1. **Ir a Actions tab en GitHub**
2. **Verificar que el workflow esté disponible**
3. **Hacer un commit de prueba**:
```bash
git add .
git commit -m "test: Verificar pipeline"
git push
```

## 🚨 Troubleshooting

### Problema: Actions no se ejecutan

**Solución**:
1. Verificar que Actions esté habilitado en Settings > Actions > General
2. Verificar que el archivo `.github/workflows/ci-cd.yml` esté en el repositorio
3. Verificar que el archivo tenga la sintaxis correcta

### Problema: Error de permisos en Container Registry

**Solución**:
1. Ir a Settings > Actions > General
2. Configurar "Workflow permissions" como "Read and write permissions"
3. Verificar que el repositorio tenga habilitado Packages

### Problema: Error de SSH en deployment

**Solución**:
1. Verificar que la clave SSH esté correctamente configurada
2. Verificar que el usuario tenga permisos en la VM
3. Verificar conectividad SSH desde GitHub Actions

### Problema: SonarQube no responde

**Solución**:
1. Verificar que SonarQube esté corriendo en la VM
2. Verificar que el puerto 9000 esté abierto
3. Verificar que el token de SonarQube sea válido

## 📚 Recursos Adicionales

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [GitHub SSH Setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

## ✅ Checklist de Configuración

- [ ] Repositorio creado en GitHub
- [ ] Código subido al repositorio
- [ ] Branch protection configurado
- [ ] GitHub Actions habilitado
- [ ] Secrets configurados:
  - [ ] VM_HOST
  - [ ] VM_USERNAME
  - [ ] VM_SSH_KEY
  - [ ] SONAR_TOKEN
  - [ ] SONAR_HOST_URL
- [ ] SSH configurado
- [ ] Container Registry habilitado
- [ ] Pipeline ejecutado exitosamente

---

**¡Configuración completada! 🎉** 