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
            child: Text('Carga un SVG primero', style: TextStyle(color: AppColors.textDim)),
          );
        }

        final parseResult = SvgParser.parse(provider.currentSvgString!);
        if (!parseResult.isSuccess) {
          return Center(
            child: Text(parseResult.error ?? 'Error al parsear', style: const TextStyle(color: AppColors.danger)),
          );
        }

        final elements = parseResult.elements;
        final selected = provider.activeWorkspace.selectedGroupElements;
        final groups = provider.activeWorkspace.elementGroups;

        return Column(
          children: [
            if (provider.activeWorkspace.selectedGroupElements.length >= 2)
              Padding(
                padding: const EdgeInsets.all(8),
                child: _buildGroupButton(context, provider),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  if (groups.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text('GRUPOS', style: TextStyle(fontSize: 10, color: AppColors.textDim, fontWeight: FontWeight.w600)),
                    ),
                    ...groups.entries.map((entry) => _buildGroupTile(context, provider, entry.key, entry.value)),
                    const SizedBox(height: 8),
                  ],
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text('PIEZAS', style: TextStyle(fontSize: 10, color: AppColors.textDim, fontWeight: FontWeight.w600)),
                  ),
                  ...elements.asMap().entries.map((entry) {
                    final index = entry.key;
                    final el = entry.value;
                    final isSelected = selected.contains(index);
                    final config = provider.elementAnimations[index];
                    final animName = config?.presetId ?? '—';

                    return GestureDetector(
                      onTap: () => provider.toggleElementSelection(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accent.withValues(alpha: 0.2) : AppColors.surface2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.accent : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Icon(_getIconForTag(el.tag), size: 16, color: AppColors.textDim),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${el.tag} $index',
                                    style: const TextStyle(fontSize: 13, color: AppColors.text, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    animName,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textDim),
                                  ),
                                ],
                              ),
                            ),
                            if (config?.presetId != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(_getEffectIcon(config!.presetId!), size: 18, color: AppColors.textDim),
                              ),
                            if (isSelected)
                              const Icon(Icons.check_circle, size: 18, color: AppColors.accent)
                            else
                              const Icon(Icons.circle_outlined, size: 18, color: AppColors.border),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroupButton(BuildContext context, SvgProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showGroupDialog(context, provider),
        icon: const Icon(Icons.group_add, size: 18),
        label: const Text('Agrupar seleccionadas'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildGroupTile(BuildContext context, SvgProvider provider, String groupId, group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(int.parse(group.color.replaceFirst('#', '0xFF')))),
      ),
      child: Row(
        children: [
          Icon(Icons.group, size: 18, color: Color(int.parse(group.color.replaceFirst('#', '0xFF')))),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.name, style: const TextStyle(fontSize: 13, color: AppColors.text, fontWeight: FontWeight.w600)),
                Text(
                  '${group.elements.length} piezas',
                  style: const TextStyle(fontSize: 11, color: AppColors.textDim),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 16, color: AppColors.textDim),
            onPressed: () => _showRenameGroupDialog(context, provider, groupId, group.name),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 16, color: AppColors.danger),
            onPressed: () => provider.deleteGroup(groupId),
          ),
        ],
      ),
    );
  }

  void _showGroupDialog(BuildContext context, SvgProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title: const Text('Nombre del grupo', style: TextStyle(color: AppColors.text)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'ej: Rueda, Alas, Motor...',
            hintStyle: TextStyle(color: AppColors.textDim),
          ),
          style: const TextStyle(color: AppColors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.createGroup(
                  List.from(provider.activeWorkspace.selectedGroupElements),
                  controller.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Crear', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showRenameGroupDialog(BuildContext context, SvgProvider provider, String groupId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface2,
        title: const Text('Renombrar grupo', style: TextStyle(color: AppColors.text)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.renameGroup(groupId, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
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

  IconData _getEffectIcon(String presetId) {
    switch (presetId) {
      case 'rotate':
        return Icons.rotate_right;
      case 'wheel':
        return Icons.radio_button_checked;
      case 'pulse':
        return Icons.waves;
      case 'bounce':
        return Icons.arrow_upward;
      case 'gravity':
        return Icons.arrow_downward;
      case 'slide':
        return Icons.arrow_forward;
      case 'oval':
        return Icons.blur_circular;
      case 'fade':
        return Icons.opacity;
      case 'draw':
        return Icons.brush;
      case 'shake':
        return Icons.vibration;
      case 'float':
        return Icons.cloud;
      case 'levitate':
        return Icons.arrow_upward;
      case 'projectile':
        return Icons.rocket_launch;
      case 'radiate':
        return Icons.radar;
      case 'spin':
        return Icons.trip_origin;
      case 'glow':
        return Icons.flare;
      case 'wave-sine':
        return Icons.emergency;
      case 'wave-square':
        return Icons.wifi;
      case 'wave-triangle':
        return Icons.change_history;
      case 'pendulum':
        return Icons.science;
      case 'freefall':
        return Icons.arrow_circle_down;
      case 'elastic-bounce':
        return Icons.show_chart;
      case 'spring':
        return Icons.blur_on;
      case 'opacity-anim':
        return Icons.invert_colors;
      default:
        return Icons.animation;
    }
  }
}
