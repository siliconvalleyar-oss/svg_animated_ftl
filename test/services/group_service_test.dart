import 'package:flutter_test/flutter_test.dart';
import 'package:svg_animated_ftl/services/group_service.dart';
import 'package:svg_animated_ftl/models/workspace.dart';
import 'package:svg_animated_ftl/models/animation_config.dart';
import 'package:svg_animated_ftl/models/group.dart';

Workspace _createWs() {
  final ws = Workspace(id: 'test', name: 'Test');
  ws.elementAnimations[0] = AnimationConfig(presetId: 'rotate');
  ws.elementAnimations[1] = AnimationConfig(presetId: 'bounce');
  ws.elementAnimations[2] = AnimationConfig(presetId: 'slide');
  return ws;
}

void main() {
  group('GroupService', () {
    late GroupService service;

    setUp(() {
      service = GroupService();
    });

    group('createGroup', () {
      test('creates a group from selected indices', () {
        final ws = _createWs();
        final groupId = service.createGroup(ws, [0, 1], 'Grupo 1');

        expect(groupId, isNotNull);
        expect(groupId, startsWith('g'));
        expect(ws.elementGroups.containsKey(groupId), isTrue);

        final group = ws.elementGroups[groupId]!;
        expect(group.name, equals('Grupo 1'));
        expect(group.elements, equals([0, 1]));
        expect(group.config.presetId, equals('rotate'));
        expect(group.color, equals('#6c5ce7'));
      });

      test('applies template config (from first index) to all group elements', () {
        final ws = _createWs();
        service.createGroup(ws, [0, 1], 'G');

        expect(ws.elementAnimations[0]!.presetId, equals('rotate'));
        expect(ws.elementAnimations[1]!.presetId, equals('rotate'));
      });

      test('creates a group preserving draw preset from first element', () {
        final ws = Workspace(id: 'test', name: 'Test');
        ws.elementAnimations[0] = AnimationConfig(presetId: 'draw');
        ws.elementAnimations[1] = AnimationConfig(presetId: 'bounce');

        final groupId = service.createGroup(ws, [0, 1], 'Draw Group');
        final group = ws.elementGroups[groupId!]!;

        expect(group.config.presetId, equals('draw'));
        expect(ws.elementAnimations[0]!.presetId, equals('draw'));
        expect(ws.elementAnimations[1]!.presetId, equals('draw'));
      });

      test('creates a group from elements with only draw animation', () {
        final ws = Workspace(id: 'test', name: 'Test');
        ws.elementAnimations[2] = AnimationConfig(presetId: 'draw');
        ws.elementAnimations[3] = AnimationConfig(presetId: 'draw', speed: 1.5);

        final groupId = service.createGroup(ws, [2, 3], 'Draw Only');
        final group = ws.elementGroups[groupId!]!;

        expect(group.config.presetId, equals('draw'));
        expect(group.config.speed, equals(4.0)); // uses first element's config (default)
        expect(ws.elementAnimations[2]!.presetId, equals('draw'));
        expect(ws.elementAnimations[3]!.presetId, equals('draw'));
      });

      test('clears selectedGroupElements after creation', () {
        final ws = _createWs();
        ws.selectedGroupElements.addAll([0, 1]);
        service.createGroup(ws, [0, 1], 'G');

        expect(ws.selectedGroupElements, isEmpty);
      });

      test('sets selectedGroupId', () {
        final ws = _createWs();
        final groupId = service.createGroup(ws, [0, 1], 'G');

        expect(ws.selectedGroupId, equals(groupId));
      });

      test('increments nextGroupId', () {
        final ws = _createWs();
        expect(ws.nextGroupId, equals(1));
        service.createGroup(ws, [0, 1], 'G');
        expect(ws.nextGroupId, equals(2));
      });

      test('returns null for less than 2 indices', () {
        final ws = _createWs();
        expect(service.createGroup(ws, [0], 'G'), isNull);
        expect(ws.elementGroups, isEmpty);
      });

      test('cycles through group colors', () {
        final ws = _createWs();
        final id1 = service.createGroup(ws, [0, 1], 'G1');
        final id2 = service.createGroup(ws, [1, 2], 'G2');
        final id3 = service.createGroup(ws, [0, 2], 'G3');

        expect(ws.elementGroups[id1]!.color, equals('#6c5ce7'));
        expect(ws.elementGroups[id2]!.color, equals('#e74c3c'));
        expect(ws.elementGroups[id3]!.color, equals('#2ecc71'));
      });
    });

    group('deleteGroup', () {
      test('removes group from workspace', () {
        final ws = _createWs();
        service.createGroup(ws, [0, 1], 'G');
        final groupId = ws.selectedGroupId!;

        service.deleteGroup(ws, groupId);

        expect(ws.elementGroups.containsKey(groupId), isFalse);
      });

      test('clears selectedGroupId when deleting selected group', () {
        final ws = _createWs();
        service.createGroup(ws, [0, 1], 'G');
        final groupId = ws.selectedGroupId!;

        service.deleteGroup(ws, groupId);

        expect(ws.selectedGroupId, isNull);
      });

      test('does not clear selectedGroupId when deleting other group', () {
        final ws = _createWs();
        service.createGroup(ws, [0, 1], 'G');
        ws.elementGroups['other'] = Group(name: 'Other', color: '#e74c3c', elements: [2]);

        service.deleteGroup(ws, 'other');

        expect(ws.selectedGroupId, isNotNull);
      });
    });

    group('renameGroup', () {
      test('renames existing group', () {
        final ws = _createWs();
        service.createGroup(ws, [0, 1], 'Viejo');
        final groupId = ws.selectedGroupId!;

        service.renameGroup(ws, groupId, 'Nuevo');

        expect(ws.elementGroups[groupId]!.name, equals('Nuevo'));
      });

      test('does nothing for non-existent group', () {
        final ws = _createWs();
        service.renameGroup(ws, 'nonexistent', 'Nuevo');
        // No crash = success
      });
    });
  });
}
