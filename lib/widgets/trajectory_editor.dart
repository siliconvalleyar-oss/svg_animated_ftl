import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/svg_provider.dart';
import '../core/constants.dart';

class TrajectoryEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        final trajectories = provider.activeWorkspace.trajectories;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Trayectorias',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.accent),
                    onPressed: () => provider.addTrajectory('Trayectoria ${trajectories.length + 1}'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: trajectories.length,
                itemBuilder: (context, index) {
                  final id = trajectories.keys.elementAt(index);
                  final trajectory = trajectories[id];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            trajectory?.name ?? '',
                            style: const TextStyle(color: AppColors.text),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: AppColors.danger),
                          onPressed: () => provider.deleteTrajectory(id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
