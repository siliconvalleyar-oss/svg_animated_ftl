# SVG Animator — Flutter Mobile App
# App completa, funcional, sin crashes, bien estructurada

---

## OBJETIVO

Construir una aplicación móvil Flutter completa para animar archivos SVG. La app debe:
- Funcionar sin servidor (100% offline)
- No tener crashes ni errores en runtime
- Tener manejo de errores en cada operación
- Ser performante con SVGs complejos
- Tener una UI responsive y fluida
- Seguir las mejores prácticas de Flutter
usar como logo o simbolo de la aplicacion assets/logo.cvg es el que va a aparecer en la aplicacion

---

## 1. STACK Y DEPENDENCIAS

### pubspec.yaml
```yaml
name: svg_animated_ftl
description: Aplicación móvil para animar archivos SVG
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.9
  provider: ^6.1.1
  path_provider: ^2.1.1
  file_picker: ^6.1.1
  share_plus: ^7.2.1
  permission_handler: ^11.0.0
  uuid: ^4.2.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  hive_generator: ^2.0.1
  build_runner: ^2.4.7

flutter:
  uses-material-design: true
  assets:
    - assets/logo.png
    - assets/sample.svg
```

---

## 2. ESTRUCTURA DE ARCHIVOS

```
lib/
├── main.dart                          # Entry point, inicialización
├── app.dart                           # MaterialApp, tema, rutas
├── core/
│   ├── constants.dart                 # Colores, dimensiones, valores por defecto
│   ├── theme.dart                     # Tema oscuro de la app
│   └── extensions.dart                # Extensiones de Dart
├── models/
│   ├── animation_config.dart          # Config de animación por elemento
│   ├── workspace.dart                 # Modelo de workspace
│   ├── trajectory.dart                # Modelo de trayectoria
│   ├── trajectory_point.dart          # Punto de trayectoria
│   ├── group.dart                     # Modelo de grupo
│   ├── background_image.dart          # Modelo de imagen de fondo
│   └── svg_element.dart               # Elemento SVG parseado
├── providers/
│   ├── svg_provider.dart              # Estado global (ChangeNotifier)
│   └── theme_provider.dart            # Tema de la app
├── screens/
│   └── home_screen.dart               # Pantalla principal
├── widgets/
│   ├── svg_preview.dart               # Área de previsualización SVG
│   ├── bottom_nav.dart                # Barra inferior de navegación
│   ├── panel_slider.dart              # Panel deslizante desde abajo
│   ├── animation_grid.dart            # Grid de presets de animación
│   ├── animation_preset_button.dart   # Botón individual de preset
│   ├── controls_panel.dart            # Panel de controles
│   ├── elements_list.dart             # Lista de elementos del SVG
│   ├── element_tile.dart              # Tile individual de elemento
│   ├── shapes_grid.dart               # Grid de formas predefinidas
│   ├── shape_button.dart              # Botón individual de forma
│   ├── pieces_overlay.dart            # Overlay de modo piezas
│   ├── trajectory_editor.dart         # Editor de trayectorias
│   ├── trajectory_overlay.dart        # Overlay de puntos de trayectoria
│   ├── zoom_controls.dart             # Controles de zoom
│   ├── background_layer.dart          # Capa de imágenes de fondo
│   ├── direction_pad.dart             # Pad de direcciones cardinales
│   ├── slider_control.dart            # Slider reutilizable
│   ├── toggle_group.dart              # Grupo de toggles reutilizable
│   └── empty_state.dart               # Estado vacío del preview
├── services/
│   ├── svg_parser.dart                # Parseo de SVG
│   ├── animation_engine.dart          # Motor de animaciones
│   ├── export_service.dart            # Servicio de exportación
│   └── file_service.dart              # Servicio de archivos
├── widgets/animations/
│   ├── rotate_animation.dart
│   ├── wheel_animation.dart
│   ├── pulse_animation.dart
│   ├── bounce_animation.dart
│   ├── gravity_animation.dart
│   ├── slide_animation.dart
│   ├── oval_animation.dart
│   ├── fade_animation.dart
│   ├── draw_animation.dart
│   ├── shake_animation.dart
│   ├── float_animation.dart
│   ├── levitate_animation.dart
│   ├── arc_animation.dart
│   ├── radiate_animation.dart
│   ├── spin_animation.dart
│   ├── glow_animation.dart
│   ├── wave_sine_animation.dart
│   ├── wave_square_animation.dart
│   └── wave_triangle_animation.dart
└── utils/
    ├── svg_utils.dart                 # Utilidades SVG
    ├── math_utils.dart                # Utilidades matemáticas
    └── file_utils.dart                # Utilidades de archivos
```

---

## 3. MANEJO DE ERRORES (CRÍTICO)

Cada operación que pueda fallar DEBE tener try-catch. NO dejar errores sin atrapar.

### Reglas de manejo de errores

1. **Todo operación de archivo**: try-catch con mensaje al usuario
2. **Parseo de SVG**: try-catch, SVG inválido muestra error
3. **Exportación**: try-catch, muestra SnackBar con error
4. **Permisos**: verificar antes de usar, mostrar dialog si denegado
5. **Animaciones**: try-catch en applyAnimation, no crashear si un elemento falla
6. **Navegación**: verificar que el widget sigue montado antes de setState

### Ejemplo de patrón de error
```dart
Future<void> loadSvgFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['svg'],
    );
    
    if (result == null || result.files.isEmpty) return;
    
    final file = File(result.files.first.path!);
    if (!await file.exists()) {
      _showError('El archivo no existe');
      return;
    }
    
    final content = await file.readAsString();
    if (content.isEmpty) {
      _showError('El archivo está vacío');
      return;
    }
    
    // Parsear SVG
    final elements = SvgParser.parse(content);
    if (elements.isEmpty) {
      _showError('No se encontraron elementos en el SVG');
      return;
    }
    
    notifyListeners();
  } catch (e, stackTrace) {
    debugPrint('Error loading SVG: $e');
    debugPrint('Stack trace: $stackTrace');
    _showError('Error al cargar el archivo: ${e.toString()}');
  }
}
```

### Widget que verifica mounted
```dart
void _safeSetState(VoidCallback fn) {
  if (mounted) {
    setState(fn);
  }
}
```

---

## 4. MODELOS DE DATOS

