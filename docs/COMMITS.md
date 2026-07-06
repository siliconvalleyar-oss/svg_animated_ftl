# Historial de Commits y Cambios por Versión

> Este archivo documenta todos los cambios realizados en cada version (tag) del proyecto.

---

## v1.2.0 — Actual

**Fecha:** Julio 2026
**Mensaje:** `docs: actualizacion completa de documentacion y reportes QA`

### Cambios

- Reporte QA completo: 20 hallazgos (6 criticos, 5 altos, 5 medios, 4 bajos)
- Actualizada documentacion para reflejar estado real del codigo
- Skill svg-flutter actualizado con bugs conocidos y estructura correcta
- Nuevo archivo docs/BUGS.md con registro de bugs conocidos
- Corregidas incongruencias en ANALYSIS.md, DEVELOPMENT.md, SKILL.md
- Actualizado reports/ con nuevo QA_TESTING_REPORT.md

### Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `docs/README.md` | Estructura de archivos corregida, 4 tabs, sin export_screen |
| `docs/ANALYSIS.md` | Stats actualizados (version, lineas, providers, widgets, servicios) |
| `docs/DEVELOPMENT.md` | Estructura de archivos corregida, servicios agregados |
| `docs/SKILL.md` | Version 1.2.0, bugs conocidos, servicios actualizados |
| `docs/PIECES.md` | Comportamiento corregido (tap toggle, sin pause de animaciones) |
| `docs/BUGS.md` | Nuevo — registro de 20 bugs conocidos |
| `docs/COMMITS.md` | Este registro |
| `.agents/skills/svg-flutter/SKILL.md` | Skill actualizado |
| `reports/QA_TESTING_REPORT.md` | Reporte QA completo |
| `reports/README.md` | Version y referencia a nuevo reporte |

---

## v1.0.6 — `80c96b1`

**Fecha:** Actual  
**Mensaje:** `feat: multi-select, groups, projectile physics, opacity control, new animations`

### Cambios

- Multi-selección con toggle boolean (click para seleccionar/deseleccionar)
- Controles aplican a todas las piezas seleccionadas simultáneamente
- Sistema de grupos: crear, renombrar, eliminar (mínimo 2 piezas)
- Piezas agrupadas rotan juntas con mismo eje de referencia
- Reemplazado "Arco" por "Tiro Oblicuo" con fórmulas de física reales
- Nuevos efectos físicos: Péndulo, Caída Libre, Rebote Elástico, Resorte
- Control de Opacidad individual por pieza o grupo
- 24 animaciones preset (antes 19)

### Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `lib/core/constants.dart` | 24 presets (reemplazado arc por projectile, +5 físicas) |
| `lib/models/animation_config.dart` | +opacity, +initialVelocity, +launchAngle, +gravity |
| `lib/services/animation_engine.dart` | 24 animaciones (projectile, pendulum, freefall, spring, elastic-bounce, opacity) |
| `lib/providers/svg_provider.dart` | Multi-select, grupos, controles multi-elemento |
| `lib/widgets/controls_panel.dart` | Opacidad, controles de física |
| `lib/widgets/elements_list.dart` | Grupos, multi-selección visual |
| `lib/widgets/animation_grid.dart` | Iconos para nuevos presets |
| `docs/ANIMATIONS.md` | Actualizado a 24 presets |
| `docs/CONTROLS.md` | Tiro oblicuo + opacidad |
| `docs/README.md` | Features actualizadas |
| `docs/DEVELOPMENT.md` | Dependencias actualizadas |
| `VERSION` | `1.0.6` |

---

## v1.0.5 — `c428410`

**Fecha:** Actual  
**Mensaje:** `feat: add example.svg as default, replace Android icon with logo.svg, adaptive icon support`

### Cambios

- Agregado `assets/example.svg` como SVG por defecto al iniciar la app
- Si no hay SVG cargado, se carga automáticamente `example.svg`
- Reemplazado el icono de Android por `logo.svg`
- Soportados iconos adaptativos (mipmap-anydpi-v26)
- Actualizado `VERSION` a `1.0.5`

### Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `lib/providers/svg_provider.dart` | Carga automática de example.svg al init |
| `pubspec.yaml` | Registro de `assets/example.svg` |
| `VERSION` | `1.0.5` |
| `android/app/src/main/res/mipmap-*` | Nuevos iconos PNG |
| `android/app/src/main/res/mipmap-anydpi-v26/` | Iconos adaptativos |
| `android/app/src/main/res/values/ic_launcher_background.xml` | Color de fondo del icono |
| `assets/example.svg` | SVG de ejemplo (nuevo) |

---

## v1.0.4 — `0a693b2`

**Mensaje:** `fix: remove file_picker/shares_plus (Flutter 3.44 compat), import via paste, export to documents dir`

### Cambios

