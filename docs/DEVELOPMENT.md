# Desarrollo

## Stack de tecnología

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter 3.0+ |
| Lenguaje | Dart 3.0+ |
| Estado | ChangeNotifier + Provider |
| SVG rendering | `flutter_svg` package |
| Almacenamiento | `path_provider` |
| Persistencia | Hive (NoSQL) |
| XML | `xml` package |

## Estructura del código

### `lib/main.dart`
- Entry point de la app
- Inicialización de Provider y tema

### `lib/models/`
- **animation_config.dart**: Modelo de configuración de animación por elemento
  - `presetId`, `speed`, `delay`, `iter`, `dir`, `directionAngle`
  - `ovalRx`, `ovalRy`, `ovalAngle`, `arcRx`, `arcRy`
  - `pivotX`, `pivotY`, `extraPresets`, `trajectoryId`
- **workspace.dart**: Modelo de workspace (SVG, animaciones, grupos, trayectorias, etc.)
- **trajectory.dart**: Modelo de trayectoria (nombre, puntos)
- **group.dart**: Modelo de grupo (nombre, color, índices de elementos, config)
- **background_image.dart**: Modelo de imagen de fondo

### `lib/providers/`
- **svg_provider.dart**: Estado global de la app (`ChangeNotifier`)
  - SVG actual, animaciones, grupos, selección, modo piezas
  - Métodos para modificar estado y notificar a la UI
- **theme_provider.dart**: Tema oscuro de la app

### `lib/screens/`
- **splash_screen.dart**: Splash de 3s con fade + logo SVG
- **home_screen.dart**: Layout principal (596 lineas, preview + bottom nav + 4 paneles)

### `lib/widgets/`
- **svg_preview.dart**: Area de previsualizacion con InteractiveViewer + AnimationScope
- **individual_elements_view.dart**: Renderiza cada elemento SVG como widget animado
- **animation_scope.dart**: InheritedWidget con AnimationController compartido
- **bottom_nav.dart**: Barra inferior con 4 tabs
- **panel_slider.dart**: Panel deslizante desde abajo (AnimatedPositioned)
- **animation_grid.dart**: Grid 4 columnas de presets de animacion
- **controls_panel.dart**: Sliders y toggles de controles
- **elements_list.dart**: Lista scrollable de elementos del SVG
- **shapes_grid.dart**: Grid de formas predefinidas
- **pieces_overlay.dart**: Overlay interactivo para modo piezas
- **trajectory_overlay.dart**: CustomPainter de trayectorias
- **trajectory_editor.dart**: Editor visual de trayectorias
- **zoom_controls.dart**: Botones flotantes de zoom
- **background_layer.dart**: Capa de imagenes de fondo
- **slider_control.dart**: Slider reutilizable
- **toggle_group.dart**: Toggle buttons reutilizables
- **direction_pad.dart**: Pad 8 direcciones cardinales
- **empty_state.dart**: Estado vacio del preview

### `lib/services/`
- **svg_parser.dart**: Parseo de SVG a estructura de elementos
- **animation_engine.dart**: Generacion de animaciones (24 presets, 460 lineas)
- **animation_service.dart**: Gestion de configs de animacion
- **selection_service.dart**: Logica de seleccion
- **group_service.dart**: CRUD de grupos
- **history_service.dart**: Undo/Redo via snapshots
- **trajectory_service.dart**: CRUD de trayectorias
- **export_service.dart**: Generacion de SVG con CSS keyframes (288 lineas)
- **file_service.dart**: CRUD archivos en dispositivo (sin uso actual)
- **permission_service.dart**: Permisos Android/iOS (sin uso actual)

### `lib/core/`
- **constants.dart**: AppColors, AnimationPresets (24+12), AppConstants
- **theme.dart**: AppTheme.darkTheme
- **extensions.dart**: String.capitalize(), Double.toFixed()

## Agregar nueva animación

### 1. Agregar preset en `constants.dart`
```dart
const List<AnimationPreset> animationPresets = [
  // ... existentes
  AnimationPreset(
    name: 'Mi Animación',
    id: 'mi-anim',
    color: Color(0xFFFF0000),
    duration: 1.0,
    easing: Curves.easeInOut,
    isTranslatable: false, // true si soporta dirección
  ),
];
```

### 2. Crear widget de animación en `animation_engine.dart`
```dart
class MiAnimAnimation extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  
  const MiAnimAnimation({required this.child, required this.animation});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Aplicar transformación según el preset
        return Transform.scale(
          scale: 1.0 + animation.value * 0.15,
          child: child,
        );
      },
      child: child,
    );
  }
}
```

### 3. Registrar en `animation_engine.dart`
```dart
Widget buildAnimation({
  required String presetId,
  required Widget child,
  required Animation<double> animation,
  required AnimationConfig config,
}) {
  switch (presetId) {
    case 'mi-anim':
      return MiAnimAnimation(child: child, animation: animation);
    // ... otros presets
  }
}
```

### 4. Si soporta dirección, agregar en `isTranslatable`
```dart
bool isTranslatable(String presetId) {
  return ['slide', 'bounce', 'shake', 'float', 'gravity', 
          'levitate', 'arc', 'radiate', 'wave-sine', 
          'wave-square', 'wave-triangle', 'mi-anim'].contains(presetId);
}
```

### 5. Agregar en `export_service.dart` (keyframes CSS para export)
```dart
String _generateKeyframes(String presetId, int index, AnimationConfig config) {
  switch (presetId) {
    case 'mi-anim':
      return '@keyframes svgMiAnim { 0% { transform: scale(1); } 100% { transform: scale(1.15); } }';
    // ... otros presets
  }
}
```

## Agregar nueva forma

Agregar en `constants.dart`:
```dart
const List<ShapePreset> shapePresets = [
  // ... existentes
  ShapePreset(
    name: 'Mi Forma',
    svg: '<svg viewBox="0 0 200 200"><path d="M..." fill="none" stroke="#hex" stroke-width="3"/></svg>',
  ),
];
```

## Ejecutar en desarrollo

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en emulador/dispositivo
flutter run

# Ejecutar con hot reload
flutter run --hot

# Ejecutar en modo release
flutter run --release
```

## Paquetes Flutter utilizados

| Paquete | Propósito |
|---------|-----------|
| `flutter_svg` | Renderizado de SVG |
| `provider` | Gestión de estado |
| `path_provider` | Rutas de almacenamiento |
| `permission_handler` | Permisos de almacenamiento |
| `hive` + `hive_flutter` | Persistencia local NoSQL |
| `xml` | Parseo y generación de SVG |
| `uuid` | IDs únicos para workspaces |

## Dependencias en pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.9
  provider: ^6.1.1
  path_provider: ^2.1.1
  permission_handler: ^11.0.0
  uuid: ^4.2.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  xml: ^6.3.0
```
