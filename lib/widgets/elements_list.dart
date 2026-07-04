import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/svg_provider.dart';
import '../services/svg_parser.dart';
import '../core/constants.dart';

class ElementsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        if (provider.currentSvgString == null) {
          return const Center(
            child: Text(
              'Carga un SVG primero',
              style: TextStyle(color: AppColors.textDim),
            ),
          );
        }

        final parseResult = SvgParser.parse(provider.currentSvgString!);
        if (!parseResult.isSuccess) {
          return Center(
            child: Text(
              parseResult.error ?? 'Error al parsear',
              style: const TextStyle(color: AppColors.danger),
            ),
          );
        }

        final elements = parseResult.elements;
        final selected = provider.activeWorkspace.selectedElementIndex;

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: elements.length,
          itemBuilder: (context, index) {
            final el = elements[index];
            final config = provider.elementAnimations[index];
            final animName = config?.presetId ?? '—';

            return GestureDetector(
              onTap: () => provider.selectElement(index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected == index ? AppColors.accent.withOpacity(0.2) : AppColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected == index ? AppColors.accent : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Icon(
                          _getIconForTag(el.tag),
                          size: 20,
                          color: AppColors.textDim,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${el.tag} ${index}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.text,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            animName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textDim,
                            ),
                          ),
                        ],
                      ),
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

  IconData _getIconForTag(String tag) {
    switch (tag) {
      case 'circle':
      case 'ellipse':
        return Icons.circle_outlined;
      case 'rect':
        return Icons.square_outlined;
      case 'path':
        return Icons.timeline;
      case 'line':
        return Icons.line_axis;
      case 'polygon':
      case 'polyline':
        return Icons.pentagon_outlined;
      case 'g':
        return Icons.group_work;
      case 'text':
        return Icons.text_fields;
      default:
        return Icons.help_outline;
    }
  }
}
