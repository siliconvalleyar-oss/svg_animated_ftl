import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/svg_provider.dart';
import '../services/svg_parser.dart';
import '../core/constants.dart';
import 'animation_scope.dart';
import 'empty_state.dart';
import 'zoom_controls.dart';
import 'background_layer.dart';
import 'pieces_overlay.dart';
import 'trajectory_overlay.dart';
import 'individual_elements_view.dart';

class SvgPreview extends StatelessWidget {
  final double dimOpacity;

  const SvgPreview({Key? key, this.dimOpacity = 0.5}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        if (provider.currentSvgString == null) {
          return EmptyState();
        }

        final hasSelection = provider.activeWorkspace.selectedGroupElements.isNotEmpty;
        final isPlaying = provider.animationPlaying;
        final hasAnimations = provider.elementAnimations.values.any(
          (c) => c.presetId != null,
        );

        // Calculate animation duration based on average speed
        final avgSpeed = _getAverageSpeed(provider);
        final animDuration = Duration(milliseconds: (avgSpeed * 1000).toInt());

        return AnimationScope(
          duration: animDuration,
          child: Stack(
            children: [
              BackgroundLayer(),

              // Main content area
              ClipRect(
                child: InteractiveViewer(
                  minScale: AppConstants.minZoom,
                  maxScale: AppConstants.maxZoom,
                  child: hasAnimations
                      ? IndividualElementsView(dimOpacity: dimOpacity)
                      : AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: hasSelection ? dimOpacity : 1.0,
                          child: SvgPicture.string(
                            provider.currentSvgString!,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
              ),

              // Selection highlight border
              if (hasSelection)
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

              // Selection count badge
              if (hasSelection)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.activeWorkspace.selectedGroupElements.length} sel.',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

              // Play/Pause button
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => provider.togglePlayPause(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface2.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: AppColors.text,
                      size: 22,
                    ),
                  ),
                ),
              ),

              if (provider.activeWorkspace.isTrajectoryMode)
                TrajectoryOverlay(),
              if (provider.activeWorkspace.isPiecesMode)
                PiecesOverlay(),
              ZoomControls(),
            ],
          ),
        );
      },
    );
  }

  double _getAverageSpeed(SvgProvider provider) {
    final configs = provider.elementAnimations.values;
    if (configs.isEmpty) return 4.0;
    final speeds = configs.where((c) => c.presetId != null).map((c) => c.speed);
    if (speeds.isEmpty) return 4.0;
    return speeds.reduce((a, b) => a + b) / speeds.length;
  }
}
