# SKILL.md — SVG Animated FTL

> ⚠️ **LEER PRIMERO** — Este archivo contiene todas las reglas y skills del proyecto.
> Instálalo con: `npx skills add . --skill svg-flutter --yes`

---

## Project Overview

Flutter mobile app for animating SVG files with 24 preset animations, offline-first, no server required.

- **Version**: 1.0.5
- **Platforms**: Android 5.0+ / iOS 12.0+
- **Stack**: Flutter 3.0+, Dart 3.0+, Provider, Hive, flutter_svg, xml
- **Lines of code**: ~3,434 in 37 Dart files
- **Animations**: 24 presets
- **Shapes**: 12 predefined
- **Theme**: Dark theme only (AppColors)

---

## 1. PROJECT CONTEXT

### Architecture

```
lib/
├── main.dart              → Entry point, Hive init, Provider setup
├── app.dart               → MaterialApp + dark theme
├── core/                  → Constants, theme, extensions
├── models/                → Workspace, AnimationConfig, Group, Trajectory, etc.
├── providers/             → SvgProvider (global state), ThemeProvider
├── services/              → SVG parser, animation engine, export, file I/O
├── screens/               → HomeScreen
└── widgets/               → 17 reusable widgets
```

### Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | Entry point, Hive init, Provider setup |
| `lib/app.dart` | MaterialApp, theme, routing |
| `lib/providers/svg_provider.dart` | Global state (ChangeNotifier) — 526 lines |
| `lib/services/svg_parser.dart` | SVG parsing to element list |
| `lib/services/animation_engine.dart` | Animation building (Tween + Curves) — 327 lines |
| `lib/services/export_service.dart` | SVG export with embedded CSS keyframes |
| `lib/core/constants.dart` | Colors, presets, shapes |
| `lib/screens/home_screen.dart` | Main screen with bottom nav + panels — 278 lines |

### Data Flow

```
User Action → Widget → SvgProvider (ChangeNotifier) → notifyListeners() → Widget rebuild
                            ↕
                         Hive (persistencia)
```

### Animation Flow

```
SvgPreview (AnimationController)
    → SvgParser.parse() → List<SvgElement>
    → AnimationEngine.buildAnimation() → Widget animado
    → ExportService.generateAnimatedSvg() → SVG con CSS keyframes embebido
```

### Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_svg` | ^2.0.9 | SVG rendering |
| `provider` | ^6.1.1 | State management |
| `path_provider` | ^2.1.1 | Local storage paths |
| `permission_handler` | ^11.0.0 | Android/iOS permissions |
| `uuid` | ^4.2.1 | Unique IDs |
| `hive` + `hive_flutter` | ^2.2.3 / ^1.1.0 | Local NoSQL persistence |
| `xml` | ^6.3.0 | SVG parsing and generation |

### Models

**Workspace** — The central model:
- `id`, `name`, `originalSvgString`
- `elementAnimations`: `Map<int, AnimationConfig>`
- `elementGroups`: `Map<String, Group>`
- `trajectories`: `Map<String, Trajectory>`
- `backgroundImages`: `List<BackgroundImage>`
- `zoomLevel` (0.2–5.0), `isPiecesMode`, `undoStack` (up to 50)

**AnimationConfig** (19 fields):
- `presetId`, `speed`, `delay`, `iter`, `dir`
- `ovalRx`, `ovalRy`, `ovalAngle`, `arcRx`, `arcRy`
- `directionAngle`, `pivotX`, `pivotY`
- `extraPresets`, `trajectoryId`, `opacity`
- `initialVelocity`, `launchAngle`, `gravity`

### Services

| Service | File | Purpose |
|---------|------|---------|
| SvgParser | `svg_parser.dart` | Parse SVG, extract elements, viewBox |
| AnimationEngine | `animation_engine.dart` | Build 24 animations with AnimatedBuilder |
| ExportService | `export_service.dart` | Generate SVG with embedded CSS keyframes |
| FileService | `file_service.dart` | CRUD operations on device storage |
| PermissionService | `permission_service.dart` | Storage and photos permissions |

### Widgets (17 total)

| Widget | Purpose |
|--------|---------|
| `SvgPreview` | Preview with InteractiveViewer + AnimationController |
| `BottomNav` | 5-tab bottom navigation bar |
| `PanelSlider` | Animated sliding panel |
| `AnimationGrid` | 3-column grid of 24 presets |
| `ControlsPanel` | Sliders + toggles + direction pad |
| `ElementsList` | Element list with selection and groups |
| `ShapesGrid` | 3-column grid of 12 predefined shapes |
| `PiecesOverlay` | Interactive pieces mode overlay |
| `TrajectoryEditor` | Trajectory editor with add/delete |
| `EmptyState` | Empty state when no SVG loaded |
| `SliderControl` | Reusable slider widget |
| `ToggleGroup` | Reusable toggle buttons |
| `DirectionPad` | 3×3 cardinal direction pad |
| `BackgroundLayer` | Background image layer |
| `ZoomControls` | Floating zoom buttons |
| `TrajectoryOverlay` | CustomPaint trajectory renderer |