- Eliminadas dependencias `file_picker` y `share_plus` para compatibilidad con Flutter 3.44
- Nueva funcionalidad: importar SVG mediante pegado (clipboard)
- Exportación ahora dirige al directorio de documentos del dispositivo
- Mejorada la robustez del flujo de exportación

### Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `pubspec.yaml` | Eliminación de dependencias |
| `lib/services/file_service.dart` | Nuevo método de import/export |
| `lib/providers/svg_provider.dart` | Adaptación al nuevo flujo |
| `VERSION` | `1.0.4` |

---

## v1.0.3 — `76e9016`

**Mensaje:** `chore: update VERSION`

### Cambios

- Actualización del archivo `VERSION` a `1.0.3`
- Solo cambios de versión, sin modificaciones de código

### Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `VERSION` | `1.0.3` |

---

## v1.0.2 — `9a16201`

**Mensaje:** `feat: complete Flutter SVG Animator app with all features`

### Cambios

- Implementación completa de la app Flutter SVG Animator
- **19 animaciones preset**: Rotar, Rueda, Pulsar, Rebotar, Gravedad, Deslizar, Óvalo, Desvanecer, Dibujar, Temblar, Flotar, Levitar, Arco, Radiar, Girar, Brillar, Senoidal, Cuadrada, Triangular
- **11 animaciones direccionables** con control de ángulo 0-360°
- **Modo piezas**: seleccionar y mover elementos individuales del SVG mediante touch
- **Grupos**: combinar elementos para animación sincronizada
- **Trayectorias personalizadas**: dibujar caminos punto a punto
- **Generador de formas**: 12 formas predefinidas
- **Importar SVG** desde el dispositivo
- **Exportar** SVG con animaciones CSS embebidas
- **Imágenes de fondo** como referencia visual
- **Zoom** con pinch-to-zoom + controles flotantes
- **Undo/Redo** con historial de hasta 50 estados
- **Workspaces** múltiples con persistencia
- **Tema oscuro** completo
- Manejo de errores en todas las operaciones
- Persistencia con Hive

### Archivos creados/modificados

Prácticamente todos los archivos del proyecto en `lib/`, incluyendo:

| Archivo | Descripción |
|---------|-------------|
| `lib/main.dart` | Entry point, Hive init, Provider setup |
| `lib/app.dart` | MaterialApp, tema, routing |
| `lib/providers/svg_provider.dart` | Estado global (ChangeNotifier) |
| `lib/providers/theme_provider.dart` | Tema de la app |
| `lib/models/*.dart` | Modelos (Workspace, AnimationConfig, Trajectory, Group, etc.) |
| `lib/services/*.dart` | Servicios (svg_parser, animation_engine, export_service, file_service) |
| `lib/screens/home_screen.dart` | Pantalla principal |
| `lib/widgets/*.dart` | Todos los widgets de UI |
| `lib/core/*.dart` | Constantes y configuración |

---

## v1.0.1 — `3276c30`

**Mensaje:** `docs: add SKILL.md and PROMPT.md, update assets and VERSION`

### Cambios

- Agregado `docs/SKILL.md` — guía rápida de habilidades del proyecto
- Agregado `docs/PROMPT.md` — prompt completo para reconstrucción de la app
- Actualizados assets del proyecto
- Actualizado `VERSION` a `1.0.1`

### Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `docs/SKILL.md` | Nuevo |
| `docs/PROMPT.md` | Nuevo |
| `VERSION` | `1.0.1` |

---

## v1.0.0 — `46ff370`

**Mensaje:** `feat: initial project setup with TODO, docs, assets, and .gitignore`

### Cambios

- Configuración inicial del proyecto Flutter
- Estructura base del proyecto
- Archivos de documentación iniciales en `docs/`
- Assets iniciales
- Archivo `.gitignore`
- Archivo `TODO.md` con plan de desarrollo
- `VERSION` inicial en `1.0.0`

### Archivos creados

| Archivo | Descripción |
|---------|-------------|
| `pubspec.yaml` | Configuración del proyecto Flutter |
| `VERSION` | `1.0.0` |
| `TODO.md` | Plan de tareas |
| `docs/README.md` | Documentación inicial |
| `docs/INSTALLATION.md` | Guía de instalación |
| `docs/CONTROLS.md` | Documentación de controles |
| `docs/ANIMATIONS.md` | Documentación de animaciones |
| `docs/EXPORT.md` | Documentación de exportación |
| `docs/DEVELOPMENT.md` | Guía de desarrollo |
| `docs/PIECES.md` | Documentación de modo piezas |
| `.gitignore` | Reglas de ignorados de Git |
| `assets/` | Assets iniciales |
| `lib/` | Estructura inicial de código Flutter |
| `android/` | Configuración Android |
| `ios/` | Configuración iOS |
| `linux/` | Configuración Linux |
| `macos/` | Configuración macOS |
| `windows/` | Configuración Windows |
| `web/` | Configuración web |
