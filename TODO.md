# TODO — SVG Animated FTL

## Estado del Proyecto

Aplicación móvil Flutter para animar archivos SVG. 100% offline, sin crashes, performante.
**Versión actual:** v1.0.6 | **Animaciones:** 24 presets | **Archivos Dart:** 37

---

## FASE 1: Setup del Proyecto ✅

- [x] Definir estructura de archivos y dependencias en `pubspec.yaml`
- [x] Crear proyecto Flutter con `flutter create svg_animated_ftl`
- [x] Configurar `.gitignore` para Flutter
- [x] Configurar `.gitignore` para Dart/Hive/build artifacts
- [x] Agregar dependencias al `pubspec.yaml`
- [x] Ejecutar `flutter pub get`
- [x] Configurar `build_runner` para Hive type adapters

---

## FASE 2: Modelos de Datos ✅

- [x] Crear `lib/core/constants.dart` — colores, dimensiones, valores por defecto
- [x] Crear `lib/core/theme.dart` — tema oscuro de la app
- [x] Crear `lib/core/extensions.dart` — extensiones de Dart
- [x] Crear `lib/models/animation_config.dart` — config de animación por elemento
- [x] Crear `lib/models/workspace.dart` — modelo de workspace
- [x] Crear `lib/models/trajectory.dart` — modelo de trayectoria + trajectory_point
- [x] Crear `lib/models/group.dart` — modelo de grupo
- [x] Crear `lib/models/background_image.dart` — modelo de imagen de fondo
- [x] Crear `lib/models/svg_element.dart` — elemento SVG parseado
- [x] Generar type adapters de Hive con `build_runner`

---

## FASE 3: Servicios ✅

- [x] Crear `lib/services/svg_parser.dart` — parseo de SVG con xml
- [x] Crear `lib/services/animation_engine.dart` — motor de animaciones (24 presets)
- [x] Crear `lib/services/export_service.dart` — servicio de exportación
- [x] Crear `lib/services/file_service.dart` — servicio de archivos
- [x] Crear `lib/services/permission_service.dart` — permisos
- [ ] Crear `lib/utils/svg_utils.dart` — utilidades SVG
- [ ] Crear `lib/utils/math_utils.dart` — utilidades matemáticas
- [ ] Crear `lib/utils/file_utils.dart` — utilidades de archivos

---

## FASE 4: Providers (Estado) ✅

- [x] Crear `lib/providers/svg_provider.dart` — estado global (ChangeNotifier)
- [x] Crear `lib/providers/theme_provider.dart` — tema de la app

---

## FASE 5: Widgets Base ✅

- [x] Crear `lib/widgets/empty_state.dart` — estado vacío del preview
- [x] Crear `lib/widgets/slider_control.dart` — slider reutilizable
- [x] Crear `lib/widgets/toggle_group.dart` — grupo de toggles reutilizable
- [x] Crear `lib/widgets/zoom_controls.dart` — controles de zoom
- [x] Crear `lib/widgets/direction_pad.dart` — pad de direcciones cardinales
- [x] Crear `lib/widgets/background_layer.dart` — capa de imágenes de fondo
- [x] Crear `lib/widgets/bottom_nav.dart` — barra inferior de navegación
- [x] Crear `lib/widgets/panel_slider.dart` — panel deslizante desde abajo

---

## FASE 6: Widgets de Elementos ✅

- [x] Crear `lib/widgets/elements_list.dart` — lista de elementos + grupos
- [x] Crear `lib/widgets/shapes_grid.dart` — grid de formas predefinidas

---

## FASE 7: Widgets de Animación ✅

- [x] Crear `lib/widgets/animation_grid.dart` — grid de presets de animación (24)
- [x] Crear `lib/widgets/controls_panel.dart` — panel de controles + opacidad + física

---

## FASE 8: Animaciones ✅ (implementadas en animation_engine.dart)

- [x] Todas las 24 animaciones implementadas en `lib/services/animation_engine.dart`
- [ ] Crear archivos individuales en `lib/widgets/animations/` (alternativa)
  - rotate, wheel, pulse, bounce, gravity, slide, oval, fade, draw
  - shake, float, levitate, projectile, radiate, spin, glow
  - wave-sine, wave-square, wave-triangle
  - pendulum, freefall, elastic-bounce, spring, opacity-anim

---

## FASE 9: Widgets de Modos Especiales ✅

