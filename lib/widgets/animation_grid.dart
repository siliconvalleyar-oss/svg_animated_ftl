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
          padding: const EdgeInsets.all(6),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 0.9,
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
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isActive
                        ? Color(int.parse(preset['color'].replaceFirst('#', '0xFF')))
                        : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIcon(preset['id']),
                      size: 18,
                      color: isActive ? Colors.white : AppColors.textDim,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preset['name'],
                      style: TextStyle(
                        fontSize: 8,
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
      case 'projectile':
        return Icons.rocket_launch;
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
      case 'pendulum':
        return Icons.swap_vert;
      case 'freefall':
        return Icons.vertical_align_bottom;
      case 'elastic-bounce':
        return Icons.swap_calls;
      case 'spring':
        return Icons.waves;
      case 'opacity-anim':
        return Icons.opacity;
      default:
        return Icons.animation;
    }
  }
}