### AnimationConfig
```dart
@HiveType(typeId: 0)
class AnimationConfig extends HiveObject {
  @HiveField(0)
  String? presetId;
  
  @HiveField(1)
  double speed;
  
  @HiveField(2)
  double delay;
  
  @HiveField(3)
  String iter; // 'infinite', '1', '3', 'random', o número como string
  
  @HiveField(4)
  String dir; // 'normal', 'reverse', 'alternate'
  
  @HiveField(5)
  double ovalRx;
  
  @HiveField(6)
  double ovalRy;
  
  @HiveField(7)
  double ovalAngle;
  
  @HiveField(8)
  double arcRx;
  
  @HiveField(9)
  double arcRy;
  
  @HiveField(10)
  double directionAngle;
  
  @HiveField(11)
  double? pivotX;
  
  @HiveField(12)
  double? pivotY;
  
  @HiveField(13)
  List<String> extraPresets;
  
  @HiveField(14)
  String? trajectoryId;

  AnimationConfig({
    this.presetId,
    this.speed = 1.0,
    this.delay = 0.0,
    this.iter = 'infinite',
    this.dir = 'normal',
    this.ovalRx = 80.0,
    this.ovalRy = 40.0,
    this.ovalAngle = 0.0,
    this.arcRx = 80.0,
    this.arcRy = 80.0,
    this.directionAngle = 0.0,
    this.pivotX,
    this.pivotY,
    List<String>? extraPresets,
    this.trajectoryId,
  }) : extraPresets = extraPresets ?? [];

  AnimationConfig copyWith({
    String? presetId,
    double? speed,
    double? delay,
    String? iter,
    String? dir,
    double? ovalRx,
    double? ovalRy,
    double? ovalAngle,
    double? arcRx,
    double? arcRy,
    double? directionAngle,
    double? pivotX,
    double? pivotY,
    List<String>? extraPresets,
    String? trajectoryId,
  }) {
    return AnimationConfig(
      presetId: presetId ?? this.presetId,
      speed: speed ?? this.speed,
      delay: delay ?? this.delay,
      iter: iter ?? this.iter,
      dir: dir ?? this.dir,
      ovalRx: ovalRx ?? this.ovalRx,
      ovalRy: ovalRy ?? this.ovalRy,
      ovalAngle: ovalAngle ?? this.ovalAngle,
      arcRx: arcRx ?? this.arcRx,
      arcRy: arcRy ?? this.arcRy,
      directionAngle: directionAngle ?? this.directionAngle,
      pivotX: pivotX ?? this.pivotX,
      pivotY: pivotY ?? this.pivotY,
      extraPresets: extraPresets ?? List.from(this.extraPresets),
      trajectoryId: trajectoryId ?? this.trajectoryId,
    );
  }

  Map<String, dynamic> toJson() => {
    'presetId': presetId,
    'speed': speed,
    'delay': delay,
    'iter': iter,
    'dir': dir,
    'ovalRx': ovalRx,
    'ovalRy': ovalRy,
    'ovalAngle': ovalAngle,
    'arcRx': arcRx,
    'arcRy': arcRy,
    'directionAngle': directionAngle,
    'pivotX': pivotX,
    'pivotY': pivotY,
    'extraPresets': extraPresets,
    'trajectoryId': trajectoryId,
  };

  factory AnimationConfig.fromJson(Map<String, dynamic> json) {
    return AnimationConfig(
      presetId: json['presetId'],
      speed: (json['speed'] ?? 1.0).toDouble(),
      delay: (json['delay'] ?? 0.0).toDouble(),
      iter: json['iter'] ?? 'infinite',
      dir: json['dir'] ?? 'normal',
      ovalRx: (json['ovalRx'] ?? 80.0).toDouble(),
      ovalRy: (json['ovalRy'] ?? 40.0).toDouble(),
      ovalAngle: (json['ovalAngle'] ?? 0.0).toDouble(),
      arcRx: (json['arcRx'] ?? 80.0).toDouble(),
      arcRy: (json['arcRy'] ?? 80.0).toDouble(),
      directionAngle: (json['directionAngle'] ?? 0.0).toDouble(),
      pivotX: json['pivotX']?.toDouble(),
      pivotY: json['pivotY']?.toDouble(),
      extraPresets: List<String>.from(json['extraPresets'] ?? []),
      trajectoryId: json['trajectoryId'],
    );
  }
}
```

