# TODO — SVG Animated FTL

## Estado del Proyecto

Aplicación móvil Flutter para animar archivos SVG. 100% offline, sin crashes, performante.

---

## FASE 1: Setup del Proyecto

- [x] Definir estructura de archivos y dependencias en `pubspec.yaml`
- [ ] Crear proyecto Flutter con `flutter create svg_animated_ftl`
- [ ] Configurar `.gitignore` para Flutter
- [ ] Configurar `.gitignore` para Dart/Hive/build artifacts
- [ ] Agregar dependencias al `pubspec.yaml`
- [ ] Ejecutar `flutter pub get`
- [ ] Configurar `build_runner` para Hive type adapters

---

## FASE 2: Modelos de Datos

- [ ] Crear `lib/core/constants.dart` — colores, dimensiones, valores por defecto
- [ ] Crear `lib/core/theme.dart` — tema oscuro de la app
- [ ] Crear `lib/core/extensions.dart` — extensiones de Dart
- [ ] Crear `lib/models/animation_config.dart` — config de animación por elemento
- [ ] Crear `lib/models/workspace.dart` — modelo de workspace
- [ ] Crear `lib/models/trajectory.dart` — modelo de trayectoria
- [ ] Crear `lib/models/trajectory_point.dart` — punto de trayectoria
- [ ] Crear `lib/models/group.dart` — modelo de grupo
- [ ] Crear `lib/models/background_image.dart` — modelo de imagen de fondo
- [ ] Crear `lib/models/svg_element.dart` — elemento SVG parseado
- [ ] Generar type adapters de Hive con `build_runner`

---

## FASE 3: Servicios

- [ ] Crear `lib/services/svg_parser.dart` — parseo de SVG con xml
- [ ] Crear `lib/services/animation_engine.dart` — motor de animaciones
- [ ] Crear `lib/services/export_service.dart` — servicio de exportación
- [ ] Crear `lib/services/file_service.dart` — servicio de archivos
- [ ] Crear `lib/utils/svg_utils.dart` — utilidades SVG
- [ ] Crear `lib/utils/math_utils.dart` — utilidades matemáticas
- [ ] Crear `lib/utils/file_utils.dart` — utilidades de archivos

---

## FASE 4: Providers (Estado)

- [ ] Crear `lib/providers/svg_provider.dart` — estado global (ChangeNotifier)
- [ ] Crear `lib/providers/theme_provider.dart` — tema de la app

---

## FASE 5: Widgets Base

- [ ] Crear `lib/widgets/empty_state.dart` — estado vacío del preview
- [ ] Crear `lib/widgets/slider_control.dart` — slider reutilizable
- [ ] Crear `lib/widgets/toggle_group.dart` — grupo de toggles reutilizable
- [ ] Crear `lib/widgets/zoom_controls.dart` — controles de zoom
- [ ] Crear `lib/widgets/direction_pad.dart` — pad de direcciones cardinales
- [ ] Crear `lib/widgets/background_layer.dart` — capa de imágenes de fondo
- [ ] Crear `lib/widgets/bottom_nav.dart` — barra inferior de navegación
- [ ] Crear `lib/widgets/panel_slider.dart` — panel deslizante desde abajo

---

## FASE 6: Widgets de Elementos

- [ ] Crear `lib/widgets/elements_list.dart` — lista de elementos del SVG
- [ ] Crear `lib/widgets/element_tile.dart` — tile individual de elemento
- [ ] Crear `lib/widgets/shapes_grid.dart` — grid de formas predefinidas
- [ ] Crear `lib/widgets/shape_button.dart` — botón individual de forma

---

## FASE 7: Widgets de Animación

- [ ] Crear `lib/widgets/animation_grid.dart` — grid de presets de animación
- [ ] Crear `lib/widgets/animation_preset_button.dart` — botón individual de preset
- [ ] Crear `lib/widgets/controls_panel.dart` — panel de controles

---

## FASE 8: Animaciones Individuales

