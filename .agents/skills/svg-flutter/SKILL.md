# Skill: svg-flutter

# SVG Animated FTL — Flutter Development Skill

## Project Context

This is a Flutter mobile app (`svg_animated_ftl`) for animating SVG files 100% offline. Version 1.2.0.

## Tech Stack

- **Flutter SDK**: >=3.0.0 <4.0.0
- **State**: Provider + ChangeNotifier (3 providers: SvgProvider, SettingsProvider, ThemeProvider)
- **Persistence**: Hive + hive_flutter
- **SVG**: flutter_svg + xml (for parsing/modifying)
- **File handling**: path_provider
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
├── main.dart                    # Entry point, Hive init, Provider setup
├── app.dart                     # MaterialApp + dark theme
├── core/
│   ├── constants.dart           # AppColors, AnimationPresets (24+12), AppConstants
│   ├── theme.dart               # AppTheme.darkTheme
│   └── extensions.dart          # String.capitalize(), Double.toFixed()
├── models/
│   ├── animation_config.dart    # AnimationConfig (HiveType typeId:0, 19 fields)
│   ├── workspace.dart           # Workspace (central model, 29 fields)
│   ├── group.dart               # Group
│   ├── trajectory.dart          # Trajectory + TrajectoryPoint
│   ├── background_image.dart    # BackgroundImage
│   └── svg_element.dart         # SvgElement
├── providers/
│   ├── svg_provider.dart        # Global state (ChangeNotifier, 375 lines)
│   ├── settings_provider.dart   # Settings persistence
│   └── theme_provider.dart      # Theme toggle
├── screens/
│   ├── splash_screen.dart       # 3s splash with fade
│   └── home_screen.dart         # Main screen (596 lines, 4 bottom tabs)
├── widgets/
│   ├── svg_preview.dart         # Preview with InteractiveViewer + AnimationScope
│   ├── individual_elements_view.dart  # Renders each SVG element animated
│   ├── animation_scope.dart     # InheritedWidget with shared AnimationController
│   ├── animation_grid.dart      # 4-column grid of 24 presets
│   ├── controls_panel.dart      # Sliders + toggles + direction pad
│   ├── elements_list.dart       # Element list with selection and groups
│   ├── shapes_grid.dart         # 12 predefined shapes grid
│   ├── pieces_overlay.dart      # Pieces mode overlay
│   ├── trajectory_overlay.dart  # CustomPainter for trajectories
│   ├── trajectory_editor.dart   # Trajectory list + add/delete
│   ├── zoom_controls.dart       # Zoom in/out/reset buttons
│   ├── background_layer.dart    # Background image layer
│   ├── bottom_nav.dart          # 4-tab bottom navigation
│   ├── panel_slider.dart        # Animated sliding panel
│   ├── slider_control.dart      # Reusable slider
│   ├── toggle_group.dart        # Reusable toggle buttons
│   ├── direction_pad.dart       # 8-direction compass pad
│   └── empty_state.dart         # Empty state placeholder
├── services/
│   ├── svg_parser.dart          # SVG XML parser using xml package
│   ├── animation_engine.dart    # 24 animation presets (460 lines, static)
│   ├── animation_service.dart   # Animation config management
│   ├── selection_service.dart   # Element selection logic
│   ├── group_service.dart       # Group CRUD
│   ├── history_service.dart     # Undo/redo via snapshots
│   ├── trajectory_service.dart  # Trajectory CRUD
│   ├── export_service.dart      # Generates SVG with CSS @keyframes (288 lines)
│   ├── file_service.dart        # File I/O wrapper (unused)
│   └── permission_service.dart  # Permission requests (unused)
└── test/
    ├── widget_test.dart
    ├── widget_components_test.dart
    ├── models_test.dart
    ├── providers_test.dart
    └── services/ (7 test files)
```

## Animation Presets

The app supports 24 animation presets:
rotate, wheel, pulse, bounce, gravity, slide, oval, fade, draw, shake, float, levitate, projectile, radiate, spin, glow, wave-sine, wave-square, wave-triangle, pendulum, freefall, elastic-bounce, spring, opacity-anim

Each preset has: name, id, color, duration, easing, and optional `translatable` flag (for directional animations).

### Directional Animations (11)
bounce, gravity, slide, shake, float, levitate, projectile, radiate, wave-sine, wave-square, wave-triangle

### Physics Animations (4)
projectile, freefall, elastic-bounce, spring

## Model Key Points

- `AnimationConfig` uses HiveType with typeId: 0, 19 fields
- `Workspace` stores all state: animations, groups, trajectories, undo stack (29 fields)
- `Trajectory` contains list of `TrajectoryPoint` (x, y)
- `Group` links multiple elements with shared AnimationConfig
- `BackgroundImage` supports opacity, zIndex, position

## Export Flow

1. Parse original SVG with XmlDocument
2. Generate CSS @keyframes for each animated element
3. Inject `<style>` element into SVG
4. Save via File.writeAsString with `flush: true`

## Known Bugs (see docs/BUGS.md for full list)

1. PiecesOverlay drag doesn't update provider state (broken)
2. SvgParser only parses direct children, ignores `<g>` nesting
3. moveSelectedElements doesn't persist to Hive
4. Undo/Redo doesn't restore elementOffsets
5. gravity export ignores directionAngle
6. freefall export distance is 2x the preview value
7. ThemeProvider registered but not connected to MaterialApp

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

## Adding a New Animation

1. Add preset in `lib/core/constants.dart` -> `AnimationPresets.presets`
2. Add case in `buildAnimation()` in `lib/services/animation_engine.dart`
3. Create static method `_buildXxx(Widget child, Animation<double> animation, ...)`
4. If directional, add to `AnimationEngine.isTranslatable()`
5. If has extra params, add fields to `AnimationConfig` + toJson/fromJson/copyWith
6. Add CSS keyframes in `lib/services/export_service.dart` -> `_generateKeyframes()`
7. Add icon mapping in `AnimationGrid`

## Adding a New Shape

1. Add entry to `AnimationPresets.shapes` in `lib/core/constants.dart`
2. Format: `{'name': 'Name', 'svg': '<svg viewBox="0 0 200 200">...</svg>'}`
3. Requirements: viewBox 200x200, `fill="none"`, `stroke-width="3"`

Base directory for this skill: file:///C:/Users/optim/Documents/src/flutter/svg_animated_ftl/.agents/skills/svg-flutter
Relative paths in this skill (e.g., scripts/, reference/) are relative to this base directory.