---

## 2. 24 ANIMATION PRESETS

| ID | Name | Type | Directional | Extra Params |
|----|------|------|:-----------:|:-------------|
| `rotate` | Rotar | Rotation | ❌ | — |
| `wheel` | Rueda | Rotation (90° steps) | ❌ | — |
| `pulse` | Pulsar | Scale | ❌ | — |
| `bounce` | Rebotar | Translation | ✅ | angle |
| `gravity` | Gravedad | Translation | ✅ | angle |
| `slide` | Deslizar | Translation | ✅ | angle |
| `oval` | Óvalo | Translation | ❌ | ovalRx, ovalRy, ovalAngle |
| `fade` | Desvanecer | Opacity | ❌ | — |
| `draw` | Dibujar | Stroke | ❌ | — |
| `shake` | Temblar | Translation | ✅ | angle |
| `float` | Flotar | Translation | ✅ | angle |
| `levitate` | Levitar | Translation + Scale | ✅ | angle |
| `projectile` | Tiro Oblicuo | Physics | ❌ | initialVelocity, launchAngle, gravity |
| `radiate` | Radiar | Translation + Shadow | ✅ | arcRx, arcRy, angle |
| `spin` | Girar | Rotation + Scale | ❌ | — |
| `glow` | Brillar | Shadow | ❌ | — |
| `wave-sine` | Senoidal | Sine wave | ✅ | angle |
| `wave-square` | Cuadrada | Square wave | ✅ | angle |
| `wave-triangle` | Triangular | Triangle wave | ✅ | angle |
| `pendulum` | Péndulo | Rotation (physics) | ❌ | — |
| `freefall` | Caída Libre | Physics (y=½gt²) | ❌ | — |
| `elastic-bounce` | Rebote Elástico | Physics | ❌ | — |
| `spring` | Resorte | Physics (damped) | ❌ | — |
| `opacity-anim` | Opacidad | Oscillating opacity | ❌ | — |

### Directional Animations (11)
`bounce`, `gravity`, `slide`, `shake`, `float`, `levitate`, `projectile`, `radiate`, `wave-sine`, `wave-square`, `wave-triangle`

### Physics Animations (4)
`projectile` (projectile motion), `freefall` (free fall), `elastic-bounce` (elastic bounce), `spring` (damped spring)

### 12 Predefined Shapes
Circle, Square, Triangle, Star, Heart, Hexagon, Rhombus, Cross, Wave, Arrow, Lightning, Moon

---

## 3. ADDING A NEW ANIMATION

Follow these steps in order:

1. **Add preset to `lib/core/constants.dart`** → `AnimationPresets.presets`:
   ```dart
   {'name': 'Nombre', 'id': 'my-anim', 'color': '#hex', 'duration': 2.0, 'easing': 'easeInOut'},
   ```
   - If directional, add `'translatable': true`
   - Use colors from AppColors

2. **Add case to `buildAnimation()`** in `lib/services/animation_engine.dart`:
   ```dart
   case 'my-anim':
     return _buildMyAnim(child, animation);
   ```

3. **Create animation method** using `AnimatedBuilder` + `Transform`:
   ```dart
   static Widget _buildMyAnim(Widget child, Animation<double> animation) {
     return AnimatedBuilder(
       animation: animation,
       builder: (context, child) {
         return Transform.xxx(/* your transform */, child: child);
       },
       child: child,
     );
   }
   ```

4. **If directional** → Add ID to `AnimationEngine.isTranslatable()` list

5. **If has extra params** → Add fields to `AnimationConfig` (with defaults, copyWith, toJson/fromJson)

6. **If has extra params** → Add setters in `SvgProvider` (using `_applyToSelectedElements` pattern)

7. **Add CSS keyframes** → Add case in `ExportService._generateKeyframes()`

8. **Add icon** → Add mapping in `AnimationGrid._getIcon()`

9. **If has controls** → Add UI in `ControlsPanel`

---

## 4. ADDING A NEW SHAPE

1. Open `lib/core/constants.dart` → `AnimationPresets.shapes`
2. Add entry:
   ```dart
   {'name': 'Mi Forma', 'svg': '<svg viewBox="0 0 200 200">...</svg>'},
   ```
