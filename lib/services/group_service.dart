import 'package:flutter/material.dart';
import '../models/animation_config.dart';
import '../models/workspace.dart';
import '../models/group.dart';

/// Service responsible for managing element groups.
class GroupService {
  /// Creates a new group from the given element indices.
  /// Returns the new group ID, or null on failure.
  String? createGroup(Workspace ws, List<int> indices, String name) {
    try {
      if (indices.length < 2) return null;
      final color = _getNextGroupColor(ws.nextGroupId);
      final groupId = 'g${ws.nextGroupId++}';
      final templateConfig = ws.elementAnimations[indices.first] ?? AnimationConfig();
      final group = Group(
        name: name,
        color: color,
        elements: List.from(indices),
        config: AnimationConfig.fromJson(templateConfig.toJson()),
      );
      ws.elementGroups[groupId] = group;
      for (final idx in indices) {
        ws.elementAnimations[idx] = AnimationConfig.fromJson(templateConfig.toJson());
      }
      ws.selectedGroupElements.clear();
      ws.selectedGroupId = groupId;
      return groupId;
    } catch (e) {
      debugPrint('Error creating group: $e');
      return null;
    }
  }

  /// Deletes a group by ID.
  void deleteGroup(Workspace ws, String groupId) {
    try {
      ws.elementGroups.remove(groupId);
      if (ws.selectedGroupId == groupId) {
        ws.selectedGroupId = null;
      }
    } catch (e) {
      debugPrint('Error deleting group: $e');
    }
  }

  /// Renames a group.
  void renameGroup(Workspace ws, String groupId, String newName) {
    try {
      final group = ws.elementGroups[groupId];
      if (group != null) {
        group.name = newName;
      }
    } catch (e) {
      debugPrint('Error renaming group: $e');
    }
  }

  String _getNextGroupColor(int groupId) {
    const colors = ['#6c5ce7', '#e74c3c', '#2ecc71', '#f39c12', '#1abc9c', '#9b59b6', '#3498db', '#e67e22'];
    return colors[(groupId - 1) % colors.length];
  }
}