- [x] Crear `lib/widgets/pieces_overlay.dart` — overlay de modo piezas
- [x] Crear `lib/widgets/trajectory_editor.dart` — editor de trayectorias
- [x] Crear `lib/widgets/trajectory_overlay.dart` — overlay de puntos de trayectoria

---

## FASE 10: Pantalla Principal ✅

- [x] Crear `lib/widgets/svg_preview.dart` — área de previsualización SVG
- [x] Crear `lib/screens/home_screen.dart` — pantalla principal con 5 paneles

---

## FASE 11: App Entry Point ✅

- [x] Crear `lib/app.dart` — MaterialApp, tema, rutas
- [x] Crear `lib/main.dart` — entry point, inicialización Hive

---

## FASE 12: Assets ✅

- [x] Verificar `assets/logo.svg` existe y es válido
- [x] Verificar `assets/example.svg` existe (cargado como default)
- [x] Verificar `assets/car_animated.svg` existe
- [x] Iconos Android generados desde `logo.svg` (todas las densidades)
- [x] Adaptive icon configurado (Android 8+)

---

## FASE 13: Testing ✅

- [x] Crear tests unitarios para `SvgParser`
- [x] Crear tests unitarios para `AnimationEngine`
- [x] Crear tests unitarios para modelos (AnimationConfig, Workspace, etc.)
- [x] Crear tests unitarios para servicios (AnimationService, GroupService, TrajectoryService, HistoryService, SelectionService)
- [x] Crear tests de widget para `HomeScreen`, `SvgPreview`, `BottomNav`, `EmptyState` (22 tests con MockSvgProvider)
- [x] Ejecutar `flutter test` — 153 tests pasando

---

## FASE 14: Build y Release ✅

- [x] `flutter analyze` sin errores
- [x] `flutter build apk --release` exitoso
- [ ] `flutter build appbundle --release` exitoso
- [x] Verificar que la app inicia sin crashes en dispositivo real
- [x] Probar carga de SVG completo
- [x] Probar todas las animaciones en dispositivo
- [x] Probar modo piezas en touch
- [x] Probar exportación de SVG animado
- [x] Probar undo/redo
- [x] Probar persistencia de workspaces (reiniciar app)

---

## FASE 15: Git ✅

- [x] Crear repositorio en GitHub: `siliconvalleyar-oss/svg_animated_ftl`
- [x] Push inicial con `.gitignore`
- [x] Push de código completo
- [x] Tags v1.0.0 → v1.0.6 secuenciales
- [x] VERSION sincronizado con último tag

---

## FASE 16: Features Implementadas ✅

- [x] Multi-selección con toggle boolean (click = seleccionar/deseleccionar)
- [x] Controles aplican a todas las piezas seleccionadas simultáneamente
- [x] Sistema de grupos: crear, renombrar, eliminar (mínimo 2 piezas)
- [x] Piezas agrupadas rotan juntas con mismo eje de referencia
- [x] Reemplazado "Arco" por "Tiro Oblicuo" con fórmulas de física reales
- [x] Efectos físicos: Péndulo, Caída Libre, Rebote Elástico, Resorte
- [x] Control de Opacidad individual por pieza o grupo
- [x] Ejemplo SVG cargado por defecto al iniciar
- [x] Importar SVG pegando código (sin file_picker)
- [x] Exportar SVG a directorio de documentos (sin file_picker)

---

## FASE 17: Pendientes / Deuda Técnica ⬜

- [ ] **Extraer SvgProvider** en múltiples providers (WorkspaceProvider, AnimationProvider, PiecesProvider)
- [ ] **Internacionalizar** textos (hardcodeados en español)
- [ ] **Loading states** en operaciones asíncronas largas
- [ ] **Drawer** para workspaces en vez de solo el nombre en AppBar
- [ ] **ExportScreen** — pantalla dedicada de exportación (referenciada en docs)
- [ ] **Mejorar PiecesOverlay** con detección de hit por elemento SVG real
- [ ] **Integrar animación 'draw' con grupos** — verificar que togglePreset funcione correctamente con elementos agrupados
- [ ] **Verificar animación 'draw' visualmente** — ajustar velocidad, easing y clipping en dispositivo real
- [ ] **Refactorizar SvgPreview** — separar AnimationController del widget de presentación para mejorar testabilidad
- [ ] **Agregar tests de integración** para SvgPreview con AnimationController funcionando (flutter_driver/integration_test)
- [ ] **Generar reporte de cobertura** de código para identificar áreas no cubiertas por tests
- [ ] **Refactorizar historial (undo/redo)** — usar patron Memento más limpio en vez de snapshots completos

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
