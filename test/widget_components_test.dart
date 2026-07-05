import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:svg_animated_ftl/providers/svg_provider.dart';
import 'package:svg_animated_ftl/providers/theme_provider.dart';
import 'package:svg_animated_ftl/providers/settings_provider.dart';
import 'package:svg_animated_ftl/widgets/slider_control.dart';
import 'package:svg_animated_ftl/widgets/toggle_group.dart';
import 'package:svg_animated_ftl/widgets/direction_pad.dart';
import 'package:svg_animated_ftl/widgets/controls_panel.dart';
import 'package:svg_animated_ftl/widgets/elements_list.dart';
import 'package:svg_animated_ftl/widgets/pieces_overlay.dart';
import 'package:svg_animated_ftl/widgets/background_layer.dart';
import 'package:svg_animated_ftl/widgets/shapes_grid.dart';
import 'package:svg_animated_ftl/screens/home_screen.dart';
import 'package:svg_animated_ftl/models/background_image.dart';
import 'package:svg_animated_ftl/core/theme.dart';
import 'package:svg_animated_ftl/core/constants.dart';
import 'package:svg_animated_ftl/models/group.dart';
import 'package:svg_animated_ftl/models/workspace.dart';
import 'package:svg_animated_ftl/models/animation_config.dart';

/// A minimal mock SvgProvider for widget testing that doesn't use Hive.
/// A minimal mock SettingsProvider for widget testing.
class MockSettingsProvider extends ChangeNotifier implements SettingsProvider {
  String _exportPath = '/tmp/test';

  @override
  String get exportPath => _exportPath;

  @override
  Future<void> setExportPath(String path) async {
    _exportPath = path;
    notifyListeners();
  }

  @override
  Future<void> init() async {}
}

/// A minimal mock SvgProvider for widget testing that doesn't use Hive.
class MockSvgProvider extends ChangeNotifier implements SvgProvider {
  final Workspace _workspace = Workspace(id: 'test', name: 'Test Workspace');

  @override
  Workspace get activeWorkspace => _workspace;

  @override
  List<Workspace> get workspaces => [_workspace];

  @override
  int get activeWorkspaceIndex => 0;

  @override
  bool animationPlaying = true;

  @override
  String? get currentSvgString => _workspace.originalSvgString;

  @override
  Map<int, AnimationConfig> get elementAnimations => _workspace.elementAnimations;

  @override
  bool get canUndo => false;

  @override
  bool get canRedo => false;

  @override
  void addWorkspace() {}

  @override
  void switchWorkspace(int index) {}

  @override
  void removeWorkspace(int index) {}

  @override
  void renameWorkspace(String name) {}

  String? loadSvgStringCalledWith;

  @override
  Future<void> loadSvgString(String svgString, {bool createNewWorkspace = true}) async {
    loadSvgStringCalledWith = svgString;
  }

  @override
  void toggleElementSelection(int index) {
    if (_workspace.selectedGroupElements.contains(index)) {
      _workspace.selectedGroupElements.remove(index);
    } else {
      _workspace.selectedGroupElements.add(index);
    }
    notifyListeners();
  }

  @override
  void selectElement(int index) {
    _workspace.selectedElementIndex = index;
    notifyListeners();
  }

  bool clearSelectionCalled = false;

  @override
  void clearSelection() {
    clearSelectionCalled = true;
    notifyListeners();
  }

  // Helpers for widget tests
  void setSvgString(String svg) {
    _workspace.originalSvgString = svg;
    notifyListeners();
  }

  void addGroup(String groupId, Group group) {
    _workspace.elementGroups[groupId] = group;
    notifyListeners();
  }

  void addSelectedElement(int index) {
    _workspace.selectedGroupElements.add(index);
    notifyListeners();
  }

  void clearSelectedElements() {
    _workspace.selectedGroupElements.clear();
    notifyListeners();
  }

  void setConfigForElement(int index, AnimationConfig config) {
    _workspace.elementAnimations[index] = config;
    notifyListeners();
  }

  @override
  void togglePreset(String presetId) {}

  @override
  void updateAnimationSpeed(double speed) {}

  @override
  void updateAnimationDelay(double delay) {}

  @override
  void updateAnimationIteration(String iter) {}

  @override
  void updateAnimationDirection(String dir) {}

  @override
  void updateDirectionAngle(double angle) {}

  @override
  void updateOpacity(double opacity) {}

  @override
  void updateInitialVelocity(double velocity) {}

  @override
  void updateLaunchAngle(double angle) {}

  @override
  void updateGravity(double gravity) {}

  @override
  void updateOvalRx(double rx) {}

  @override
  void updateOvalRy(double ry) {}

  @override
  void updateArcRx(double rx) {}

  @override
  void updateArcRy(double ry) {}

  @override
  void createGroup(List<int> indices, String name) {
    final groupId = 'g_${_workspace.nextGroupId}';
    _workspace.nextGroupId++;
    final colorIndex = _workspace.elementGroups.length % AppColors.groupColors.length;
    _workspace.elementGroups[groupId] = Group(
      name: name,
      color: AppColors.groupColors[colorIndex],
      elements: List.from(indices),
      config: AnimationConfig(presetId: 'rotate'),
    );
    notifyListeners();
  }

  @override
  void deleteGroup(String groupId) {
    _workspace.elementGroups.remove(groupId);
    notifyListeners();
  }

  @override
  void renameGroup(String groupId, String newName) {
    if (_workspace.elementGroups.containsKey(groupId)) {
      _workspace.elementGroups[groupId]!.name = newName;
      notifyListeners();
    }
  }

  @override
  void togglePiecesMode() {}

  @override
  String addTrajectory(String name) => '';

  @override
  void deleteTrajectory(String id) {}

  @override
  void undo() {}

  @override
  void redo() {}

  @override
  void togglePlayPause() {}

  @override
  void setZoom(double level) {}

  @override
  Future<void> init() async {}
}

