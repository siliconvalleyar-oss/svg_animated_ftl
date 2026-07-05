import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:svg_animated_ftl/providers/svg_provider.dart';
import 'package:svg_animated_ftl/providers/theme_provider.dart';
import 'package:svg_animated_ftl/providers/settings_provider.dart';
import 'package:svg_animated_ftl/screens/home_screen.dart';
import 'package:svg_animated_ftl/widgets/empty_state.dart';
import 'package:svg_animated_ftl/widgets/bottom_nav.dart';
import 'package:svg_animated_ftl/widgets/svg_preview.dart';
import 'package:svg_animated_ftl/widgets/animation_scope.dart';
import 'package:svg_animated_ftl/widgets/zoom_controls.dart';
import 'package:svg_animated_ftl/widgets/pieces_overlay.dart';
import 'package:svg_animated_ftl/widgets/trajectory_overlay.dart';

import 'package:svg_animated_ftl/core/theme.dart';
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
  bool get canUndo => _canUndo;
  bool _canUndo = false;

  @override
  bool get canRedo => _canRedo;
  bool _canRedo = false;

  void setCanUndo(bool value) {
    _canUndo = value;
    notifyListeners();
  }

  void setCanRedo(bool value) {
    _canRedo = value;
    notifyListeners();
  }

  void setSvgString(String? svg) {
    _workspace.originalSvgString = svg;
    notifyListeners();
  }

  void setPiecesMode(bool value) {
    _workspace.isPiecesMode = value;
    notifyListeners();
  }

  void setTrajectoryMode(bool value) {
    _workspace.isTrajectoryMode = value;
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

  // No-op implementations
  @override
  void addWorkspace() {}
  @override
  void switchWorkspace(int index) {}
  @override
  void removeWorkspace(int index) {}
  @override
  void renameWorkspace(String name) {}
  @override
  Future<void> loadSvgString(String svgString, {bool createNewWorkspace = true}) async {}
  @override
  void toggleElementSelection(int index) {}
  @override
  void selectElement(int index) {}
  @override
  void clearSelection() {
    clearSelectedElements();
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
  void createGroup(List<int> indices, String name) {}
  @override
  void deleteGroup(String groupId) {}
  @override
  void renameGroup(String groupId, String newName) {}
  @override
  void togglePiecesMode() {
    _workspace.isPiecesMode = !_workspace.isPiecesMode;
    notifyListeners();
  }
  @override
  String addTrajectory(String name) => '';
  @override
  void deleteTrajectory(String id) {}
  @override
  void undo() {}
  @override
  void redo() {}
  @override
  void togglePlayPause() {
    animationPlaying = !animationPlaying;
    notifyListeners();
  }
  @override
  void setZoom(double level) {
    _workspace.zoomLevel = level;
    notifyListeners();
  }
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
  group('HomeScreen', () {
    testWidgets('renders scaffold with bottom nav tabs', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      expect(find.text('Importar'), findsOneWidget);
      expect(find.text('Animar'), findsOneWidget);
      expect(find.text('Controles'), findsOneWidget);
      expect(find.text('Piezas'), findsOneWidget);
      expect(find.text('Exportar'), findsOneWidget);
    });

    testWidgets('shows workspace name in appbar', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      expect(find.text('Test Workspace'), findsOneWidget);
    });

    testWidgets('has undo and redo icons', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.undo), findsOneWidget);
      expect(find.byIcon(Icons.redo), findsOneWidget);
    });

    testWidgets('tapping Import tab opens import panel', (tester) async {
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

    testWidgets('tapping Piezas tab opens pieces panel', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      await tester.tap(find.text('Piezas'));
      await tester.pump();

      expect(find.text('Activar piezas'), findsOneWidget);
    });

    testWidgets('Export tab shows export button', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      await tester.tap(find.text('Exportar'));
      await tester.pump();

      expect(find.text('Exportar SVG'), findsOneWidget);
    });

    testWidgets('tapping same tab twice closes panel', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      await tester.tap(find.text('Importar'));
      await tester.pump();
      expect(find.text('Pegar SVG'), findsOneWidget);

      await tester.tap(find.text('Importar'));
      await tester.pump();
      expect(find.text('Pegar SVG'), findsNothing);
    });

    testWidgets('pieces mode toggle switches text', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      await tester.tap(find.text('Piezas'));
      await tester.pump();
      expect(find.text('Activar piezas'), findsOneWidget);

      // Tap the button to toggle pieces mode
      await tester.tap(find.text('Activar piezas'));
      await tester.pump();
      expect(find.text('Desactivar piezas'), findsOneWidget);
    });

    testWidgets('shows empty state when no SVG loaded', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      expect(find.text('Sin SVG cargado'), findsOneWidget);
    });

    testWidgets('Controles tab shows selection message', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      await tester.tap(find.text('Controles'));
      await tester.pump();

      expect(find.text('Selecciona piezas para editar'), findsOneWidget);
    });

    testWidgets('Animar tab shows animation options', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: HomeScreen(),
        provider: provider,
      ));
      await tester.pump();

      await tester.tap(find.text('Animar'));
      await tester.pump();

      // Animation grid shows preset names
      expect(find.text('Rotar'), findsWidgets);
    });
  });

  group('BottomNav', () {
    testWidgets('renders all 5 tabs', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: Scaffold(
          body: BottomNav(
            selectedIndex: 0,
            onTabChanged: (_) {},
          ),
        ),
        provider: provider,
      ));

      expect(find.text('Importar'), findsOneWidget);
      expect(find.text('Animar'), findsOneWidget);
      expect(find.text('Controles'), findsOneWidget);
      expect(find.text('Piezas'), findsOneWidget);
      expect(find.text('Exportar'), findsOneWidget);
    });

    testWidgets('calls onTabChanged when tapped', (tester) async {
      final provider = MockSvgProvider();
      int tappedIndex = -1;
      await tester.pumpWidget(createTestApp(
        home: Scaffold(
          body: BottomNav(
            selectedIndex: 0,
            onTabChanged: (index) => tappedIndex = index,
          ),
        ),
        provider: provider,
      ));

      await tester.tap(find.text('Animar'));
      await tester.pump();
      expect(tappedIndex, equals(1));
    });
  });

  group('EmptyState', () {
    testWidgets('shows correct texts and icon', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: EmptyState(),
        provider: provider,
      ));

      expect(find.text('Sin SVG cargado'), findsOneWidget);
      expect(find.text('Importa un SVG o selecciona una forma'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });
  });

  group('SvgPreview', () {
    // Helper to wrap SvgPreview with AnimationScope
    Widget wrapPreview(Widget preview) => AnimationScope(child: preview);

    testWidgets('shows empty state when no SVG loaded', (tester) async {
      final provider = MockSvgProvider();
      await tester.pumpWidget(createTestApp(
        home: wrapPreview(SvgPreview()),
        provider: provider,
      ));
      await tester.pump();

      expect(find.text('Sin SVG cargado'), findsOneWidget);
    });

    testWidgets('shows zoom controls when SVG loaded', (tester) async {
      final provider = MockSvgProvider();
      provider.animationPlaying = false;
      provider.setSvgString('<svg viewBox="0 0 100 100"><circle cx="50" cy="50" r="40"/></svg>');

      await tester.pumpWidget(createTestApp(
        home: wrapPreview(SvgPreview()),
        provider: provider,
      ));
      await tester.pump();

      expect(find.text('Sin SVG cargado'), findsNothing);
      expect(find.byType(ZoomControls), findsOneWidget);
    });

    testWidgets('zoom in button exists and is tappable', (tester) async {
      final provider = MockSvgProvider();
      provider.animationPlaying = false;
      provider.setSvgString('<svg viewBox="0 0 100 100"><circle cx="50" cy="50" r="40"/></svg>');

      await tester.pumpWidget(createTestApp(
        home: wrapPreview(SvgPreview()),
        provider: provider,
      ));
      await tester.pump();

      // ZoomControls creates ZoomControls() without a TransformationController
      // in production, so the buttons exist but don't change provider.zoomLevel
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.center_focus_strong), findsOneWidget);

      // Verify buttons are tappable without error
      await tester.tap(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.tap(find.byIcon(Icons.center_focus_strong));
    });

    testWidgets('ZoomControls with TransformationController changes matrix', (tester) async {
      final controller = TransformationController();

      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              ZoomControls(controller: controller),
            ],
          ),
        ),
      );

      final initialMatrix = controller.value.clone();

      // Tap zoom in
      await tester.tap(find.byIcon(Icons.add));
      expect(controller.value.storage, isNot(equals(initialMatrix.storage)));

      final zoomedMatrix = controller.value.clone();

      // Tap zoom out
      await tester.tap(find.byIcon(Icons.remove));
      expect(controller.value.storage, isNot(equals(zoomedMatrix.storage)));

      // Tap reset
      await tester.tap(find.byIcon(Icons.center_focus_strong));
      expect(controller.value.storage, equals(Matrix4.identity().storage));
    });

    testWidgets('shows PiecesOverlay when pieces mode on', (tester) async {
      final provider = MockSvgProvider();
      provider.animationPlaying = false;
      provider.setSvgString('<svg viewBox="0 0 100 100"><circle cx="50" cy="50" r="40"/></svg>');
      provider.setPiecesMode(true);

      await tester.pumpWidget(createTestApp(
        home: wrapPreview(SvgPreview()),
        provider: provider,
      ));
      await tester.pump();

      expect(find.byType(PiecesOverlay), findsOneWidget);
    });

    testWidgets('shows selection count badge when elements selected', (tester) async {
      final provider = MockSvgProvider();
      provider.animationPlaying = false;
      provider.setSvgString('<svg viewBox="0 0 100 100"><circle cx="50" cy="50" r="40"/></svg>');
      provider.addSelectedElement(0);
      provider.addSelectedElement(1);

      await tester.pumpWidget(createTestApp(
        home: wrapPreview(SvgPreview()),
        provider: provider,
      ));
      await tester.pump();

      // SvgPreview shows "{count} sel." format (e.g. "2 sel.")
      expect(find.text('2 sel.'), findsOneWidget);
    });

    testWidgets('shows TrajectoryOverlay in trajectory mode', (tester) async {
      final provider = MockSvgProvider();
      provider.animationPlaying = false;
      provider.setSvgString('<svg viewBox="0 0 100 100"><circle cx="50" cy="50" r="40"/></svg>');
      provider.setTrajectoryMode(true);

      await tester.pumpWidget(createTestApp(
        home: wrapPreview(SvgPreview()),
        provider: provider,
      ));
      await tester.pump();

      expect(find.byType(TrajectoryOverlay), findsOneWidget);
    });

    testWidgets('shows error message for invalid SVG', (tester) async {
      final provider = MockSvgProvider();
      provider.animationPlaying = false;
      provider.setSvgString('not valid svg');

      await tester.pumpWidget(createTestApp(
        home: wrapPreview(SvgPreview()),
        provider: provider,
      ));
      await tester.pump();

      // Should show error text
      expect(find.textContaining('Error'), findsWidgets);
    });
  });
}
