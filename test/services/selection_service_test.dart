import 'package:flutter_test/flutter_test.dart';
import 'package:svg_animated_ftl/services/selection_service.dart';
import 'package:svg_animated_ftl/models/workspace.dart';

Workspace _createWs() {
  return Workspace(id: 'test', name: 'Test');
}

void main() {
  group('SelectionService', () {
    late SelectionService service;

    setUp(() {
      service = SelectionService();
    });

    group('toggleElementSelection', () {
      test('adds element when not selected', () {
        final ws = _createWs();
        service.toggleElementSelection(ws, 0);

        expect(ws.selectedGroupElements, contains(0));
        expect(ws.selectedElementIndex, equals(0));
      });

      test('removes element when already selected', () {
        final ws = _createWs();
        ws.selectedGroupElements.add(0);
        ws.selectedElementIndex = 0;

        service.toggleElementSelection(ws, 0);

        expect(ws.selectedGroupElements, isEmpty);
        expect(ws.selectedElementIndex, isNull);
      });

      test('allows multi-selection', () {
        final ws = _createWs();
        service.toggleElementSelection(ws, 0);
        service.toggleElementSelection(ws, 1);
        service.toggleElementSelection(ws, 2);

        expect(ws.selectedGroupElements, equals([0, 1, 2]));
        expect(ws.selectedElementIndex, equals(2));
      });

      test('toggling twice removes element from selection', () {
        final ws = _createWs();
        service.toggleElementSelection(ws, 0);
        service.toggleElementSelection(ws, 1);
        service.toggleElementSelection(ws, 0);

        expect(ws.selectedGroupElements, equals([1]));
        expect(ws.selectedElementIndex, equals(1));
      });
    });

    group('selectElement', () {
      test('selects single element and clears previous', () {
        final ws = _createWs();
        ws.selectedGroupElements.addAll([0, 1]);

        service.selectElement(ws, 2);

        expect(ws.selectedGroupElements, equals([2]));
        expect(ws.selectedElementIndex, equals(2));
      });
    });

    group('clearSelection', () {
      test('clears all selection state', () {
        final ws = _createWs();
        ws.selectedGroupElements.addAll([0, 1]);
        ws.selectedElementIndex = 1;
        ws.selectedGroupId = 'g1';

        service.clearSelection(ws);

        expect(ws.selectedGroupElements, isEmpty);
        expect(ws.selectedElementIndex, isNull);
        expect(ws.selectedGroupId, isNull);
      });
    });

    group('togglePiecesMode', () {
      test('activates pieces mode', () {
        final ws = _createWs();
        expect(ws.isPiecesMode, isFalse);

        service.togglePiecesMode(ws);

        expect(ws.isPiecesMode, isTrue);
      });

      test('deactivates pieces mode and clears state', () {
        final ws = _createWs();
        ws.isPiecesMode = true;
        ws.piecesSelectedIndex = 0;
        ws.selectedGroupElements.add(1);

        service.togglePiecesMode(ws);

        expect(ws.isPiecesMode, isFalse);
        expect(ws.piecesSelectedIndex, equals(-1));
        expect(ws.selectedGroupElements, isEmpty);
      });
    });
  });
}
