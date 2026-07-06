# Reporte de QA — SVG Animator FTL

| Campo | Valor |
|:------|:------|
| **Proyecto** | svg_animated_ftl |
| **Version analizada** | 1.2.0 (VERSION) / 1.0.0+1 (pubspec) |
| **Fecha** | 2026-07-05 |
| **Responsable QA** | MiMoCode Agent |
| **Metodo** | Revision estatica del codigo fuente (sin ejecucion) |
| **Archivos revisados** | 37 archivos lib/ + 11 archivos test/ |

---

## 1. Resumen Ejecutivo

Se identificaron **20 hallazgos** clasificados por severidad:

| Severidad | Cantidad | Bloquean release |
|:----------|:--------:|:----------------:|
| Critica   | 6        | Si               |
| Alta      | 5        | Si               |
| Media     | 5        | No               |
| Baja      | 4        | No               |

**Veredicto:** La app NO esta lista para release. Hay 6 bugs criticos que afectan funcionalidad core (drag de piezas, parsing de SVGs anidados, exportaciones incorrectas).

---

## 2. Bugs Criticos (P0)

### BUG-QA-001: Drag en modo Piezas no funciona

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/widgets/pieces_overlay.dart:39-44` |
| **Severidad** | Critica |
| **Componente** | UI / Piezas Mode |
| **Reproducibilidad** | 100% |

**Descripcion:**
El gesto `onPanUpdate` solo actualiza un mapa local `_offsets` via `setState()`, pero nunca invoca `provider.moveSelectedElements()`. Los offsets calculados se guardan en estado local del widget y se descartan al reconstruir.

**Pasos para reproducir:**
1. Cargar un SVG
2. Seleccionar la tab "Piezas"
3. Activar modo piezas
4. Seleccionar una pieza
5. Arrastrar la pieza

**Resultado esperado:** La pieza se mueve y la posicion se persiste.
**Resultado actual:** La pieza no se mueve visualmente. El drag se registra localmente pero nunca se propaga al provider.

**Impacto:** La funcionalidad de "Piezas" esta completamente rota para drag.

---

### BUG-QA-002: Parser SVG ignora elementos anidados en grupos `<g>`

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/services/svg_parser.dart:55` |
| **Severidad** | Critica |
| **Componente** | SVG Parsing |
| **Reproducibilidad** | 100% |

**Descripcion:**
`SvgParser.parse()` solo itera `svg.childElements` (hijos directos del root `<svg>`). Elementos dentro de `<g>`, `<defs>`, o cualquier contenedor anidado no son detectados.

```xml
<!-- Este SVG solo genera 1 elemento detectado: el <g> -->
<svg viewBox="0 0 200 200">
  <g>
    <circle cx="50" cy="50" r="30"/>
    <rect x="100" y="100" width="60" height="60"/>
  </g>
</svg>
```

**Impacto:** Cualquier SVG que use grupos `<g>` para organizar elementos no puede animar individualmente las piezas internas. Esto afecta la mayoria de SVGs profesionales.

**Nota:** `ExportService:25` tiene el mismo problema.

---

### BUG-QA-003: Elementos movidos no se persisten

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/providers/svg_provider.dart:265-280` |
| **Severidad** | Critica |
| **Componente** | Persistencia |
| **Reproducibilidad** | 100% |

**Descripcion:**
`moveSelectedElements()` y `resetElementOffsets()` modifican `elementOffsets` y notifican listeners, pero nunca llaman `_saveActiveWorkspace()`. Los cambios se pierden al cerrar la app.

**Metodos afectados:**
- `moveSelectedElements(double dx, double dy)` — linea 265
- `resetElementOffsets()` — linea 275

---

### BUG-QA-004: Undo/Redo no restaura posiciones de elementos

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/services/history_service.dart:16-18` |
| **Severidad** | Critica |
| **Componente** | Undo/Redo |
| **Reproducibilidad** | 100% |

**Descripcion:**
`pushHistory()` solo serializa `elementAnimations` y `elementGroups`, pero omite `elementOffsets`. Al hacer undo despues de mover piezas, las posiciones no se restauran a su estado anterior.

**Flujo de fallo:**
1. Mover pieza A 50px a la derecha
2. Presionar Undo
3. La pieza A permanece desplazada (no se resta el offset)

---

### BUG-QA-005: Exportacion de `gravity` ignora angulo de direccion

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/services/export_service.dart:74-75, 183-184` |
| **Severidad** | Critica |
| **Componente** | Export SVG |
| **Reproducibilidad** | 100% |

**Descripcion:**
`AnimationEngine.isTranslatable('gravity')` retorna `true`, por lo que se muestra el pad de direccion al usuario. Sin embargo:
- `_generateKeyframes()` para `gravity` siempre genera `translateY` sin importar `directionAngle`
- `_generateElementStyle()` para `gravity` siempre usa `svgGravity_$index`
- `_generateDirectionalKeyframes()` no tiene caso para `gravity`

**Impacto:** El SVG exportado no coincide con lo que el usuario ve en preview cuando usa direccion en gravedad.

---

### BUG-QA-006: Exportacion `freefall` genera distancia incorrecta

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/services/export_service.dart:115` vs `lib/services/animation_engine.dart:366` |
| **Severidad** | Critica |
| **Componente** | Export SVG |
| **Reproducibilidad** | 100% |

