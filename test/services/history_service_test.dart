import 'package:flutter_test/flutter_test.dart';
import 'package:svg_animated_ftl/services/history_service.dart';
import 'package:svg_animated_ftl/models/workspace.dart';
import 'package:svg_animated_ftl/models/animation_config.dart';
import 'package:svg_animated_ftl/models/group.dart';

Workspace _createWs() {
  final ws = Workspace(id: 'test', name: 'Test');
  ws.elementAnimations[0] = AnimationConfig(presetId: 'rotate', speed: 1.0);
  return ws;
}

void main() {
  group('HistoryService', () {
    late HistoryService service;

    setUp(() {
      service = HistoryService();
    });

    group('pushHistory', () {
      test('pushes a snapshot of current state', () {
        final ws = _createWs();
        service.pushHistory(ws);

        expect(ws.undoStack.length, equals(1));
        expect(ws.undoIndex, equals(0));
      });

      test('truncates future states when pushing after undo', () {
        final ws = _createWs();
        service.pushHistory(ws); // state 1
        service.pushHistory(ws); // state 2
        ws.undoIndex = 0; // simulate undo

        service.pushHistory(ws); // state 3 — should truncate state 2

        expect(ws.undoStack.length, equals(2));
        expect(ws.undoIndex, equals(1));
      });

      test('enforces max history limit of 50', () {
        final ws = _createWs();
        for (int i = 0; i < 60; i++) {
          ws.elementAnimations[0] = AnimationConfig(presetId: 'anim$i');
          service.pushHistory(ws);
        }
        expect(ws.undoStack.length, equals(50));
      });

      test('captures animations and groups', () {
        final ws = _createWs();
        ws.elementAnimations[1] = AnimationConfig(presetId: 'bounce');
        ws.elementGroups['g1'] = Group(name: 'G1', color: '#6c5ce7', elements: [0, 1]);

        service.pushHistory(ws);

        final snapshot = ws.undoStack.last;
        expect(snapshot.containsKey('animations'), isTrue);
        expect(snapshot.containsKey('groups'), isTrue);
      });
    });

    group('undo', () {
      test('restores previous state', () {
        final ws = _createWs();
        service.pushHistory(ws); // state: rotate
        ws.elementAnimations[0]!.presetId = 'bounce';
        service.pushHistory(ws); // state: bounce

        final result = service.undo(ws);

        expect(result, isTrue);
        expect(ws.elementAnimations[0]!.presetId, equals('rotate'));
        expect(ws.undoIndex, equals(0));
      });

      test('returns false when no history to undo', () {
        final ws = _createWs();
        expect(service.undo(ws), isFalse);
      });

      test('cannot undo past first state', () {
        final ws = _createWs();
        service.pushHistory(ws);
        expect(service.undo(ws), isFalse); // undoIndex is 0, can't go lower
      });
    });

    group('redo', () {
      test('restores undone state', () {
        final ws = _createWs();
        service.pushHistory(ws); // state: rotate
        ws.elementAnimations[0]!.presetId = 'bounce';
        service.pushHistory(ws); // state: bounce
        service.undo(ws); // back to rotate

        final result = service.redo(ws);

        expect(result, isTrue);
        expect(ws.elementAnimations[0]!.presetId, equals('bounce'));
        expect(ws.undoIndex, equals(1));
      });

      test('returns false when no history to redo', () {
        final ws = _createWs();
        expect(service.redo(ws), isFalse);
      });

      test('returns false at latest state', () {
        final ws = _createWs();
        service.pushHistory(ws);
        expect(service.redo(ws), isFalse);
      });
    });

    group('canUndo / canRedo', () {
      test('canUndo returns false when no history', () {
        final ws = _createWs();
        expect(service.canUndo(ws), isFalse);
      });

      test('canUndo returns false at first state', () {
        final ws = _createWs();
        service.pushHistory(ws);
        expect(service.canUndo(ws), isFalse);
      });

      test('canUndo returns true after second push', () {
        final ws = _createWs();
        service.pushHistory(ws);
        ws.elementAnimations[0]!.presetId = 'bounce';
        service.pushHistory(ws);
        expect(service.canUndo(ws), isTrue);
      });

      test('canRedo returns false when no undone states', () {
        final ws = _createWs();
        service.pushHistory(ws);
        expect(service.canRedo(ws), isFalse);
      });

      test('canRedo returns true after undo', () {
        final ws = _createWs();
        service.pushHistory(ws);
        ws.elementAnimations[0]!.presetId = 'bounce';
        service.pushHistory(ws);
        service.undo(ws);
        expect(service.canRedo(ws), isTrue);
      });

      test('canRedo returns false after redo', () {
        final ws = _createWs();
        service.pushHistory(ws);
        ws.elementAnimations[0]!.presetId = 'bounce';
        service.pushHistory(ws);
        service.undo(ws);
        service.redo(ws);
        expect(service.canRedo(ws), isFalse);
      });
    });
  });
}
