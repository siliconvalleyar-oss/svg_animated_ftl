# Bugs Conocidos

> Registro de bugs identificados por QA. Para el reporte completo ver `reports/QA_TESTING_REPORT.md`.

---

## Bugs Criticos (P0) — Bloquean release

### BUG-001: Drag en modo Piezas no funciona
- **Archivo**: `lib/widgets/pieces_overlay.dart:39-44`
- **Problema**: `onPanUpdate` actualiza un mapa local `_offsets` pero nunca llama a `provider.moveSelectedElements()`. Los offsets no se propagan al provider.
- **Impacto**: El drag en modo piezas esta completamente roto.

### BUG-002: Parser SVG ignora elementos anidados en `<g>`
- **Archivo**: `lib/services/svg_parser.dart:55`
- **Problema**: `svg.childElements` solo itera hijos directos del root `<svg>`. Elementos dentro de `<g>` no se detectan.
- **Impacto**: SVGs con grupos no pueden animar piezas internas individualmente.
- **Nota**: `ExportService:25` tiene el mismo problema.

### BUG-003: Elementos movidos no se persisten
- **Archivo**: `lib/providers/svg_provider.dart:265-280`
- **Problema**: `moveSelectedElements()` y `resetElementOffsets()` modifican estado pero nunca llaman `_saveActiveWorkspace()`.
- **Impacto**: Los offsets se pierden al reiniciar la app.

### BUG-004: Undo/Redo no restaura posiciones
- **Archivo**: `lib/services/history_service.dart:16-18`
- **Problema**: `pushHistory()` solo serializa `animations` y `groups`, omite `elementOffsets`.
- **Impacto**: Undo despues de mover piezas no restaura las posiciones.

### BUG-005: Exportacion de gravity ignora angulo de direccion
- **Archivo**: `lib/services/export_service.dart:74-75, 183-184`
- **Problema**: `isTranslatable('gravity')` retorna true (pad de direccion visible), pero la exportacion no genera keyframes direccionales para gravity.
- **Impacto**: SVG exportado no coincide con preview para gravity direccional.

### BUG-006: Exportacion freefall genera distancia x2
- **Archivo**: `lib/services/export_service.dart:115` vs `lib/services/animation_engine.dart:366`
- **Problema**: Engine calcula 98px, export hardcodea 196px.
- **Impacto**: SVG exportado se desplaza el doble de lo previsto.

---

## Bugs Altos (P1)

### BUG-007: Separador de paths incorrecto en Windows
- **Archivo**: `lib/screens/home_screen.dart:519`
- **Problema**: `f.path.split('/').last` usa `/` como separador. En Windows los paths usan `\`.

### BUG-008: ThemeProvider registrado pero no conectado
- **Archivo**: `lib/main.dart:31` + `lib/app.dart:10`
- **Problema**: `ThemeProvider` se registra pero `MaterialApp` usa tema hardcodeado. Toggle no funciona.

### BUG-009: Sin permisos antes de exportar
- **Archivo**: `lib/screens/home_screen.dart:554-594`
- **Problema**: `_exportSvg()` escribe archivos sin solicitar permisos. `PermissionService` existe pero nunca se invoca.

### BUG-010: Ruta de exportacion invalida en iOS
- **Archivo**: `lib/providers/settings_provider.dart:10`
- **Problema**: Ruta por defecto `/sdcard/Pictures/...` es especifica de Android.

### BUG-011: Race condition en persistencia Hive
- **Archivo**: `lib/providers/svg_provider.dart:345-370`
- **Problema**: `_saveWorkspaces()` es async pero se llama sin await desde metodos sincronos.

---

## Bugs Medios (P2)

### BUG-012: Mounted check incompleto en dialogo de Settings
- **Archivo**: `lib/screens/home_screen.dart:402-424`

### BUG-013: VERSION vs pubspec.yaml desincronizados
- **Archivo**: `VERSION` (1.2.0) vs `pubspec.yaml` (1.0.0+1)

### BUG-014: AnimationScope se reconstruye en exceso
- **Archivo**: `lib/widgets/animation_scope.dart:47`

### BUG-015: TrajectoryPainter repinta siempre
- **Archivo**: `lib/widgets/trajectory_overlay.dart:58`

### BUG-016: Duplicado de xmlns en mini-SVG
- **Archivo**: `lib/widgets/individual_elements_view.dart:123`

---

## Bugs Bajos (P3)

### BUG-017: FileService es codigo muerto
- **Archivo**: `lib/services/file_service.dart` — nunca importado.

### BUG-018: PermissionService nunca se invoca
- **Archivo**: `lib/services/permission_service.dart` — metodos sin uso.

### BUG-019: AppConstants.maxUndoSteps no se usa
- **Archivo**: `lib/core/constants.dart:68` — HistoryService hardcodea 50.

### BUG-020: Reporte POTENTIAL_BUGS.md obsoleto
- **Archivo**: `reports/POTENTIAL_BUGS.md` — referencia bugs ya corregidos.

---

## Resumen

| Severidad | Cantidad | Bloquean release |
|:----------|:--------:|:----------------:|
| Critica | 6 | Si |
| Alta | 5 | Si |
| Media | 5 | No |
| Baja | 4 | No |
