import 'package:flutter/material.dart';
import '../models/workspace.dart';
import '../models/animation_config.dart';
import '../models/group.dart';

/// Service responsible for undo/redo history management.
class HistoryService {
  static const int _maxHistory = 50;

  /// Pushes the current state onto the undo stack.
  void pushHistory(Workspace ws) {
    try {
      if (ws.undoIndex < ws.undoStack.length - 1) {
        ws.undoStack = ws.undoStack.sublist(0, ws.undoIndex + 1);
      }
      ws.undoStack.add({
        'animations': ws.elementAnimations.map((k, v) => MapEntry(k.toString(), v.toJson())),
        'groups': ws.elementGroups.map((k, v) => MapEntry(k, v.toJson())),
      });
      if (ws.undoStack.length > _maxHistory) {
        ws.undoStack.removeAt(0);
      }
      ws.undoIndex = ws.undoStack.length - 1;
    } catch (e) {
      debugPrint('Error pushing history: $e');
    }
  }

  /// Undoes the last action.
  bool undo(Workspace ws) {
    try {
      if (ws.undoIndex <= 0) return false;
      ws.undoIndex--;
      _restoreHistory(ws, ws.undoStack[ws.undoIndex]);
      return true;
    } catch (e) {
      debugPrint('Error undoing: $e');
      return false;
    }
  }

  /// Redoes the last undone action.
  bool redo(Workspace ws) {
    try {
      if (ws.undoIndex >= ws.undoStack.length - 1) return false;
      ws.undoIndex++;
      _restoreHistory(ws, ws.undoStack[ws.undoIndex]);
      return true;
    } catch (e) {
      debugPrint('Error redoing: $e');
      return false;
    }
  }

  bool canUndo(Workspace ws) => ws.undoIndex > 0;
  bool canRedo(Workspace ws) => ws.undoIndex < ws.undoStack.length - 1;

  void _restoreHistory(Workspace ws, Map<String, dynamic> state) {
    try {
      ws.elementAnimations = (state['animations'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(int.parse(k), AnimationConfig.fromJson(v))) ?? {};
      ws.elementGroups = (state['groups'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, Group.fromJson(v))) ?? {};
    } catch (e) {
      debugPrint('Error restoring history: $e');
    }
  }
}
