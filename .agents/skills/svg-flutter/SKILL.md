---
name: svg-flutter
description: Use when building or maintaining a Flutter app that parses, animates, or exports SVG files. Covers SVG parsing with xml, AnimationController patterns, Hive persistence, Provider state management, and error handling best practices for this project.
---

# SVG Animated FTL — Flutter Development Skill

## Project Context

This is a Flutter mobile app (`svg_animated_ftl`) for animating SVG files 100% offline. Version 1.0.0.

## Tech Stack

- **Flutter SDK**: >=3.0.0 <4.0.0
- **State**: Provider + ChangeNotifier
- **Persistence**: Hive + hive_flutter
- **SVG**: flutter_svg + xml (for parsing/modifying)
- **File handling**: file_picker, path_provider, share_plus
- **Permissions**: permission_handler

## Critical Rules

### Error Handling (CRITICAL)

Every file operation, SVG parse, export, and permission request MUST have try-catch. Never leave errors uncaught.

```dart
// Pattern for async operations
try {
  final result = await someOperation();
  if (result == null) return;
  // Process...
} catch (e, stackTrace) {
  debugPrint('Error: $e');
  debugPrint('Stack trace: $stackTrace');
  _showError('User-friendly message: ${e.toString()}');
}
```

### Mounted Check

Always verify `mounted` before `setState` in async methods:

```dart
void _safeSetState(VoidCallback fn) {
  if (mounted) setState(fn);
}
```

### AnimationController

Always dispose AnimationControllers:

```dart
@override
void dispose() {
  for (final controller in _controllers) {
    controller.dispose();
  }
  super.dispose();
}
```

## File Structure

```
lib/
├── main.dart                    # Entry point, Hive init
├── app.dart                     # MaterialApp, theme, routes
├── core/                        # Constants, theme, extensions
├── models/                      # Data models (Hive annotated)
├── providers/                   # ChangeNotifier providers
├── screens/                     # Screen widgets
├── widgets/                     # Reusable widgets
│   └── animations/              # Individual animation widgets
├── services/                    # SVG parser, animation engine, export
└── utils/                       # SVG, math, file utilities
```

## Animation Presets

The app supports 19 animation presets:
rotate, wheel, pulse, bounce, gravity, slide, oval, fade, draw, shake, float, levitate, arc, radiate, spin, glow, wave-sine, wave-square, wave-triangle

Each preset has: name, id, color, duration, easing, and optional `translatable` flag (for directional animations).

## Model Key Points

- `AnimationConfig` uses HiveType with typeId: 0
- `Workspace` stores all state: animations, groups, trajectories, undo stack
- `Trajectory` contains list of `TrajectoryPoint` (x, y)
- `Group` links multiple elements with shared AnimationConfig
- `BackgroundImage` supports opacity, zIndex, position

## Export Flow

1. Parse original SVG with XmlDocument
2. Generate CSS @keyframes for each animated element
3. Inject `<style>` element into SVG
4. Save via FilePicker with `flush: true`

## Common Pitfalls

1. Never use `setState` without `mounted` check in async
2. Always `dispose()` AnimationControllers
3. Check `file.exists()` before `readAsString()`
4. Always wrap SVG parsing in try-catch
5. Use null-safe serialization (null-aware operators)
6. Always use `flush: true` in `writeAsString`
7. Check context is valid before `Navigator.push`
8. Always call `notifyListeners()` after state changes
9. Don't use `Container` with both `color` and `decoration`
10. Always add `key` to `ListView.builder` items
