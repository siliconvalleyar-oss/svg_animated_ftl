# 📊 Análisis Completo del Proyecto — SVG Animated FTL

> **Archivo generado:** `docs/ANALYSIS.md`
>
> Este documento contiene el análisis completo del proyecto, incluyendo arquitectura, patrones de código, dependencias, estructura, y skills personalizados generados automáticamente.

---

## 1. RESUMEN DEL PROYECTO

| Atributo | Valor |
|----------|-------|
| **Nombre** | `svg_animated_ftl` |
| **Versión actual** | `1.0.5` (VERSION) / `1.0.0+1` (pubspec) |
| **Plataformas** | Android 5.0+, iOS 12.0+ |
| **Stack** | Flutter 3.0+ / Dart 3.0+ |
| **Líneas de código** | ~3,434 en 37 archivos Dart |
| **Archivo más grande** | `lib/providers/svg_provider.dart` (526 líneas) |
| **Dependencias principales** | 7 (flutter_svg, provider, path_provider, permission_handler, uuid, hive, xml) |
| **Animaciones** | 24 presets |

---

## 2. ARQUITECTURA

### 2.1 Patrón arquitectónico

**Provider + ChangeNotifier** — patrón recomendado por Flutter para apps medianas.

```
lib/
├── main.dart                    → Entry point, Hive init, Provider setup
├── app.dart                     → MaterialApp + tema
├── core/                         → Constantes, tema, extensiones
├── models/                       → Datos (Workspace, AnimationConfig, etc.)
├── providers/                    → Estado global (SvgProvider, ThemeProvider)
├── services/                     → Lógica de negocio (parser, animación, export)
├── screens/                      → Pantallas (HomeScreen)
└── widgets/                      → Componentes UI reutilizables
```

### 2.2 Flujo de datos

```
User Action → Widget → SvgProvider (ChangeNotifier) → notifyListeners() → Widget rebuild
                            ↕
                         Hive (persistencia)
```

### 2.3 Flujo de animación

```
SvgPreview (AnimationController)
    → SvgParser.parse() → List<SvgElement>
    → AnimationEngine.buildAnimation() → Widget animado
    → ExportService.generateAnimatedSvg() → SVG con CSS embebido
```

---

## 3. DEPENDENCIAS

### 3.1 Producción

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `flutter_svg` | ^2.0.9 | Renderizado de SVG |
| `provider` | ^6.1.1 | Estado global |
| `path_provider` | ^2.1.1 | Rutas de almacenamiento local |
| `permission_handler` | ^11.0.0 | Permisos Android/iOS |
| `uuid` | ^4.2.1 | IDs únicos para workspaces |
| `hive` + `hive_flutter` | ^2.2.3 / ^1.1.0 | Persistencia local NoSQL |
| `xml` | ^6.3.0 | Parseo y generación de SVG |

### 3.2 Desarrollo

| Paquete | Propósito |
|---------|-----------|
| `flutter_test` | Testing |
| `flutter_lints` | Linting |
| `hive_generator` | Generación de adaptadores Hive |
| `build_runner` | Ejecución de generadores de código |

### 3.3 Assets registrados

```
assets/logo.svg
assets/example.svg
assets/car_animated.svg
assets/car_animated_01.svg
assets/car_animated_04.svg
```

---

## 4. MODELOS DE DATOS

### 4.1 Workspace (el modelo central)

- **id**: String (UUID-based)
- **name**: String
- **originalSvgString**: String? — el SVG cargado
- **elementAnimations**: `Map<int, AnimationConfig>` — animación por índice de elemento
- **elementGroups**: `Map<String, Group>` — grupos de elementos
- **trajectories**: `Map<String, Trajectory>` — trayectorias personalizadas
- **backgroundImages**: `List<BackgroundImage>` — imágenes de fondo
- **zoomLevel**: double (0.2–5.0)
- **isPiecesMode**: bool
- **undoStack**: `List<Map>` — historial de hasta 50 estados

### 4.2 AnimationConfig (19 campos)

- `presetId` — ID del preset de animación
- `speed`, `delay`, `iter`, `dir` — controles básicos
- `ovalRx`, `ovalRy`, `ovalAngle` — parámetros de óvalo
- `arcRx`, `arcRy` — parámetros de arco
- `directionAngle` — ángulo direccional (0-360°)
- `pivotX`, `pivotY` — punto de pivote
- `extraPresets` — lista de presets adicionales (combinación)
- `trajectoryId` — trayectoria asignada
- `opacity` — opacidad
- `initialVelocity`, `launchAngle`, `gravity` — físicas (tiro oblicuo)

### 4.3 Otros modelos