### Workspace
```dart
class Workspace {
  final String id;
  String name;
  String? originalSvgString;
  Map<int, AnimationConfig> elementAnimations;
  Map<String, Group> elementGroups;
  int? selectedElementIndex;
  List<int> selectedGroupElements;
  bool isMultiSelectMode;
  String? selectedGroupId;
  int nextGroupId;
  Map<String, Trajectory> trajectories;
  int nextTrajId;
  bool isTrajectoryMode;
  String? selectedTrajectoryId;
  List<BackgroundImage> backgroundImages;
  double zoomLevel;
  bool isPiecesMode;
  int piecesSelectedIndex;
  bool boundaryActive;
  List<Map<String, dynamic>> undoStack;
  int undoIndex;

  Workspace({
    required this.id,
    required this.name,
    this.originalSvgString,
    Map<int, AnimationConfig>? elementAnimations,
    Map<String, Group>? elementGroups,
    this.selectedElementIndex,
    List<int>? selectedGroupElements,
    this.isMultiSelectMode = false,
    this.selectedGroupId,
    this.nextGroupId = 1,
    Map<String, Trajectory>? trajectories,
    this.nextTrajId = 1,
    this.isTrajectoryMode = false,
    this.selectedTrajectoryId,
    List<BackgroundImage>? backgroundImages,
    this.zoomLevel = 1.0,
    this.isPiecesMode = false,
    this.piecesSelectedIndex = -1,
    this.boundaryActive = false,
    List<Map<String, dynamic>>? undoStack,
    this.undoIndex = -1,
  })  : elementAnimations = elementAnimations ?? {},
        elementGroups = elementGroups ?? {},
        selectedGroupElements = selectedGroupElements ?? [],
        trajectories = trajectories ?? {},
        backgroundImages = backgroundImages ?? [],
        undoStack = undoStack ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'originalSvgString': originalSvgString,
    'elementAnimations': elementAnimations.map((k, v) => MapEntry(k.toString(), v.toJson())),
    'elementGroups': elementGroups.map((k, v) => MapEntry(k, v.toJson())),
    'selectedElementIndex': selectedElementIndex,
    'selectedGroupElements': selectedGroupElements,
    'isMultiSelectMode': isMultiSelectMode,
    'selectedGroupId': selectedGroupId,
    'nextGroupId': nextGroupId,
    'trajectories': trajectories.map((k, v) => MapEntry(k, v.toJson())),
    'nextTrajId': nextTrajId,
    'isTrajectoryMode': isTrajectoryMode,
    'selectedTrajectoryId': selectedTrajectoryId,
    'backgroundImages': backgroundImages.map((e) => e.toJson()).toList(),
    'zoomLevel': zoomLevel,
    'isPiecesMode': isPiecesMode,
    'piecesSelectedIndex': piecesSelectedIndex,
    'boundaryActive': boundaryActive,
    'undoStack': undoStack,
    'undoIndex': undoIndex,
  };

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      name: json['name'],
      originalSvgString: json['originalSvgString'],
      elementAnimations: (json['elementAnimations'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(int.parse(k), AnimationConfig.fromJson(v))) ?? {},
      elementGroups: (json['elementGroups'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, Group.fromJson(v))) ?? {},
      selectedElementIndex: json['selectedElementIndex'],
      selectedGroupElements: List<int>.from(json['selectedGroupElements'] ?? []),
      isMultiSelectMode: json['isMultiSelectMode'] ?? false,
      selectedGroupId: json['selectedGroupId'],
      nextGroupId: json['nextGroupId'] ?? 1,
      trajectories: (json['trajectories'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, Trajectory.fromJson(v))) ?? {},
      nextTrajId: json['nextTrajId'] ?? 1,
      isTrajectoryMode: json['isTrajectoryMode'] ?? false,
      selectedTrajectoryId: json['selectedTrajectoryId'],
      backgroundImages: (json['backgroundImages'] as List?)
          ?.map((e) => BackgroundImage.fromJson(e)).toList() ?? [],
      zoomLevel: (json['zoomLevel'] ?? 1.0).toDouble(),
      isPiecesMode: json['isPiecesMode'] ?? false,
      piecesSelectedIndex: json['piecesSelectedIndex'] ?? -1,
      boundaryActive: json['boundaryActive'] ?? false,
      undoStack: List<Map<String, dynamic>>.from(json['undoStack'] ?? []),
      undoIndex: json['undoIndex'] ?? -1,
    );
  }
}
```

### Trajectory
```dart
class Trajectory {
  String name;
  List<TrajectoryPoint> points;

  Trajectory({required this.name, List<TrajectoryPoint>? points})
      : points = points ?? [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'points': points.map((e) => e.toJson()).toList(),
  };

  factory Trajectory.fromJson(Map<String, dynamic> json) {
    return Trajectory(
      name: json['name'],
      points: (json['points'] as List?)
          ?.map((e) => TrajectoryPoint.fromJson(e)).toList() ?? [],
    );
  }
}

class TrajectoryPoint {
  double x;
  double y;

  TrajectoryPoint({required this.x, required this.y});

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory TrajectoryPoint.fromJson(Map<String, dynamic> json) {
    return TrajectoryPoint(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
    );
  }
}
```

### Group
```dart
class Group {
  String name;
  String color; // hex string
  List<int> elements;
  AnimationConfig config;

  Group({
    required this.name,
    required this.color,
    List<int>? elements,
    AnimationConfig? config,
  })  : elements = elements ?? [],
        config = config ?? AnimationConfig();

  Map<String, dynamic> toJson() => {
    'name': name,
    'color': color,
    'elements': elements,
    'config': config.toJson(),
  };

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      name: json['name'],
      color: json['color'],
      elements: List<int>.from(json['elements'] ?? []),
      config: AnimationConfig.fromJson(json['config'] ?? {}),
    );
  }
}
```

### BackgroundImage
```dart
class BackgroundImage {
  String id;
  String name;
  String path; // ruta local del archivo
  double x;
  double y;
  double width;
  double height;
  double opacity;
  bool hidden;
  int zIndex;

  BackgroundImage({
    required this.id,
    required this.name,
    required this.path,
    this.x = 50,
    this.y = 50,
    this.width = 400,
    this.height = 300,
    this.opacity = 0.8,
    this.hidden = false,
    this.zIndex = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'opacity': opacity,
    'hidden': hidden,
    'zIndex': zIndex,
  };

  factory BackgroundImage.fromJson(Map<String, dynamic> json) {
    return BackgroundImage(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      x: (json['x'] ?? 50).toDouble(),
      y: (json['y'] ?? 50).toDouble(),
      width: (json['width'] ?? 400).toDouble(),
      height: (json['height'] ?? 300).toDouble(),
      opacity: (json['opacity'] ?? 0.8).toDouble(),
      hidden: json['hidden'] ?? false,
      zIndex: json['zIndex'] ?? 0,
    );
  }
}
```

---

## 5. PROVIDER (ESTADO GLOBAL)

