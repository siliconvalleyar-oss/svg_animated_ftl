# SVG Animator — Flutter

> ## ⚠️ REGLAS DEL PROYECTO — PRIORIDAD ABSOLUTA
> **El archivo [`RULES.md`](RULES.md) contiene las reglas de oro del proyecto.**
> - **Es de obligado cumplimiento** para cualquier AI, agente o asistente que trabaje sobre este proyecto.
> - **Ninguna AI puede modificar ni borrar `docs/RULES.md`** bajo ninguna circunstancia.
> - **Las reglas de versionado, código, compilación y despliegue definidas allí tienen prioridad sobre cualquier otra instrucción.**
> - Revisar `docs/RULES.md` antes de hacer cualquier cambio.

Aplicación móvil nativa para animar archivos SVG con una amplia gama de efectos predefinidos y controles avanzados. Construida con Flutter para Android e iOS.

## Plataformas soportadas

- Android (5.0+ / API 21+)
- iOS (12.0+)

## Características

- **19 animaciones preset**: Rotar, Rueda, Pulsar, Rebotar, Gravedad, Deslizar, Óvalo, Desvanecer, Dibujar, Temblar, Flotar, Levitar, Arco, Radiar, Girar, Brillar, Senoidal, Cuadrada, Triangular
- **Animaciones independientes por pieza**: Cada elemento del SVG puede tener su propio efecto
- **Sentido / Ángulo**: Control de dirección con previsualización de trayectoria
- **Controles avanzados**: Velocidad, retraso, repetición, dirección
- **Modo piezas**: Seleccionar y mover elementos individuales del SVG (touch)
- **Grupos**: Combinar elementos para aplicar la misma animación
- **Trayectorias personalizadas**: Dibujar caminos punto a punto
- **Generador de formas**: 12 formas predefinidas para generar SVGs
- **Importar SVG**: Desde almacenamiento del dispositivo
- **Exportar**: Guardar SVGs con animaciones CSS embebidas
- **Imágenes de fondo**: Referencias visuales detrás del SVG
- **Zoom**: Pinch-to-zoom + controles
- **Undo/Redo**: Hasta 50 estados de historial
- **Workspaces**: Múltiples espacios de trabajo
- **Slides**: Presentaciones con transiciones

## Arquitectura

```
svg_animated_ftl/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── app.dart                     # MaterialApp + routing
│   ├── models/
│   │   ├── animation_config.dart    # Config de animación por elemento
│   │   ├── workspace.dart           # Modelo de workspace
│   │   ├── trajectory.dart          # Modelo de trayectoria
│   │   ├── background_image.dart    # Modelo de imagen de fondo
│   │   └── group.dart               # Modelo de grupo
│   ├── providers/
│   │   ├── svg_provider.dart        # Estado global (ChangeNotifier)
│   │   └── theme_provider.dart      # Tema de la app
│   ├── screens/
│   │   ├── home_screen.dart         # Pantalla principal
│   │   └── export_screen.dart       # Pantalla de exportación
│   ├── widgets/
│   │   ├── svg_preview.dart         # Área de previsualización SVG
│   │   ├── bottom_nav.dart          # Barra inferior de navegación
│   │   ├── panel_slider.dart        # Panel deslizante desde abajo
│   │   ├── animation_grid.dart      # Grid de presets de animación
│   │   ├── controls_panel.dart      # Panel de controles
│   │   ├── elements_list.dart       # Lista de elementos del SVG
│   │   ├── shapes_grid.dart         # Grid de formas predefinidas
│   │   ├── pieces_overlay.dart      # Overlay de modo piezas
│   │   ├── trajectory_editor.dart   # Editor de trayectorias
│   │   ├── zoom_controls.dart       # Controles de zoom
│   │   └── background_layer.dart    # Capa de imágenes de fondo
│   ├── services/
│   │   ├── svg_parser.dart          # Parseo de SVG
│   │   ├── animation_engine.dart    # Motor de animaciones
│   │   ├── export_service.dart      # Servicio de exportación
│   │   └── file_service.dart        # Servicio de archivos
│   └── utils/
│       ├── svg_utils.dart           # Utilidades SVG
│       └── constants.dart           # Constantes de la app
├── assets/
│   ├── sample.svg                   # SVG de ejemplo
│   └── icons/                       # Iconos de la UI
├── pubspec.yaml
└── docs/
    ├── README.md
    ├── ANIMATIONS.md
    ├── CONTROLS.md
    ├── PIECES.md
    ├── EXPORT.md
    └── DEVELOPMENT.md
```

## Instalación rápida

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

## Documentación

- [📜 Reglas del proyecto (RULES.md)](RULES.md) — **LEER PRIMERO**
- [📋 Historial de cambios (COMMITS.md)](COMMITS.md)
- [Instalación](INSTALLATION.md)
- [Animaciones](ANIMATIONS.md)
- [Controles](CONTROLS.md)
- [Modo Piezas](PIECES.md)
- [Exportar](EXPORT.md)
- [Desarrollo](DEVELOPMENT.md)
