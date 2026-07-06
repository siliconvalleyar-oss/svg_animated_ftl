# SVG Animator — Flutter

> ## REGLAS DEL PROYECTO — PRIORIDAD ABSOLUTA
> **El archivo [`RULES.md`](RULES.md) contiene las reglas de oro del proyecto.**
> - **Es de obligado cumplimiento** para cualquier AI, agente o asistente que trabaje sobre este proyecto.
> - **Ninguna AI puede modificar ni borrar `docs/RULES.md`** bajo ninguna circunstancia.
> - **Las reglas de versionado, codigo, compilacion y despliegue definidas alli tienen prioridad sobre cualquier otra instruccion.**
> - Revisar `docs/RULES.md` antes de hacer cualquier cambio.

Aplicacion movil nativa para animar archivos SVG con una amplia gama de efectos predefinidos y controles avanzados. Construida con Flutter para Android e iOS.

## Plataformas soportadas

- Android (5.0+ / API 21+)
- iOS (12.0+)

## Caracteristicas

- **24 animaciones preset**: Rotar, Rueda, Pulsar, Rebotar, Gravedad, Deslizar, Ovalo, Desvanecer, Dibujar, Temblar, Flotar, Levitar, Tiro Oblicuo, Radiar, Girar, Brillar, Senoidal, Cuadrada, Triangular, Pendulo, Caida Libre, Rebote elastico, Resorte, Opacidad
- **Animaciones independientes por pieza**: Cada elemento del SVG puede tener su propio efecto
- **Multi-seleccion**: Seleccionar multiples piezas para aplicar controles a todas
- **Grupos**: Combinar elementos para animacion sincronizada con mismo eje
- **Sentido / Angulo**: Control de direccion con previsualizacion de trayectoria
- **Controles avanzados**: Velocidad, retraso, iteracion, direccion, opacidad
- **Fisica real**: Tiro oblicuo con formulas de fisica (v0, theta, g), pendulo, caida libre, resorte
- **Modo piezas**: Seleccionar y mover elementos individuales del SVG (touch)
- **Trayectorias personalizadas**: Dibujar caminos punto a punto
- **Generador de formas**: 12 formas predefinidas para generar SVGs
- **Importar SVG**: Desde almacenamiento del dispositivo o pegando codigo SVG
- **Exportar**: Guardar SVGs con animaciones CSS embebidas
- **Zoom**: Pinch-to-zoom + controles
- **Undo/Redo**: Hasta 50 estados de historial
- **Workspaces**: Multiples espacios de trabajo con persistencia Hive

## Arquitectura

```
svg_animated_ftl/
├── lib/
│   ├── main.dart                    # Entry point, Hive init, Provider setup
│   ├── app.dart                     # MaterialApp + dark theme
│   ├── core/
│   │   ├── constants.dart           # AppColors, AnimationPresets (24 presets + 12 shapes), AppConstants
│   │   ├── theme.dart               # AppTheme.darkTheme
│   │   └── extensions.dart          # String.capitalize(), Double.toFixed()
│   ├── models/
│   │   ├── animation_config.dart    # AnimationConfig (HiveType typeId:0, 19 campos)
│   │   ├── workspace.dart           # Workspace (modelo central, 29 campos)
│   │   ├── group.dart               # Group (nombre, color, elementos, config)
│   │   ├── trajectory.dart          # Trajectory + TrajectoryPoint
│   │   ├── background_image.dart    # BackgroundImage (ruta, posicion, opacidad)
│   │   └── svg_element.dart         # SvgElement (index, tag, XmlElement)
│   ├── providers/
│   │   ├── svg_provider.dart        # Estado global (ChangeNotifier, 375 lineas)
│   │   ├── settings_provider.dart   # Settings (export path, opacidades, speed)
│   │   └── theme_provider.dart      # Theme toggle (dark/light)
│   ├── screens/
│   │   ├── splash_screen.dart       # Splash 3s con fade + logo
│   │   └── home_screen.dart         # Pantalla principal (596 lineas, 4 tabs)
│   ├── widgets/
│   │   ├── svg_preview.dart         # Preview con InteractiveViewer + AnimationScope
│   │   ├── individual_elements_view.dart  # Renderiza cada elemento SVG animado
│   │   ├── animation_scope.dart     # InheritedWidget con AnimationController compartido
│   │   ├── animation_grid.dart      # Grid 4 columnas de 24 presets
│   │   ├── controls_panel.dart      # Sliders + toggles + direction pad
│   │   ├── elements_list.dart       # Lista de elementos con seleccion y grupos
│   │   ├── shapes_grid.dart         # Grid de 12 formas predefinidas
│   │   ├── pieces_overlay.dart      # Overlay interactivo para modo piezas
│   │   ├── trajectory_overlay.dart  # CustomPainter de trayectorias
│   │   ├── trajectory_editor.dart   # Editor de trayectorias
│   │   ├── zoom_controls.dart       # Controles de zoom flotantes
│   │   ├── background_layer.dart    # Capa de imagenes de fondo
│   │   ├── bottom_nav.dart          # Barra inferior con 4 tabs
│   │   ├── panel_slider.dart        # Panel deslizante animado
│   │   ├── slider_control.dart      # Slider reutilizable
│   │   ├── toggle_group.dart        # Toggle buttons reutilizables
│   │   ├── direction_pad.dart       # Pad 8 direcciones cardinales
│   │   └── empty_state.dart         # Estado vacio del preview
│   ├── services/
│   │   ├── svg_parser.dart          # Parseo SVG con xml package
│   │   ├── animation_engine.dart    # 24 animaciones (460 lineas, static methods)
│   │   ├── animation_service.dart   # Gestion de configs de animacion
│   │   ├── selection_service.dart   # Logica de seleccion
│   │   ├── group_service.dart       # CRUD de grupos
│   │   ├── history_service.dart     # Undo/Redo via snapshots
│   │   ├── trajectory_service.dart  # CRUD de trayectorias
│   │   ├── export_service.dart      # Genera SVG con CSS keyframes (288 lineas)
│   │   ├── file_service.dart        # CRUD archivos en dispositivo
│   │   └── permission_service.dart  # Permisos Android/iOS
├── test/
│   ├── widget_test.dart             # Tests de widgets principales
│   ├── widget_components_test.dart  # Tests de componentes reutilizables
│   ├── models_test.dart             # Tests de modelos
│   ├── providers_test.dart          # Tests de providers
│   └── services/                    # Tests de servicios (7 archivos)
├── assets/
│   ├── logo.svg, logo.png, example.svg
│   ├── car_animated.svg             # Logo de splash
│   └── svg/, riv/, example/         # Assets adicionales
├── reports/                         # Reportes de QA y analisis
├── docs/                            # Documentacion del proyecto
└── pubspec.yaml
```

## Instalacion rapida

### Requisitos
- Flutter SDK 3.0+
- Android Studio o VS Code con plugin Flutter
- Dispositivo Android o simulador

### Ejecutar
```bash
cd svg_animated_ftl
flutter pub get
flutter run
```

### Build release
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (requiere Xcode)
flutter build ios --release
```

## Documentacion

- [Reglas del proyecto (RULES.md)](RULES.md) — **LEER PRIMERO**
- [Historial de cambios (COMMITS.md)](COMMITS.md)
- [Instalacion](INSTALLATION.md)
- [Analisis completo](ANALYSIS.md)
- [Animaciones](ANIMATIONS.md)
- [Controles](CONTROLS.md)
- [Modo Piezas](PIECES.md)
- [Exportar](EXPORT.md)
- [Desarrollo](DEVELOPMENT.md)
- [Bugs conocidos](BUGS.md)