3. SVG requirements:
   - viewBox: `0 0 200 200`
   - `fill="none"`, `stroke-width="3"`
   - Use colors from `AppColors.groupColors`
   - Single inline string
4. Automatically appears in ShapesGrid — no other changes needed

---

## 5. EXPORT FLOW

1. Parse SVG with `XmlDocument.parse()`
2. For each animated element:
   - Generate `@keyframes` CSS via `_generateKeyframes()`
   - Generate element style via `_generateElementStyle()`
3. Insert `<style>` element as first child of `<svg>`
4. Return XML with pretty print

**Output format:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg viewBox="0 0 200 200">
  <style>
    @keyframes svgRotate_0 { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
    [data-anim-index="0"] { animation: svgRotate_0 2s normal; }
  </style>
  <circle data-anim-index="0" cx="100" cy="100" r="70"/>
</svg>
```

**Saving**: `File.writeAsString(content, flush: true)` to app documents directory.

**On error**: Returns original SVG as fallback — never crashes.

---

## 6. PIECES MODE

- **Activation**: `SvgProvider.togglePiecesMode()` toggles `isPiecesMode`
- **UI**: `PiecesOverlay` renders on top of SVG preview
- **Selection**: `ElementsList` with multi-select (tap to toggle)
- **Groups**: When ≥2 elements selected, "Agrupar" button appears → creates group with shared config
- **Group ops**: rename, delete, visual color coding
- **Important**: Pieces mode positions are NOT exported — preview only
- **On deactivation**: selections are cleared

---

## 7. VERSIONING RULES

- **Format**: `v1.X.Y` (X = minor every 10, Y = patch 0-9)
- **Increment**: +0.0.1 each new version
- **Cycle**: `v1.0.0 → v1.0.9 → v1.1.0 → v1.1.9 → v1.2.0...`
- **VERSION file**: Number WITHOUT `v` prefix (e.g., `1.0.5`)
- **Git tag**: Number WITH `v` prefix (e.g., `v1.0.5`)
- **Sync**: Tag and VERSION must always match
- **Commits**: Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`
- **No tag deletion**: Once published, tags are immutable

---

## 8. ERROR HANDLING RULES

1. Every file/SVG/export/permission operation MUST have try-catch
2. Check `mounted` before `setState` in async methods
3. Always `dispose()` AnimationControllers
4. Use `flush: true` in `writeAsString`
5. Never use `Container` with both `color` and `decoration`
6. Always check `File.exists()` before reading
7. Always call `notifyListeners()` after state changes
8. Always add `key` to `ListView.builder` items
9. Never skip null safety in serialization
10. Never use `Navigator.push` without valid context

---

## 9. CODE CONVENTIONS

### Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/methods: `camelCase`
- Constants: `camelCase` with `static const`

### Imports Order
```dart
import 'dart:io';           // Dart SDK
import 'package:...';        // External packages
import '../models/...';      // Project modules
```

### Provider Pattern
```dart
Consumer<SvgProvider>(
  builder: (context, provider, _) {
    // use provider to build UI
  },
)
```

### Multi-selection Pattern
```dart
_applyToSelectedElements((idx, cfg) => cfg.speed = speed);
```

### Undo/Redo Pattern
- `_pushHistory()` saves snapshot of animations + groups
- `undo()` / `redo()` restores snapshots
- Max 50 states

---

## 10. COMMON PITFALLS

1. `setState` without `mounted` check in async
2. Missing `dispose()` on AnimationController
3. `File.readAsString()` without `exists()` check
4. SVG parse without try-catch
5. Non-null-safe serialization
6. Missing `flush: true` on writeAsString
7. `Navigator.push` with invalid context
8. Missing `notifyListeners()` after state change
9. `Container` with both `color` and `decoration`
10. Missing `key` in `ListView.builder` items

---

## 11. TODO & KNOWN ISSUES

### Technical Debt
- SvgProvider (526 lines) should be split into smaller providers
- AnimationConfig (19 fields) should use sub-objects
- TrajectoryPainter uses `Map<String, dynamic>` instead of typed `Trajectory`
- `draw` animation declared but not implemented in AnimationEngine
- No Hive type adapters generated (missing `.g.dart` files)
- No unit or widget tests
- 24 animations in 3-column grid = 8 rows (too many for mobile)

### Strengths
- Clean Provider/ChangeNotifier architecture
- Consistent error handling throughout
- Good separation of concerns
- Functional Undo/Redo with 50-state history
- Multi-selection with groups
- 24 varied animations including physics-based ones
- SVG export with CSS keyframes
- Hive persistence

---

*Este archivo es instalable como skill con: `npx skills add . --skill svg-flutter --yes`*
*Última actualización: Julio 2026*