### SvgProvider
```dart
class SvgProvider extends ChangeNotifier {
  // === WORKSPACES ===
  List<Workspace> _workspaces = [];
  int _activeWorkspaceIndex = 0;
  
  // === ESTADO TRANSITORIO ===
  bool _animationPlaying = true;
  List<AnimationController> _controllers = [];
  
  // Getters
  Workspace get activeWorkspace => _workspaces[_activeWorkspaceIndex];
  List<Workspace> get workspaces => _workspaces;
  int get activeWorkspaceIndex => _activeWorkspaceIndex;
  bool get animationPlaying => _animationPlaying;
  String? get currentSvgString => activeWorkspace.originalSvgString;
  Map<int, AnimationConfig> get elementAnimations => activeWorkspace.elementAnimations;
  
  // === INICIALIZACIÓN ===
  Future<void> init() async {
    try {
      await _loadWorkspaces();
      if (_workspaces.isEmpty) {
        _workspaces.add(Workspace(
          id: _generateId(),
          name: 'Espacio 1',
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing: $e');
      _workspaces = [Workspace(id: _generateId(), name: 'Espacio 1')];
      notifyListeners();
    }
  }
  
  // === WORKSPACE MANAGEMENT ===
  void addWorkspace() {
    try {
      _saveActiveWorkspace();
      final ws = Workspace(
        id: _generateId(),
        name: 'Espacio ${_workspaces.length + 1}',
      );
      _workspaces.add(ws);
      _activeWorkspaceIndex = _workspaces.length - 1;
      _restoreWorkspace(ws);
      _saveWorkspaces();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding workspace: $e');
    }
  }
  
  void switchWorkspace(int index) {
    if (index == _activeWorkspaceIndex) return;
    if (index < 0 || index >= _workspaces.length) return;
    try {
      _saveActiveWorkspace();
      _activeWorkspaceIndex = index;
      _restoreWorkspace(activeWorkspace);
      notifyListeners();
    } catch (e) {
      debugPrint('Error switching workspace: $e');
    }
  }
  
  void removeWorkspace(int index) {
    if (_workspaces.length <= 1) return;
    if (index < 0 || index >= _workspaces.length) return;
    try {
      _workspaces.removeAt(index);
      if (_activeWorkspaceIndex >= _workspaces.length) {
        _activeWorkspaceIndex = _workspaces.length - 1;
      }
      _restoreWorkspace(activeWorkspace);
      _saveWorkspaces();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing workspace: $e');
    }
  }
  
  void renameWorkspace(String name) {
    activeWorkspace.name = name;
    _saveWorkspaces();
    notifyListeners();
  }
  
  // === SVG LOADING ===
  Future<void> loadSvgString(String svgString, {bool createNewWorkspace = true}) async {
    try {
      if (createNewWorkspace) {
        _saveActiveWorkspace();
        final currentWs = activeWorkspace;
        if (currentWs.originalSvgString == null) {
          // Reutilizar workspace vacío
        } else {
          final ws = Workspace(id: _generateId(), name: 'Espacio ${_workspaces.length + 1}');
          _workspaces.add(ws);
          _activeWorkspaceIndex = _workspaces.length - 1;
        }
      }
      
      activeWorkspace.originalSvgString = svgString;
      _resetAnimationState();
      _saveActiveWorkspace();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading SVG: $e');
    }
  }
  
  Future<void> loadSvgFile(File file) async {
    try {
      if (!await file.exists()) {
        debugPrint('File does not exist');
        return;
      }
      final content = await file.readAsString();
      if (content.isEmpty) {
        debugPrint('File is empty');
        return;
      }
      await loadSvgString(content);
    } catch (e) {
      debugPrint('Error loading file: $e');
    }
  }
  
  // === ANIMATION MANAGEMENT ===
  void togglePreset(String presetId) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      
      _pushHistory();
      final cfg = _getConfigForIndex(index);
      
      // Toggle logic
      if (cfg.presetId == presetId) {
        if (cfg.extraPresets.isNotEmpty) {
          cfg.presetId = cfg.extraPresets.removeAt(0);
        } else {
          cfg.presetId = null;
        }
      } else if (cfg.extraPresets.contains(presetId)) {
        cfg.extraPresets.remove(presetId);
      } else {
        if (cfg.presetId != null) {
          if (!cfg.extraPresets.contains(cfg.presetId!)) {
            cfg.extraPresets.add(cfg.presetId!);
          }
        }
        cfg.presetId = presetId;
      }
      
      activeWorkspace.elementAnimations[index] = cfg;
      _syncGroupIfNeeded(index, cfg);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling preset: $e');
    }
  }
  
  void updateAnimationSpeed(double speed) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.speed = speed;
      _syncGroupValue(index, 'speed', speed);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating speed: $e');
    }
  }
  
  void updateAnimationDelay(double delay) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.delay = delay;
      _syncGroupValue(index, 'delay', delay);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating delay: $e');
    }
  }
  
  void updateAnimationIteration(String iter) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.iter = iter;
      _syncGroupValue(index, 'iter', iter);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating iteration: $e');
    }
  }
  
  void updateAnimationDirection(String dir) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.dir = dir;
      _syncGroupValue(index, 'dir', dir);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating direction: $e');
    }
  }
  
  void updateDirectionAngle(double angle) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.directionAngle = angle;
      _syncGroupValue(index, 'directionAngle', angle);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating angle: $e');
    }
  }
  
  // === ELEMENT SELECTION ===
  void selectElement(int index) {
    activeWorkspace.selectedElementIndex = index;
    notifyListeners();
  }
  
  void clearSelection() {
    activeWorkspace.selectedElementIndex = null;
    notifyListeners();
  }
  
  // === PIECES MODE ===
  void togglePiecesMode() {
    activeWorkspace.isPiecesMode = !activeWorkspace.isPiecesMode;
    if (!activeWorkspace.isPiecesMode) {
      activeWorkspace.piecesSelectedIndex = -1;
    }
    notifyListeners();
  }
  
  void moveElement(int index, double dx, double dy) {
    // Mover elemento en modo piezas
    // Almacena offset por elemento
    notifyListeners();
  }
  
  // === GROUPS ===
  void createGroup(List<int> indices, String name) {
    try {
      if (indices.length < 2) return;
      _pushHistory();
      
      final color = _getNextGroupColor(activeWorkspace.nextGroupId);
      final groupId = 'g${activeWorkspace.nextGroupId++}';
      
      final templateConfig = elementAnimations[indices.first] ?? AnimationConfig();
      
      final group = Group(
        name: name,
        color: color,
        elements: List.from(indices),
        config: AnimationConfig.fromJson(templateConfig.toJson()),
      );
      
      activeWorkspace.elementGroups[groupId] = group;
      
      // Aplicar config a todos los elementos
      for (final idx in indices) {
        activeWorkspace.elementAnimations[idx] = AnimationConfig.fromJson(templateConfig.toJson());
      }
      
      activeWorkspace.selectedGroupElements = [];
      activeWorkspace.isMultiSelectMode = false;
      activeWorkspace.selectedGroupId = groupId;
      
      _saveActiveWorkspace();
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating group: $e');
    }
  }
  
  void deleteGroup(String groupId) {
    try {
      _pushHistory();
      activeWorkspace.elementGroups.remove(groupId);
      if (activeWorkspace.selectedGroupId == groupId) {
        activeWorkspace.selectedGroupId = null;
      }
      _saveActiveWorkspace();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting group: $e');
    }
  }
  
  // === TRAJECTORIES ===
  String addTrajectory(String name) {
    try {
      final id = 'traj_${activeWorkspace.nextTrajId++}';
      final trajectory = Trajectory(
        name: name,
        points: [
          TrajectoryPoint(x: 30, y: 100),
          TrajectoryPoint(x: 55, y: 60),
          TrajectoryPoint(x: 100, y: 40),
          TrajectoryPoint(x: 145, y: 60),
          TrajectoryPoint(x: 170, y: 100),
        ],
      );
      activeWorkspace.trajectories[id] = trajectory;
      activeWorkspace.selectedTrajectoryId = id;
      activeWorkspace.isTrajectoryMode = true;
      _pushHistory();
      notifyListeners();
      return id;
    } catch (e) {
      debugPrint('Error adding trajectory: $e');
      return '';
    }
  }
  
  void deleteTrajectory(String id) {
    try {
      _pushHistory();
      activeWorkspace.trajectories.remove(id);
      if (activeWorkspace.selectedTrajectoryId == id) {
        activeWorkspace.selectedTrajectoryId = null;
        activeWorkspace.isTrajectoryMode = false;
      }
      // Remover asignación de elementos
      for (final entry in activeWorkspace.elementAnimations.entries) {
        if (entry.value.trajectoryId == id) {
          entry.value.trajectoryId = null;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting trajectory: $e');
    }
  }
  
  // === UNDO / REDO ===
  void _pushHistory() {
    try {
      final ws = activeWorkspace;
      if (ws.undoIndex < ws.undoStack.length - 1) {
        ws.undoStack = ws.undoStack.sublist(0, ws.undoIndex + 1);
      }
      ws.undoStack.add({
        'animations': ws.elementAnimations.map((k, v) => MapEntry(k, v.toJson())),
        'groups': ws.elementGroups.map((k, v) => MapEntry(k, v.toJson())),
      });
      if (ws.undoStack.length > 50) {
        ws.undoStack.removeAt(0);
      }
      ws.undoIndex = ws.undoStack.length - 1;
    } catch (e) {
      debugPrint('Error pushing history: $e');
    }
  }
  
  void undo() {
    try {
      final ws = activeWorkspace;
      if (ws.undoIndex <= 0) return;
      ws.undoIndex--;
      _restoreHistory(ws.undoStack[ws.undoIndex]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error undoing: $e');
    }
  }
  
  void redo() {
    try {
      final ws = activeWorkspace;
      if (ws.undoIndex >= ws.undoStack.length - 1) return;
      ws.undoIndex++;
      _restoreHistory(ws.undoStack[ws.undoIndex]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error redoing: $e');
    }
  }
  
  void _restoreHistory(Map<String, dynamic> state) {
    try {
      final ws = activeWorkspace;
      ws.elementAnimations = (state['animations'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(int.parse(k), AnimationConfig.fromJson(v))) ?? {};
      ws.elementGroups = (state['groups'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, Group.fromJson(v))) ?? {};
    } catch (e) {
      debugPrint('Error restoring history: $e');
    }
  }
  
  bool get canUndo => activeWorkspace.undoIndex > 0;
  bool get canRedo => activeWorkspace.undoIndex < activeWorkspace.undoStack.length - 1;
  
  // === PLAYBACK ===
  void togglePlayPause() {
    _animationPlaying = !_animationPlaying;
    notifyListeners();
  }
  
  // === ZOOM ===
  void setZoom(double level) {
    activeWorkspace.zoomLevel = level.clamp(0.2, 5.0);
    notifyListeners();
  }
  
  // === HELPERS ===
  AnimationConfig _getConfigForIndex(int index) {
    return activeWorkspace.elementAnimations[index] ?? AnimationConfig();
  }
  
  void _syncGroupValue(int index, String key, dynamic value) {
    final groupId = activeWorkspace.elementGroups.keys.firstWhere(
      (gid) => activeWorkspace.elementGroups[gid]!.elements.contains(index),
      orElse: () => '',
    );
    if (groupId.isEmpty) return;
    
    final group = activeWorkspace.elementGroups[groupId]!;
    switch (key) {
      case 'speed': group.config.speed = value; break;
      case 'delay': group.config.delay = value; break;
      case 'iter': group.config.iter = value; break;
      case 'dir': group.config.dir = value; break;
      case 'directionAngle': group.config.directionAngle = value; break;
    }
    
    for (final idx in group.elements) {
      if (activeWorkspace.elementAnimations.containsKey(idx)) {
        switch (key) {
          case 'speed': activeWorkspace.elementAnimations[idx]!.speed = value; break;
          case 'delay': activeWorkspace.elementAnimations[idx]!.delay = value; break;
          case 'iter': activeWorkspace.elementAnimations[idx]!.iter = value; break;
          case 'dir': activeWorkspace.elementAnimations[idx]!.dir = value; break;
          case 'directionAngle': activeWorkspace.elementAnimations[idx]!.directionAngle = value; break;
        }
      }
    }
  }
  
  void _syncGroupIfNeeded(int index, AnimationConfig config) {
    final groupId = activeWorkspace.elementGroups.keys.firstWhere(
      (gid) => activeWorkspace.elementGroups[gid]!.elements.contains(index),
      orElse: () => '',
    );
    if (groupId.isEmpty) return;
    
    final group = activeWorkspace.elementGroups[groupId]!;
    group.config = AnimationConfig.fromJson(config.toJson());
    
    for (final idx in group.elements) {
      activeWorkspace.elementAnimations[idx] = AnimationConfig.fromJson(config.toJson());
    }
  }
  
  void _resetAnimationState() {
    activeWorkspace.elementAnimations = {};
    activeWorkspace.elementGroups = {};
    activeWorkspace.selectedElementIndex = null;
    activeWorkspace.selectedGroupElements = [];
    activeWorkspace.selectedGroupId = null;
    activeWorkspace.isMultiSelectMode = false;
    activeWorkspace.nextGroupId = 1;
    activeWorkspace.trajectories = {};
    activeWorkspace.nextTrajId = 1;
    activeWorkspace.isTrajectoryMode = false;
    activeWorkspace.selectedTrajectoryId = null;
    activeWorkspace.undoStack = [];
    activeWorkspace.undoIndex = -1;
  }
  
  void _saveActiveWorkspace() {
    // Persistir en Hive
    _saveWorkspaces();
  }
  
  void _restoreWorkspace(Workspace ws) {
    // Restaurar estado desde workspace
  }
  
  Future<void> _loadWorkspaces() async {
    // Cargar desde Hive
  }
  
  Future<void> _saveWorkspaces() async {
    // Guardar en Hive
  }
  
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${uuid.v4().substring(0, 8)}';
  }
  
  String _getNextGroupColor(int groupId) {
    const colors = ['#6c5ce7', '#e74c3c', '#2ecc71', '#f39c12', '#1abc9c', '#9b59b6', '#3498db', '#e67e22'];
    return colors[(groupId - 1) % colors.length];
  }
}
```

