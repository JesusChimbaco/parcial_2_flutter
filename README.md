# Parcial 2 - Datos Abiertos de Colombia 🇨🇴

Una aplicación Flutter que consume la API pública de datos abiertos de Colombia para mostrar información sobre regiones, especies invasoras, platos típicos y áreas naturales del país.

## 📱 Funcionalidades

La aplicación implementa un dashboard con navegación hacia cuatro secciones principales, cada una consumiendo diferentes endpoints de la [API-Colombia](https://api-colombia.com):

## 🌍 Endpoints Implementados

### 1. **Regiones** (`/api/v1/Region`)
- **Lista de regiones**: Muestra todas las regiones de Colombia
- **Detalle de región**: Información completa de cada región incluyendo departamentos
- **Datos**: Nombre, descripción, superficie, población y departamentos asociados

### 2. **Especies Invasoras** (`/api/v1/InvasiveSpecie`)
- **Lista de especies**: Catálogo de especies invasoras en Colombia  
- **Detalle de especie**: Información detallada de cada especie
- **Datos**: Nombre científico, nombres comunes, nivel de riesgo, impacto e imagen
- **Nota especial**: Implementa parsing robusto para niveles de riesgo (1=Bajo, 2=Medio, 3=Alto)

### 3. **Platos Típicos** (`/api/v1/TypicalDish`)
- **Lista de platos**: Gastronomía tradicional colombiana
- **Detalle de plato**: Descripción completa y características
- **Datos**: Nombre, descripción, ingredientes e imagen

### 4. **Áreas Naturales** (`/api/v1/NaturalArea`)
- **Lista de áreas**: Parques y reservas naturales de Colombia
- **Detalle de área**: Información completa de cada área protegida  
- **Datos**: Nombre, tipo, ubicación, descripción y características

## 🧭 Navegación

- **Dashboard central**: Acceso fácil a todas las secciones
- **Navegación intuitiva**: Botones de regreso en cada vista
- **Experiencia fluida**: Los usuarios nunca quedan atrapados en una sección

## 🛠️ Tecnologías

- **Flutter**: Framework principal
- **go_router**: Navegación de la aplicación  
- **http**: Consumo de APIs REST
- **Material Design 3**: Interfaz de usuario moderna
- **API Colombia**: Fuente de datos abiertos

## 📊 API Base

Todos los endpoints consumen la API pública de Colombia:
```
https://api-colombia.com/api/v1/
```

Esta API no requiere autenticación y proporciona datos actualizados sobre diversos aspectos del país.
