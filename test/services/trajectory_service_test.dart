import 'package:flutter_test/flutter_test.dart';
import 'package:svg_animated_ftl/services/trajectory_service.dart';
import 'package:svg_animated_ftl/models/workspace.dart';
import 'package:svg_animated_ftl/models/animation_config.dart';
import 'package:svg_animated_ftl/models/trajectory.dart';

Workspace _createWs() {
  return Workspace(id: 'test', name: 'Test');
}

void main() {
  group('TrajectoryService', () {
    late TrajectoryService service;

    setUp(() {
      service = TrajectoryService();
    });

    group('addTrajectory', () {
      test('adds a trajectory with default points', () {
        final ws = _createWs();
        final id = service.addTrajectory(ws, 'Mi Trayectoria');

        expect(id, startsWith('traj_'));
        expect(ws.trajectories.containsKey(id), isTrue);

        final traj = ws.trajectories[id]!;
        expect(traj.name, equals('Mi Trayectoria'));
        expect(traj.points.length, equals(5));
        expect(traj.points[0].x, equals(30));
        expect(traj.points[0].y, equals(100));
        expect(traj.points[2].x, equals(100));
        expect(traj.points[2].y, equals(40));
      });

      test('sets selectedTrajectoryId and activates trajectory mode', () {
        final ws = _createWs();
        final id = service.addTrajectory(ws, 'T1');

        expect(ws.selectedTrajectoryId, equals(id));
        expect(ws.isTrajectoryMode, isTrue);
      });

      test('increments nextTrajId', () {
        final ws = _createWs();
        expect(ws.nextTrajId, equals(1));
        service.addTrajectory(ws, 'T1');
        expect(ws.nextTrajId, equals(2));
        service.addTrajectory(ws, 'T2');
        expect(ws.nextTrajId, equals(3));
      });

      test('each trajectory gets a unique ID', () {
        final ws = _createWs();
        final id1 = service.addTrajectory(ws, 'T1');
        final id2 = service.addTrajectory(ws, 'T2');
        expect(id1, isNot(equals(id2)));
      });
    });

    group('deleteTrajectory', () {
      test('removes trajectory from workspace', () {
        final ws = _createWs();
        final id = service.addTrajectory(ws, 'T1');
        service.deleteTrajectory(ws, id);
        expect(ws.trajectories.containsKey(id), isFalse);
      });

      test('clears selected state when deleting selected trajectory', () {
        final ws = _createWs();
        final id = service.addTrajectory(ws, 'T1');
        service.deleteTrajectory(ws, id);
        expect(ws.selectedTrajectoryId, isNull);
        expect(ws.isTrajectoryMode, isFalse);
      });

      test('does not affect selected state when deleting other trajectory', () {
        final ws = _createWs();
        final id1 = service.addTrajectory(ws, 'T1');
        service.addTrajectory(ws, 'T2');
        service.deleteTrajectory(ws, id1);
        expect(ws.selectedTrajectoryId, isNot(id1));
        expect(ws.isTrajectoryMode, isTrue);
      });

      test('cleans up element references to deleted trajectory', () {
        final ws = _createWs();
        final id = service.addTrajectory(ws, 'T1');
        ws.elementAnimations[0] = AnimationConfig(trajectoryId: id);
        ws.elementAnimations[1] = AnimationConfig(trajectoryId: 'other');

        service.deleteTrajectory(ws, id);

        expect(ws.elementAnimations[0]!.trajectoryId, isNull);
        expect(ws.elementAnimations[1]!.trajectoryId, equals('other'));
      });
    });
  });
}
