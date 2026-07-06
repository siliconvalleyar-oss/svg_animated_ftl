# 📊 Análisis Completo del Proyecto — SVG Animated FTL

> **Archivo generado:** `docs/ANALYSIS.md`
>
> Este documento contiene el análisis completo del proyecto, incluyendo arquitectura, patrones de código, dependencias, estructura, y skills personalizados generados automáticamente.

---

## 1. RESUMEN DEL PROYECTO

| Atributo | Valor |
|----------|-------|
| **Nombre** | `svg_animated_ftl` |
| **Versión actual** | `1.2.0` (VERSION) |
| **Plataformas** | Android 5.0+, iOS 12.0+ |
| **Stack** | Flutter 3.0+ / Dart 3.0+ |
| **Líneas de código** | ~5,500 en 50 archivos Dart |
| **Archivo más grande** | `lib/screens/home_screen.dart` (596 líneas) |
| **Dependencias principales** | 7 (flutter_svg, provider, path_provider, permission_handler, uuid, hive, xml) |
| **Animaciones** | 24 presets |
| **Tests** | ~153 tests en 11 archivos |

---

## 2. ARQUITECTURA

### 2.1 Patrón arquitectónico

**Provider + ChangeNotifier** — patrón recomendado por Flutter para apps medianas.

