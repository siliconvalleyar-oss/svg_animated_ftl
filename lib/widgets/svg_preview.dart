import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/svg_provider.dart';
import '../core/constants.dart';
import 'animation_scope.dart';
import 'empty_state.dart';
import 'zoom_controls.dart';
import 'background_layer.dart';
import 'pieces_overlay.dart';
import 'trajectory_overlay.dart';
import 'individual_elements_view.dart';

class SvgPreview extends StatefulWidget {
  final double dimOpacity;
  final double selectedOpacity;

  const SvgPreview({Key? key, this.dimOpacity = 0.5, this.selectedOpacity = 1.0}) : super(key: key);

  @override
  State<SvgPreview> createState() => _SvgPreviewState();
}

class _SvgPreviewState extends State<SvgPreview> {
  final TransformationController _transformController = TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

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

        final avgSpeed = _getAverageSpeed(provider);
        final animDuration = Duration(milliseconds: (avgSpeed * 1000).toInt());

        return AnimationScope(
          duration: animDuration,
          child: Stack(
            children: [
              BackgroundLayer(),

              // Main content area with zoom support
              ClipRect(
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: AppConstants.minZoom,
                  maxScale: AppConstants.maxZoom,
                  child: hasAnimations
                      ? IndividualElementsView(dimOpacity: widget.dimOpacity, selectedOpacity: widget.selectedOpacity)
                      : AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: hasSelection ? widget.dimOpacity : 1.0,
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
              Positioned(
                right: 8,
                top: 8,
                child: LayoutBuilder(
                  builder: (context, constraints) => ZoomControls(
                    controller: _transformController,
                    viewportSize: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _getAverageSpeed(SvgProvider provider) {
    final configs = provider.elementAnimations.values;
    if (configs.isEmpty) return 30.0;
    final speeds = configs.where((c) => c.presetId != null).map((c) => c.speed);
    if (speeds.isEmpty) return 30.0;
    return speeds.reduce((a, b) => a + b) / speeds.length;
  }
}
