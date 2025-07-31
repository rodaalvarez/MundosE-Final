# Next.js App - Proyecto Final DevOps

Esta es la aplicación Next.js que será desplegada mediante el pipeline DevOps.

## Tecnologías

- **Next.js 14** - Framework de React
- **TypeScript** - Tipado estático
- **React 18** - Biblioteca de UI
- **Jest** - Testing framework
- **ESLint** - Linting de código

## Scripts Disponibles

```bash
# Desarrollo
npm run dev

# Build de producción
npm run build

# Iniciar en producción
npm run start

# Linting
npm run lint

# Testing
npm run test

# Type checking
npm run type-check
```

## Estructura del Proyecto

```
src/
├── pages/          # Páginas de Next.js
├── styles/         # Estilos CSS
└── __tests__/      # Tests
```

## Desarrollo Local

1. Instalar dependencias:
```bash
npm install
```

2. Ejecutar en modo desarrollo:
```bash
npm run dev
```

3. Abrir [http://localhost:3000](http://localhost:3000)

## Testing

```bash
# Ejecutar todos los tests
npm test

# Ejecutar tests en modo watch
npm run test:watch
```

## Build para Producción

```bash
npm run build
npm run start
```

La aplicación estará disponible en el puerto 3000. 