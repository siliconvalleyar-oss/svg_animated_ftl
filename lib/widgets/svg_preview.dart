import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/svg_provider.dart';
import '../services/svg_parser.dart';
import '../core/constants.dart';
import 'empty_state.dart';
import 'zoom_controls.dart';
import 'background_layer.dart';
import 'pieces_overlay.dart';
import 'trajectory_overlay.dart';

class SvgPreview extends StatefulWidget {
  @override
  State<SvgPreview> createState() => _SvgPreviewState();
}

class _SvgPreviewState extends State<SvgPreview> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        if (provider.currentSvgString == null) {
          return EmptyState();
        }

        if (!provider.animationPlaying) {
          _controller.stop();
        } else {
          _controller.repeat();
        }

        final hasSelection = provider.activeWorkspace.selectedGroupElements.isNotEmpty;

        return Stack(
          children: [
            BackgroundLayer(),

            // SVG with dimming when elements are selected
            InteractiveViewer(
              minScale: AppConstants.minZoom,
              maxScale: AppConstants.maxZoom,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: hasSelection ? 0.25 : 1.0,
                child: _buildAnimatedSvg(provider),
              ),
            ),

            // Selection indicator overlay
            if (hasSelection)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.activeWorkspace.selectedGroupElements.length} seleccionadas',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
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
        child: CircularProgressIndicator(),
      ),
    );
  }
}
