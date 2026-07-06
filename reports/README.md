# 🧪 Informes de Aseguramiento de Calidad (QA)

> **Proyecto:** SVG Animated FTL  
> **Versión:** 1.2.0  
> **Fecha del reporte:** Julio 2026  
> **Cobertura total:** 72.0%

---

## 📋 Índice de Reportes

| Documento | Descripción |
|:----------|:------------|
| [`FAILING_TESTS.md`](./FAILING_TESTS.md) | Tests que fallan: errores de aserción, `ProviderNotFoundException`, y valores inesperados |
| [`CODE_ANALYSIS.md`](./CODE_ANALYSIS.md) | Advertencias de `flutter analyze`: APIs deprecadas, imports no usados, operadores null-aware inválidos |
| [`COVERAGE_GAPS.md`](./COVERAGE_GAPS.md) | Análisis de cobertura: código no testeado por archivo, directorios con baja cobertura |
| [`POTENTIAL_BUGS.md`](./POTENTIAL_BUGS.md) | Bugs identificados en el código fuente: errores de tipos, lógica incorrecta, riesgos de runtime |
| [`QA_TESTING_REPORT.md`](./QA_TESTING_REPORT.md) | Reporte completo de QA: 20 hallazgos (6 criticos, 5 altos, 5 medios, 4 bajos) con tabla de seguimiento |

---

## 🚨 Resumen Ejecutivo

| Métrica | Valor | Estado |
|:--------|:-----:|:------:|
| **Tests totales** | ~260 | — |
| **Tests fallando** | **5+** | 🔴 |
| **Advertencias análisis** | **11** | 🟡 |
| **Cobertura global** | **72.0%** | 🟡 |
| **Providers sin cobertura** | **3 archivos (0%)** | 🔴 |

### Problemas Críticos (Prioridad Alta)

1. **ProviderNotFoundException** — Los tests de `HomeScreen` crashan porque `SettingsProvider` no está en el árbol de widgets de prueba.
2. **Error de tipo en `TrajectoryPainter`** — Usa `Map<String, dynamic>` en vez de `Map<String, Trajectory>`, causando error de compilación en tiempo de ejecución.
3. **Test de `GroupService`** — Valor esperado incorrecto: espera `1.0` pero recibe `4.0` (el valor por defecto de `AnimationConfig.speed`).

### Problemas Medios (Prioridad Media)

4. **APIs deprecadas** — `withOpacity` y `matrix.scale()` deben actualizarse.
5. **Null-aware operators inválidos** — 3 instancias de `?.` en receptores no-nullable en `workspace.dart`.
6. **Cobertura 0% en providers** — `svg_provider.dart` (176 líneas), `settings_provider.dart`, `theme_provider.dart` sin pruebas.

---

*Generado automáticamente por el agente QA de Codebuff.*
