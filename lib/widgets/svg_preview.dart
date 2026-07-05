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

class SvgPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        if (provider.currentSvgString == null) {
          return EmptyState();
        }

        _syncAnimationState(context, provider);

        final hasSelection = provider.activeWorkspace.selectedGroupElements.isNotEmpty;
        final isPlaying = provider.animationPlaying;

        return Stack(
          children: [
            BackgroundLayer(),

            // SVG with zoom support
            ClipRect(
              child: InteractiveViewer(
                minScale: AppConstants.minZoom,
                maxScale: AppConstants.maxZoom,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: hasSelection ? 0.3 : 1.0,
                  child: _buildAnimatedSvg(provider),
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

            // Play/Pause button - minimal gray circle
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
        );
      },
    );
  }

  void _syncAnimationState(BuildContext context, SvgProvider provider) {
    final ctrl = AnimationScope.of(context);
    if (ctrl == null) return;

    if (!provider.animationPlaying) {
      ctrl.stop();
    } else if (!ctrl.isAnimating) {
      ctrl.repeat();
    }
  }

  Widget _buildAnimatedSvg(SvgProvider provider) {
    final parseResult = SvgParser.parse(provider.currentSvgString!);
    if (!parseResult.isSuccess) {
      return Center(
        child: Text(
          parseResult.error ?? 'Error al parsear SVG',
          style: const TextStyle(color: AppColors.danger),
        ),
      );
    }

    return SvgPicture.string(
      provider.currentSvgString!,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
