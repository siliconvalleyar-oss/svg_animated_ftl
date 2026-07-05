# 🐛 Bugs Potenciales Identificados

---

## 🔴 BUG 1 — Error de Tipo en `TrajectoryPainter`

**Archivo:** `lib/widgets/trajectory_overlay.dart:27`  
**Severidad:** 🔴 **Alta** — Causa error en tiempo de ejecución

### Problema

```dart
class TrajectoryPainter extends CustomPainter {
  final Map<String, dynamic> trajectories;  // ❌ Tipo incorrecto

  TrajectoryPainter(this.trajectories);

  @override
  void paint(Canvas canvas, Size size) {
    trajectories.forEach((key, trajectory) {
      if (trajectory.points.length < 2) return;  // ❌ 'dynamic' no tiene '.points'
```

El campo `trajectories` está declarado como `Map<String, dynamic>`, pero en `paint()` se accede a `trajectory.points` como si cada valor fuera un objeto `Trajectory`. Como `dynamic` no tiene verificación de tipo, esto puede causar:

- **Error en compilación:** Si `Trajectory` no es un `Map` con clave `points`
- **Error en runtime:** `NoSuchMethodError` si el valor no tiene la propiedad `points`

### Solución

```dart
class TrajectoryPainter extends CustomPainter {
  final Map<String, Trajectory> trajectories;  // ✅ Tipo correcto

  // También actualizar el Consumer en TrajectoryOverlay para que pase el Map con tipo correcto
}
```

---

## 🔴 BUG 2 — `ProviderNotFoundException` en Tests de HomeScreen

**Archivos:** `test/widget_test.dart`, `test/widget_components_test.dart`  
**Severidad:** 🔴 **Alta** — Tests no pueden ejecutarse correctamente

### Problema

`HomeScreen._buildImportPanel()` y `HomeScreen._buildExportPanel()` usan `Consumer<SettingsProvider>` que requiere un `SettingsProvider` ancestro. Los tests de widget no lo proveen, causando que todos los tests de `HomeScreen` que tocan los paneles de Importar y Exportar fallen.

### Solución

Crear `MockSettingsProvider` y agregarlo a los tests:

```dart
class MockSettingsProvider extends ChangeNotifier {
  String _exportPath = '/tmp/test';
  String get exportPath => _exportPath;

  Future<void> setExportPath(String path) async {
    _exportPath = path;
    notifyListeners();
  }
}
```

Y en los tests:

```dart
await tester.pumpWidget(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MockSvgProvider()),
      ChangeNotifierProvider(create: (_) => MockSettingsProvider()),
    ],
    child: HomeScreen(),
  ),
);
```

---

## 🟡 BUG 3 — Error de Assertion en Test `GroupService`

**Archivo:** `test/services/group_service_test.dart:69`  
**Severidad:** 🟡 **Media** — Test con expectativa incorrecta

### Problema

El test espera `group.config.speed == 1.0` cuando el speed real es `4.0` (valor por defecto de `AnimationConfig`). La implementación de `GroupService.createGroup` copia el config del primer elemento seleccionado correctamente.

### Posibles Causas

1. **BUG EN TEST:** El test debería esperar `4.0` en vez de `1.0`
2. **BUG EN CÓDIGO:** Si la intención es que `draw` siempre tenga speed `1.0`, entonces `GroupService` debería sobrescribir el speed a `1.0` cuando el preset es 'draw'

---

## 🟡 BUG 4 — `withOpacity` Deprecado

**Archivo:** `lib/core/theme.dart:39`  
**Severidad:** 🟡 **Media** — API deprecada será eliminada

```dart
AppColors.accent.withOpacity(0.2)   // ❌ Deprecado
AppColors.accent.withValues(alpha: 0.2)  // ✅ Correcto
```

### Impacto

Flutter 3.x+ recomienda `withValues(alpha:)` en vez de `withOpacity()`. No causa error hoy pero generará error de compilación en versiones futuras.

---

## 🟡 BUG 5 — `matrix.scale()` Deprecado

**Archivo:** `lib/widgets/zoom_controls.dart:23,34`  
**Severidad:** 🟡 **Media** — API deprecada será eliminada

