import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:xml/xml.dart';
import '../providers/svg_provider.dart';
import '../services/svg_parser.dart';
import '../services/animation_engine.dart';
import '../core/constants.dart';
import 'animation_scope.dart';

class IndividualElementsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        if (provider.currentSvgString == null) return const SizedBox.shrink();

        final parseResult = SvgParser.parse(provider.currentSvgString!);
        if (!parseResult.isSuccess || parseResult.elements.isEmpty) {
          return SvgPicture.string(
            provider.currentSvgString!,
            fit: BoxFit.contain,
          );
        }

        final ctrl = AnimationScope.of(context);
        final isPlaying = provider.animationPlaying;
        final selectedElements = provider.activeWorkspace.selectedGroupElements;
        final hasSelection = selectedElements.isNotEmpty;

        return LayoutBuilder(
          builder: (context, constraints) {
            final vw = parseResult.viewBoxWidth;
            final vh = parseResult.viewBoxHeight;
            final scaleX = constraints.maxWidth / vw;
            final scaleY = constraints.maxHeight / vh;
            final scale = scaleX < scaleY ? scaleX : scaleY;

            return Stack(
              children: [
                // Full SVG as background (dimmed if selection active)
                if (hasSelection)
                  Opacity(
                    opacity: 0.2,
                    child: SvgPicture.string(
                      provider.currentSvgString!,
                      fit: BoxFit.contain,
                    ),
                  ),

                // Individual animated elements
                ...parseResult.elements.map((svgEl) {
                  final index = svgEl.index;
                  final config = provider.elementAnimations[index];
                  final isSelected = selectedElements.contains(index);

                  // Build mini SVG for this element
                  final miniSvg = _buildMiniSvg(
                    svgElement: svgEl.element,
                    viewBoxWidth: vw,
                    viewBoxHeight: vh,
                  );

                  Widget elementWidget = SvgPicture.string(
                    miniSvg,
                    fit: BoxFit.contain,
                  );

                  // Apply animation if config exists and has preset
                  if (config?.presetId != null && ctrl != null) {
                    final animValue = _buildAnimValue(ctrl, config!.speed);
                    elementWidget = AnimationEngine.buildAnimation(
                      presetId: config!.presetId!,
                      child: elementWidget,
                      animation: animValue,
                      config: config,
                    );

                    // Apply opacity from config
                    elementWidget = Opacity(
                      opacity: config.opacity,
                      child: elementWidget,
                    );
                  }

                  // Highlight selected elements
                  if (isSelected && hasSelection) {
                    elementWidget = Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.8),
                          width: 2,
                        ),
                      ),
                      child: elementWidget,
                    );
                  }

                  return elementWidget;
                }),
              ],
            );
          },
        );
      },
    );
  }

  String _buildMiniSvg({
    required XmlElement svgElement,
    required double viewBoxWidth,
    required double viewBoxHeight,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('<svg viewBox="0 0 $viewBoxWidth $viewBoxHeight" xmlns="http://www.w3.org/2000/svg">');
    buffer.writeln(svgElement.toXmlString());
    buffer.writeln('</svg>');
    return buffer.toString();
  }

  Animation<double> _buildAnimValue(AnimationController ctrl, double speed) {
    // Scale the animation duration based on speed
    // speed=4 means 4 seconds per cycle (slow)
    final tween = Tween<double>(begin: 0.0, end: 1.0);
    return tween.animate(CurvedAnimation(
      parent: ctrl,
      curve: Curves.linear,
    ));
  }
}
