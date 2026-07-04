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
        final selectedElements = provider.activeWorkspace.selectedGroupElements;
        if (selectedElements.isEmpty) {
          return const Center(
            child: Text(
              'Selecciona piezas para editar',
              style: TextStyle(color: AppColors.textDim),
            ),
          );
        }

        final config = provider.elementAnimations[selectedElements.first];
        final count = selectedElements.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (count > 1)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count piezas seleccionadas — los cambios aplican a todas',
                    style: const TextStyle(fontSize: 12, color: AppColors.accent),
                  ),
                ),
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
              const Text('Opacidad', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
              SliderControl(
                label: 'Transparencia',
                value: config?.opacity ?? 1.0,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                suffix: '',
                onChanged: provider.updateOpacity,
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
                DirectionPad(onAngleChanged: provider.updateDirectionAngle),
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
              if (config?.presetId == 'projectile') ...[
                const SizedBox(height: 12),
                const Text('Física — Tiro Oblicuo', style: TextStyle(fontSize: 12, color: AppColors.accent)),
                SliderControl(
                  label: 'Velocidad inicial (v₀)',
                  value: config?.initialVelocity ?? 100.0,
                  min: 10,
                  max: 300,
                  suffix: 'px/s',
                  onChanged: provider.updateInitialVelocity,
                ),
                SliderControl(
                  label: 'Ángulo de lanzamiento (θ)',
                  value: config?.launchAngle ?? 45.0,
                  min: 0,
                  max: 90,
                  divisions: 18,
                  suffix: '°',
                  onChanged: provider.updateLaunchAngle,
                ),
                SliderControl(
                  label: 'Gravedad (g)',
                  value: config?.gravity ?? 9.8,
                  min: 1.0,
                  max: 30.0,
                  suffix: 'm/s²',
                  onChanged: provider.updateGravity,
                ),
              ],
              if (config?.presetId == 'radiate') ...[
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