**Descripcion:**
Hay discrepancia numerica entre el engine Flutter y la exportacion CSS:

| Fuente | Formula | Resultado al final |
|:-------|:--------|:-------------------|
| AnimationEngine | `0.5 * 9.8 * 1.0 * 1.0 * 20` | 98px |
| ExportService | `translateY(196px)` | 196px |

El SVG exportado se desplaza el **doble** de lo que se muestra en la preview.

---

## 3. Bugs Altos (P1)

### BUG-QA-007: Separador de paths incorrecto en Windows

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/screens/home_screen.dart:519` |
| **Severidad** | Alta |
| **Componente** | Import SVG |
| **Plataforma** | Windows |

**Descripcion:**
`f.path.split('/').last` usa `/` como separador. En Windows, los paths usan `\`, por lo que se muestra el path completo (`C:\Users\...\archivo.svg`) en vez del nombre del archivo.

**Solucion:** Usar `Platform.pathSeparator` o `path.basename(f.path)`.

---

### BUG-QA-008: ThemeProvider registrado pero no conectado

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/main.dart:31` + `lib/app.dart:10` |
| **Severidad** | Alta |
| **Componente** | Tema |

**Descripcion:**
`ThemeProvider` se registra en `MultiProvider` pero `MaterialApp` usa `AppTheme.darkTheme` hardcodeado. El toggle de tema claro/oscuro es no-op.

---

### BUG-QA-009: Sin permisos antes de exportar

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/screens/home_screen.dart:554-594` |
| **Severidad** | Alta |
| **Componente** | Export |
| **Plataforma** | Android |

**Descripcion:**
`_exportSvg()` escribe archivos sin solicitar permisos de almacenamiento. `PermissionService` existe pero nunca se invoca desde la UI. En Android 10+ con scoped storage, la escritura puede fallar silenciosamente.

---

### BUG-QA-010: Ruta de exportacion no valida en iOS

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/providers/settings_provider.dart:10` |
| **Severidad** | Alta |
| **Componente** | Settings |

**Descripcion:**
La ruta por defecto `/sdcard/Pictures/svg_animated_ftl` es especifica de Android. En iOS no existe `/sdcard/`, y el intento de crear el directorio falla.

---

### BUG-QA-011: Race condition en persistencia Hive

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/providers/svg_provider.dart:345-370` |
| **Severidad** | Alta |
| **Componente** | Persistencia |

**Descripcion:**
`_saveWorkspaces()` es `async` pero se invoca sin `await` desde multiples metodos sincronos (`addWorkspace`, `switchWorkspace`, `renameWorkspace`, `loadSvgString`). Si el usuario realiza varias operaciones rapidamente, las escrituras pueden sobreescribirse.

---

## 4. Bugs Medios (P2)

### BUG-QA-012: mounted check incompleto en dialogo de Settings

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/screens/home_screen.dart:402-424` |
| **Severidad** | Media |

**Descripcion:**
Dentro del callback `onPressed` del dialogo, hay operaciones `await` (`setExportPath`, `setDimOpacity`, etc.) sin verificar `mounted` despues de cada una. `Navigator.pop(context)` en linea 423 se ejecuta sin validacion post-async.

---

### BUG-QA-013: VERSION vs pubspec.yaml desincronizados

| Campo | Valor |
|:------|:------|
| **Archivo** | `VERSION` vs `pubspec.yaml` |
| **Severidad** | Media |

**Descripcion:**
`VERSION` contiene "1.2.0" pero `pubspec.yaml` define version "1.0.0+1". Discrepancia que genera confusion en releases.

---

### BUG-QA-014: AnimationScope se reconstruye en exceso

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/widgets/animation_scope.dart:47` |
| **Severidad** | Media |
| **Componente** | Performance |

**Descripcion:**
`context.watch<SvgProvider>()` dentro de `build()` causa que todo el subtree de animacion se reconstruya ante cualquier cambio de estado del provider, no solo cambios relevantes (play/pause).

---

### BUG-QA-015: TrajectoryPainter repinta siempre

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/widgets/trajectory_overlay.dart:58` |
| **Severidad** | Media |
| **Componente** | Performance |

**Descripcion:**
`shouldRepaint()` retorna `true` incondicionalmente. El CustomPainter se repinta en cada frame aunque las trayectorias no hayan cambiado.

