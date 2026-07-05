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
  final double dimOpacity;

  const IndividualElementsView({Key? key, this.dimOpacity = 0.5}) : super(key: key);

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
        final selectedElements = provider.activeWorkspace.selectedGroupElements;
        final hasSelection = selectedElements.isNotEmpty;

        return LayoutBuilder(
          builder: (context, constraints) {
            final vw = parseResult.viewBoxWidth;
            final vh = parseResult.viewBoxHeight;

            return Stack(
              children: [
                // Full SVG as background (dimmed if selection active)
                if (hasSelection)
                  Opacity(
                    opacity: dimOpacity,
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

                  final miniSvg = _buildMiniSvg(
                    svgElement: svgEl.element,
                    viewBoxWidth: vw,
                    viewBoxHeight: vh,
                  );

                  Widget elementWidget = SvgPicture.string(
                    miniSvg,
                    fit: BoxFit.contain,
                  );

                  // Apply animation if config has preset AND controller is running
                  if (config?.presetId != null && ctrl != null) {
                    // Create animation that runs from 0 to 1 over the controller's duration
                    final animValue = Tween<double>(begin: 0.0, end: 1.0).animate(ctrl);

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

                  // Non-selected pieces get dimmed when there's a selection
                  if (hasSelection && !isSelected && config?.presetId == null) {
                    elementWidget = Opacity(
                      opacity: 1.0 - dimOpacity,
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
}
