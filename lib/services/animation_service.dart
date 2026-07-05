import 'package:flutter/material.dart';
import '../models/animation_config.dart';
import '../models/workspace.dart';

/// Service responsible for managing animation configurations on elements.
class AnimationService {
  /// Toggles a preset on selected elements.
  /// Returns true if history should be pushed.
  bool togglePreset(Workspace ws, String presetId) {
    try {
      for (final index in ws.selectedGroupElements) {
        final cfg = _getConfigForIndex(ws, index);
        if (cfg.presetId == presetId) {
          if (cfg.extraPresets.isNotEmpty) {
            cfg.presetId = cfg.extraPresets.removeAt(0);
          } else {
            cfg.presetId = null;
          }
        } else if (cfg.extraPresets.contains(presetId)) {
          cfg.extraPresets.remove(presetId);
        } else {
          if (cfg.presetId != null) {
            if (!cfg.extraPresets.contains(cfg.presetId!)) {
              cfg.extraPresets.add(cfg.presetId!);
            }
          }
          cfg.presetId = presetId;
        }
        ws.elementAnimations[index] = cfg;
        _syncGroupIfNeeded(ws, index, cfg);
      }
      return true;
    } catch (e) {
      debugPrint('Error toggling preset: $e');
      return false;
    }
  }

  /// Applies a function to all selected elements.
  /// Returns true if history should be pushed.
  bool applyToSelected(Workspace ws, void Function(AnimationConfig cfg) fn) {
    try {
      for (final idx in ws.selectedGroupElements) {
        final cfg = _getConfigForIndex(ws, idx);
        fn(cfg);
        ws.elementAnimations[idx] = cfg;
      }
      return true;
    } catch (e) {
      debugPrint('Error applying to selected: $e');
      return false;
    }
  }

  AnimationConfig _getConfigForIndex(Workspace ws, int index) {
    return ws.elementAnimations[index] ?? AnimationConfig();
  }

  void _syncGroupIfNeeded(Workspace ws, int index, AnimationConfig config) {
    final groupId = ws.elementGroups.keys.firstWhere(
      (gid) => ws.elementGroups[gid]!.elements.contains(index),
      orElse: () => '',
    );
    if (groupId.isEmpty) return;
    final group = ws.elementGroups[groupId]!;
    group.config = AnimationConfig.fromJson(config.toJson());
    for (final idx in group.elements) {
      ws.elementAnimations[idx] = AnimationConfig.fromJson(config.toJson());
    }
  }

  void syncGroupValue(Workspace ws, int index, String key, dynamic value) {
    final groupId = ws.elementGroups.keys.firstWhere(
      (gid) => ws.elementGroups[gid]!.elements.contains(index),
      orElse: () => '',
    );
    if (groupId.isEmpty) return;
    final group = ws.elementGroups[groupId]!;
    switch (key) {
      case 'speed': group.config.speed = value; break;
      case 'delay': group.config.delay = value; break;
      case 'iter': group.config.iter = value; break;
      case 'dir': group.config.dir = value; break;
      case 'directionAngle': group.config.directionAngle = value; break;
      case 'opacity': group.config.opacity = value; break;
    }
    for (final idx in group.elements) {
      if (ws.elementAnimations.containsKey(idx)) {
        switch (key) {
          case 'speed': ws.elementAnimations[idx]!.speed = value; break;
          case 'delay': ws.elementAnimations[idx]!.delay = value; break;
          case 'iter': ws.elementAnimations[idx]!.iter = value; break;
          case 'dir': ws.elementAnimations[idx]!.dir = value; break;
          case 'directionAngle': ws.elementAnimations[idx]!.directionAngle = value; break;
          case 'opacity': ws.elementAnimations[idx]!.opacity = value; break;
        }
      }
    }
  }

  void resetAnimationState(Workspace ws) {
    ws.elementAnimations = {};
    ws.elementGroups = {};
    ws.selectedElementIndex = null;
    ws.selectedGroupElements.clear();
    ws.selectedGroupId = null;
    ws.isMultiSelectMode = false;
    ws.nextGroupId = 1;
    ws.trajectories = {};
    ws.nextTrajId = 1;
    ws.isTrajectoryMode = false;
    ws.selectedTrajectoryId = null;
    ws.undoStack = [];
    ws.undoIndex = -1;
  }
}
