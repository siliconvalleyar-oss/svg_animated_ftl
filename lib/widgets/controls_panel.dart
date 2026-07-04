import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/svg_provider.dart';
import '../core/constants.dart';
import '../services/animation_engine.dart';
import 'slider_control.dart';
import 'toggle_group.dart';
import 'direction_pad.dart';

class ControlsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        final selectedElement = provider.activeWorkspace.selectedElementIndex;
        if (selectedElement == null) {
          return const Center(
            child: Text(
              'Selecciona un elemento para editar',
              style: TextStyle(color: AppColors.textDim),
            ),
          );
        }

        final config = provider.elementAnimations[selectedElement];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SliderControl(
                label: 'Velocidad',
                value: config?.speed ?? 1.0,
                min: 0.2,
                max: 16.0,
                suffix: 's',
                onChanged: provider.updateAnimationSpeed,
              ),
              SliderControl(
                label: 'Retraso',
                value: config?.delay ?? 0.0,
                min: 0.0,
                max: 3.0,
                suffix: 's',
                onChanged: provider.updateAnimationDelay,
              ),
              const SizedBox(height: 12),
              const Text('Repetición', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
              const SizedBox(height: 4),
              ToggleGroup(
                options: ['infinite', '1', '3', 'random'],
                selected: config?.iter ?? 'infinite',
                onChanged: provider.updateAnimationIteration,
              ),
              const SizedBox(height: 12),
              const Text('Dirección', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
              const SizedBox(height: 4),
              ToggleGroup(
                options: ['normal', 'reverse', 'alternate'],
                selected: config?.dir ?? 'normal',
                onChanged: provider.updateAnimationDirection,
              ),
              if (config?.presetId != null && AnimationEngine.isTranslatable(config!.presetId!)) ...[
                const SizedBox(height: 12),
                DirectionPad(
                  onAngleChanged: provider.updateDirectionAngle,
                ),
              ],
              if (config?.presetId == 'oval') ...[
                const SizedBox(height: 12),
                SliderControl(
                  label: 'Ancho (X)',
                  value: config?.ovalRx ?? 80.0,
                  min: 10,
                  max: 150,
                  suffix: 'px',
                  onChanged: provider.updateOvalRx,
                ),
                SliderControl(
                  label: 'Alto (Y)',
                  value: config?.ovalRy ?? 40.0,
                  min: 10,
                  max: 150,
                  suffix: 'px',
                  onChanged: provider.updateOvalRy,
                ),
              ],
              if (config?.presetId == 'arc' || config?.presetId == 'radiate') ...[
                const SizedBox(height: 12),
                SliderControl(
                  label: 'Eje X',
                  value: config?.arcRx ?? 80.0,
                  min: 10,
                  max: 200,
                  suffix: 'px',
                  onChanged: provider.updateArcRx,
                ),
                SliderControl(
                  label: 'Eje Y',
                  value: config?.arcRy ?? 80.0,
                  min: 10,
                  max: 200,
                  suffix: 'px',
                  onChanged: provider.updateArcRy,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
