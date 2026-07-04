import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/svg_provider.dart';
import '../core/constants.dart';

class AnimationGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        final selectedElement = provider.activeWorkspace.selectedElementIndex;
        final config = provider.elementAnimations[selectedElement];

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: AnimationPresets.presets.length,
          itemBuilder: (context, index) {
            final preset = AnimationPresets.presets[index];
            final isActive = config?.presetId == preset['id'];

            return GestureDetector(
              onTap: () {
                if (selectedElement != null) {
                  provider.togglePreset(preset['id']);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isActive
                      ? Color(int.parse(preset['color'].replaceFirst('#', '0xFF')))
                      : AppColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? Color(int.parse(preset['color'].replaceFirst('#', '0xFF')))
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIcon(preset['id']),
                      size: 24,
                      color: isActive ? Colors.white : AppColors.textDim,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preset['name'],
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive ? Colors.white : AppColors.textDim,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIcon(String presetId) {
    switch (presetId) {
      case 'rotate':
        return Icons.rotate_right;
      case 'wheel':
        return Icons.settings;
      case 'pulse':
        return Icons.favorite;
      case 'bounce':
        return Icons.arrow_upward;
      case 'gravity':
        return Icons.arrow_downward;
      case 'slide':
        return Icons.swap_horiz;
      case 'oval':
        return Icons.circle;
      case 'fade':
        return Icons.opacity;
      case 'draw':
        return Icons.brush;
      case 'shake':
        return Icons.vibration;
      case 'float':
        return Icons.waves;
      case 'levitate':
        return Icons.flight;
      case 'arc':
        return Icons.architecture;
      case 'radiate':
        return Icons.wb_sunny;
      case 'spin':
        return Icons.sync;
      case 'glow':
        return Icons.brightness_high;
      case 'wave-sine':
        return Icons.show_chart;
      case 'wave-square':
        return Icons.stacked_line_chart;
      case 'wave-triangle':
        return Icons.change_history;
      default:
        return Icons.animation;
    }
  }
}
