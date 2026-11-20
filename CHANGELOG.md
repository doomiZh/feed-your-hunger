# Registro de cambios

Todos los cambios relevantes del proyecto se documentan en este archivo.

El formato se basa en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y el proyecto sigue el [Versionado Semántico](https://semver.org/lang/es/).

## [0.1.0] - 2026-11-20

### Añadido

- Base de datos: Creación de tablas mediante migraciones con Flyway.
- Datos semilla: países, municipios, ingredientes, categorías, recetas, administrador, clientes de demostración, valoraciones y eventos de uso.
- Procedimientos de recálculo de precio, costo y tendencia.
- Pruebas de la base de datos y datos de demostración de ofertas.
- 20 imágenes de recetas en formato `.webp`.
- Entorno con Docker Compose (servicios `db` y `flyway`) y plantilla de variables `.env.example`.
- Configuración del repositorio: `.gitignore`, `.gitattributes`, `.editorconfig` y licencia propietaria.