- **Trajectory**: nombre + puntos (TrajectoryPoint[])
- **Group**: nombre + color + elementos[] + config
- **BackgroundImage**: ruta + posición + tamaño + opacidad
- **SvgElement**: índice + tag + XmlElement

---

## 5. PROVIDERS (ESTADO GLOBAL)

### 5.1 SvgProvider (526 líneas)

El cerebro de la app. Gestiona:

- **Workspaces**: add, switch, remove, rename
- **Carga SVG**: desde string, pegado, shapes predefinidos
- **Selección**: toggle individual / multi-select
- **Animaciones**: togglePreset (con extraPresets), speed, delay, iter, dir, angle, opacity, físicas
- **Grupos**: create, delete, rename, sync de config
- **Modo piezas**: toggle, selección por touch
- **Trayectorias**: add, delete
- **Undo/Redo**: historial de hasta 50 estados
- **Persistencia**: Hive (load/save workspaces)

### 5.2 ThemeProvider (tema oscuro por defecto)

---

## 6. SERVICIOS

### 6.1 SvgParser

- Parsea SVG con `xml` package
- Extrae elementos animables: circle, rect, ellipse, path, line, polyline, polygon, g, text
- Extrae viewBox (width/height)

### 6.2 AnimationEngine (327 líneas)

- **24 animaciones**: rotate, wheel, pulse, bounce, gravity, slide, oval, fade, shake, float, levitate, projectile, radiate, spin, glow, wave-sine, wave-square, wave-triangle, pendulum, freefall, elastic-bounce, spring, opacity-anim
- Cada animación usa `AnimatedBuilder` + `Transform`
- 11 animaciones direccionables (soporte ángulo)
- Física real: projectile usa fórmulas de tiro oblicuo

### 6.3 ExportService

- Genera SVG con `<style>` + `@keyframes` CSS embebidos
- Usa `XmlDocument` para manipular el SVG
- Soporta keyframes direccionales

### 6.4 FileService

- Operaciones CRUD en directorio de documentos
- `flush: true` en writeAsString

### 6.5 PermissionService

- Permisos de storage (Android) y photos (iOS)

---

## 7. WIDGETS (17 widgets)

| Widget | Propósito |
|--------|-----------|
| `SvgPreview` | Área de preview con InteractiveViewer + AnimationController |
| `BottomNav` | Barra inferior con 5 tabs |
| `PanelSlider` | Panel deslizante animado |
| `AnimationGrid` | Grid 3 columnas de 24 presets |
| `ControlsPanel` | Sliders + toggles + direction pad |
| `ElementsList` | Lista de elementos con selección y grupos |
| `ShapesGrid` | Grid 3 columnas de 12 formas predefinidas |
| `PiecesOverlay` | Overlay interactivo para modo piezas |
| `TrajectoryEditor` | Editor de trayectorias |
| `EmptyState` | Estado vacío del preview |
| `SliderControl` | Slider reutilizable |
| `ToggleGroup` | Toggle buttons reutilizables |
| `DirectionPad` | Pad 3×3 de direcciones cardinales |
| `BackgroundLayer` | Capa de imágenes de fondo |
| `ZoomControls` | Botones de zoom flotantes |
| `TrajectoryOverlay` | CustomPaint de trayectorias |

---

## 8. PANTALLAS

### HomeScreen (278 líneas)

- AppBar con workspace name + undo/redo
- Body: SvgPreview + PanelSlider
- BottomNav: Importar, Animar, Controles, Piezas, Exportar
- Paneles: Import (paste + shapes), Animation (grid + elements), Controls (sliders), Pieces (mode + elements), Export

---

## 9. ANIMACIONES — CATÁLOGO COMPLETO

### 9.1 Lista de 24 presets

| ID | Nombre | Tipo | Direccionable | Parámetros extra |
|----|--------|------|:---:|:---|
| `rotate` | Rotar | Rotación | ❌ | — |
| `wheel` | Rueda | Rotación (pasos 90°) | ❌ | — |
| `pulse` | Pulsar | Escala | ❌ | — |
| `bounce` | Rebotar | Translación | ✅ | angle |
| `gravity` | Gravedad | Translación | ✅ | angle |
| `slide` | Deslizar | Translación | ✅ | angle |
| `oval` | Óvalo | Translación | ❌ | ovalRx, ovalRy, ovalAngle |
| `fade` | Desvanecer | Opacidad | ❌ | — |
| `draw` | Dibujar | Trazo | ❌ | — |
| `shake` | Temblar | Translación | ✅ | angle |
| `float` | Flotar | Translación | ✅ | angle |
| `levitate` | Levitar | Translación + Escala | ✅ | angle |
| `projectile` | Tiro Oblicuo | Física | ❌ | initialVelocity, launchAngle, gravity |
| `radiate` | Radiar | Translación + Sombra | ✅ | arcRx, arcRy, angle |
| `spin` | Girar | Rotación + Escala | ❌ | — |
| `glow` | Brillar | Sombra | ❌ | — |
| `wave-sine` | Senoidal | Onda | ✅ | angle |
| `wave-square` | Cuadrada | Onda cuadrada | ✅ | angle |
| `wave-triangle` | Triangular | Onda triangular | ✅ | angle |
| `pendulum` | Péndulo | Rotación | ❌ | — |
| `freefall` | Caída Libre | Física (y=½gt²) | ❌ | — |
| `elastic-bounce` | Rebote Elástico | Física | ❌ | — |
| `spring` | Resorte | Física (amortiguado) | ❌ | — |
| `opacity-anim` | Opacidad | Opacidad oscilante | ❌ | — |