- [ ] Crear `lib/widgets/animations/rotate_animation.dart`
- [ ] Crear `lib/widgets/animations/wheel_animation.dart`
- [ ] Crear `lib/widgets/animations/pulse_animation.dart`
- [ ] Crear `lib/widgets/animations/bounce_animation.dart`
- [ ] Crear `lib/widgets/animations/gravity_animation.dart`
- [ ] Crear `lib/widgets/animations/slide_animation.dart`
- [ ] Crear `lib/widgets/animations/oval_animation.dart`
- [ ] Crear `lib/widgets/animations/fade_animation.dart`
- [ ] Crear `lib/widgets/animations/draw_animation.dart`
- [ ] Crear `lib/widgets/animations/shake_animation.dart`
- [ ] Crear `lib/widgets/animations/float_animation.dart`
- [ ] Crear `lib/widgets/animations/levitate_animation.dart`
- [ ] Crear `lib/widgets/animations/arc_animation.dart`
- [ ] Crear `lib/widgets/animations/radiate_animation.dart`
- [ ] Crear `lib/widgets/animations/spin_animation.dart`
- [ ] Crear `lib/widgets/animations/glow_animation.dart`
- [ ] Crear `lib/widgets/animations/wave_sine_animation.dart`
- [ ] Crear `lib/widgets/animations/wave_square_animation.dart`
- [ ] Crear `lib/widgets/animations/wave_triangle_animation.dart`

---

## FASE 9: Widgets de Modos Especiales

- [ ] Crear `lib/widgets/pieces_overlay.dart` — overlay de modo piezas
- [ ] Crear `lib/widgets/trajectory_editor.dart` — editor de trayectorias
- [ ] Crear `lib/widgets/trajectory_overlay.dart` — overlay de puntos de trayectoria

---

## FASE 10: Pantalla Principal

- [ ] Crear `lib/widgets/svg_preview.dart` — área de previsualización SVG
- [ ] Crear `lib/screens/home_screen.dart` — pantalla principal

---

## FASE 11: App Entry Point

- [ ] Crear `lib/app.dart` — MaterialApp, tema, rutas
- [ ] Crear `lib/main.dart` — entry point, inicialización Hive

---

## FASE 12: Assets

- [ ] Verificar `assets/logo.svg` existe y es válido
- [ ] Verificar `assets/car_animated.svg` existe
- [ ] Verificar `assets/icon.png` existe
- [ ] Agregar assets faltantes al `pubspec.yaml`

---

## FASE 13: Testing

- [ ] Crear tests unitarios para `SvgParser`
- [ ] Crear tests unitarios para `AnimationEngine`
- [ ] Crear tests unitarios para modelos (AnimationConfig, Workspace, etc.)
- [ ] Crear tests de widget para `HomeScreen`
- [ ] Crear tests de widget para `SvgPreview`
- [ ] Ejecutar `flutter test` y verificar coverage

---

## FASE 14: Build y Release

- [ ] `flutter analyze` sin errores
- [ ] `flutter build apk --release` exitoso
- [ ] `flutter build appbundle --release` exitoso
- [ ] Verificar que la app inicia sin crashes en dispositivo real
- [ ] Probar carga de SVG completo
- [ ] Probar todas las animaciones en dispositivo
- [ ] Probar modo piezas en touch
- [ ] Probar exportación de SVG animado
- [ ] Probar undo/redo
- [ ] Probar persistencia de workspaces (reiniciar app)

---

## FASE 15: Git

- [ ] Crear repositorio en GitHub: `siliconvalleyar-oss/svg_animated_ftl`
- [ ] Push inicial con `.gitignore`
- [ ] Push de código completo
- [ ] Verificar que no se suben archivos sensibles o innecesarios

---

## ERRORES COMUNES A EVITAR

1. NO usar `setState` sin `mounted` check en async methods
2. NO olvidar `dispose()` de AnimationController
3. NO usar `File` sin verificar `exists()`
4. NO parsear SVG sin try-catch
5. NO serializar sin null safety
6. NO olvidar `flush: true` en `writeAsString`
7. NO usar `Navigator.push` sin context válido
8. NO olvidar `notifyListeners()` después de modificar estado
9. NO usar `Container` con `color` + `decoration` (causa error)
10. NO olvidar `key` en `ListView.builder` items
