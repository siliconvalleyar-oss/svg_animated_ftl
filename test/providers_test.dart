import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:svg_animated_ftl/providers/svg_provider.dart';
import 'package:svg_animated_ftl/providers/settings_provider.dart';
import 'package:svg_animated_ftl/providers/theme_provider.dart';
import 'package:svg_animated_ftl/models/workspace.dart';
import 'package:svg_animated_ftl/models/animation_config.dart';
import 'package:svg_animated_ftl/models/trajectory.dart';

void main() {
  group('ThemeProvider', () {
    test('default theme mode is dark', () {
      final provider = ThemeProvider();
      expect(provider.themeMode, equals(ThemeMode.dark));
    });

    test('toggleTheme switches to light', () {
      final provider = ThemeProvider();
      provider.toggleTheme();
      expect(provider.themeMode, equals(ThemeMode.light));
    });

    test('toggleTheme toggles back to dark', () {
      final provider = ThemeProvider();
      provider.toggleTheme(); // -> light
      provider.toggleTheme(); // -> dark
      expect(provider.themeMode, equals(ThemeMode.dark));
    });

    test('toggleTheme notifies listeners', () {
      final provider = ThemeProvider();
      bool notified = false;
      provider.addListener(() => notified = true);
      provider.toggleTheme();
      expect(notified, isTrue);
    });
  });

  group('SettingsProvider', () {
    late SettingsProvider provider;

    setUp(() async {
      Hive.init(Directory.systemTemp.path);
      // Clean up any existing test boxes
      try {
        await Hive.deleteBoxFromDisk('svg_settings');
      } catch (_) {}
      provider = SettingsProvider();
    });

    tearDown(() async {
      provider.dispose();
      try {
        await Hive.deleteBoxFromDisk('svg_settings');
      } catch (_) {}
    });

    test('default export path is /sdcard/Pictures/svg_animated_ftl', () {
      expect(
        provider.exportPath,
        equals('/sdcard/Pictures/svg_animated_ftl'),
      );
    });

    test('init does not crash', () async {
      await provider.init();
      // After init with empty box, should still have default path
      expect(provider.exportPath, isNotEmpty);
    });

    test('setExportPath changes value', () async {
      await provider.setExportPath('/custom/path');
      expect(provider.exportPath, equals('/custom/path'));
    });

    test('setExportPath notifies listeners', () async {
      bool notified = false;
      provider.addListener(() => notified = true);
      await provider.setExportPath('/new/path');
      expect(notified, isTrue);
    });

    test('setExportPath persists to Hive', () async {
      await provider.setExportPath('/persisted/path');

      // Create a new provider to verify persistence
      final provider2 = SettingsProvider();
      await provider2.init();
      expect(provider2.exportPath, equals('/persisted/path'));
      provider2.dispose();
    });
  });

  group('SvgProvider', () {
    late SvgProvider provider;

    setUp(() async {
      Hive.init(Directory.systemTemp.path);
      // Clean up any existing test boxes
      try {
        await Hive.deleteBoxFromDisk('svg_animator');
      } catch (_) {}
      provider = SvgProvider();
    });

    tearDown(() async {
      provider.dispose();
      try {
        await Hive.deleteBoxFromDisk('svg_animator');
      } catch (_) {}
    });

    // ============================================================
    // INITIALIZATION
    // ============================================================

    test('init creates workspace when none exist', () async {
      await provider.init();
      expect(provider.workspaces.length, equals(1));
      expect(provider.workspaces[0].name, equals('Workspace'));
      expect(provider.activeWorkspaceIndex, equals(0));
    });

    test('after init, animation is playing by default', () {
      expect(provider.animationPlaying, isTrue);
    });

    test('currentSvgString is null before SVG loaded', () async {
      await provider.init();
      expect(provider.currentSvgString, isNull);
    });

    test('elementAnimations is empty initially', () async {
      await provider.init();
      expect(provider.elementAnimations, isEmpty);
    });

    // ============================================================
    // WORKSPACE MANAGEMENT
    // ============================================================

    test('addWorkspace adds and switches to new workspace', () async {
      await provider.init();
      provider.addWorkspace();
      expect(provider.workspaces.length, equals(2));
      expect(provider.activeWorkspaceIndex, equals(1));
      expect(provider.activeWorkspace.name, equals('Workspace 2'));
    });

    test('switchWorkspace changes active workspace', () async {
      await provider.init();
      provider.addWorkspace();
      provider.switchWorkspace(0);
      expect(provider.activeWorkspaceIndex, equals(0));
    });

    test('switchWorkspace to same index does nothing', () async {
      await provider.init();
      bool notified = false;
      provider.addListener(() => notified = true);
      provider.switchWorkspace(0);
      expect(notified, isFalse);
    });

    test('switchWorkspace with invalid index does nothing', () async {
      await provider.init();
      provider.switchWorkspace(-1);
      expect(provider.activeWorkspaceIndex, equals(0));
      provider.switchWorkspace(99);
      expect(provider.activeWorkspaceIndex, equals(0));
    });

    test('removeWorkspace removes and adjusts index', () async {
      await provider.init();
      provider.addWorkspace();
      provider.addWorkspace();
      // workspaces: [0, 1, 2], active: 2
      provider.removeWorkspace(0);
      expect(provider.workspaces.length, equals(2));
      // active should now be 1 (last)
      expect(provider.activeWorkspaceIndex, equals(1));
    });

    test('removeWorkspace does nothing when only one workspace', () async {
      await provider.init();
      provider.removeWorkspace(0);
      expect(provider.workspaces.length, equals(1));
    });

    test('removeWorkspace with invalid index does nothing', () async {
      await provider.init();
      provider.removeWorkspace(-1);
      expect(provider.workspaces.length, equals(1));
    });

    test('renameWorkspace changes name', () async {
      await provider.init();
      provider.renameWorkspace('My Project');
      expect(provider.activeWorkspace.name, equals('My Project'));
    });

    test('loadSvgString sets SVG string on active workspace', () async {
      await provider.init();
      await provider.loadSvgString('<svg></svg>');
      expect(provider.currentSvgString, equals('<svg></svg>'));
    });

    test('loadSvgString with createNewWorkspace creates new workspace when SVG already loaded', () async {
      await provider.init();
      await provider.loadSvgString('<svg>first</svg>');
      await provider.loadSvgString('<svg>second</svg>');
      expect(provider.workspaces.length, equals(2));
      expect(provider.activeWorkspaceIndex, equals(1));
      expect(provider.currentSvgString, equals('<svg>second</svg>'));
    });

    test('loadSvgString without createNewWorkspace replaces in place', () async {
      await provider.init();
      await provider.loadSvgString('<svg>first</svg>');
      await provider.loadSvgString('<svg>replaced</svg>', createNewWorkspace: false);
      expect(provider.workspaces.length, equals(1));
      expect(provider.currentSvgString, equals('<svg>replaced</svg>'));
    });

    // ============================================================
    // ELEMENT SELECTION
    // ============================================================

    test('toggleElementSelection adds element to selection', () async {
      await provider.init();
      provider.toggleElementSelection(0);
      expect(provider.activeWorkspace.selectedGroupElements, contains(0));
    });

    test('toggleElementSelection removes element from selection', () async {
      await provider.init();
      provider.toggleElementSelection(0);
      provider.toggleElementSelection(0);
      expect(provider.activeWorkspace.selectedGroupElements, isEmpty);
    });

    test('selectElement selects single element', () async {
      await provider.init();
      provider.selectElement(3);
      expect(provider.activeWorkspace.selectedGroupElements, equals([3]));
      expect(provider.activeWorkspace.selectedElementIndex, equals(3));
    });

    test('selectElement replaces previous selection', () async {
      await provider.init();
      provider.selectElement(0);
      provider.selectElement(1);
      expect(provider.activeWorkspace.selectedGroupElements, equals([1]));
    });

    test('clearSelection removes all selected elements', () async {
      await provider.init();
      provider.addWorkspace();
      provider.selectElement(0);
      provider.clearSelection();
      expect(provider.activeWorkspace.selectedGroupElements, isEmpty);
      expect(provider.activeWorkspace.selectedElementIndex, isNull);
    });

    // ============================================================
    // ANIMATION CONTROLS
    // ============================================================

    test('togglePreset applies preset to selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.togglePreset('bounce');
      expect(provider.elementAnimations[0]?.presetId, equals('bounce'));
    });

    test('updateAnimationSpeed changes speed on selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.updateAnimationSpeed(2.5);
      expect(provider.elementAnimations[0]?.speed, equals(2.5));
    });

    test('updateAnimationDelay changes delay on selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.updateAnimationDelay(1.5);
      expect(provider.elementAnimations[0]?.delay, equals(1.5));
    });

    test('updateAnimationIteration changes iter on selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.updateAnimationIteration('3');
      expect(provider.elementAnimations[0]?.iter, equals('3'));
    });

    test('updateAnimationDirection changes dir on selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.updateAnimationDirection('alternate');
      expect(provider.elementAnimations[0]?.dir, equals('alternate'));
    });

    test('updateDirectionAngle changes angle on selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.updateDirectionAngle(90.0);
      expect(provider.elementAnimations[0]?.directionAngle, equals(90.0));
    });

    test('updateOpacity changes opacity on selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.updateOpacity(0.5);
      expect(provider.elementAnimations[0]?.opacity, equals(0.5));
    });

    test('updateInitialVelocity changes velocity on selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.updateInitialVelocity(200.0);
      expect(provider.elementAnimations[0]?.initialVelocity, equals(200.0));
    });

    test('updateLaunchAngle changes angle on selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.updateLaunchAngle(30.0);
      expect(provider.elementAnimations[0]?.launchAngle, equals(30.0));
    });

    test('updateGravity changes gravity on selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.updateGravity(15.0);
      expect(provider.elementAnimations[0]?.gravity, equals(15.0));
    });

    test('updateOvalRx changes ovalRx on selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.updateOvalRx(100.0);
      expect(provider.elementAnimations[0]?.ovalRx, equals(100.0));
    });

    test('updateOvalRy changes ovalRy on selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.updateOvalRy(50.0);
      expect(provider.elementAnimations[0]?.ovalRy, equals(50.0));
    });

    test('updateArcRx changes arcRx on selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.updateArcRx(120.0);
      expect(provider.elementAnimations[0]?.arcRx, equals(120.0));
    });

    test('updateArcRy changes arcRy on selected element', () async {
      await provider.init();
      provider.selectElement(0);
      provider.updateArcRy(90.0);
      expect(provider.elementAnimations[0]?.arcRy, equals(90.0));
    });

    // ============================================================
    // GROUPS
    // ============================================================

    test('createGroup creates group with given indices', () async {
      await provider.init();
      provider.selectElement(0);
      provider.selectElement(1);
      provider.createGroup([0, 1], 'Test Group');
      expect(provider.activeWorkspace.elementGroups.length, equals(1));
      final group = provider.activeWorkspace.elementGroups.values.first;
      expect(group.name, equals('Test Group'));
      expect(group.elements, equals([0, 1]));
    });

    test('deleteGroup removes group', () async {
      await provider.init();
      provider.selectElement(0);
      provider.selectElement(1);
      provider.createGroup([0, 1], 'To Delete');
      final groupId = provider.activeWorkspace.elementGroups.keys.first;
      provider.deleteGroup(groupId);
      expect(provider.activeWorkspace.elementGroups, isEmpty);
    });

    test('renameGroup changes group name', () async {
      await provider.init();
      provider.selectElement(0);
      provider.selectElement(1);
      provider.createGroup([0, 1], 'Old Name');
      final groupId = provider.activeWorkspace.elementGroups.keys.first;
      provider.renameGroup(groupId, 'New Name');
      expect(provider.activeWorkspace.elementGroups[groupId]!.name, equals('New Name'));
    });

    // ============================================================
    // PIECES MODE
    // ============================================================

    test('togglePiecesMode toggles pieces mode', () async {
      await provider.init();
      expect(provider.activeWorkspace.isPiecesMode, isFalse);
      provider.togglePiecesMode();
      expect(provider.activeWorkspace.isPiecesMode, isTrue);
      provider.togglePiecesMode();
      expect(provider.activeWorkspace.isPiecesMode, isFalse);
    });

    // ============================================================
    // TRAJECTORIES
    // ============================================================

    test('addTrajectory adds trajectory', () async {
      await provider.init();
      provider.addTrajectory('My Trajectory');
      expect(provider.activeWorkspace.trajectories.length, equals(1));
      expect(provider.activeWorkspace.trajectories.values.first.name, equals('My Trajectory'));
    });

    test('deleteTrajectory removes trajectory', () async {
      await provider.init();
      provider.addTrajectory('Test Traj');
      final trajId = provider.activeWorkspace.trajectories.keys.first;
      provider.deleteTrajectory(trajId);
      expect(provider.activeWorkspace.trajectories, isEmpty);
      expect(provider.activeWorkspace.isTrajectoryMode, isFalse);
    });

    // ============================================================
    // UNDO / REDO
    // ============================================================

    test('canUndo is false initially', () async {
      await provider.init();
      expect(provider.canUndo, isFalse);
    });

    test('canRedo is false initially', () async {
      await provider.init();
      expect(provider.canRedo, isFalse);
    });

    test('undo restores state before last change', () async {
      await provider.init();
      provider.selectElement(0);
      // pushHistory saves the CURRENT state BEFORE each change
      provider.updateAnimationSpeed(3.0);  // push {} (empty), set speed=3.0. undoIndex=0
      provider.updateAnimationDelay(1.0);  // push {0: {speed:3.0,…}}, set delay=1.0. undoIndex=1

      expect(provider.elementAnimations[0]?.speed, equals(3.0));
      expect(provider.elementAnimations[0]?.delay, equals(1.0));

      // Undo → restore history[0]: {} → elementAnimations empty
      provider.undo();
      expect(provider.elementAnimations[0], isNull);
    });

    test('redo after undo restores state', () async {
      await provider.init();
      provider.selectElement(0);
      // pushHistory saves state BEFORE each change
      provider.updateAnimationSpeed(1.0);  // push {}, set speed=1.0. undoIndex=0
      // Now elementAnimations = {0: {speed:1.0,…}}
      provider.updateAnimationSpeed(3.0);  // push {0: {speed:1.0,…}}, set speed=3.0. undoIndex=1

      expect(provider.elementAnimations[0]?.speed, equals(3.0));

      // Undo → restore history[0]: {} (empty)
      provider.undo();
      expect(provider.elementAnimations[0], isNull);

      // Redo → restore history[1]: {0: {speed:1.0,…}}
      provider.redo();
      expect(provider.elementAnimations[0]?.speed, equals(1.0));
    });

    // ============================================================
    // PLAYBACK & ZOOM
    // ============================================================

    test('togglePlayPause toggles playing state', () async {
      await provider.init();
      expect(provider.animationPlaying, isTrue);
      provider.togglePlayPause();
      expect(provider.animationPlaying, isFalse);
      provider.togglePlayPause();
      expect(provider.animationPlaying, isTrue);
    });

    test('setZoom changes zoom level', () async {
      await provider.init();
      provider.setZoom(2.0);
      expect(provider.activeWorkspace.zoomLevel, equals(2.0));
    });

    test('setZoom clamps to min zoom', () async {
      await provider.init();
      provider.setZoom(0.0);
      expect(provider.activeWorkspace.zoomLevel, equals(0.2));
    });

    test('setZoom clamps to max zoom', () async {
      await provider.init();
      provider.setZoom(10.0);
      expect(provider.activeWorkspace.zoomLevel, equals(5.0));
    });

    // ============================================================
    // LISTENER NOTIFICATIONS
    // ============================================================

    test('addWorkspace notifies listeners', () async {
      await provider.init();
      bool notified = false;
      provider.addListener(() => notified = true);
      provider.addWorkspace();
      expect(notified, isTrue);
    });

    test('switchWorkspace notifies listeners', () async {
      await provider.init();
      provider.addWorkspace();
      bool notified = false;
      provider.addListener(() => notified = true);
      provider.switchWorkspace(0);
      expect(notified, isTrue);
    });

    test('loadSvgString notifies listeners', () async {
      await provider.init();
      bool notified = false;
      provider.addListener(() => notified = true);
      await provider.loadSvgString('<svg/>');
      expect(notified, isTrue);
    });

    test('togglePlayPause notifies listeners', () async {
      await provider.init();
      bool notified = false;
      provider.addListener(() => notified = true);
      provider.togglePlayPause();
      expect(notified, isTrue);
    });

    // ============================================================
    // PERSISTENCE (Hive round-trip)
    // ============================================================

    test('workspaces persist across provider instances', () async {
      await provider.init();
      provider.renameWorkspace('Persisted Name');

      // Create new provider - should load saved workspaces
      final provider2 = SvgProvider();
      await provider2.init();
      expect(provider2.workspaces.length, equals(1));
      expect(provider2.activeWorkspace.name, equals('Persisted Name'));
      provider2.dispose();
    });

    test('multiple workspaces persist', () async {
      await provider.init();
      provider.addWorkspace();
      provider.renameWorkspace('WS 2');
      provider.switchWorkspace(0);
      provider.renameWorkspace('WS 1');

      final provider2 = SvgProvider();
      await provider2.init();
      expect(provider2.workspaces.length, equals(2));
      expect(provider2.workspaces[0].name, equals('WS 1'));
      expect(provider2.workspaces[1].name, equals('WS 2'));
      provider2.dispose();
    });
  });
}