```dart
matrix.scale(1.3);  // ❌ Deprecado
matrix.scaleByDouble(1.3);  // ✅ Correcto
```

### Impacto

`Matrix4.scale()` acepta múltiples argumentos para escalar en cada eje. `scaleByDouble()` escala uniformemente. El comportamiento actual funciona pero usará la API incorrecta.

---

## 🟢 BUG 6 — Posible Error en `_buildBounce` sin `AnimatedBuilder`

**Archivo:** `lib/services/animation_engine.dart:61-63`  
**Severidad:** 🟢 **Baja** — Puede no actualizarse visualmente

### Problema

```dart
static Widget _buildBounce(Widget child, Animation<double> animation, double angle) {
  final rad = angle * pi / 180;
  final dx = sin(rad) * animation.value * 20;
  final dy = -cos(rad) * animation.value * 20;
  return Transform.translate(offset: Offset(dx, dy), child: child);
}
```

`_buildBounce` (y varios otros como `_buildGravity`, `_buildSlide`, `_buildShake`, `_buildFloat`, `_buildLevitate`) no usan `AnimatedBuilder` para escuchar cambios en la animación. En cambio, leen `animation.value` directamente en el build.

**Esto funciona** porque Flutter reconstruye el widget cuando el padre notifica cambios, PERO es frágil: si el widget se cachea o no se reconstruye correctamente, la animación no se actualizará.

### Solución Recomendada

```dart
static Widget _buildBounce(Widget child, Animation<double> animation, double angle) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final rad = angle * pi / 180;
      final dx = sin(rad) * animation.value * 20;
      final dy = -cos(rad) * animation.value * 20;
      return Transform.translate(offset: Offset(dx, dy), child: child);
    },
    child: child,
  );
}
```

---

## 🟢 BUG 7 — `withOpacity`/`withValues` en `home_screen.dart`

**Archivo:** `lib/screens/home_screen.dart:136, 218`  
**Severidad:** 🟢 **Baja**

```dart
AppColors.surface2.withOpacity(0.5)  // ❌ Deprecado (pero no reportado por analyzer)
```

Estos usos de `withOpacity` no fueron reportados por `flutter analyze` porque están anidados dentro de widgets, pero deben migrarse igual.

---

## 🟢 BUG 8 — Animaciones Sin `child` en `AnimatedBuilder`

**Archivo:** `lib/services/animation_engine.dart`  
**Severidad:** 🟢 **Baja** — Optimización perdida

Varias animaciones usan:

```dart
AnimatedBuilder(
  animation: animation,
  builder: (context, child) { ... },
  child: child,
);
```

Pero en el builder, no usan el parámetro `child` recibido. Esto significa que el `child` se reconstruye en cada frame de la animación en vez de optimizarse con el parámetro `child`.

**Ejemplo correcto:**

```dart
AnimatedBuilder(
  animation: animation,
  builder: (context, child) {
    return Transform.rotate(
      angle: animation.value * 2 * pi,
      child: child!,  // ✅ Usar el child optimizado
    );
  },
  child: child,
);
```

Esto aplica a: `_buildRotate`, `_buildPulse`, `_buildSpin`, `_buildDraw`, `_buildOpacityAnim`.

---

## Resumen de Bugs

| # | Bug | Archivo | Severidad |
|:-:|:----|:--------|:---------:|
| 1 | Tipo incorrecto en `TrajectoryPainter` | `trajectory_overlay.dart` | 🔴 Alta |
| 2 | `ProviderNotFoundException` en tests | `widget_test.dart` | 🔴 Alta |
| 3 | Assertion incorrecta en test | `group_service_test.dart` | 🟡 Media |
| 4 | `withOpacity` deprecado | `theme.dart` | 🟡 Media |
| 5 | `matrix.scale()` deprecado | `zoom_controls.dart` | 🟡 Media |
| 6 | Sin `AnimatedBuilder` en animaciones | `animation_engine.dart` | 🟢 Baja |
| 7 | `withOpacity` en home_screen | `home_screen.dart` | 🟢 Baja |
| 8 | `child` no usado en `AnimatedBuilder` | `animation_engine.dart` | 🟢 Baja |