```
lib/
├── main.dart                    → Entry point, Hive init, Provider setup (3 providers)
├── app.dart                     → MaterialApp + tema oscuro
├── core/                         → Constantes, tema, extensiones
├── models/                       → Datos (Workspace, AnimationConfig, Group, etc.)
├── providers/                    → Estado global (SvgProvider, SettingsProvider, ThemeProvider)
├── services/                     → Lógica de negocio (10 servicios)
├── screens/                      → Pantallas (SplashScreen, HomeScreen)
└── widgets/                      → Componentes UI (18 widgets)
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

### 5.1 SvgProvider (375 líneas)

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

### 5.2 SettingsProvider (persistencia de ajustes)

- Export path, dim opacity, selected opacity, default speed
- Persisted to Hive box `svg_settings`

### 5.3 ThemeProvider (tema oscuro por defecto)

- Toggle dark/light (registrado pero no conectado a MaterialApp)

---

## 6. SERVICIOS

### 6.1 SvgParser

- Parsea SVG con `xml` package
- Extrae elementos animables: circle, rect, ellipse, path, line, polyline, polygon, g, text
- Extrae viewBox (width/height)

### 6.2 AnimationEngine (460 líneas)

- **24 animaciones**: rotate, wheel, pulse, bounce, gravity, slide, oval, fade, draw, shake, float, levitate, projectile, radiate, spin, glow, wave-sine, wave-square, wave-triangle, pendulum, freefall, elastic-bounce, spring, opacity-anim
- Cada animación usa `AnimatedBuilder` + `Transform`
- 11 animaciones direccionables (soporte ángulo)
- Física real: projectile usa fórmulas de tiro oblicuo

### 6.3 AnimationService

- Gestión de configuraciones de animación por elemento
- Toggle presets con cola `extraPresets`
- Sincronización de grupo

### 6.4 SelectionService

- Toggle selección individual/multi
- Clear selección
- Toggle modo piezas

### 6.5 GroupService

- CRUD de grupos (create, delete, rename)
- Colores ciclicos (8 colores)

### 6.6 HistoryService

- Undo/Redo via snapshots (max 50 estados)
- Serializa animations + groups

### 6.7 TrajectoryService

- CRUD de trayectorias
- Puntos por defecto en arco

### 6.8 ExportService (288 líneas)

- Genera SVG con `<style>` + `@keyframes` CSS embebidos
- Usa `XmlDocument` para manipular el SVG
- Soporta keyframes direccionales

### 6.4 FileService

- Operaciones CRUD en directorio de documentos
- `flush: true` en writeAsString

### 6.5 PermissionService

- Permisos de storage (Android) y photos (iOS)

---

## 7. WIDGETS (18 widgets)

| Widget | Propósito |
|--------|-----------|
| `SvgPreview` | Área de preview con InteractiveViewer + AnimationScope |
| `IndividualElementsView` | Renderiza cada elemento SVG como widget animado independiente |
| `AnimationScope` | InheritedWidget con AnimationController compartido |
| `BottomNav` | Barra inferior con 4 tabs (Mover, Animar, Controles, Piezas) |
| `PanelSlider` | Panel deslizante animado |
| `AnimationGrid` | Grid 4 columnas de 24 presets |
| `ControlsPanel` | Sliders + toggles + direction pad |
| `ElementsList` | Lista de elementos con selección y grupos |
| `ShapesGrid` | Grid de 12 formas predefinidas |
| `PiecesOverlay` | Overlay interactivo para modo piezas |
| `TrajectoryEditor` | Editor de trayectorias |
| `TrajectoryOverlay` | CustomPaint de trayectorias |
| `EmptyState` | Estado vacío del preview |
| `SliderControl` | Slider reutilizable |
| `ToggleGroup` | Toggle buttons reutilizables |
| `DirectionPad` | Pad 8 direcciones cardinales |
| `BackgroundLayer` | Capa de imágenes de fondo |
| `ZoomControls` | Botones de zoom flotantes |

---

## 8. PANTALLAS

### SplashScreen (92 líneas)

- Splash de 3 segundos con fade-in
- Logo SVG animado + titulo
- Navegacion automatica a HomeScreen

### HomeScreen (596 líneas)

- AppBar con workspace name + undo/redo + popup menu (import/export) + settings
- Body: SvgPreview + PanelSlider condicional
- BottomNav: 4 tabs (Mover, Animar, Controles, Piezas)
- Paneles: Move (direction pad), Animation (grid + elements), Controls (sliders + toggles), Pieces (mode + elements)
- Dialogo de settings con export path, workspace name, speed, opacidades

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

1. **SvgProvider (375 líneas)**: todavia grande. Recomendación: dividir en providers especializados.
2. **AnimationConfig (19 campos)**: muchos campos opcionales. Recomendación: usar sub-objetos (OvalConfig, ProjectileConfig, ArcConfig).
3. **SvgParser solo parsea hijos directos**: no detecta elementos dentro de `<g>`.
4. **moveSelectedElements no persiste**: falta `_saveActiveWorkspace()`.
5. **Undo/Redo incompleto**: no restaura `elementOffsets`.
6. **gravity export sin soporte direccional**: keyframes siempre verticales.
7. **freefall export distancia x2**: 196px vs 98px calculado.
8. **ThemeProvider no conectado**: registrado pero MaterialApp lo ignora.
9. **FileService y PermissionService sin uso**: codigo muerto.
10. **PiecesOverlay drag roto**: actualiza estado local, nunca llama al provider.

### 13.2 Puntos fuertes

1. Arquitectura limpia con Provider + Service Layer
2. Manejo de errores consistente en toda la app (try-catch + debugPrint)
3. Separación clara de responsabilidades (models/providers/services/widgets)
4. 24 animaciones variadas con soporte de física real
5. Exportación SVG con CSS @keyframes embebidos
6. Persistencia con Hive (workspaces + settings)
7. Splash screen con animacion
8. Test suite con ~153 tests

### 13.3 Recomendaciones

1. **Corregir bugs criticos** (ver docs/BUGS.md): drag piezas, parser anidados, persistencia offsets
2. **Extraer SvgProvider** en multiples providers mas pequenos
3. **Conectar ThemeProvider** a MaterialApp o eliminarlo
4. **Integrar PermissionService** en flujo de export
5. **Resolver paths multi-plataforma** (Windows separator, iOS paths)
6. **Eliminar codigo muerto** (FileService, PermissionService sin uso)
7. **Internacionalizar** textos (hardcodeados en espanol)

---

## 14. ESTADÍSTICAS DEL PROYECTO

| Métrica | Valor |
|---------|-------|
| Archivos Dart (lib/) | 37 |
| Archivos Dart (test/) | 11 |
| Líneas de código | ~5,500 |
| Archivo más grande | `home_screen.dart` (596 líneas) |
| Archivo más pequeño | `svg_element.dart` (13 líneas) |
| Widgets | 18 |
| Servicios | 10 |
| Modelos | 6 |
| Providers | 3 |
| Screens | 2 |
| Animaciones | 24 |
| Formas predefinidas | 12 |
| Tests | ~153 |
| Dependencias producción | 7 |
| Dependencias desarrollo | 4 |

---

*Análisis generado automáticamente. Última actualización: Julio 2026.*
