import 'package:flutter/material.dart';
import '../models/workspace.dart';
import '../models/trajectory.dart';

/// Service responsible for managing animation trajectories.
class TrajectoryService {
  /// Adds a new trajectory with default points.
  /// Returns the new trajectory ID, or empty string on failure.
  String addTrajectory(Workspace ws, String name) {
    try {
      final id = 'traj_${ws.nextTrajId++}';
      final trajectory = Trajectory(
        name: name,
        points: [
          TrajectoryPoint(x: 30, y: 100),
          TrajectoryPoint(x: 55, y: 60),
          TrajectoryPoint(x: 100, y: 40),
          TrajectoryPoint(x: 145, y: 60),
          TrajectoryPoint(x: 170, y: 100),
        ],
      );
      ws.trajectories[id] = trajectory;
      ws.selectedTrajectoryId = id;
      ws.isTrajectoryMode = true;
      return id;
    } catch (e) {
      debugPrint('Error adding trajectory: $e');
      return '';
    }
  }

  /// Deletes a trajectory by ID and cleans up element references.
  void deleteTrajectory(Workspace ws, String id) {
    try {
      ws.trajectories.remove(id);
      if (ws.selectedTrajectoryId == id) {
        ws.selectedTrajectoryId = null;
        ws.isTrajectoryMode = false;
      }
      for (final entry in ws.elementAnimations.entries) {
        if (entry.value.trajectoryId == id) {
          entry.value.trajectoryId = null;
        }
      }
    } catch (e) {
      debugPrint('Error deleting trajectory: $e');
    }
  }
}