---

## 6. SERVICIOS

### SvgParser
```dart
class SvgParser {
  static const animatedTags = ['circle', 'rect', 'ellipse', 'path', 'line', 'polyline', 'polygon', 'g', 'text'];
  
  static SvgParseResult parse(String svgString) {
    try {
      final doc = XmlDocument.parse(svgString);
      final svg = doc.rootElement;
      
      if (svg.name.local != 'svg') {
        return SvgParseResult.error('No se encontró un elemento SVG válido');
      }
      
      final elements = <SvgElement>[];
      int index = 0;
      
      for (final child in svg.childElements) {
        if (animatedTags.contains(child.name.local)) {
          elements.add(SvgElement(
            index: index,
            tag: child.name.local,
            element: child,
          ));
          index++;
        }
      }
      
      // Buscar viewBox
      final viewBox = svg.getAttribute('viewBox') ?? '0 0 200 200';
      final parts = viewBox.split(RegExp(r'[\s,]+'));
      final vbWidth = parts.length >= 3 ? double.tryParse(parts[2]) ?? 200 : 200;
      final vbHeight = parts.length >= 4 ? double.tryParse(parts[3]) ?? 200 : 200;
      
      return SvgParseResult.success(
        elements: elements,
        viewBoxWidth: vbWidth,
        viewBoxHeight: vbHeight,
      );
    } catch (e) {
      return SvgParseResult.error('Error al parsear SVG: ${e.toString()}');
    }
  }
}

class SvgParseResult {
  final bool isSuccess;
  final String? error;
  final List<SvgElement> elements;
  final double viewBoxWidth;
  final double viewBoxHeight;
  
  SvgParseResult._({
    required this.isSuccess,
    this.error,
    List<SvgElement>? elements,
    this.viewBoxWidth = 200,
    this.viewBoxHeight = 200,
  }) : elements = elements ?? [];
  
  factory SvgParseResult.success({
    required List<SvgElement> elements,
    required double viewBoxWidth,
    required double viewBoxHeight,
  }) {
    return SvgParseResult._(
      isSuccess: true,
      elements: elements,
      viewBoxWidth: viewBoxWidth,
      viewBoxHeight: viewBoxHeight,
    );
  }
  
  factory SvgParseResult.error(String error) {
    return SvgParseResult._(
      isSuccess: false,
      error: error,
    );
  }
}

class SvgElement {
  final int index;
  final String tag;
  final XmlElement element;
  
  SvgElement({
    required this.index,
    required this.tag,
    required this.element,
  });
}
```