---

### BUG-QA-016: Duplicado de xmlns en mini-SVG

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/widgets/individual_elements_view.dart:123` |
| **Severidad** | Media |

**Descripcion:**
`_buildMiniSvg()` agrega `xmlns="http://www.w3.org/2000/svg"` al wrapper, pero el elemento XML original ya lo contiene. Genera atributos duplicados que podrian causar problemas en algunos renderizadores SVG.

---

## 5. Bugs Bajos (P3)

### BUG-QA-017: FileService es codigo muerto

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/services/file_service.dart` |
| **Severidad** | Baja |

**Descripcion:**
Servicio completo (64 lineas) que nunca es importado ni utilizado por ningun otro archivo del proyecto.

---

### BUG-QA-018: PermissionService nunca se invoca

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/services/permission_service.dart` |
| **Severidad** | Baja |

**Descripcion:**
Metodos `requestStoragePermission()` y `requestPhotosPermission()` existen pero nunca se llaman desde ningun widget o pantalla.

---

### BUG-QA-019: AppConstants.maxUndoSteps no se usa

| Campo | Valor |
|:------|:------|
| **Archivo** | `lib/core/constants.dart:68` |
| **Severidad** | Baja |

**Descripcion:**
La constante define 50 pasos maximos, pero `HistoryService` hardcodea `_maxHistory = 50` en vez de referenciar la constante.

---

### BUG-QA-020: Version deprecada en analysis existente

| Campo | Valor |
|:------|:------|
| **Archivo** | `reports/POTENTIAL_BUGS.md` |
| **Severidad** | Baja |

**Descripcion:**
El reporte `POTENTIAL_BUGS.md` referencia bugs de versiones anteriores (tipo `TrajectoryPainter` con `Map<String, dynamic>`) que ya fueron corregidos en el codigo actual. El reporte necesita actualizacion.

---

## 6. Tabla de Seguimiento

| ID | Bug | Severidad | Estado | Asignado | Sprint |
|:---|:----|:---------:|:------:|:---------|:-------|
| BUG-QA-001 | Drag piezas no funciona | Critica | Abierto | — | — |
| BUG-QA-002 | Parser ignora anidados | Critica | Abierto | — | — |
| BUG-QA-003 |Offsets no persisten | Critica | Abierto | — | — |
| BUG-QA-004 | Undo no restaura offsets | Critica | Abierto | — | — |
| BUG-QA-005 | Gravity export sin direccion | Critica | Abierto | — | — |
| BUG-QA-006 | Freefall distancia x2 | Critica | Abierto | — | — |
| BUG-QA-007 | Path separator Windows | Alta | Abierto | — | — |
| BUG-QA-008 | ThemeProvider sin usar | Alta | Abierto | — | — |
| BUG-QA-009 | Sin permisos export | Alta | Abierto | — | — |
| BUG-QA-010 | Ruta iOS invalida | Alta | Abierto | — | — |
| BUG-QA-011 | Race condition Hive | Alta | Abierto | — | — |
| BUG-QA-012 | Mounted check dialog | Media | Abierto | — | — |
| BUG-QA-013 | VERSION mismatch | Media | Abierto | — | — |
| BUG-QA-014 | AnimationScope rebuild | Media | Abierto | — | — |
| BUG-QA-015 | TrajectoryPainter repaint | Media | Abierto | — | — |
| BUG-QA-016 | xmlns duplicado | Media | Abierto | — | — |
| BUG-QA-017 | FileService muerto | Baja | Abierto | — | — |
| BUG-QA-018 | PermissionService sin uso | Baja | Abierto | — | — |
| BUG-QA-019 | Constante no referenciada | Baja | Abierto | — | — |
| BUG-QA-020 | Reporte obsoleto | Baja | Abierto | — | — |

---

## 7. Recomendaciones de Prioridad

**Fase 1 (Inmediato) — Bloquea release:**
1. Corregir drag en `PiecesOverlay` (BUG-QA-001)
2. Corregir parser SVG para soportar anidados (BUG-QA-002)
3. Agregar persistencia en `moveSelectedElements` (BUG-QA-003)
4. Expandir historial para incluir offsets (BUG-QA-004)
5. Corregir exportacion de gravity con direccion (BUG-QA-005)
6. Ajustar distancia en export freefall (BUG-QA-006)

**Fase 2 (Antes de beta):**
7. Corregir path separator para Windows (BUG-QA-007)
8. Conectar ThemeProvider o eliminarlo (BUG-QA-008)
9. Integrar permisos en flujo de export (BUG-QA-009)
10. Resolver rutas multi-plataforma (BUG-QA-010)

**Fase 3 (Post-release):**
11-20. Mejoras de performance, limpieza de codigo muerto, sincronizacion de versiones.

---

*Generado por QA Agent — 2026-07-05*
