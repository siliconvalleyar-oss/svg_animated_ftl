import 'package:flutter_test/flutter_test.dart';
import 'package:svg_animated_ftl/services/animation_service.dart';
import 'package:svg_animated_ftl/models/workspace.dart';
import 'package:svg_animated_ftl/models/animation_config.dart';
import 'package:svg_animated_ftl/models/group.dart';
import 'package:svg_animated_ftl/models/trajectory.dart';

Workspace _createWs({List<int> selected = const [0]}) {
  final ws = Workspace(id: 'test', name: 'Test');
  ws.elementAnimations[0] = AnimationConfig();
  ws.elementAnimations[1] = AnimationConfig();
  ws.selectedGroupElements.addAll(selected);
  return ws;
}

void main() {
  group('AnimationService', () {
    late AnimationService service;

    setUp(() {
      service = AnimationService();
    });

    group('togglePreset', () {
      test('sets presetId on selected element', () {
        final ws = _createWs(selected: [0]);
        service.togglePreset(ws, 'rotate');
        expect(ws.elementAnimations[0]!.presetId, equals('rotate'));
      });

      test('removes presetId if same preset toggled again (no extras)', () {
        final ws = _createWs(selected: [0]);
        ws.elementAnimations[0]!.presetId = 'rotate';
        service.togglePreset(ws, 'rotate');
        expect(ws.elementAnimations[0]!.presetId, isNull);
      });

      test('cycles to extraPreset when same preset toggled with extras', () {
        final ws = _createWs(selected: [0]);
        ws.elementAnimations[0]!.presetId = 'bounce';
        ws.elementAnimations[0]!.extraPresets = ['slide', 'fade'];
        service.togglePreset(ws, 'bounce');
        expect(ws.elementAnimations[0]!.presetId, equals('slide'));
        expect(ws.elementAnimations[0]!.extraPresets, equals(['fade']));
      });

      test('moves old preset to extraPresets when switching to new one', () {
        final ws = _createWs(selected: [0]);
        ws.elementAnimations[0]!.presetId = 'bounce';
        service.togglePreset(ws, 'slide');
        expect(ws.elementAnimations[0]!.presetId, equals('slide'));
        expect(ws.elementAnimations[0]!.extraPresets, contains('bounce'));
      });

      test('removes preset from extras if it already exists there', () {
        final ws = _createWs(selected: [0]);
        ws.elementAnimations[0]!.presetId = 'bounce';
        ws.elementAnimations[0]!.extraPresets = ['slide'];
        service.togglePreset(ws, 'slide');
        expect(ws.elementAnimations[0]!.presetId, equals('bounce'));
        expect(ws.elementAnimations[0]!.extraPresets, isEmpty);
      });

      test('applies to multiple selected elements', () {
        final ws = _createWs(selected: [0, 1]);
        service.togglePreset(ws, 'rotate');
        expect(ws.elementAnimations[0]!.presetId, equals('rotate'));
        expect(ws.elementAnimations[1]!.presetId, equals('rotate'));
      });

      test('synces group config when element belongs to a group', () {
        final ws = _createWs(selected: [0]);
        final group = Group(name: 'G1', color: '#6c5ce7', elements: [0, 1]);
        ws.elementGroups['g1'] = group;
        service.togglePreset(ws, 'rotate');
        expect(group.config.presetId, equals('rotate'));
        expect(ws.elementAnimations[1]!.presetId, equals('rotate'));
      });

      test('togglePreset with draw preset on grouped element syncs to all members', () {
        final ws = _createWs(selected: [0]);
        final group = Group(name: 'G1', color: '#6c5ce7', elements: [0, 1]);
        ws.elementGroups['g1'] = group;
        service.togglePreset(ws, 'draw');
        expect(group.config.presetId, equals('draw'));
        expect(ws.elementAnimations[0]!.presetId, equals('draw'));
        expect(ws.elementAnimations[1]!.presetId, equals('draw'));
      });

      test('togglePreset with draw preset on multiple selected elements works', () {
        final ws = _createWs(selected: [0, 1]);
        service.togglePreset(ws, 'draw');
        expect(ws.elementAnimations[0]!.presetId, equals('draw'));
        expect(ws.elementAnimations[1]!.presetId, equals('draw'));
      });

      test('togglePreset toggling draw off then re-applying works', () {
        final ws = _createWs(selected: [0]);
        service.togglePreset(ws, 'draw');
        expect(ws.elementAnimations[0]!.presetId, equals('draw'));

        service.togglePreset(ws, 'draw');
        expect(ws.elementAnimations[0]!.presetId, isNull);

        service.togglePreset(ws, 'draw');
        expect(ws.elementAnimations[0]!.presetId, equals('draw'));
      });

      test('returns true on success', () {
        final ws = _createWs(selected: [0]);
        expect(service.togglePreset(ws, 'rotate'), isTrue);
      });

      test('handles empty selection gracefully', () {
        final ws = _createWs(selected: []);
        expect(service.togglePreset(ws, 'rotate'), isTrue);
        expect(ws.elementAnimations[0]!.presetId, isNull);
      });
    });

    group('applyToSelected', () {
      test('applies function to all selected elements', () {
        final ws = _createWs(selected: [0, 1]);
        service.applyToSelected(ws, (cfg) => cfg.speed = 2.5);
        expect(ws.elementAnimations[0]!.speed, equals(2.5));
        expect(ws.elementAnimations[1]!.speed, equals(2.5));
      });

      test('creates config for unconfigured elements', () {
        final ws = Workspace(id: 'test', name: 'Test');
        ws.selectedGroupElements.add(0);
        service.applyToSelected(ws, (cfg) => cfg.speed = 3.0);
        expect(ws.elementAnimations[0]!.speed, equals(3.0));
      });

      test('returns true on success', () {
        final ws = _createWs(selected: [0]);
        expect(service.applyToSelected(ws, (cfg) {}), isTrue);
      });

      test('handles empty selection', () {
        final ws = _createWs(selected: []);
        expect(service.applyToSelected(ws, (cfg) {}), isTrue);
      });
    });

    group('syncGroupValue', () {
      test('syncs value to group config and all group elements', () {
        final ws = _createWs(selected: [0]);
        ws.elementAnimations[0] = AnimationConfig();
        ws.elementAnimations[1] = AnimationConfig();
        ws.elementGroups['g1'] = Group(name: 'G1', color: '#6c5ce7', elements: [0, 1]);
        service.syncGroupValue(ws, 0, 'speed', 5.0);
        expect(ws.elementGroups['g1']!.config.speed, equals(5.0));
        expect(ws.elementAnimations[0]!.speed, equals(5.0));
        expect(ws.elementAnimations[1]!.speed, equals(5.0));
      });

      test('does nothing if element not in a group', () {
        final ws = _createWs(selected: [0]);
        ws.elementAnimations[0]!.speed = 1.0;
        service.syncGroupValue(ws, 0, 'speed', 5.0);
        expect(ws.elementAnimations[0]!.speed, equals(1.0));
      });

      test('handles all supported keys', () {
        final ws = _createWs(selected: [0]);
        ws.elementGroups['g1'] = Group(name: 'G1', color: '#6c5ce7', elements: [0]);
        service.syncGroupValue(ws, 0, 'speed', 2.0);
        service.syncGroupValue(ws, 0, 'delay', 1.5);
        service.syncGroupValue(ws, 0, 'iter', '3');
        service.syncGroupValue(ws, 0, 'dir', 'reverse');
        service.syncGroupValue(ws, 0, 'directionAngle', 90.0);
        service.syncGroupValue(ws, 0, 'opacity', 0.5);
        final group = ws.elementGroups['g1']!;
        expect(group.config.speed, equals(2.0));
        expect(group.config.delay, equals(1.5));
        expect(group.config.iter, equals('3'));
        expect(group.config.dir, equals('reverse'));
        expect(group.config.directionAngle, equals(90.0));
        expect(group.config.opacity, equals(0.5));
      });
    });

    group('resetAnimationState', () {
      test('resets all animation-related state', () {
        final ws = _createWs(selected: [0]);
        ws.elementAnimations[0]!.presetId = 'rotate';
        ws.elementGroups['g1'] = Group(name: 'G1', color: '#6c5ce7', elements: [0]);
        ws.selectedElementIndex = 0;
        ws.isMultiSelectMode = true;
        ws.nextGroupId = 5;
        ws.trajectories['t1'] = Trajectory(name: 'T1', points: [TrajectoryPoint(x: 0, y: 0)]);
        ws.nextTrajId = 3;
        ws.isTrajectoryMode = true;
        ws.selectedTrajectoryId = 't1';
        ws.undoStack.add({'a': 1});
        ws.undoIndex = 0;

        service.resetAnimationState(ws);

        expect(ws.elementAnimations, isEmpty);
        expect(ws.elementGroups, isEmpty);
        expect(ws.selectedElementIndex, isNull);
        expect(ws.selectedGroupElements, isEmpty);
        expect(ws.selectedGroupId, isNull);
        expect(ws.isMultiSelectMode, isFalse);
        expect(ws.nextGroupId, equals(1));
        expect(ws.trajectories, isEmpty);
        expect(ws.nextTrajId, equals(1));
        expect(ws.isTrajectoryMode, isFalse);
        expect(ws.selectedTrajectoryId, isNull);
        expect(ws.undoStack, isEmpty);
        expect(ws.undoIndex, equals(-1));
      });
    });
  });
}
