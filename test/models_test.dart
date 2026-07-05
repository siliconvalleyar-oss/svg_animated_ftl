import 'package:flutter_test/flutter_test.dart';
import 'package:svg_animated_ftl/models/animation_config.dart';
import 'package:svg_animated_ftl/models/workspace.dart';
import 'package:svg_animated_ftl/models/group.dart';
import 'package:svg_animated_ftl/models/background_image.dart';
import 'package:svg_animated_ftl/models/trajectory.dart';

void main() {
  group('AnimationConfig', () {
    test('constructor uses defaults', () {
      final config = AnimationConfig();

      expect(config.presetId, isNull);
      expect(config.speed, equals(4.0));
      expect(config.delay, equals(0.0));
      expect(config.iter, equals('infinite'));
      expect(config.dir, equals('normal'));
      expect(config.ovalRx, equals(80.0));
      expect(config.ovalRy, equals(40.0));
      expect(config.ovalAngle, equals(0.0));
      expect(config.arcRx, equals(80.0));
      expect(config.arcRy, equals(80.0));
      expect(config.directionAngle, equals(0.0));
      expect(config.pivotX, isNull);
      expect(config.pivotY, isNull);
      expect(config.extraPresets, isEmpty);
      expect(config.trajectoryId, isNull);
      expect(config.opacity, equals(1.0));
      expect(config.initialVelocity, equals(100.0));
      expect(config.launchAngle, equals(45.0));
      expect(config.gravity, equals(9.8));
    });

    test('constructor with custom values', () {
      final config = AnimationConfig(
        presetId: 'bounce',
        speed: 2.0,
        delay: 0.5,
        iter: '3',
        dir: 'alternate',
        ovalRx: 60.0,
        ovalRy: 30.0,
        ovalAngle: 45.0,
        arcRx: 100.0,
        arcRy: 50.0,
        directionAngle: 90.0,
        pivotX: 10.0,
        pivotY: 20.0,
        extraPresets: ['fade', 'shake'],
        trajectoryId: 'traj1',
        opacity: 0.5,
        initialVelocity: 200.0,
        launchAngle: 30.0,
        gravity: 15.0,
      );

      expect(config.presetId, equals('bounce'));
      expect(config.speed, equals(2.0));
      expect(config.delay, equals(0.5));
      expect(config.iter, equals('3'));
      expect(config.dir, equals('alternate'));
      expect(config.ovalRx, equals(60.0));
      expect(config.ovalRy, equals(30.0));
      expect(config.ovalAngle, equals(45.0));
      expect(config.arcRx, equals(100.0));
      expect(config.arcRy, equals(50.0));
      expect(config.directionAngle, equals(90.0));
      expect(config.pivotX, equals(10.0));
      expect(config.pivotY, equals(20.0));
      expect(config.extraPresets, equals(['fade', 'shake']));
      expect(config.trajectoryId, equals('traj1'));
      expect(config.opacity, equals(0.5));
      expect(config.initialVelocity, equals(200.0));
      expect(config.launchAngle, equals(30.0));
      expect(config.gravity, equals(15.0));
    });

    test('toJson returns correct map', () {
      final config = AnimationConfig(
        presetId: 'slide',
        speed: 1.5,
        delay: 0.3,
        extraPresets: ['fade'],
      );

      final json = config.toJson();

      expect(json['presetId'], equals('slide'));
      expect(json['speed'], equals(1.5));
      expect(json['delay'], equals(0.3));
      expect(json['extraPresets'], equals(['fade']));
      expect(json['iter'], equals('infinite'));
      expect(json['dir'], equals('normal'));
    });

    test('fromJson creates correct object', () {
      final json = {
        'presetId': 'rotate',
        'speed': 2.0,
        'delay': 1.0,
        'iter': 'infinite',
        'dir': 'reverse',
        'ovalRx': 100.0,
        'ovalRy': 50.0,
        'ovalAngle': 10.0,
        'arcRx': 120.0,
        'arcRy': 90.0,
        'directionAngle': 45.0,
        'pivotX': 5.0,
        'pivotY': 15.0,
        'extraPresets': ['glow'],
        'trajectoryId': 't1',
        'opacity': 0.8,
        'initialVelocity': 150.0,
        'launchAngle': 60.0,
        'gravity': 5.0,
      };

      final config = AnimationConfig.fromJson(json);

      expect(config.presetId, equals('rotate'));
      expect(config.speed, equals(2.0));
      expect(config.delay, equals(1.0));
      expect(config.iter, equals('infinite'));
      expect(config.dir, equals('reverse'));
      expect(config.ovalRx, equals(100.0));
      expect(config.ovalRy, equals(50.0));
      expect(config.ovalAngle, equals(10.0));
      expect(config.arcRx, equals(120.0));
      expect(config.arcRy, equals(90.0));
      expect(config.directionAngle, equals(45.0));
      expect(config.pivotX, equals(5.0));
      expect(config.pivotY, equals(15.0));
      expect(config.extraPresets, equals(['glow']));
      expect(config.trajectoryId, equals('t1'));
      expect(config.opacity, equals(0.8));
      expect(config.initialVelocity, equals(150.0));
      expect(config.launchAngle, equals(60.0));
      expect(config.gravity, equals(5.0));
    });

    test('fromJson with null values uses defaults', () {
      final config = AnimationConfig.fromJson({});

      expect(config.presetId, isNull);
      expect(config.speed, equals(4.0));
      expect(config.delay, equals(0.0));
      expect(config.iter, equals('infinite'));
      expect(config.dir, equals('normal'));
      expect(config.ovalRx, equals(80.0));
      expect(config.ovalRy, equals(40.0));
      expect(config.arcRx, equals(80.0));
      expect(config.arcRy, equals(80.0));
      expect(config.opacity, equals(1.0));
      expect(config.extraPresets, isEmpty);
    });

    test('toJson/fromJson round-trip preserves data', () {
      final original = AnimationConfig(
        presetId: 'projectile',
        speed: 3.0,
        delay: 0.5,
        iter: '1',
        dir: 'alternate',
        opacity: 0.3,
        initialVelocity: 250.0,
        launchAngle: 75.0,
        gravity: 12.0,
        extraPresets: ['fade', 'rotate'],
      );

      final json = original.toJson();
      final restored = AnimationConfig.fromJson(json);

      expect(restored.presetId, equals(original.presetId));
      expect(restored.speed, equals(original.speed));
      expect(restored.delay, equals(original.delay));
      expect(restored.iter, equals(original.iter));
      expect(restored.dir, equals(original.dir));
      expect(restored.opacity, equals(original.opacity));
      expect(restored.initialVelocity, equals(original.initialVelocity));
      expect(restored.launchAngle, equals(original.launchAngle));
      expect(restored.gravity, equals(original.gravity));
      expect(restored.extraPresets, equals(original.extraPresets));
    });

    test('copyWith changes only specified fields', () {
      final original = AnimationConfig(presetId: 'bounce', speed: 1.0);
      final copy = original.copyWith(presetId: 'slide', speed: 2.0);

      expect(copy.presetId, equals('slide'));
      expect(copy.speed, equals(2.0));
      expect(copy.delay, equals(original.delay));
      expect(copy.iter, equals(original.iter));
      expect(copy.dir, equals(original.dir));
    });

    test('copyWith with null fields keeps original values', () {
      final original = AnimationConfig(presetId: 'bounce', speed: 2.0);
      final copy = original.copyWith(presetId: null, speed: null);

      expect(copy.presetId, equals('bounce'));
      expect(copy.speed, equals(2.0));
    });

    test('copyWith extraPresets is a mutable copy', () {
      final original = AnimationConfig(extraPresets: ['fade']);
      final copy = original.copyWith(extraPresets: ['glow']);

      expect(copy.extraPresets, equals(['glow']));
      expect(original.extraPresets, equals(['fade']));
    });

    test('extraPresets defaults to empty list', () {
      final config = AnimationConfig();
      expect(config.extraPresets, isA<List<String>>());
      expect(config.extraPresets, isEmpty);
    });
  });

  group('Workspace', () {
    test('constructor with required fields only', () {
      final ws = Workspace(id: 'ws1', name: 'Test');

      expect(ws.id, equals('ws1'));
      expect(ws.name, equals('Test'));
      expect(ws.originalSvgString, isNull);
      expect(ws.elementAnimations, isEmpty);
      expect(ws.elementGroups, isEmpty);
      expect(ws.selectedElementIndex, isNull);
      expect(ws.selectedGroupElements, isEmpty);
      expect(ws.isMultiSelectMode, isFalse);
      expect(ws.selectedGroupId, isNull);
      expect(ws.nextGroupId, equals(1));
      expect(ws.trajectories, isEmpty);
      expect(ws.nextTrajId, equals(1));
      expect(ws.isTrajectoryMode, isFalse);
      expect(ws.selectedTrajectoryId, isNull);
      expect(ws.backgroundImages, isEmpty);
      expect(ws.zoomLevel, equals(1.0));
      expect(ws.isPiecesMode, isFalse);
      expect(ws.piecesSelectedIndex, equals(-1));
      expect(ws.boundaryActive, isFalse);
      expect(ws.undoStack, isEmpty);
      expect(ws.undoIndex, equals(-1));
    });

    test('constructor with all fields', () {
      final ws = Workspace(
        id: 'ws2',
        name: 'My Workspace',
        originalSvgString: '<svg></svg>',
        elementAnimations: {0: AnimationConfig(presetId: 'rotate')},
        elementGroups: {'g1': Group(name: 'Grupo', color: '#ff0000')},
        selectedElementIndex: 2,
        selectedGroupElements: [0, 1],
        isMultiSelectMode: true,
        selectedGroupId: 'g1',
        nextGroupId: 5,
        trajectories: {'t1': Trajectory(name: 'Trayectoria')},
        nextTrajId: 3,
        isTrajectoryMode: true,
        selectedTrajectoryId: 't1',
        backgroundImages: [BackgroundImage(id: 'img1', name: 'bg', path: '/tmp/bg.png')],
        zoomLevel: 2.5,
        isPiecesMode: true,
        piecesSelectedIndex: 3,
        boundaryActive: true,
        undoStack: [{'action': 'delete'}],
        undoIndex: 0,
      );

      expect(ws.id, equals('ws2'));
      expect(ws.name, equals('My Workspace'));
      expect(ws.originalSvgString, equals('<svg></svg>'));
      expect(ws.elementAnimations.length, equals(1));
      expect(ws.elementAnimations[0]!.presetId, equals('rotate'));
      expect(ws.elementGroups.length, equals(1));
      expect(ws.elementGroups['g1']!.name, equals('Grupo'));
      expect(ws.selectedElementIndex, equals(2));
      expect(ws.selectedGroupElements, equals([0, 1]));
      expect(ws.isMultiSelectMode, isTrue);
      expect(ws.selectedGroupId, equals('g1'));
      expect(ws.nextGroupId, equals(5));
      expect(ws.trajectories.length, equals(1));
      expect(ws.trajectories['t1']!.name, equals('Trayectoria'));
      expect(ws.nextTrajId, equals(3));
      expect(ws.isTrajectoryMode, isTrue);
      expect(ws.selectedTrajectoryId, equals('t1'));
      expect(ws.backgroundImages.length, equals(1));
      expect(ws.zoomLevel, equals(2.5));
      expect(ws.isPiecesMode, isTrue);
      expect(ws.piecesSelectedIndex, equals(3));
      expect(ws.boundaryActive, isTrue);
      expect(ws.undoStack, equals([{'action': 'delete'}]));
      expect(ws.undoIndex, equals(0));
    });

    test('toJson serializes all fields', () {
      final ws = Workspace(
        id: 'test-id',
        name: 'Test WS',
        originalSvgString: '<svg/>',
        elementAnimations: {0: AnimationConfig(presetId: 'fade')},
        selectedGroupElements: [1, 2],
        zoomLevel: 1.5,
      );

      final json = ws.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['name'], equals('Test WS'));
      expect(json['originalSvgString'], equals('<svg/>'));
      expect(json['zoomLevel'], equals(1.5));
      expect(json['selectedGroupElements'], equals([1, 2]));
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'ws1',
        'name': 'From JSON',
        'originalSvgString': '<rect/>',
        'elementAnimations': {
          '0': {
            'presetId': 'bounce',
            'speed': 2.0,
            'delay': 0.0,
            'iter': 'infinite',
            'dir': 'normal',
            'ovalRx': 80.0,
            'ovalRy': 40.0,
            'ovalAngle': 0.0,
            'arcRx': 80.0,
            'arcRy': 80.0,
            'directionAngle': 0.0,
            'extraPresets': [],
            'opacity': 1.0,
            'initialVelocity': 100.0,
            'launchAngle': 45.0,
            'gravity': 9.8,
          }
        },
        'elementGroups': {},
        'selectedGroupElements': [0],
        'isMultiSelectMode': false,
        'nextGroupId': 3,
        'trajectories': {},
        'nextTrajId': 1,
        'isTrajectoryMode': false,
        'backgroundImages': [],
        'zoomLevel': 2.0,
        'isPiecesMode': true,
        'piecesSelectedIndex': 0,
        'boundaryActive': false,
        'undoStack': [],
        'undoIndex': -1,
      };

      final ws = Workspace.fromJson(json);

      expect(ws.id, equals('ws1'));
      expect(ws.name, equals('From JSON'));
      expect(ws.originalSvgString, equals('<rect/>'));
      expect(ws.elementAnimations[0]!.presetId, equals('bounce'));
      expect(ws.elementAnimations[0]!.speed, equals(2.0));
      expect(ws.selectedGroupElements, equals([0]));
      expect(ws.nextGroupId, equals(3));
      expect(ws.zoomLevel, equals(2.0));
      expect(ws.isPiecesMode, isTrue);
      expect(ws.piecesSelectedIndex, equals(0));
    });

    test('fromJson with missing fields uses defaults', () {
      final json = {'id': 'ws1', 'name': 'Minimal'};
      final ws = Workspace.fromJson(json);

      expect(ws.id, equals('ws1'));
      expect(ws.name, equals('Minimal'));
      expect(ws.elementAnimations, isEmpty);
      expect(ws.elementGroups, isEmpty);
      expect(ws.selectedGroupElements, isEmpty);
      expect(ws.isMultiSelectMode, isFalse);
      expect(ws.nextGroupId, equals(1));
      expect(ws.trajectories, isEmpty);
      expect(ws.nextTrajId, equals(1));
      expect(ws.isTrajectoryMode, isFalse);
      expect(ws.backgroundImages, isEmpty);
      expect(ws.zoomLevel, equals(1.0));
      expect(ws.isPiecesMode, isFalse);
      expect(ws.piecesSelectedIndex, equals(-1));
      expect(ws.undoStack, isEmpty);
      expect(ws.undoIndex, equals(-1));
    });

    test('toJson/fromJson round-trip preserves all data', () {
      final original = Workspace(
        id: 'rt1',
        name: 'Round Trip',
        originalSvgString: '<svg><circle/></svg>',
        elementAnimations: {0: AnimationConfig(presetId: 'pulse'), 1: AnimationConfig(presetId: 'fade')},
        elementGroups: {'g1': Group(name: 'G1', color: '#ff0', elements: [0, 1])},
        selectedElementIndex: 1,
        selectedGroupElements: [0, 1, 2],
        isMultiSelectMode: true,
        selectedGroupId: 'g1',
        nextGroupId: 10,
        trajectories: {'t1': Trajectory(name: 'T1', points: [TrajectoryPoint(x: 10, y: 20)])},
        nextTrajId: 5,
        isTrajectoryMode: true,
        selectedTrajectoryId: 't1',
        backgroundImages: [BackgroundImage(id: 'img1', name: 'bg', path: '/tmp/bg.png', x: 100, y: 200)],
        zoomLevel: 3.0,
        isPiecesMode: true,
        piecesSelectedIndex: 2,
        boundaryActive: true,
        undoStack: [{'action': 'move'}, {'action': 'delete'}],
        undoIndex: 1,
      );

      final json = original.toJson();
      final restored = Workspace.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.originalSvgString, equals(original.originalSvgString));
      expect(restored.elementAnimations.length, equals(2));
      expect(restored.elementAnimations[0]!.presetId, equals('pulse'));
      expect(restored.elementAnimations[1]!.presetId, equals('fade'));
      expect(restored.elementGroups.length, equals(1));
      expect(restored.elementGroups['g1']!.name, equals('G1'));
      expect(restored.elementGroups['g1']!.elements, equals([0, 1]));
      expect(restored.selectedElementIndex, equals(1));
      expect(restored.selectedGroupElements, equals([0, 1, 2]));
      expect(restored.isMultiSelectMode, isTrue);
      expect(restored.selectedGroupId, equals('g1'));
      expect(restored.nextGroupId, equals(10));
      expect(restored.trajectories.length, equals(1));
      expect(restored.trajectories['t1']!.name, equals('T1'));
      expect(restored.trajectories['t1']!.points.length, equals(1));
      expect(restored.trajectories['t1']!.points[0].x, equals(10));
      expect(restored.trajectories['t1']!.points[0].y, equals(20));
      expect(restored.nextTrajId, equals(5));
      expect(restored.isTrajectoryMode, isTrue);
      expect(restored.selectedTrajectoryId, equals('t1'));
      expect(restored.backgroundImages.length, equals(1));
      expect(restored.backgroundImages[0].id, equals('img1'));
      expect(restored.backgroundImages[0].x, equals(100));
      expect(restored.backgroundImages[0].y, equals(200));
      expect(restored.zoomLevel, equals(3.0));
      expect(restored.isPiecesMode, isTrue);
      expect(restored.piecesSelectedIndex, equals(2));
      expect(restored.boundaryActive, isTrue);
      expect(restored.undoStack, equals([{'action': 'move'}, {'action': 'delete'}]));
      expect(restored.undoIndex, equals(1));
    });

    test('elementAnimations keys are serialized as strings in toJson', () {
      final ws = Workspace(
        id: 'ws',
        name: 'WS',
        elementAnimations: {0: AnimationConfig(), 10: AnimationConfig()},
      );

      final json = ws.toJson();
      final anims = json['elementAnimations'] as Map<String, dynamic>;

      expect(anims.containsKey('0'), isTrue);
      expect(anims.containsKey('10'), isTrue);
      expect(anims.containsKey(0), isFalse); // key is String, not int
    });
  });

  group('Group', () {
    test('constructor with required fields only', () {
      final group = Group(name: 'Test', color: '#ff0000');

      expect(group.name, equals('Test'));
      expect(group.color, equals('#ff0000'));
      expect(group.elements, isEmpty);
      expect(group.config, isA<AnimationConfig>());
      expect(group.config.speed, equals(4.0));
    });

    test('constructor with all fields', () {
      final group = Group(
        name: 'Wheels',
        color: '#6c5ce7',
        elements: [0, 1, 2],
        config: AnimationConfig(presetId: 'rotate', speed: 2.0),
      );

      expect(group.name, equals('Wheels'));
      expect(group.color, equals('#6c5ce7'));
      expect(group.elements, equals([0, 1, 2]));
      expect(group.config.presetId, equals('rotate'));
      expect(group.config.speed, equals(2.0));
    });

    test('toJson serializes correctly', () {
      final group = Group(
        name: 'Alas',
        color: '#e74c3c',
        elements: [3, 4],
        config: AnimationConfig(presetId: 'slide', speed: 1.5),
      );

      final json = group.toJson();

      expect(json['name'], equals('Alas'));
      expect(json['color'], equals('#e74c3c'));
      expect(json['elements'], equals([3, 4]));
      expect(json['config']['presetId'], equals('slide'));
      expect(json['config']['speed'], equals(1.5));
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'name': 'Motor',
        'color': '#f39c12',
        'elements': [0, 1, 2, 3],
        'config': {
          'presetId': 'pulse',
          'speed': 1.0,
          'delay': 0.0,
          'iter': 'infinite',
          'dir': 'normal',
          'ovalRx': 80.0,
          'ovalRy': 40.0,
          'ovalAngle': 0.0,
          'arcRx': 80.0,
          'arcRy': 80.0,
          'directionAngle': 0.0,
          'extraPresets': [],
          'opacity': 1.0,
          'initialVelocity': 100.0,
          'launchAngle': 45.0,
          'gravity': 9.8,
        },
      };

      final group = Group.fromJson(json);

      expect(group.name, equals('Motor'));
      expect(group.color, equals('#f39c12'));
      expect(group.elements, equals([0, 1, 2, 3]));
      expect(group.config.presetId, equals('pulse'));
      expect(group.config.speed, equals(1.0));
    });

    test('fromJson with missing fields uses defaults', () {
      final group = Group.fromJson({'name': 'Empty', 'color': '#000'});

      expect(group.name, equals('Empty'));
      expect(group.color, equals('#000'));
      expect(group.elements, isEmpty);
      expect(group.config, isA<AnimationConfig>());
    });

    test('toJson/fromJson round-trip preserves data', () {
      final original = Group(
        name: 'Ruedas Delanteras',
        color: '#2ecc71',
        elements: [0, 1],
        config: AnimationConfig(presetId: 'wheel', speed: 3.0),
      );

      final json = original.toJson();
      final restored = Group.fromJson(json);

      expect(restored.name, equals(original.name));
      expect(restored.color, equals(original.color));
      expect(restored.elements, equals(original.elements));
      expect(restored.config.presetId, equals(original.config.presetId));
      expect(restored.config.speed, equals(original.config.speed));
    });
  });

  group('BackgroundImage', () {
    test('constructor with required fields only', () {
      final img = BackgroundImage(id: 'img1', name: 'test', path: '/tmp/test.png');

      expect(img.id, equals('img1'));
      expect(img.name, equals('test'));
      expect(img.path, equals('/tmp/test.png'));
      expect(img.x, equals(50.0));
      expect(img.y, equals(50.0));
      expect(img.width, equals(400.0));
      expect(img.height, equals(300.0));
      expect(img.opacity, equals(0.8));
      expect(img.hidden, isFalse);
      expect(img.zIndex, equals(0));
    });

    test('constructor with all fields', () {
      final img = BackgroundImage(
        id: 'img2',
        name: 'background',
        path: '/sdcard/bg.png',
        x: 100,
        y: 200,
        width: 800,
        height: 600,
        opacity: 1.0,
        hidden: true,
        zIndex: 5,
      );

      expect(img.id, equals('img2'));
      expect(img.name, equals('background'));
      expect(img.path, equals('/sdcard/bg.png'));
      expect(img.x, equals(100.0));
      expect(img.y, equals(200.0));
      expect(img.width, equals(800.0));
      expect(img.height, equals(600.0));
      expect(img.opacity, equals(1.0));
      expect(img.hidden, isTrue);
      expect(img.zIndex, equals(5));
    });

    test('toJson serializes correctly', () {
      final img = BackgroundImage(id: 'i1', name: 'n', path: '/p', x: 10, y: 20, opacity: 0.5, hidden: true);

      final json = img.toJson();

      expect(json['id'], equals('i1'));
      expect(json['name'], equals('n'));
      expect(json['path'], equals('/p'));
      expect(json['x'], equals(10.0));
      expect(json['y'], equals(20.0));
      expect(json['width'], equals(400.0));
      expect(json['height'], equals(300.0));
      expect(json['opacity'], equals(0.5));
      expect(json['hidden'], isTrue);
      expect(json['zIndex'], equals(0));
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'bg1',
        'name': 'wallpaper',
        'path': '/images/wall.png',
        'x': 200,
        'y': 100,
        'width': 1024,
        'height': 768,
        'opacity': 0.3,
        'hidden': true,
        'zIndex': 10,
      };

      final img = BackgroundImage.fromJson(json);

      expect(img.id, equals('bg1'));
      expect(img.name, equals('wallpaper'));
      expect(img.path, equals('/images/wall.png'));
      expect(img.x, equals(200.0));
      expect(img.y, equals(100.0));
      expect(img.width, equals(1024.0));
      expect(img.height, equals(768.0));
      expect(img.opacity, equals(0.3));
      expect(img.hidden, isTrue);
      expect(img.zIndex, equals(10));
    });

    test('fromJson with missing fields uses defaults', () {
      final img = BackgroundImage.fromJson({'id': 'i1', 'name': 'n', 'path': '/p'});

      expect(img.x, equals(50.0));
      expect(img.y, equals(50.0));
      expect(img.width, equals(400.0));
      expect(img.height, equals(300.0));
      expect(img.opacity, equals(0.8));
      expect(img.hidden, isFalse);
      expect(img.zIndex, equals(0));
    });

    test('toJson/fromJson round-trip preserves data', () {
      final original = BackgroundImage(
        id: 'rt1',
        name: 'sky',
        path: '/images/sky.png',
        x: 0,
        y: 0,
        width: 1920,
        height: 1080,
        opacity: 1.0,
        hidden: false,
        zIndex: 1,
      );

      final json = original.toJson();
      final restored = BackgroundImage.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.path, equals(original.path));
      expect(restored.x, equals(original.x));
      expect(restored.y, equals(original.y));
      expect(restored.width, equals(original.width));
      expect(restored.height, equals(original.height));
      expect(restored.opacity, equals(original.opacity));
      expect(restored.hidden, equals(original.hidden));
      expect(restored.zIndex, equals(original.zIndex));
    });
  });

  group('Trajectory', () {
    test('constructor with required fields only', () {
      final traj = Trajectory(name: 'Mi Trayectoria');

      expect(traj.name, equals('Mi Trayectoria'));
      expect(traj.points, isEmpty);
    });

    test('constructor with points', () {
      final traj = Trajectory(
        name: 'Curva',
        points: [
          TrajectoryPoint(x: 0, y: 0),
          TrajectoryPoint(x: 100, y: 50),
          TrajectoryPoint(x: 200, y: 0),
        ],
      );

      expect(traj.name, equals('Curva'));
      expect(traj.points.length, equals(3));
      expect(traj.points[0].x, equals(0));
      expect(traj.points[0].y, equals(0));
      expect(traj.points[1].x, equals(100));
      expect(traj.points[1].y, equals(50));
      expect(traj.points[2].x, equals(200));
      expect(traj.points[2].y, equals(0));
    });

    test('toJson serializes correctly', () {
      final traj = Trajectory(
        name: 'Line',
        points: [TrajectoryPoint(x: 10, y: 20)],
      );

      final json = traj.toJson();

      expect(json['name'], equals('Line'));
      expect(json['points'], isA<List>());
      expect((json['points'] as List).length, equals(1));
      expect(json['points'][0]['x'], equals(10));
      expect(json['points'][0]['y'], equals(20));
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'name': 'Parabola',
        'points': [
          {'x': 0, 'y': 100},
          {'x': 50, 'y': 50},
          {'x': 100, 'y': 100},
        ],
      };

      final traj = Trajectory.fromJson(json);

      expect(traj.name, equals('Parabola'));
      expect(traj.points.length, equals(3));
      expect(traj.points[1].x, equals(50));
      expect(traj.points[1].y, equals(50));
    });

    test('fromJson with missing points defaults to empty', () {
      final traj = Trajectory.fromJson({'name': 'Empty'});

      expect(traj.name, equals('Empty'));
      expect(traj.points, isEmpty);
    });

    test('toJson/fromJson round-trip preserves data', () {
      final original = Trajectory(
        name: 'Complex',
        points: [
          TrajectoryPoint(x: 10.5, y: 20.3),
          TrajectoryPoint(x: 30.7, y: 40.9),
        ],
      );

      final json = original.toJson();
      final restored = Trajectory.fromJson(json);

      expect(restored.name, equals(original.name));
      expect(restored.points.length, equals(2));
      expect(restored.points[0].x, equals(10.5));
      expect(restored.points[0].y, equals(20.3));
      expect(restored.points[1].x, equals(30.7));
      expect(restored.points[1].y, equals(40.9));
    });
  });

  group('TrajectoryPoint', () {
    test('constructor stores values', () {
      final pt = TrajectoryPoint(x: 100, y: 200);

      expect(pt.x, equals(100));
      expect(pt.y, equals(200));
    });

    test('toJson serializes correctly', () {
      final pt = TrajectoryPoint(x: 50.5, y: 75.3);

      final json = pt.toJson();

      expect(json['x'], equals(50.5));
      expect(json['y'], equals(75.3));
    });

    test('fromJson deserializes correctly', () {
      final pt = TrajectoryPoint.fromJson({'x': 150, 'y': 250});

      expect(pt.x, equals(150));
      expect(pt.y, equals(250));
    });

    test('fromJson with missing fields defaults to 0', () {
      final pt = TrajectoryPoint.fromJson({});

      expect(pt.x, equals(0));
      expect(pt.y, equals(0));
    });

    test('toJson/fromJson round-trip', () {
      final original = TrajectoryPoint(x: 99.9, y: 88.8);
      final restored = TrajectoryPoint.fromJson(original.toJson());

      expect(restored.x, equals(original.x));
      expect(restored.y, equals(original.y));
    });
  });
}