### AnimationEngine
```dart
class AnimationEngine {
  static Widget buildAnimation({
    required String presetId,
    required Widget child,
    required Animation<double> animation,
    required AnimationConfig config,
  }) {
    try {
      switch (presetId) {
        case 'rotate':
          return _buildRotate(child, animation);
        case 'wheel':
          return _buildWheel(child, animation);
        case 'pulse':
          return _buildPulse(child, animation);
        case 'bounce':
          return _buildBounce(child, animation, config.directionAngle);
        case 'gravity':
          return _buildGravity(child, animation, config.directionAngle);
        case 'slide':
          return _buildSlide(child, animation, config.directionAngle);
        case 'oval':
          return _buildOval(child, animation, config.ovalRx, config.ovalRy);
        case 'fade':
          return _buildFade(child, animation);
        case 'shake':
          return _buildShake(child, animation, config.directionAngle);
        case 'float':
          return _buildFloat(child, animation, config.directionAngle);
        case 'levitate':
          return _buildLevitate(child, animation, config.directionAngle);
        case 'arc':
          return _buildArc(child, animation, config.arcRx, config.arcRy, config.directionAngle);
        case 'radiate':
          return _buildRadiate(child, animation, config.arcRx, config.arcRy, config.directionAngle);
        case 'spin':
          return _buildSpin(child, animation);
        case 'glow':
          return _buildGlow(child, animation);
        case 'wave-sine':
          return _buildWaveSine(child, animation, config.directionAngle);
        case 'wave-square':
          return _buildWaveSquare(child, animation, config.directionAngle);
        case 'wave-triangle':
          return _buildWaveTriangle(child, animation, config.directionAngle);
        default:
          return child;
      }
    } catch (e) {
      debugPrint('Error building animation $presetId: $e');
      return child;
    }
  }
  
  static Widget _buildRotate(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: animation.value * 2 * 3.14159265359,
          child: child,
        );
      },
      child: child,
    );
  }
  
  static Widget _buildPulse(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = 1.0 + animation.value * 0.15;
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }
  
  static Widget _buildBounce(Widget child, Animation<double> animation, double angle) {
    final rad = angle * 3.14159265359 / 180;
    final dx = sin(rad) * animation.value * 20;
    final dy = -cos(rad) * animation.value * 20;
    
    return Transform.translate(
      offset: Offset(dx, dy),
      child: child,
    );
  }
  
  // ... otros métodos de animación similares
}
```

