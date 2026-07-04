# SKILL.md — SVG Animated FTL

## Project Overview

Flutter mobile app for animating SVG files with 19 preset animations, offline-first, no server required.

- **Version**: 1.0.0
- **Platforms**: Android 5.0+ / iOS 12.0+
- **Stack**: Flutter 3.0+, Dart 3.0+, Provider, Hive, flutter_svg

## Quick Reference

### Key Files
| File | Purpose |
|------|---------|
| `lib/main.dart` | Entry point, Hive init, Provider setup |
| `lib/app.dart` | MaterialApp, theme, routing |
| `lib/providers/svg_provider.dart` | Global state (ChangeNotifier) |
| `lib/services/svg_parser.dart` | SVG parsing to element list |
| `lib/services/animation_engine.dart` | Animation building (Tween + Curves) |
| `lib/services/export_service.dart` | SVG export with embedded CSS keyframes |
| `lib/core/constants.dart` | Colors, presets, shapes |

### 19 Animation Presets
rotate, wheel, pulse, bounce, gravity, slide, oval, fade, draw, shake, float, levitate, arc, radiate, spin, glow, wave-sine, wave-square, wave-triangle

### 11 Directional Animations (support angle 0-360)
bounce, gravity, slide, shake, float, levitate, arc, radiate, wave-sine, wave-square, wave-triangle

## Error Handling Rules

1. Every file/SVG/export/permission operation MUST have try-catch
2. Check `mounted` before `setState` in async methods
3. Always `dispose()` AnimationControllers
4. Use `flush: true` in `writeAsString`
5. Never use `Container` with both `color` and `decoration`

## Adding a New Animation

1. Add preset in `lib/core/constants.dart`
2. Create widget in `lib/services/animation_engine.dart`
3. Register in `buildAnimation()` switch
4. Add CSS keyframes in `lib/services/export_service.dart`
5. If directional, add to `isTranslatable` list

## Adding a New Shape

Add to `AnimationPresets.shapes` in `lib/core/constants.dart` with SVG string.

## Export Flow

1. Parse SVG with `XmlDocument`
2. Generate `@keyframes` CSS per animated element
3. Inject `<style>` element into SVG
4. Save via FilePicker with `flush: true`

## Common Pitfalls

1. `setState` without `mounted` check in async
2. Missing `dispose()` on AnimationController
3. `File.readAsString()` without `exists()` check
4. SVG parse without try-catch
5. Non-null-safe serialization
6. Missing `flush: true` on writeAsString
7. `Navigator.push` with invalid context
8. Missing `notifyListeners()` after state change
9. `Container` with both `color` and `decoration`
10. Missing `key` in `ListView.builder` items
