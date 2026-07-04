import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/svg_provider.dart';
import '../core/constants.dart';

class DirectionPad extends StatelessWidget {
  final ValueChanged<double> onAngleChanged;

  const DirectionPad({Key? key, required this.onAngleChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        final index = provider.activeWorkspace.selectedElementIndex;
        final config = provider.elementAnimations[index];
        final currentAngle = config?.directionAngle ?? 0;

        return Column(
          children: [
            const Text(
              'Dirección',
              style: TextStyle(fontSize: 12, color: AppColors.textDim),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 8,
              itemBuilder: (context, i) {
                final angles = [0, 45, 90, 135, 180, 225, 270, 315];
                final labels = ['↗', '↑', '↖', '→', '←', '↘', '↓', '↙'];
                final isSelected = currentAngle == angles[i].toDouble();

                return GestureDetector(
                  onTap: () => onAngleChanged(angles[i].toDouble()),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : AppColors.surface2,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 18,
                          color: isSelected ? Colors.white : AppColors.textDim,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