### ExportService
```dart
class ExportService {
  static Future<String> generateAnimatedSvg({
    required String originalSvg,
    required Map<int, AnimationConfig> elementAnimations,
    required Map<String, Trajectory> trajectories,
  }) async {
    try {
      final doc = XmlDocument.parse(originalSvg);
      final svg = doc.rootElement;
      
      String embeddedStyle = '';
      String elementStyles = '';
      
      elementAnimations.forEach((index, config) {
        if (config.presetId == null) return;
        
        // Generar keyframes
        final keyframes = _generateKeyframes(index, config);
        embeddedStyle += '$keyframes\n';
        
        // Generar estilo del elemento
        elementStyles += _generateElementStyle(index, config);
      });
      
      // Inyectar <style>
      final styleElement = XmlElement(
        XmlName('style'),
        [],
        [XmlText('$embeddedStyle\n$elementStyles')],
      );
      svg.children.insert(0, styleElement);
      
      return '<?xml version="1.0" encoding="UTF-8"?>\n${doc.toXml(pretty: true, indent: '  ')}';
    } catch (e) {
      debugPrint('Error generating SVG: $e');
      return originalSvg; // Fallback al SVG original
    }
  }
  
  static Future<void> saveToDevice(String svgContent, String fileName) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar SVG Animado',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['svg'],
      );
      
      if (result == null) return;
      
      final file = File(result);
      await file.writeAsString(svgContent, flush: true);
    } catch (e) {
      debugPrint('Error saving file: $e');
      rethrow;
    }
  }
  
  static String _generateKeyframes(int index, AnimationConfig config) {
    switch (config.presetId) {
      case 'rotate':
        return '@keyframes svgRotate { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }';
      case 'pulse':
        return '@keyframes svgPulse { 0%,100% { transform: scale(1); } 50% { transform: scale(1.15); } }';
      case 'bounce':
        if (config.directionAngle != 0) {
          return _generateDirectionalKeyframes('bounce', index, config);
        }
        return '@keyframes svgBounce { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-20px); } }';
      // ... otros presets
      default:
        return '';
    }
  }
  
  static String _generateDirectionalKeyframes(String presetId, int index, AnimationConfig config) {
    final rad = config.directionAngle * 3.14159265359 / 180;
    final cosA = cos(rad);
    final sinA = sin(rad);
    
    switch (presetId) {
      case 'bounce':
        return '@keyframes bounce_${index}_${config.directionAngle.toInt()} { 0%,100% { transform: translate(0,0); } 50% { transform: translate(${sinA * 20}px, ${-cosA * 20}px); } }';
      // ... otros presets
      default:
        return '';
    }
  }
  
  static String _generateElementStyle(int index, AnimationConfig config) {
    return '[data-anim-index="$index"] { animation: ${config.presetId} ${config.speed}s ${config.dir}; animation-delay: ${config.delay}s; }';
  }
}
```

---

## 7. WIDGETS PRINCIPALES

### HomeScreen
```dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPanel = -1; // -1 = cerrado
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: SvgPreview()),
          if (_selectedPanel >= 0) _buildPanel(),
        ],
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedPanel,
        onTabChanged: (index) {
          setState(() {
            _selectedPanel = _selectedPanel == index ? -1 : index;
          });
        },
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      title: Consumer<SvgProvider>(
        builder: (context, provider, _) {
          return Text(
            provider.activeWorkspace.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.undo),
          onPressed: context.watch<SvgProvider>().canUndo 
              ? () => context.read<SvgProvider>().undo() 
              : null,
        ),
        IconButton(
          icon: Icon(Icons.redo),
          onPressed: context.watch<SvgProvider>().canRedo 
              ? () => context.read<SvgProvider>().redo() 
              : null,
        ),
      ],
    );
  }
  
  Widget _buildPanel() {
    switch (_selectedPanel) {
      case 0:
        return PanelSlider(child: ImportPanel());
      case 1:
        return PanelSlider(child: AnimationPanel());
      case 2:
        return PanelSlider(child: ControlsPanel());
      case 3:
        return PanelSlider(child: PiecesPanel());
      case 4:
        return PanelSlider(child: ExportPanel());
      default:
        return SizedBox.shrink();
    }
  }
}
```

### SvgPreview
```dart
class SvgPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        if (provider.currentSvgString == null) {
          return EmptyState();
        }
        
        return InteractiveViewer(
          minScale: 0.2,
          maxScale: 5.0,
          child: Stack(
            children: [
              // Capa de fondos
              BackgroundLayer(),
              
              // SVG renderizado
              SvgPicture.string(
                provider.currentSvgString!,
                fit: BoxFit.contain,
                placeholderBuilder: (context) => Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              
              // Overlay de trayectorias
              if (provider.activeWorkspace.isTrajectoryMode)
                TrajectoryOverlay(),
              
              // Overlay de modo piezas
              if (provider.activeWorkspace.isPiecesMode)
                PiecesOverlay(),
              
              // Controles de zoom
              ZoomControls(),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 8. CONSTANTES

### AppColors
```dart
class AppColors {
  static const background = Color(0xFF0F1117);
  static const surface = Color(0xFF1A1D27);
  static const surface2 = Color(0xFF242734);
  static const border = Color(0xFF2E3245);
  static const text = Color(0xFFE4E6F0);
  static const textDim = Color(0xFF8B8FA7);
  static const accent = Color(0xFF6C5CE7);
  static const accentHover = Color(0xFF7C6EF7);
  static const danger = Color(0xFFE74C3C);
  static const success = Color(0xFF2ECC71);
  
