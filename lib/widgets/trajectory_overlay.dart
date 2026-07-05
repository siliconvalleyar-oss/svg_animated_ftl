import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trajectory.dart';
import '../providers/svg_provider.dart';
import '../core/constants.dart';

class TrajectoryOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        final trajectories = provider.activeWorkspace.trajectories;

        return CustomPaint(
          painter: TrajectoryPainter(trajectories),
          size: Size.infinite,
        );
      },
    );
  }
}

class TrajectoryPainter extends CustomPainter {
  final Map<String, Trajectory> trajectories;

  TrajectoryPainter(this.trajectories);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    trajectories.forEach((key, trajectory) {
      if (trajectory.points.length < 2) return;

      final path = Path();
      path.moveTo(trajectory.points[0].x, trajectory.points[0].y);

      for (int i = 1; i < trajectory.points.length; i++) {
        path.lineTo(trajectory.points[i].x, trajectory.points[i].y);
      }

      canvas.drawPath(path, paint);

      for (final point in trajectory.points) {
        canvas.drawCircle(
          Offset(point.x, point.y),
          4,
          Paint()..color = AppColors.accent,
        );
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
