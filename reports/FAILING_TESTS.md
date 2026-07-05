# ❌ Tests Fallando

## Resumen

| Archivo | Tests Fallando | Causa Raíz |
|:--------|:--------------:|:-----------|
| `test/services/group_service_test.dart` | 1 | Valor esperado incorrecto |
| `test/widget_test.dart` | 4+ | `ProviderNotFoundException` + widgets no encontrados |
| `test/widget_components_test.dart` | 4+ | `ProviderNotFoundException` + widgets no encontrados |

---

## 1. `GroupService.createGroup` — Valor esperado incorrecto

**Archivo:** `test/services/group_service_test.dart:69`  
**Test:** `creates a group from elements with only draw animation`

### Error

```
Expected: 1.0
Actual:   4.0
```

### Causa

El test crea dos elementos con animación 'draw':

```dart
ws.elementAnimations[2] = AnimationConfig(presetId: 'draw');           // speed por defecto = 4.0
ws.elementAnimations[3] = AnimationConfig(presetId: 'draw', speed: 1.5);
```

Luego crea un grupo con `[2, 3]` y espera que `group.config.speed == 1.0`:

```dart
expect(group.config.speed, equals(1.0)); // uses first element's config
```

El comentario dice "uses first element's config", pero el primer elemento (índice 2) tiene `speed = 4.0` (valor por defecto). La implementación real de `GroupService.createGroup` copia el template del primer elemento (`indices.first`), que es el índice 2 con speed 4.0.

**Diagnóstico:** El test tiene la expectativa incorrecta. Debería esperar `4.0` (el speed del primer elemento seleccionado), o el test debería configurar `speed: 1.0` explícitamente en el elemento 2.

### Gravedad: 🔴 Media

---

## 2. `ProviderNotFoundException` — `SettingsProvider` no scoped

**Archivos:** `test/widget_test.dart`, `test/widget_components_test.dart`

### Error

```
The following ProviderNotFoundException was thrown:
Error: Could not find the correct Provider<SettingsProvider> above this Widget
```

### Causa

Los widgets bajo prueba (`HomeScreen`, `_buildImportPanel`, `_buildExportPanel`) usan `Consumer<SettingsProvider>` y `context.read<SettingsProvider>()`. Sin embargo, en los tests no se proporciona un `SettingsProvider` como ancestro en el árbol de widgets.

El patrón correcto requiere:

```dart
await tester.pumpWidget(
  MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockSvgProvider()),
        ChangeNotifierProvider(create: (_) => MockSettingsProvider()),  // FALTANTE
      ],
      child: HomeScreen(),
    ),
  ),
);
```

### Tests afectados

1. `HomeScreen Export tab shows export button` — No encuentra "Exportar SVG Animado"
2. `tapping Import tab opens import panel` — No encuentra "Pegar SVG"
3. `tapping Piezas tab opens pieces panel` — No encuentra "Activar modo piezas"
4. `Import tab shows ShapesGrid below button` — No encuentra "Pegar SVG"
5. `Pegar SVG button opens paste dialog` — No encuentra "Pegar SVG"
6. `cancel paste dialog closes without loading` — No encuentra "Pegar SVG"

### Gravedad: 🔴 Alta

### Solución Propuesta

1. Crear un `MockSettingsProvider` que extienda `ChangeNotifier` con exportPath configurable
2. Agregarlo como provider en todos los tests que usen `HomeScreen`

---

## 3. `SvgPreview` — Zoom buttons no encontrados

**Archivo:** `test/widget_test.dart`

### Error

```
Expected: exactly one matching widget in the widget tree
Actual: 0 widgets matched
```

Tests afectados:
- `SvgPreview zoom in button changes zoom level`
- `SvgPreview zoom out button changes zoom level`

### Causa

Los botones de zoom (`Icons.add`, `Icons.remove`) están dentro de `ZoomControls` que se renderiza condicionalmente basado en un `TransformationController`. Si el controller es `null` o no se proporciona en el contexto de prueba, los botones no se renderizan.

### Gravedad: 🟡 Media

---

## 4. `SvgPreview` — Selection count test

**Archivo:** `test/widget_test.dart`

### Error

No se encuentra el texto con el conteo de selección.

### Causa

El test selecciona elementos pero el texto de conteo de selección no aparece, posiblemente porque el widget `SvgPreview` requiere ciertas condiciones del provider (SVG cargado, modo de selección activo) que no están configuradas correctamente en el test.

### Gravedad: 🟡 Baja

---

## Estadísticas de Fallos

| Estado | Tests |
|:-------|:-----:|
| **Valor incorrecto** (test bug) | 1 |
| **Provider faltante** | 6 |
| **Widget condicional no renderizado** | 2 |
| **Otros** | 1 |
| **Total** | **10+** |