  static const groupColors = [
    '#6c5ce7', '#e74c3c', '#2ecc71', '#f39c12',
    '#1abc9c', '#9b59b6', '#3498db', '#e67e22',
  ];
}
```

### AnimationPresets
```dart
class AnimationPresets {
  static const List<Map<String, dynamic>> presets = [
    {'name': 'Rotar', 'id': 'rotate', 'color': '#6c5ce7', 'duration': 2.0, 'easing': 'linear'},
    {'name': 'Rueda', 'id': 'wheel', 'color': '#e74c3c', 'duration': 3.0, 'easing': 'linear'},
    {'name': 'Pulsar', 'id': 'pulse', 'color': '#e67e22', 'duration': 1.5, 'easing': 'easeInOut'},
    {'name': 'Rebotar', 'id': 'bounce', 'color': '#2ecc71', 'duration': 0.8, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Gravedad', 'id': 'gravity', 'color': '#1abc9c', 'duration': 1.5, 'easing': 'easeOut', 'translatable': true},
    {'name': 'Deslizar', 'id': 'slide', 'color': '#f39c12', 'duration': 2.0, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Óvalo', 'id': 'oval', 'color': '#9b59b6', 'duration': 3.0, 'easing': 'linear'},
    {'name': 'Desvanecer', 'id': 'fade', 'color': '#e74c3c', 'duration': 2.0, 'easing': 'easeInOut'},
    {'name': 'Dibujar', 'id': 'draw', 'color': '#1abc9c', 'duration': 2.0, 'easing': 'easeInOut'},
    {'name': 'Temblar', 'id': 'shake', 'color': '#e67e22', 'duration': 0.5, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Flotar', 'id': 'float', 'color': '#9b59b6', 'duration': 3.0, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Levitar', 'id': 'levitate', 'color': '#1abc9c', 'duration': 3.5, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Arco', 'id': 'arc', 'color': '#f39c12', 'duration': 4.0, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Radiar', 'id': 'radiate', 'color': '#e67e22', 'duration': 4.0, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Girar', 'id': 'spin', 'color': '#3498db', 'duration': 1.2, 'easing': 'easeInOut'},
    {'name': 'Brillar', 'id': 'glow', 'color': '#e74c3c', 'duration': 2.0, 'easing': 'easeInOut'},
    {'name': 'Senoidal', 'id': 'wave-sine', 'color': '#1abc9c', 'duration': 3.0, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Cuadrada', 'id': 'wave-square', 'color': '#e74c3c', 'duration': 1.5, 'easing': 'linear', 'translatable': true},
    {'name': 'Triangular', 'id': 'wave-triangle', 'color': '#9b59b6', 'duration': 2.0, 'easing': 'linear', 'translatable': true},
  ];
  
  static const List<Map<String, dynamic>> shapes = [
    {'name': 'Círculo', 'svg': '<svg viewBox="0 0 200 200"><circle cx="100" cy="100" r="70" fill="none" stroke="#6c5ce7" stroke-width="3"/></svg>'},
    {'name': 'Cuadrado', 'svg': '<svg viewBox="0 0 200 200"><rect x="30" y="30" width="140" height="140" rx="8" fill="none" stroke="#e74c3c" stroke-width="3"/></svg>'},
    {'name': 'Triángulo', 'svg': '<svg viewBox="0 0 200 200"><polygon points="100,20 180,170 20,170" fill="none" stroke="#2ecc71" stroke-width="3"/></svg>'},
    {'name': 'Estrella', 'svg': '<svg viewBox="0 0 200 200"><polygon points="100,15 125,75 190,80 140,125 155,190 100,155 45,190 60,125 10,80 75,75" fill="none" stroke="#f39c12" stroke-width="3"/></svg>'},
    {'name': 'Corazón', 'svg': '<svg viewBox="0 0 200 200"><path d="M100 170 C60 130 20 100 20 65 C20 35 45 15 70 15 C85 15 95 25 100 35 C105 25 115 15 130 15 C155 15 180 35 180 65 C180 100 140 130 100 170Z" fill="none" stroke="#e74c3c" stroke-width="3"/></svg>'},
    {'name': 'Hexágono', 'svg': '<svg viewBox="0 0 200 200"><polygon points="100,15 175,50 175,140 100,180 25,140 25,50" fill="none" stroke="#1abc9c" stroke-width="3"/></svg>'},
    {'name': 'Rombo', 'svg': '<svg viewBox="0 0 200 200"><polygon points="100,15 185,100 100,185 15,100" fill="none" stroke="#9b59b6" stroke-width="3"/></svg>'},
    {'name': 'Cruz', 'svg': '<svg viewBox="0 0 200 200"><path d="M70 30 H130 V70 H170 V130 H130 V170 H70 V130 H30 V70 H70 Z" fill="none" stroke="#3498db" stroke-width="3"/></svg>'},
    {'name': 'Onda', 'svg': '<svg viewBox="0 0 200 200"><path d="M20 100 Q50 60 80 100 Q110 140 140 100 Q170 60 200 100" fill="none" stroke="#e67e22" stroke-width="3"/></svg>'},
    {'name': 'Flecha', 'svg': '<svg viewBox="0 0 200 200"><path d="M100 30 L170 100 L130 100 L130 170 L70 170 L70 100 L30 100 Z" fill="none" stroke="#6c5ce7" stroke-width="3"/></svg>'},
    {'name': 'Rayo', 'svg': '<svg viewBox="0 0 200 200"><polygon points="115,15 50,105 90,105 80,185 155,90 110,90" fill="none" stroke="#f1c40f" stroke-width="3"/></svg>'},
    {'name': 'Luna', 'svg': '<svg viewBox="0 0 200 200"><path d="M120 30 A65 65 0 1 0 120 170 A50 50 0 1 1 120 30" fill="none" stroke="#8e44ad" stroke-width="3"/></svg>'},
  ];
}
```

---

## 9. MANEJO DE PERMISOS

```dart
class PermissionService {
  static Future<bool> requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.status;
        if (status.isGranted) return true;
        
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      
      if (Platform.isIOS) {
        // iOS no necesita permiso de lectura para archivos propios
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }
  
  static Future<bool> requestPhotosPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.photos.status;
        if (status.isGranted) return true;
        
        final result = await Permission.photos.request();
        return result.isGranted;
      }
      
      if (Platform.isIOS) {
        final status = await Permission.photos.status;
        if (status.isGranted) return true;
        
        final result = await Permission.photos.request();
        return result.isGranted;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error requesting photos permission: $e');
      return false;
    }
  }
}
```

---

## 10. MAIN.DART

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'providers/svg_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Forzar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Inicializar Hive
  await Hive.initFlutter();
  
  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF1A1D27),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SvgProvider()..init()),
      ],
      child: SvgAnimatorApp(),
    ),
  );
}
```

---

## 11. CHECKLIST DE CALIDAD

### Compilación
- [ ] `flutter analyze` sin errores
- [ ] `flutter build apk --release` exitoso
- [ ] `flutter build ios --release` exitoso (si hay Mac)

### Runtime
- [ ] La app inicia sin crashes
- [ ] Cargar SVG funciona sin errores
- [ ] Las animaciones se aplican correctamente
- [ ] El modo piezas funciona con touch
- [ ] El undo/redo funciona
- [ ] La exportación genera SVG válido
- [ ] No hay memory leaks (AnimationController.dispose)

### UX
- [ ] Touch targets ≥ 44px
- [ ] Sliders se usan fácilmente con dedo
- [ ] Paneles se abren/cierran suavemente
- [ ] Loading states se muestran
- [ ] Errores muestran SnackBar amigable

### Persistencia
- [ ] Workspaces se guardan en Hive
- [ ] La app restaura estado al reiniciar
- [ ] Los archivos se guardan correctamente

---

## 12. ERRORES COMUNES A EVITAR

1. **NO usar `setState` sin `mounted` check** en async methods
2. **NO olvidar `dispose()`** de AnimationController
3. **NO usar `File` sin verificar `exists()`**
4. **NO parsear SVG sin try-catch**
5. **NO serializar sin null safety**
6. **NO olvidar `flush: true`** en `writeAsString`
7. **NO usar `Navigator.push` sin context válido**
8. **NO olvidar `notifyListeners()`** después de modificar estado
9. **NO usar `Container` con `color` + `decoration`** (causa error)
10. **NO olvidar `key` en `ListView.builder` items**
