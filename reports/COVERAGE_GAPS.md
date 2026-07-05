# 📊 Brechas de Cobertura

**Cobertura global:** 72.0% (1,087/1,510 líneas cubiertas)  
**Meta recomendada:** ≥ 80%

---

## 1. Directorios con Baja Cobertura

| Directorio | Cobertura | Líneas | Estado |
|:-----------|:---------:|:------:|:------:|
| `lib/providers/` | **0.0%** | 192 | 🔴 Crítico |
| `lib/screens/` | **54.0%** | 163 | 🟡 Bajo |
| `lib/widgets/trajectory_overlay.dart` | **56.5%** | 23 | 🟡 Bajo |
| `lib/widgets/zoom_controls.dart` | **55.2%** | 29 | 🟡 Bajo |
| `lib/widgets/animation_grid.dart` | **60.8%** | 51 | 🟡 Bajo |

---

## 2. Archivos sin Cobertura (0%)

### `lib/providers/svg_provider.dart` — 176 líneas sin testear

**Riesgo:** 🔴 **Alto.** Este es el provider central de la aplicación. Contiene:

- Inicialización y carga desde Hive (`init()`, `_loadWorkspaces()`)
- Gestión de workspaces (`addWorkspace`, `switchWorkspace`, `removeWorkspace`)
- Carga de SVGs (`loadSvgString`)
- Selección de elementos (`toggleElementSelection`, `clearSelection`)
- Control de animaciones (speed, delay, iter, dir, opacity, etc.)
- Grupos (`createGroup`, `deleteGroup`, `renameGroup`)
- Trayectorias (`addTrajectory`, `deleteTrajectory`)
- Undo/Redo (`undo()`, `redo()`)
- Persistencia (`_saveWorkspaces()`)

### `lib/providers/settings_provider.dart` — 12 líneas sin testear

**Riesgo:** 🟡 Medio. Maneja la ruta de exportación persistente.

### `lib/providers/theme_provider.dart` — 4 líneas sin testear

**Riesgo:** 🟢 Bajo.

---

## 3. Archivos con Cobertura Parcial

### `lib/screens/home_screen.dart` — 54.0% (88/163)

**Líneas sin cobertura** (75 líneas):
- `_buildAppBar()` — undo/redo buttons (64, 70)
- `_buildImportPanel()` — botón "Cargar SVG", ruta de exportación (180-199)
- `_buildExportPanel()` — panel completo (207-249)
- `_showSettings()` — diálogo de configuración (250+)
- `_importSvgFromString()` — lógica de importación con diálogo
- `_importFromFolder()` — importación desde carpeta
- `_exportSvg()` — exportación a archivo

### `lib/services/animation_engine.dart` — 90.6% (184/203)

**Líneas sin cobertura** (19 líneas):
- `_buildBounce` (66) — casos borde
- `_buildOval` (74-76) — casos borde
- `_buildProjectile` (87-89) — casos borde
- `_buildRadiate` (98-100) — casos borde
- Métodos de animación avanzada (209-214, 299-303)

### `lib/widgets/animation_grid.dart` — 60.8% (31/51)

**Líneas sin cobertura** (20 líneas):
- Constructor y build (28-41)
- `_getIcon()` casos de iconos específicos (92-122)

### `lib/widgets/trajectory_overlay.dart` — 56.5% (13/23)

**Líneas sin cobertura** (10 líneas):
- `TrajectoryPainter.paint()` — dibujo de trayectorias
- Lógica de renderizado condicional

### `lib/widgets/zoom_controls.dart` — 55.2% (16/29)

**Líneas sin cobertura** (13 líneas):
- Lógica de zoom in/out/reset
- Decoración de botones

---

## 4. Prioridades para Mejorar Cobertura

| Prioridad | Archivo | Esfuerzo | Impacto |
|:---------:|:--------|:--------:|:-------:|
| 1 | `providers/svg_provider.dart` | ⭐⭐⭐⭐⭐ | Máximo |
| 2 | `screens/home_screen.dart` | ⭐⭐⭐⭐ | Alto |
| 3 | `widgets/animation_grid.dart` | ⭐⭐ | Medio |
| 4 | `widgets/trajectory_overlay.dart` | ⭐ | Bajo |
| 5 | `widgets/zoom_controls.dart` | ⭐ | Bajo |
| 6 | `services/animation_engine.dart` | ⭐⭐ | Medio |
| 7 | `providers/settings_provider.dart` | ⭐ | Bajo |
