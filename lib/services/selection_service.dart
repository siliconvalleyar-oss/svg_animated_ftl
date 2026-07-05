import 'package:flutter/material.dart';
import '../models/workspace.dart';

/// Service responsible for element selection and pieces mode management.
class SelectionService {
  /// Toggles an element in/out of the selection.
  void toggleElementSelection(Workspace ws, int index) {
    try {
      if (ws.selectedGroupElements.contains(index)) {
        ws.selectedGroupElements.remove(index);
      } else {
        ws.selectedGroupElements.add(index);
      }
      ws.selectedElementIndex =
          ws.selectedGroupElements.isNotEmpty
              ? ws.selectedGroupElements.last
              : null;
    } catch (e) {
      debugPrint('Error toggling selection: $e');
    }
  }

  /// Selects a single element, clearing previous selection.
  void selectElement(Workspace ws, int index) {
    ws.selectedGroupElements.clear();
    ws.selectedGroupElements.add(index);
    ws.selectedElementIndex = index;
  }

  /// Clears all selections.
  void clearSelection(Workspace ws) {
    ws.selectedGroupElements.clear();
    ws.selectedElementIndex = null;
    ws.selectedGroupId = null;
  }

  /// Toggles pieces mode on/off.
  void togglePiecesMode(Workspace ws) {
    ws.isPiecesMode = !ws.isPiecesMode;
    if (!ws.isPiecesMode) {
      ws.piecesSelectedIndex = -1;
      ws.selectedGroupElements.clear();
    }
  }
}