### 9.2 Animaciones direccionables (11)

`bounce`, `gravity`, `slide`, `shake`, `float`, `levitate`, `projectile`, `radiate`, `wave-sine`, `wave-square`, `wave-triangle`

### 9.3 Animaciones con física (4)

`projectile` (tiro oblicuo), `freefall` (caída libre), `elastic-bounce` (rebote), `spring` (resorte amortiguado)

---

## 10. PATRONES DE CÓDIGO IDENTIFICADOS

### 10.1 Manejo de errores

```dart
try {
  // operación riesgosa
} catch (e) {
  debugPrint('Error en X: $e');
  // fallback o notificación al usuario
}
```

### 10.2 Widget con Consumer

```dart
Consumer<SvgProvider>(
  builder: (context, provider, _) {
    // usar provider para construir UI
  },
)
```

### 10.3 Multi-selección

```dart
_applyToSelectedElements((idx, cfg) => cfg.speed = speed);
```

### 10.4 Animación con AnimatedBuilder

```dart
AnimatedBuilder(
  animation: animation,
  builder: (context, child) {
    return Transform.rotate(
      angle: animation.value * 2 * pi,
      child: child,
    );
  },
  child: child,
)
```

### 10.5 Undo/Redo

- `_pushHistory()` guarda snapshot de animations + groups
- `undo()` / `redo()` restaura snapshots
- Máximo 50 estados

### 10.6 Persistencia con Hive

```dart
final box = await Hive.openBox('svg_animator');
final data = _workspaces.map((e) => e.toJson()).toList();
await box.put('workspaces', data);
```

---

## 11. CONVENCIONES DEL PROYECTO

### 11.1 Nomenclatura

- Archivos: `snake_case.dart`
- Clases: `PascalCase`
- Variables/métodos: `camelCase`
- Constantes: `camelCase` (en clases con `static const`)
- IDs: prefijos como `g1`, `traj_1`

### 11.2 Estructura de imports

```dart
import 'dart:io';           // Dart SDK
import 'package:...';        // Paquetes externos
import '../models/...';      // Módulos del proyecto
```

### 11.3 Commits

Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`

### 11.4 Versionado

```
v1.0.0 → v1.0.1 → ... → v1.0.9 → v1.1.0 → v1.1.1 → ...
```

VERSION sin prefijo `v`, tag con prefijo `v`.

---

## 12. SKILLS PERSONALIZADOS

Basados en el análisis del código, estos son los skills que definen cómo trabajar en este proyecto:

### Skill 1: `svg-animator-project-context`

```
Contexto completo del proyecto SVG Animated FTL:
- App Flutter offline para animar SVGs
- Provider + ChangeNotifier para estado
- Hive para persistencia
- 3,434 líneas en 37 archivos
- Tema oscuro siempre (AppColors)
- Manejo de errores con try-catch + debugPrint
- Undo/Redo con historial de 50 estados
- 24 animaciones en AnimationEngine
- 12 formas predefinidas en constants.dart
```

### Skill 2: `svg-animator-add-animation`

```
Para agregar una nueva animación:
1. Agregar preset en lib/core/constants.dart → AnimationPresets.presets
2. Agregar builder en lib/services/animation_engine.dart → buildAnimation()
3. Agregar método _buildNuevaAnimacion() en animation_engine.dart
4. Si es direccionable, agregar a AnimationEngine.isTranslatable()
5. Si usa parámetros extra, agregar campos a AnimationConfig
6. Agregar keyframes CSS en lib/services/export_service.dart → _generateKeyframes()
7. Agregar icono en AnimationGrid._getIcon()
8. Agregar controles en ControlsPanel si tiene parámetros extra
9. Agregar setter en SvgProvider si tiene parámetros extra
10. Verificar que toJson/fromJson en AnimationConfig incluya los nuevos campos
```

### Skill 3: `svg-animator-add-shape`

```
Para agregar una nueva forma predefinida:
1. Agregar entrada a AnimationPresets.shapes en lib/core/constants.dart
2. Formato: {'name': 'Nombre', 'svg': '<svg viewBox="0 0 200 200">...</svg>'}
3. El SVG debe ser inline, con viewBox 200x200, stroke-width="3"
4. Usar colores de AppColors.groupColors para el stroke
```

### Skill 4: `svg-animator-export-svg`

```
Flujo de exportación SVG:
1. SvgProvider.currentSvgString → XML original
2. ExportService.generateAnimatedSvg():
   a. XmlDocument.parse() del SVG original
   b. Por cada elementAnimations con presetId:
      - Generar @keyframes CSS
      - Generar estilo del elemento [data-anim-index="N"]
   c. Insertar <style> como primer hijo de <svg>
   d. Retornar XML serializado con pretty print
