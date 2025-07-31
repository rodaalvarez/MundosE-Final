# 🖥️ Configuración de VMware Workstation para el Proyecto DevOps

Esta guía te ayudará a configurar VMware Workstation 16 para crear la VM Ubuntu que servirá como servidor de producción.

## 📋 Prerrequisitos

- VMware Workstation 16 instalado
- Mínimo 8GB RAM disponible
- Mínimo 50GB espacio libre en disco
- Conexión a internet

## 🚀 Paso a Paso

### 1. Descargar Ubuntu Server

1. **Ir a [ubuntu.com/download/server](https://ubuntu.com/download/server)**
2. **Descargar Ubuntu Server 22.04.3 LTS**
3. **Seleccionar**: "Download Ubuntu Server 22.04.3 LTS"
4. **Guardar** el archivo ISO (aproximadamente 1GB)

### 2. Crear Nueva Máquina Virtual

#### Paso 1: Abrir VMware Workstation
1. **Abrir VMware Workstation 16**
2. **Click en "Create a New Virtual Machine"**

#### Paso 2: Configurar Tipo de VM
1. **Seleccionar**: "Typical (recommended)"
2. **Click en "Next"**

#### Paso 3: Seleccionar ISO
1. **Seleccionar**: "Installer disc image file (iso)"
2. **Browse** y seleccionar el archivo Ubuntu Server ISO descargado
3. **Click en "Next"**

#### Paso 4: Configurar Sistema Operativo
1. **Guest operating system**: Linux
2. **Version**: Ubuntu 64-bit
3. **Click en "Next"**

#### Paso 5: Configurar Nombre y Ubicación
1. **Virtual machine name**: `DevOps-Ubuntu-Server`
2. **Location**: Elegir ubicación con suficiente espacio
3. **Click en "Next"**

#### Paso 6: Configurar Disco
1. **Maximum disk size**: 20 GB
2. **Split virtual disk into multiple files**
3. **Click en "Next"**

#### Paso 7: Finalizar
1. **Click en "Finish"**

### 3. Configurar Recursos de la VM

#### Antes de Iniciar la VM
1. **Click derecho en la VM** > **Settings**
2. **Configurar recursos**:

#### Memoria (Memory)
- **Memory**: 4096 MB (4GB)

#### Procesadores (Processors)
- **Number of processors**: 2
- **Number of cores per processor**: 1

#### Disco Duro (Hard Disk)
- **Capacity**: 20 GB
- **Type**: SCSI

#### Red (Network Adapter)
- **Network connection**: NAT
- **Connect at power on**: ✅

#### Display
- **Accelerate 3D graphics**: ❌ (no necesario para servidor)

### 4. Instalar Ubuntu Server

#### Paso 1: Iniciar la VM
1. **Click en "Power on this virtual machine"**
2. **Esperar** a que cargue el instalador

#### Paso 2: Seleccionar Idioma
1. **Language**: English
2. **Click en "Continue"**

#### Paso 3: Configurar Teclado
1. **Keyboard layout**: English (US)
2. **Click en "Done"**

#### Paso 4: Configurar Red
1. **Network connections**: Dejar por defecto
2. **Click en "Done"**

#### Paso 5: Configurar Proxy
1. **Proxy address**: Dejar vacío
2. **Click en "Done"**

#### Paso 6: Configurar Mirror
1. **Mirror address**: Dejar por defecto
2. **Click en "Done"**

#### Paso 7: Configurar Disco
1. **Storage configuration**: "Use entire disk"
2. **Click en "Done"**
3. **Confirmar**: "Continue"

#### Paso 8: Configurar Usuario
1. **Your name**: `devops`
2. **Your server's name**: `devops-server`
3. **Pick a username**: `devops`
4. **Choose a password**: `devops123` (cambiar por una segura)
5. **Confirm your password**: Repetir contraseña
6. **Click en "Done"**

#### Paso 9: Configurar SSH
1. **Install OpenSSH server**: ✅
2. **Import SSH identity**: ❌
3. **Click en "Done"**

#### Paso 10: Configurar Paquetes
1. **Featured server snaps**: Dejar por defecto
2. **Click en "Done"**

#### Paso 11: Instalar
1. **Click en "Install"**
2. **Esperar** a que termine la instalación (10-15 minutos)

#### Paso 12: Reiniciar
1. **Click en "Reboot Now"**
2. **Esperar** a que reinicie

### 5. Configuración Post-Instalación

#### Paso 1: Login
1. **Username**: `devops`
2. **Password**: La contraseña que configuraste

#### Paso 2: Actualizar Sistema
```bash
sudo apt update && sudo apt upgrade -y
```

#### Paso 3: Instalar Herramientas Básicas
```bash
sudo apt install -y curl wget git htop
```

#### Paso 4: Configurar SSH
```bash
# Verificar que SSH esté corriendo
sudo systemctl status ssh

# Si no está corriendo
sudo systemctl start ssh
sudo systemctl enable ssh
```

#### Paso 5: Obtener IP de la VM
```bash
ip addr show
# Anotar la IP (ejemplo: 192.168.1.100)
```

### 6. Configurar Acceso desde Host

#### Paso 1: Obtener IP de la VM
```bash
# En la VM
hostname -I
```

#### Paso 2: Probar Conexión SSH
```bash
# Desde tu máquina host (Windows)
ssh devops@192.168.1.100
```

#### Paso 3: Configurar SSH Keys (Opcional)
```bash
# En tu máquina host, generar clave SSH
ssh-keygen -t rsa -b 4096

# Copiar clave a la VM
ssh-copy-id devops@192.168.1.100
```

### 7. Configurar Firewall

```bash
# En la VM
sudo ufw allow ssh
sudo ufw allow 3000/tcp  # Puerto de la aplicación
sudo ufw allow 9000/tcp  # Puerto de SonarQube
sudo ufw --force enable
```

### 8. Verificar Configuración

```bash
# Verificar recursos
free -h
nproc
df -h

# Verificar servicios
sudo systemctl status ssh
sudo systemctl status ufw

# Verificar conectividad
ping -c 3 google.com
```

## 🔧 Configuración Avanzada

### Configurar Snapshots

1. **Antes de configurar el proyecto**:
   - Click derecho en la VM > **Snapshot** > **Take Snapshot**
   - **Name**: "Clean Ubuntu Server"
   - **Description**: "Ubuntu Server limpio antes de configuración DevOps"

2. **Después de configurar el proyecto**:
   - Click derecho en la VM > **Snapshot** > **Take Snapshot**
   - **Name**: "DevOps Project Configured"
   - **Description**: "VM con proyecto DevOps completamente configurado"

### Configurar Red Avanzada

#### Para Acceso desde Internet
1. **VM Settings** > **Network Adapter**
2. **Network connection**: "Bridged: Connected directly to the physical network"
3. **Click en "OK"**

#### Para Acceso Solo Local
1. **VM Settings** > **Network Adapter**
2. **Network connection**: "NAT: Used to share the host's IP address"
3. **Click en "OK"**

### Configurar Recursos Dinámicos

#### Memoria Dinámica
1. **VM Settings** > **Memory**
2. **Allow some virtual machine memory to be swapped**: ✅
3. **Additional memory**: 1024 MB

#### Disco Dinámico
1. **VM Settings** > **Hard Disk**
2. **Pre-allocate disk space**: ❌
3. **Split virtual disk into multiple files**: ✅

## 🚨 Troubleshooting

### Problema: VM no inicia

**Solución**:
1. Verificar que VMware Workstation esté actualizado
2. Verificar que haya suficiente RAM disponible
3. Verificar que el archivo ISO no esté corrupto

### Problema: No se puede conectar por SSH

**Solución**:
1. Verificar que SSH esté instalado y corriendo
2. Verificar configuración de red en VMware
3. Verificar firewall de Windows

### Problema: VM lenta

**Solución**:
1. Aumentar RAM asignada
2. Aumentar número de procesadores
3. Deshabilitar aceleración 3D
4. Cerrar aplicaciones innecesarias en el host

### Problema: Problemas de red

**Solución**:
1. Verificar configuración de red en VMware
2. Reiniciar servicios de red en la VM
3. Verificar configuración de DHCP

## 📊 Especificaciones Recomendadas

### Mínimas
- **RAM**: 4GB
- **CPU**: 2 cores
- **Disco**: 20GB
- **Red**: NAT

### Recomendadas
- **RAM**: 8GB
- **CPU**: 4 cores
- **Disco**: 50GB
- **Red**: Bridged

### Para Producción
- **RAM**: 16GB
- **CPU**: 8 cores
- **Disco**: 100GB
- **Red**: Bridged con IP fija

## 📚 Recursos Adicionales

- [VMware Workstation Documentation](https://docs.vmware.com/en/VMware-Workstation-Pro/)
- [Ubuntu Server Documentation](https://ubuntu.com/server/docs)
- [SSH Configuration Guide](https://help.ubuntu.com/community/SSH)

## ✅ Checklist de Configuración

- [ ] VMware Workstation 16 instalado
- [ ] Ubuntu Server ISO descargado
- [ ] VM creada con recursos adecuados
- [ ] Ubuntu Server instalado
- [ ] Usuario y contraseña configurados
- [ ] SSH habilitado
- [ ] Sistema actualizado
- [ ] Firewall configurado
- [ ] Conexión SSH probada
- [ ] Snapshots creados
- [ ] IP de la VM anotada

---

**¡VMware Workstation configurado exitosamente! 🎉** 