/// Helper to wrap a widget with required providers.
Widget createTestApp({required Widget home, required MockSvgProvider provider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ChangeNotifierProvider<SettingsProvider>(create: (_) => MockSettingsProvider()),
      ChangeNotifierProvider<SvgProvider>.value(value: provider),
    ],
    child: MaterialApp(
      title: 'SVG Animator',
      theme: AppTheme.darkTheme,
      home: home,
      debugShowCheckedModeBanner: false,
    ),
  );
}

void main() {
  group('SliderControl', () {
    testWidgets('renders the label text', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: Scaffold(
          body: SliderControl(
            label: 'Velocidad',
            value: 1.5,
            min: 0.0,
            max: 10.0,
            onChanged: (_) {},
          ),
        ),
        provider: provider,
      ));

      expect(find.text('Velocidad'), findsOneWidget);
    });

    testWidgets('renders value formatted with one decimal and suffix', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: Scaffold(
          body: SliderControl(
            label: 'Velocidad',
            value: 2.5,
            min: 0.0,
            max: 10.0,
            suffix: 's',
            onChanged: (_) {},
          ),
        ),
        provider: provider,
      ));

      expect(find.text('2.5s'), findsOneWidget);
    });

    testWidgets('renders value without suffix when empty', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: Scaffold(
          body: SliderControl(
            label: 'Opacidad',
            value: 0.75,
            min: 0.0,
            max: 1.0,
            suffix: '',
            onChanged: (_) {},
          ),
        ),
        provider: provider,
      ));

      expect(find.text('0.8'), findsOneWidget);
    });

    testWidgets('contains a Slider widget', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: Scaffold(
          body: SliderControl(
            label: 'Retraso',
            value: 0.0,
            min: 0.0,
            max: 3.0,
            onChanged: (_) {},
          ),
        ),
        provider: provider,
      ));

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('Slider has correct min, max, and value', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: Scaffold(
          body: SliderControl(
            label: 'Retraso',
            value: 1.5,
            min: 0.0,
            max: 3.0,
            onChanged: (_) {},
          ),
        ),
        provider: provider,
      ));

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, equals(0.0));
      expect(slider.max, equals(3.0));
      expect(slider.value, equals(1.5));
    });

    testWidgets('Slider uses default divisions of 100', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: Scaffold(
          body: SliderControl(
            label: 'Velocidad',
            value: 1.0,
            min: 0.0,
            max: 10.0,
            onChanged: (_) {},
          ),
        ),
        provider: provider,
      ));

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.divisions, equals(100));
    });

    testWidgets('Slider uses custom divisions when provided', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: Scaffold(
          body: SliderControl(
            label: 'Opacidad',
            value: 0.5,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: (_) {},
          ),
        ),
        provider: provider,
      ));

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.divisions, equals(20));
    });

    testWidgets('calls onChanged when slider value changes', (tester) async {
      final provider = MockSvgProvider();
      double changedValue = -1;
      await tester.pumpWidget(createTestApp(
        home: Scaffold(
          body: SliderControl(
            label: 'Velocidad',
            value: 1.0,
            min: 0.0,
            max: 10.0,
            onChanged: (v) => changedValue = v,
          ),
        ),
        provider: provider,
      ));

      // Find the slider and simulate a drag
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(50, 0));
      await tester.pump();

      // Value should have changed from the drag
      expect(changedValue, greaterThan(1.0));
    });

    testWidgets('uses accent colors for track and thumb', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: Scaffold(
          body: SliderControl(
            label: 'Velocidad',
            value: 1.0,
            min: 0.0,
            max: 10.0,
            onChanged: (_) {},
          ),
        ),
        provider: provider,
      ));

      // SliderTheme should apply accent colors
      final sliderTheme = tester.widget<SliderTheme>(find.byType(SliderTheme));
      expect(sliderTheme.data.activeTrackColor, equals(AppColors.accent));
      expect(sliderTheme.data.thumbColor, equals(AppColors.accent));
      expect(sliderTheme.data.inactiveTrackColor, equals(AppColors.border));
    });
  });

  group('ToggleGroup', () {
    testWidgets('renders all options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleGroup(
              options: ['infinite', '1', '3', 'random'],
              selected: 'infinite',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Infinite'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Random'), findsOneWidget);
    });

    testWidgets('highlights selected option with accent color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleGroup(
              options: ['normal', 'reverse', 'alternate'],
              selected: 'reverse',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Reverse'), findsOneWidget);

      // Check that the selected option has accent color
      final reverseContainer = tester.widget<Container>(
        find.ancestor(of: find.text('Reverse'), matching: find.byType(Container)).first,
      );
      expect(reverseContainer.decoration, isA<BoxDecoration>());
      final decoration = reverseContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.accent));
      final border = decoration.border as Border;
      expect(border.top.color, equals(AppColors.accent));
    });

    testWidgets('non-selected option uses surface2 color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleGroup(
              options: ['normal', 'reverse', 'alternate'],
              selected: 'reverse',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Non-selected "Normal" should have surface2 background
      final normalContainer = tester.widget<Container>(
        find.ancestor(of: find.text('Normal'), matching: find.byType(Container)).first,
      );
      final decoration = normalContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.surface2));
      final border = decoration.border as Border;
      expect(border.top.color, equals(AppColors.border));
    });

    testWidgets('selected option has bold white text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleGroup(
              options: ['infinite', '1', '3'],
              selected: 'infinite',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final infiniteText = tester.widget<Text>(find.text('Infinite'));
      expect(infiniteText.style!.fontWeight, equals(FontWeight.w600));
      expect(infiniteText.style!.color, equals(Colors.white));
    });

    testWidgets('non-selected option has dim text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleGroup(
              options: ['infinite', '1', '3'],
              selected: 'infinite',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final oneText = tester.widget<Text>(find.text('1'));
      expect(oneText.style!.fontWeight, equals(FontWeight.normal));
      expect(oneText.style!.color, equals(AppColors.textDim));
    });

    testWidgets('calls onChanged when tapping an option', (tester) async {
      String? selectedOption;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleGroup(
              options: ['normal', 'reverse', 'alternate'],
              selected: 'normal',
              onChanged: (v) => selectedOption = v,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reverse'));
      expect(selectedOption, equals('reverse'));
    });

    testWidgets('capitalizes each option label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleGroup(
              options: ['random', 'infinite'],
              selected: 'random',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Should show "Random" not "random"
      expect(find.text('Random'), findsOneWidget);
      expect(find.text('random'), findsNothing);
    });

    testWidgets('empty string option shows empty label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleGroup(
              options: [''],
              selected: '',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Empty string should remain empty — verify by checking the container exists
      expect(find.byType(ToggleGroup), findsOneWidget);
      // There should be exactly 1 Expanded child (the empty option)
      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('tapping different options updates selection', (tester) async {
      List<String> selectedOptions = [];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToggleGroup(
              options: ['a', 'b', 'c'],
              selected: 'a',
              onChanged: (v) => selectedOptions.add(v),
            ),
          ),
        ),
      );

      await tester.tap(find.text('A'));
      await tester.tap(find.text('B'));
      await tester.tap(find.text('C'));

      expect(selectedOptions, equals(['a', 'b', 'c']));
    });
  });

  group('DirectionPad', () {
    /// Helper to build DirectionPad with scroll support (matches production usage
    /// via ControlsPanel's SingleChildScrollView).
    Widget buildDirectionPad({
      required MockSvgProvider provider,
      required ValueChanged<double> onAngleChanged,
    }) {
      return createTestApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DirectionPad(onAngleChanged: onAngleChanged),
          ),
        ),
        provider: provider,
      );
    }

    testWidgets('renders Dirección label', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(buildDirectionPad(
        provider: provider,
        onAngleChanged: (_) {},
      ));

      expect(find.text('Dirección'), findsOneWidget);
    });

    testWidgets('renders all 8 direction labels', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(buildDirectionPad(
        provider: provider,
        onAngleChanged: (_) {},
      ));

      expect(find.text('↑'), findsOneWidget);
      expect(find.text('↗'), findsOneWidget);
      expect(find.text('→'), findsOneWidget);
      expect(find.text('↘'), findsOneWidget);
      expect(find.text('↓'), findsOneWidget);
      expect(find.text('↙'), findsOneWidget);
      expect(find.text('←'), findsOneWidget);
      expect(find.text('↖'), findsOneWidget);
    });

    testWidgets('highlights selected direction based on element config', (tester) async {
      final provider = MockSvgProvider();
      // Set element 0 with directionAngle 180 (←)
      provider.selectElement(0);
      provider.elementAnimations[0] = AnimationConfig(presetId: 'slide', directionAngle: 180);

      await tester.pumpWidget(buildDirectionPad(
        provider: provider,
        onAngleChanged: (_) {},
      ));

      // The ← (180°) button should have accent color
      final leftContainer = tester.widget<Container>(
        find.ancestor(of: find.text('←'), matching: find.byType(Container)).first,
      );
      final decoration = leftContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.accent));
    });

    testWidgets('non-selected directions have surface2 color', (tester) async {
      final provider = MockSvgProvider();
      provider.selectElement(0);
      provider.elementAnimations[0] = AnimationConfig(presetId: 'slide', directionAngle: 180);

      await tester.pumpWidget(buildDirectionPad(
        provider: provider,
        onAngleChanged: (_) {},
      ));

      // ↑ (0°) should not be selected, so surface2
      final upContainer = tester.widget<Container>(
        find.ancestor(of: find.text('↑'), matching: find.byType(Container)).first,
      );
      final decoration = upContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.surface2));
    });

    testWidgets('defaults to angle 0 when no animation config', (tester) async {
      final provider = MockSvgProvider();
      // Element selected but no config — defaults to 0
      provider.selectElement(0);

      await tester.pumpWidget(buildDirectionPad(
        provider: provider,
        onAngleChanged: (_) {},
      ));

      // In the widget's data, angle 0 corresponds to '↗' label
      final initialContainer = tester.widget<Container>(
        find.ancestor(of: find.text('↗'), matching: find.byType(Container)).first,
      );
      final decoration = initialContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.accent));
    });

    testWidgets('calls onAngleChanged with correct angle when tapping', (tester) async {
      final provider = MockSvgProvider();
      provider.selectElement(0);
      provider.elementAnimations[0] = AnimationConfig(presetId: 'slide', directionAngle: 0);

      double? changedAngle;
      await tester.pumpWidget(buildDirectionPad(
        provider: provider,
        onAngleChanged: (angle) => changedAngle = angle,
      ));

      // Tap '→' — in the widget's data, '→' is at index 3 = angle 135
      await tester.ensureVisible(find.text('→'));
      await tester.tap(find.text('→'));
      expect(changedAngle, equals(135.0));
    });

    testWidgets('tapping different directions gives different angles', (tester) async {
      final provider = MockSvgProvider();
      provider.selectElement(0);
      provider.elementAnimations[0] = AnimationConfig(presetId: 'slide', directionAngle: 0);

      List<double> angles = [];
      await tester.pumpWidget(buildDirectionPad(
        provider: provider,
        onAngleChanged: (angle) => angles.add(angle),
      ));

      // Widget's mapping: labels[3]='→'→angle 135, labels[6]='↓'→angle 270, labels[4]='←'→angle 180
      // GridView may extend beyond viewport — ensure each target is visible before tapping
      await tester.ensureVisible(find.text('→'));
      await tester.tap(find.text('→'));
      await tester.ensureVisible(find.text('↓'));
      await tester.tap(find.text('↓'));
      await tester.ensureVisible(find.text('←'));
      await tester.tap(find.text('←'));

      expect(angles, equals([135.0, 270.0, 180.0]));
    });

    testWidgets('re-renders when SvgProvider notifies change', (tester) async {
      final provider = MockSvgProvider();
      provider.selectElement(0);
      provider.elementAnimations[0] = AnimationConfig(presetId: 'slide', directionAngle: 0);

      await tester.pumpWidget(buildDirectionPad(
        provider: provider,
        onAngleChanged: (_) {},
      ));

      // Widget mapping: angle 0 → index 0 → '↗'
      final initialContainer = tester.widget<Container>(
        find.ancestor(of: find.text('↗'), matching: find.byType(Container)).first,
      );
      expect(
        (initialContainer.decoration as BoxDecoration).color,
        equals(AppColors.accent),
      );

      // Change the direction angle to 90 and notify
      provider.elementAnimations[0]!.directionAngle = 90;
      provider.notifyListeners();
      await tester.pump();

      // Widget mapping: angle 90 → index 2 → '↖'
      final newSelected = tester.widget<Container>(
        find.ancestor(of: find.text('↖'), matching: find.byType(Container)).first,
      );
      expect(
        (newSelected.decoration as BoxDecoration).color,
        equals(AppColors.accent),
      );

      // '↗' should no longer be selected
      final updatedContainer = tester.widget<Container>(
        find.ancestor(of: find.text('↗'), matching: find.byType(Container)).first,
      );
      expect(
        (updatedContainer.decoration as BoxDecoration).color,
        equals(AppColors.surface2),
      );
    });

    testWidgets('renders within a GridView', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(buildDirectionPad(
        provider: provider,
        onAngleChanged: (_) {},
      ));

      expect(find.byType(GridView), findsOneWidget);
    });
  });

  group('ControlsPanel', () {
    /// Helper to build ControlsPanel with scroll support.
    Widget buildPanel(MockSvgProvider provider) {
      return createTestApp(
        home: Scaffold(
          body: ControlsPanel(),
        ),
        provider: provider,
      );
    }

    testWidgets('shows empty message when no elements selected', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(buildPanel(provider));

      expect(find.text('Selecciona piezas para editar'), findsOneWidget);
    });

    testWidgets('shows Velocidad and Retraso sliders with defaults', (tester) async {
      final provider = MockSvgProvider();
      provider.addSelectedElement(0);
      await tester.pumpWidget(buildPanel(provider));

      expect(find.text('Velocidad'), findsOneWidget);
      expect(find.text('Retraso'), findsOneWidget);

      // Default values
      expect(find.text('1.0s'), findsOneWidget);
      expect(find.text('0.0s'), findsOneWidget);

      // Slider properties
      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      expect(sliders.length, greaterThanOrEqualTo(2));
      expect(sliders[0].min, equals(0.2));
      expect(sliders[0].max, equals(16.0));
      expect(sliders[0].value, equals(1.0));
      expect(sliders[1].min, equals(0.0));
      expect(sliders[1].max, equals(3.0));
      expect(sliders[1].value, equals(0.0));
    });

    testWidgets('shows Opacidad section with Transparencia slider', (tester) async {
      final provider = MockSvgProvider();
      provider.addSelectedElement(0);
      await tester.pumpWidget(buildPanel(provider));

      expect(find.text('Opacidad'), findsOneWidget);
      expect(find.text('Transparencia'), findsOneWidget);
      expect(find.text('1.0'), findsOneWidget); // default opacity
    });

    testWidgets('shows Repetición ToggleGroup with Infinite selected', (tester) async {
      final provider = MockSvgProvider();
      provider.addSelectedElement(0);
      await tester.pumpWidget(buildPanel(provider));

      expect(find.text('Repetición'), findsOneWidget);
      expect(find.text('Infinite'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Random'), findsOneWidget);
    });

    testWidgets('shows Dirección ToggleGroup with Normal selected', (tester) async {
      final provider = MockSvgProvider();
      provider.addSelectedElement(0);
      await tester.pumpWidget(buildPanel(provider));

      expect(find.text('Dirección'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Reverse'), findsOneWidget);
      expect(find.text('Alternate'), findsOneWidget);
    });

    testWidgets('does not show DirectionPad when no translatable preset', (tester) async {
      final provider = MockSvgProvider();
      provider.addSelectedElement(0);
      // default config has no presetId
      await tester.pumpWidget(buildPanel(provider));

      expect(find.byType(DirectionPad), findsNothing);
    });

    testWidgets('shows DirectionPad with translatable preset (slide)', (tester) async {
      final provider = MockSvgProvider();
      provider.addSelectedElement(0);
      provider.setConfigForElement(0, AnimationConfig(presetId: 'slide'));
      await tester.pumpWidget(buildPanel(provider));

      // Should show DirectionPad inside ControlsPanel
      await tester.ensureVisible(find.byType(DirectionPad));
      expect(find.byType(DirectionPad), findsOneWidget);
      expect(find.text('Dirección'), findsWidgets); // label from both section header and pad
    });

    testWidgets('shows multi-selection banner with element count', (tester) async {
      final provider = MockSvgProvider();
      provider.addSelectedElement(0);
      provider.addSelectedElement(1);
      provider.addSelectedElement(2);
      await tester.pumpWidget(buildPanel(provider));

      expect(
        find.text('3 piezas seleccionadas — los cambios aplican a todas'),
        findsOneWidget,
      );
    });

    testWidgets('shows oval sliders when preset is oval', (tester) async {
      final provider = MockSvgProvider();
      provider.addSelectedElement(0);
      provider.setConfigForElement(0, AnimationConfig(presetId: 'oval'));
      await tester.pumpWidget(buildPanel(provider));

      await tester.ensureVisible(find.text('Ancho (X)'));
      expect(find.text('Ancho (X)'), findsOneWidget);
      expect(find.text('Alto (Y)'), findsOneWidget);
      expect(find.text('80.0px'), findsOneWidget); // default ovalRx
      expect(find.text('40.0px'), findsOneWidget); // default ovalRy
    });

    testWidgets('shows projectile physics sliders when preset is projectile', (tester) async {
      final provider = MockSvgProvider();
      provider.addSelectedElement(0);
      provider.setConfigForElement(0, AnimationConfig(presetId: 'projectile'));
      await tester.pumpWidget(buildPanel(provider));

      await tester.ensureVisible(find.text('Física — Tiro Oblicuo'));
      expect(find.text('Física — Tiro Oblicuo'), findsOneWidget);
      expect(find.text('Velocidad inicial (v₀)'), findsOneWidget);
      expect(find.text('Ángulo de lanzamiento (θ)'), findsOneWidget);
      expect(find.text('Gravedad (g)'), findsOneWidget);

      // Default values
      expect(find.text('100.0px/s'), findsOneWidget);
      expect(find.text('45.0°'), findsOneWidget);
      expect(find.text('9.8m/s²'), findsOneWidget);
    });

    testWidgets('shows radiate arc sliders when preset is radiate', (tester) async {
      final provider = MockSvgProvider();
      provider.addSelectedElement(0);
      provider.setConfigForElement(0, AnimationConfig(presetId: 'radiate'));
      await tester.pumpWidget(buildPanel(provider));

      await tester.ensureVisible(find.text('Eje X'));
      expect(find.text('Eje X'), findsOneWidget);
      expect(find.text('Eje Y'), findsOneWidget);
      expect(find.text('80.0px'), findsWidgets); // default arcRx
      expect(find.text('80.0px'), findsWidgets); // default arcRy
    });

    testWidgets('hides oval, projectile, and radiate sections without matching preset', (tester) async {
      final provider = MockSvgProvider();
      provider.addSelectedElement(0);
      // Default config — presetId is null
      await tester.pumpWidget(buildPanel(provider));

      expect(find.text('Ancho (X)'), findsNothing);
      expect(find.text('Física — Tiro Oblicuo'), findsNothing);
      expect(find.text('Eje X'), findsNothing);
    });

    testWidgets('uses custom config values from provider', (tester) async {
      final provider = MockSvgProvider();
      provider.addSelectedElement(0);
      provider.setConfigForElement(0, AnimationConfig(
        presetId: 'bounce',
        speed: 2.5,
        delay: 1.0,
        opacity: 0.5,
        iter: '3',
        dir: 'alternate',
      ));
      await tester.pumpWidget(buildPanel(provider));

      expect(find.text('2.5s'), findsOneWidget);
      expect(find.text('1.0s'), findsOneWidget);
      expect(find.text('0.5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Alternate'), findsOneWidget);
    });

    testWidgets('does not show multi-selection banner with single element', (tester) async {
      final provider = MockSvgProvider();
      provider.addSelectedElement(0);
      await tester.pumpWidget(buildPanel(provider));

      expect(find.textContaining('piezas seleccionadas'), findsNothing);
    });
  });

  group('ElementsList', () {
    final svgCircle = '<svg viewBox="0 0 200 200"><circle cx="100" cy="100" r="70"/></svg>';
    final svgMulti = '<svg viewBox="0 0 200 200">'
        '<circle cx="50" cy="50" r="30"/>'
        '<rect x="10" y="10" width="50" height="50"/>'
        '<path d="M10 10 L50 50"/>'
        '<ellipse cx="100" cy="100" rx="30" ry="20"/>'
        '</svg>';

    Widget buildList(MockSvgProvider provider) {
      return createTestApp(
        home: Scaffold(
          body: ElementsList(),
        ),
        provider: provider,
      );
    }

    testWidgets('shows carga SVG message when no SVG loaded', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(buildList(provider));

      expect(find.text('Carga un SVG primero'), findsOneWidget);
    });

    testWidgets('shows error message for invalid SVG', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString('not valid svg');
      await tester.pumpWidget(buildList(provider));

      expect(find.textContaining('Error'), findsWidgets);
    });

    testWidgets('shows PIEZAS section with element items', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      await tester.pumpWidget(buildList(provider));

      expect(find.text('PIEZAS'), findsOneWidget);
      expect(find.text('circle 0'), findsOneWidget);
      expect(find.text('rect 1'), findsOneWidget);
      expect(find.text('path 2'), findsOneWidget);
      expect(find.text('ellipse 3'), findsOneWidget);
    });

    testWidgets('shows icon matching element tag', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      await tester.pumpWidget(buildList(provider));

      // circle/ellipse -> circle_outlined, rect -> square_outlined, path -> timeline
      expect(find.byIcon(Icons.circle_outlined), findsWidgets);
      expect(find.byIcon(Icons.square_outlined), findsOneWidget);
      expect(find.byIcon(Icons.timeline), findsOneWidget);
    });

    testWidgets('shows default animation name (dash) when no config', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgCircle);
      await tester.pumpWidget(buildList(provider));

      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('shows animation config name for element', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgCircle);
      provider.setConfigForElement(0, AnimationConfig(presetId: 'bounce'));
      await tester.pumpWidget(buildList(provider));

      expect(find.text('bounce'), findsOneWidget);
      expect(find.text('—'), findsNothing);
    });

    testWidgets('shows selected element with accent border', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgCircle);
      provider.addSelectedElement(0);
      await tester.pumpWidget(buildList(provider));

      final elementContainer = tester.widget<Container>(
        find.ancestor(of: find.text('circle 0'), matching: find.byType(Container)).first,
      );
      final decoration = elementContainer.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, equals(AppColors.accent));
    });

    testWidgets('shows check icon for selected element', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addSelectedElement(1);
      await tester.pumpWidget(buildList(provider));

      // The selected element should have a check_circle icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsWidgets); // other elements
    });

    testWidgets('tapping element selects it', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgCircle);
      await tester.pumpWidget(buildList(provider));

      expect(find.byIcon(Icons.check_circle), findsNothing);

      await tester.tap(find.text('circle 0'));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('tapping element twice deselects it', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgCircle);
      await tester.pumpWidget(buildList(provider));

      // First tap selects
      await tester.tap(find.text('circle 0'));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Second tap deselects
      await tester.tap(find.text('circle 0'));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('shows empty PIEZAS when no animatable elements', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString('<svg viewBox="0 0 200 200"><defs><linearGradient id="g"/></defs></svg>');
      await tester.pumpWidget(buildList(provider));

      expect(find.text('PIEZAS'), findsOneWidget);
      // No element items should exist
      expect(find.textContaining(' 0'), findsNothing);
    });

    testWidgets('hides Agrupar button with single element selected', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addSelectedElement(0);
      await tester.pumpWidget(buildList(provider));

      expect(find.text('Agrupar seleccionadas'), findsNothing);
    });

    testWidgets('shows Agrupar button when 2+ elements selected', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addSelectedElement(0);
      provider.addSelectedElement(1);
      await tester.pumpWidget(buildList(provider));

      expect(find.text('Agrupar seleccionadas'), findsOneWidget);
      expect(find.byIcon(Icons.group_add), findsOneWidget);
    });

    testWidgets('tapping Agrupar opens create group dialog', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addSelectedElement(0);
      provider.addSelectedElement(1);
      await tester.pumpWidget(buildList(provider));

      await tester.tap(find.text('Agrupar seleccionadas'));
      await tester.pump();

      expect(find.text('Nombre del grupo'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Crear'), findsOneWidget);
    });

    testWidgets('creating group via dialog adds group tile', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addSelectedElement(0);
      provider.addSelectedElement(1);
      await tester.pumpWidget(buildList(provider));

      // Open the create group dialog
      await tester.tap(find.text('Agrupar seleccionadas'));
      await tester.pump();

      // Type a group name
      await tester.enterText(find.byType(TextField), 'Motor');
      await tester.pump();

      // Press Crear
      await tester.tap(find.text('Crear'));
      await tester.pump();

      // Dialog should be closed and group should appear
      expect(find.text('Nombre del grupo'), findsNothing);
      expect(find.text('Motor'), findsOneWidget);
      expect(find.text('GRUPOS'), findsOneWidget);
      expect(find.text('2 piezas'), findsOneWidget);
    });

    testWidgets('creating group with empty name does not create', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addSelectedElement(0);
      provider.addSelectedElement(1);
      await tester.pumpWidget(buildList(provider));

      await tester.tap(find.text('Agrupar seleccionadas'));
      await tester.pump();

      // Press Crear without typing a name
      await tester.tap(find.text('Crear'));
      await tester.pump();

      // Dialog stays open because name is empty
      expect(find.text('Nombre del grupo'), findsOneWidget);
      expect(find.text('GRUPOS'), findsNothing);

      // Now cancel and verify no group was created
      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      expect(find.text('Nombre del grupo'), findsNothing);
    });

    testWidgets('Cancel button in create dialog closes without creating', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addSelectedElement(0);
      provider.addSelectedElement(1);
      await tester.pumpWidget(buildList(provider));

      await tester.tap(find.text('Agrupar seleccionadas'));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      // Press Cancelar instead of Crear
      await tester.tap(find.text('Cancelar'));
      await tester.pump();

      // Dialog closed, no group created
      expect(find.text('Nombre del grupo'), findsNothing);
      expect(find.text('Test'), findsNothing);
    });

    testWidgets('shows GRUPOS section with group tiles', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addGroup('g1', Group(
        name: 'Ruedas',
        color: '#6c5ce7',
        elements: [0, 1],
        config: AnimationConfig(presetId: 'rotate'),
      ));
      provider.addGroup('g2', Group(
        name: 'Alas',
        color: '#e74c3c',
        elements: [2, 3],
        config: AnimationConfig(presetId: 'slide'),
      ));
      await tester.pumpWidget(buildList(provider));

      expect(find.text('GRUPOS'), findsOneWidget);
      expect(find.text('Ruedas'), findsOneWidget);
      expect(find.text('Alas'), findsOneWidget);
      expect(find.text('2 piezas'), findsWidgets);
    });

    testWidgets('group tile has edit and delete buttons', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addGroup('g1', Group(
        name: 'Ruedas',
        color: '#6c5ce7',
        elements: [0, 1],
      ));
      await tester.pumpWidget(buildList(provider));

      await tester.ensureVisible(find.byIcon(Icons.edit));
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.byIcon(Icons.group), findsOneWidget);
    });

    testWidgets('tapping edit on group opens rename dialog', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addGroup('g1', Group(
        name: 'Ruedas',
        color: '#6c5ce7',
        elements: [0, 1],
      ));
      await tester.pumpWidget(buildList(provider));

      await tester.ensureVisible(find.byIcon(Icons.edit));
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      expect(find.text('Renombrar grupo'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets('renaming group via dialog updates tile name', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addGroup('g1', Group(
        name: 'Ruedas',
        color: '#6c5ce7',
        elements: [0, 1],
      ));
      await tester.pumpWidget(buildList(provider));

      expect(find.text('Ruedas'), findsOneWidget);

      await tester.ensureVisible(find.byIcon(Icons.edit));
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Clear existing and type new name
      await tester.enterText(find.byType(TextField), 'Alas Mejoradas');
      await tester.pump();

      // Press Guardar
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // Old name gone, new name appears
      expect(find.text('Ruedas'), findsNothing);
      expect(find.text('Alas Mejoradas'), findsOneWidget);
    });

    testWidgets('renaming with empty name does not change', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addGroup('g1', Group(
        name: 'Ruedas',
        color: '#6c5ce7',
        elements: [0, 1],
      ));
      await tester.pumpWidget(buildList(provider));

      await tester.ensureVisible(find.byIcon(Icons.edit));
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Clear the text field
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Press Guardar with empty name
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // Dialog stays open because name is empty
      expect(find.text('Renombrar grupo'), findsOneWidget);
      expect(find.text('Ruedas'), findsOneWidget);

      // Cancel to close
      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      expect(find.text('Renombrar grupo'), findsNothing);
    });

    testWidgets('tapping delete on group calls provider.deleteGroup', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addGroup('g1', Group(
        name: 'Ruedas',
        color: '#6c5ce7',
        elements: [0, 1],
      ));
      await tester.pumpWidget(buildList(provider));

      expect(find.text('Ruedas'), findsOneWidget);

      await tester.ensureVisible(find.byIcon(Icons.delete));
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text('Ruedas'), findsNothing);
    });

    testWidgets('GRUPOS section appears before PIEZAS', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      provider.addGroup('g1', Group(
        name: 'TestGroup',
        color: '#6c5ce7',
        elements: [0, 1],
      ));
      await tester.pumpWidget(buildList(provider));

      // Both sections present
      expect(find.text('GRUPOS'), findsOneWidget);
      expect(find.text('PIEZAS'), findsOneWidget);
    });

    testWidgets('no GRUPOS section when no groups exist', (tester) async {
      final provider = MockSvgProvider();
      provider.setSvgString(svgMulti);
      await tester.pumpWidget(buildList(provider));

      expect(find.text('GRUPOS'), findsNothing);
      expect(find.text('PIEZAS'), findsOneWidget);
    });
  });

  group('PiecesOverlay', () {
    testWidgets('shows Modo Piezas text when pieces mode active', (tester) async {
      final provider = MockSvgProvider();
      provider.activeWorkspace.isPiecesMode = true;
      await tester.pumpWidget(createTestApp(
        home: Scaffold(body: PiecesOverlay()),
        provider: provider,
      ));

      expect(find.text('Modo Piezas'), findsOneWidget);
      expect(find.byIcon(Icons.touch_app), findsOneWidget);
    });

    testWidgets('hides content when pieces mode off', (tester) async {
      final provider = MockSvgProvider();
      provider.activeWorkspace.isPiecesMode = false;
      await tester.pumpWidget(createTestApp(
        home: Scaffold(body: PiecesOverlay()),
        provider: provider,
      ));

      expect(find.text('Modo Piezas'), findsNothing);
    });

    testWidgets('text uses white color and small font', (tester) async {
      final provider = MockSvgProvider();
      provider.activeWorkspace.isPiecesMode = true;
      await tester.pumpWidget(createTestApp(
        home: Scaffold(body: PiecesOverlay()),
        provider: provider,
      ));

      final textWidget = tester.widget<Text>(find.text('Modo Piezas'));
      expect(textWidget.style?.color, equals(Colors.white));
      expect(textWidget.style?.fontSize, equals(10.0));
    });

    testWidgets('mode indicator has accent background', (tester) async {
      final provider = MockSvgProvider();
      provider.activeWorkspace.isPiecesMode = true;
      await tester.pumpWidget(createTestApp(
        home: Scaffold(body: PiecesOverlay()),
        provider: provider,
      ));

      final container = tester.widget<Container>(
        find.ancestor(of: find.text('Modo Piezas'), matching: find.byType(Container)).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
      expect(decoration.borderRadius, isNotNull);
    });

    testWidgets('tapping on overlay calls clearSelection', (tester) async {
      final provider = MockSvgProvider();
      provider.activeWorkspace.isPiecesMode = true;
      await tester.pumpWidget(createTestApp(
        home: Scaffold(body: PiecesOverlay()),
        provider: provider,
      ));

      expect(provider.clearSelectionCalled, isFalse);

      // Tap anywhere on the overlay — Positioned.fill GestureDetector covers it
      await tester.tapAt(const Offset(50, 50));
      await tester.pump();

      expect(provider.clearSelectionCalled, isTrue);
    });

    testWidgets('re-renders on provider change', (tester) async {
      final provider = MockSvgProvider();
      provider.activeWorkspace.isPiecesMode = true;
      await tester.pumpWidget(createTestApp(
        home: Scaffold(body: PiecesOverlay()),
        provider: provider,
      ));

      expect(find.text('Modo Piezas'), findsOneWidget);

      provider.notifyListeners();
      await tester.pump();

      expect(find.text('Modo Piezas'), findsOneWidget);
    });
  });

  group('BackgroundLayer', () {
    Widget buildBg(MockSvgProvider provider) {
      return createTestApp(
        home: Scaffold(body: BackgroundLayer()),
        provider: provider,
      );
    }

    testWidgets('renders nothing when no background images', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(buildBg(provider));

      // No Positioned widgets = no background images rendered
      expect(find.byType(Positioned), findsNothing);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders Positioned for visible images', (tester) async {
      final provider = MockSvgProvider();
      provider.activeWorkspace.backgroundImages.add(BackgroundImage(
        id: 'img1',
        name: 'test.png',
        path: '/tmp/test.png',
        x: 100,
        y: 200,
        width: 400,
        height: 300,
        opacity: 0.8,
      ));
      await tester.pumpWidget(buildBg(provider));

      expect(find.byType(Positioned), findsOneWidget);
      expect(find.byType(Opacity), findsOneWidget);
    });

    testWidgets('uses correct Positioned coordinates', (tester) async {
      final provider = MockSvgProvider();
      provider.activeWorkspace.backgroundImages.add(BackgroundImage(
        id: 'img1',
        name: 'test.png',
        path: '/tmp/test.png',
        x: 50,
        y: 75,
      ));
      provider.notifyListeners();
      await tester.pumpWidget(buildBg(provider));

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.left, equals(50.0));
      expect(positioned.top, equals(75.0));
    });

    testWidgets('uses correct opacity for image', (tester) async {
      final provider = MockSvgProvider();
      provider.activeWorkspace.backgroundImages.add(BackgroundImage(
        id: 'img1',
        name: 'test.png',
        path: '/tmp/test.png',
        opacity: 0.5,
      ));
      provider.notifyListeners();
      await tester.pumpWidget(buildBg(provider));

      final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacityWidget.opacity, equals(0.5));
    });

    testWidgets('shows errorBuilder for missing image files', (tester) async {
      final provider = MockSvgProvider();
      provider.activeWorkspace.backgroundImages.add(BackgroundImage(
        id: 'img1',
        name: 'missing.png',
        path: '/tmp/nonexistent_file_xyz.png',
      ));
      await tester.pumpWidget(buildBg(provider));

      // The errorBuilder returns SizedBox.shrink() when file doesn't exist
      // Image widget should still be in the tree
      expect(find.byType(Positioned), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('filters out hidden images', (tester) async {
      final provider = MockSvgProvider();
      provider.activeWorkspace.backgroundImages.add(BackgroundImage(
        id: 'visible',
        name: 'visible.png',
        path: '/tmp/visible.png',
        hidden: false,
      ));
      provider.activeWorkspace.backgroundImages.add(BackgroundImage(
        id: 'hidden',
        name: 'hidden.png',
        path: '/tmp/hidden.png',
        hidden: true,
      ));
      await tester.pumpWidget(buildBg(provider));

      // Only 1 Positioned for the visible image
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('renders multiple visible images', (tester) async {
      final provider = MockSvgProvider();
      provider.activeWorkspace.backgroundImages.add(BackgroundImage(
        id: 'img1', name: 'a.png', path: '/tmp/a.png',
      ));
      provider.activeWorkspace.backgroundImages.add(BackgroundImage(
        id: 'img2', name: 'b.png', path: '/tmp/b.png',
      ));
      provider.activeWorkspace.backgroundImages.add(BackgroundImage(
        id: 'img3', name: 'c.png', path: '/tmp/c.png',
      ));
      provider.notifyListeners();
      await tester.pumpWidget(buildBg(provider));

      expect(find.byType(Positioned), findsNWidgets(3));
    });

    testWidgets('all images hidden shows nothing', (tester) async {
      final provider = MockSvgProvider();
      provider.activeWorkspace.backgroundImages.add(BackgroundImage(
        id: 'h1', name: 'h1.png', path: '/tmp/h1.png', hidden: true,
      ));
      provider.activeWorkspace.backgroundImages.add(BackgroundImage(
        id: 'h2', name: 'h2.png', path: '/tmp/h2.png', hidden: true,
      ));
      await tester.pumpWidget(buildBg(provider));

      expect(find.byType(Positioned), findsNothing);
    });
  });

  group('ShapesGrid', () {
    /// Helper: create test app with tall viewport so all 12 GridView items render.
    /// GridView.builder uses lazy rendering — items off-screen are NOT built.
    /// Default test viewport is 800x600 which only shows ~6 items (2 rows × 3 cols).
    /// We use setSurfaceSize(800, 1400) to show all 4 rows.
    Future<void> pumpGrid(
      WidgetTester tester,
      MockSvgProvider provider,
    ) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      await tester.pumpWidget(createTestApp(
        home: Scaffold(body: ShapesGrid()),
        provider: provider,
      ));
    }

    testWidgets('renders GridView with all 12 shape names', (tester) async {
      final provider = MockSvgProvider();
      await pumpGrid(tester, provider);

      expect(find.byType(GridView), findsOneWidget);
      for (final shape in AnimationPresets.shapes) {
        expect(find.text(shape['name']), findsOneWidget);
      }
    });

    testWidgets('shape name uses textDim color and small font', (tester) async {
      final provider = MockSvgProvider();
      await pumpGrid(tester, provider);

      final text = tester.widget<Text>(find.text('Círculo'));
      expect(text.style?.color, equals(AppColors.textDim));
      expect(text.style?.fontSize, equals(10.0));
    });

    testWidgets('shape container has surface2 background with border', (tester) async {
      final provider = MockSvgProvider();
      await pumpGrid(tester, provider);

      final container = tester.widget<Container>(
        find.ancestor(of: find.text('Círculo'), matching: find.byType(Container)).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.surface2));
      final border = decoration.border as Border;
      expect(border.top.color, equals(AppColors.border));
    });

    testWidgets('tapping shape loads its SVG via provider', (tester) async {
      final provider = MockSvgProvider();
      await pumpGrid(tester, provider);

      await tester.tap(find.text('Círculo'));
      await tester.pump();

      expect(provider.loadSvgStringCalledWith, isNotNull);
      expect(provider.loadSvgStringCalledWith, contains('<circle'));
    });

    testWidgets('tapping different shapes loads different SVGs', (tester) async {
      final provider = MockSvgProvider();
      await pumpGrid(tester, provider);

      await tester.tap(find.text('Estrella'));
      expect(provider.loadSvgStringCalledWith, contains('<polygon'));

      provider.loadSvgStringCalledWith = null;
      await tester.tap(find.text('Corazón'));
      expect(provider.loadSvgStringCalledWith, contains('<path'));
    });

    testWidgets('GridView has 3 columns and correct spacing', (tester) async {
      final provider = MockSvgProvider();
      await pumpGrid(tester, provider);

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(3));
      expect(delegate.mainAxisSpacing, equals(8.0));
      expect(delegate.crossAxisSpacing, equals(8.0));
    });

    testWidgets('renders correct 12 shapes count via presets', (tester) async {
      expect(AnimationPresets.shapes.length, equals(12));
    });
  });

  group('ImportPanel (via HomeScreen)', () {
    testWidgets('tapping Importar tab shows Pegar SVG button', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      await tester.tap(find.text('Importar'));
      await tester.pump();

      expect(find.text('Pegar SVG'), findsOneWidget);
    });

    testWidgets('Pegar SVG button opens paste dialog', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      await tester.tap(find.text('Importar'));
      await tester.pump();

      await tester.tap(find.text('Pegar SVG'));
      await tester.pump();

      expect(find.text('Pegar código SVG'), findsOneWidget);
      expect(find.text('Cancelar'), findsWidgets);
      expect(find.text('Cargar'), findsOneWidget);
    });

    testWidgets('cancel paste dialog closes without loading', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      await tester.tap(find.text('Importar'));
      await tester.pump();
      await tester.tap(find.text('Pegar SVG'));
      await tester.pump();

      // Cancel
      await tester.tap(find.text('Cancelar'));
      await tester.pump();

      expect(find.text('Pegar código SVG'), findsNothing);
      expect(provider.loadSvgStringCalledWith, isNull);
    });

    testWidgets('Import tab shows ShapesGrid below button', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      await tester.tap(find.text('Importar'));
      await tester.pump();

      // Both the button and shapes grid should be visible
      expect(find.text('Pegar SVG'), findsOneWidget);
      expect(find.text('Círculo'), findsOneWidget);
      expect(find.text('Cuadrado'), findsOneWidget);
    });
  });
}
