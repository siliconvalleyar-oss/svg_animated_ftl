# 🔍 Análisis Estático de Código

**Comando:** `flutter analyze`  
**Total de issues:** 11  
**Clasificación:** 0 errores, 4 warnings, 7 info

---

## 1. APIs Deprecadas

### 1.1 `withOpacity` deprecado

**Archivo:** `lib/core/theme.dart:39`

```dart
// ❌ Actual (deprecado)
overlayColor: AppColors.accent.withOpacity(0.2),

// ✅ Recomendado
overlayColor: AppColors.accent.withValues(alpha: 0.2),
```

**Impacto:** Bajo. La API funciona pero generará error de compilación en futuras versiones de Flutter.

---

### 1.2 `matrix.scale()` deprecado

**Archivo:** `lib/widgets/zoom_controls.dart:23,34`

```dart
// ❌ Actual (deprecado)
matrix.scale(1.3);  // línea 23
matrix.scale(0.7);  // línea 34

// ✅ Recomendado
matrix.scaleByDouble(1.3);
matrix.scaleByDouble(0.7);
```

**Impacto:** Medio. `Matrix4.scale()` está deprecado desde Flutter 3.x. Usar `scaleByDouble()`.

---

## 2. Null-Aware Operators Inválidos

**Archivo:** `lib/models/workspace.dart:89,92,100`

```dart
// ❌ Actual: `?.` en receptor no-nullable
(json['elementAnimations'] as Map?)?.cast<String, dynamic>()?.map(...)

// ✅ Recomendado: usar `.` en vez de `?.`
(json['elementAnimations'] as Map?)?.cast<String, dynamic>().map(...)
```

**Explicación:** `.cast<String, dynamic>()` siempre retorna un `Map<String, dynamic>` no-nullable (nunca null). El operador `?.` es innecesario y el analyzer lo advierte.

**Impacto:** Bajo. Funciona correctamente, pero es código confuso que sugiere que podría retornar null cuando no es posible.

---

## 3. Imports No Utilizados

| Archivo | Import | 
|:--------|:-------|
| `lib/widgets/zoom_controls.dart` | `package:provider/provider.dart` |
| `lib/widgets/zoom_controls.dart` | `../providers/svg_provider.dart` |
| `test/services/svg_parser_test.dart` | `package:svg_animated_ftl/models/svg_element.dart` |
| `test/services/trajectory_service_test.dart` | `package:svg_animated_ftl/models/trajectory.dart` |
| `test/widget_test.dart` | `package:svg_animated_ftl/core/constants.dart` |

**Impacto:** Bajo. No afectan funcionalidad, pero aumentan warnings y son mala práctica.

---

## 4. Resumen por Severidad

| Severidad | Cantidad |
|:----------|:--------:|
| 🔴 Error | 0 |
| 🟡 Warning | 4 |
| 🔵 Info | 7 |
| **Total** | **11** |