3. Guardar en directorio de documentos con flush:true
```

### Skill 5: `svg-animator-pieces-mode`

```
Modo piezas:
- SvgProvider.togglePiecesMode() activa/desactiva
- PiecesOverlay muestra overlay táctil
- ElementsList gestiona selección individual/grupo
- Elementos se mueven con Transform.translate() en el overlay
- No se exportan las posiciones del modo piezas
- Al desactivar, se resetean las selecciones
```

### Skill 6: `svg-animator-versioning`

```
Versionado del proyecto:
- Formato: v1.X.Y donde X=minor (cada 10), Y=patch (0-9)
- VERSION contiene el número sin prefijo v (ej: 1.0.5)
- Git tag contiene prefijo v (ej: v1.0.5)
- VERSION y tag siempre deben coincidir
- Ciclo: v1.0.0 → v1.0.9 → v1.1.0 → v1.1.9 → v1.2.0...
- Ver docs/RULES.md para reglas completas
```

---

## 13. OBSERVACIONES Y RECOMENDACIONES

### 13.1 Deudas técnicas detectadas

1. **SvgProvider (526 líneas)**: demasiado grande. Recomendación: dividir en providers especializados (WorkspaceProvider, AnimationProvider, PiecesProvider).
2. **AnimationConfig (19 campos)**: muchos campos opcionales. Recomendación: usar sub-objetos (OvalConfig, ProjectileConfig, ArcConfig).
3. **TrajectoryPainter** en `trajectory_overlay.dart`: usa `Map<String, dynamic>` en lugar del tipo `Trajectory`.
4. **`draw` animation**: declarada en constants pero no implementada en AnimationEngine.
5. **Hive type adapters**: no se han generado (no hay archivos `.g.dart`).
6. **Tests**: no hay tests unitarios ni de widget implementados.
7. **Botonera de 24 animaciones en grid 3×3**: 8 filas pueden ser muchas en mobile.

### 13.2 Puntos fuertes

1. ✅ Arquitectura limpia con Provider/ChangeNotifier
2. ✅ Manejo de errores consistente en toda la app
3. ✅ Buen uso de try-catch en operaciones riesgosas
4. ✅ Separación clara de responsabilidades (models/providers/services/widgets)
5. ✅ Undo/Redo funcional
6. ✅ Multi-selección con grupos
7. ✅ 24 animaciones variadas con soporte de física
8. ✅ Exportación con CSS keyframes
9. ✅ Persistencia con Hive

### 13.3 Recomendaciones

1. **Extraer SvgProvider** en múltiples providers
2. **Agregar tests** (unitarios para parser y engine, widget para UI)
3. **Generar adaptadores Hive** con `build_runner`
4. **Agregar loading states** en operaciones asíncronas largas
5. **Mejorar PiecesOverlay** con detección de hit por elemento SVG real
6. **Internacionalizar** textos (hardcodeados en español)
7. **Agregar drawer** para workspaces en vez de solo el nombre en AppBar

---

## 14. ESTADÍSTICAS DEL PROYECTO

| Métrica | Valor |
|---------|-------|
| Archivos Dart | 37 |
| Líneas de código | ~3,434 |
| Archivo más grande | `svg_provider.dart` (526 líneas) |
| Archivo más pequeño | `svg_element.dart` (12 líneas) |
| Promedio por archivo | ~93 líneas |
| Widgets | 17 |
| Servicios | 5 |
| Modelos | 6 |
| Providers | 2 |
| Screens | 1 |
| Animaciones | 24 |
| Formas predefinidas | 12 |
| Tags publicados | 6 (v1.0.0 → v1.0.5) |
| Dependencias producción | 7 |
| Dependencias desarrollo | 4 |

---

*Análisis generado automáticamente. Última actualización: Julio 2026.*
