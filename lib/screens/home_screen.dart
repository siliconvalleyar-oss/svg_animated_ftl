import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../providers/svg_provider.dart';
import '../core/constants.dart';
import '../widgets/svg_preview.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/panel_slider.dart';
import '../widgets/animation_grid.dart';
import '../widgets/controls_panel.dart';
import '../widgets/elements_list.dart';
import '../widgets/shapes_grid.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPanel = -1;

  void _safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: SvgPreview()),
          if (_selectedPanel >= 0) _buildPanel(),
        ],
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedPanel,
        onTabChanged: (index) {
          _safeSetState(() {
            _selectedPanel = _selectedPanel == index ? -1 : index;
          });
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      title: Consumer<SvgProvider>(
        builder: (context, provider, _) {
          return Text(
            provider.activeWorkspace.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: context.watch<SvgProvider>().canUndo
              ? () => context.read<SvgProvider>().undo()
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: context.watch<SvgProvider>().canRedo
              ? () => context.read<SvgProvider>().redo()
              : null,
        ),
      ],
    );
  }

  Widget _buildPanel() {
    switch (_selectedPanel) {
      case 0:
        return PanelSlider(
          child: _buildImportPanel(),
        );
      case 1:
        return PanelSlider(
          child: Column(
            children: [
              Expanded(child: AnimationGrid()),
              Expanded(child: ElementsList()),
            ],
          ),
        );
      case 2:
        return PanelSlider(child: ControlsPanel());
      case 3:
        return PanelSlider(
          child: _buildPiecesPanel(),
        );
      case 4:
        return PanelSlider(child: _buildExportPanel());
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImportPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _importSvgFromString,
                  icon: const Icon(Icons.code, size: 20),
                  label: const Text('Pegar SVG'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: ShapesGrid()),
      ],
    );
  }

  Widget _buildPiecesPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Consumer<SvgProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton.icon(
                      onPressed: () => provider.togglePiecesMode(),
                      icon: Icon(
                        provider.activeWorkspace.isPiecesMode
                            ? Icons.grid_off
                            : Icons.grid_view,
                        size: 20,
                      ),
                      label: Text(
                        provider.activeWorkspace.isPiecesMode
                            ? 'Desactivar modo piezas'
                            : 'Activar modo piezas',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.activeWorkspace.isPiecesMode
                            ? AppColors.danger
                            : AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(child: ElementsList()),
      ],
    );
  }

  Widget _buildExportPanel() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _exportSvg,
            icon: const Icon(Icons.save_alt, size: 20),
            label: const Text('Exportar SVG Animado'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importSvgFromString() async {
    try {
      final controller = TextEditingController();
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface2,
          title: const Text('Pegar código SVG', style: TextStyle(color: AppColors.text)),
          content: TextField(
            controller: controller,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: '<svg viewBox="0 0 200 200">...</svg>',
              hintStyle: TextStyle(color: AppColors.textDim),
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(color: AppColors.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Cargar', style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      );

      if (result == null || result.trim().isEmpty) return;

      if (!result.trim().startsWith('<svg') && !result.trim().startsWith('<?xml')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El código no parece ser un SVG válido')),
          );
        }
        return;
      }

      await context.read<SvgProvider>().loadSvgString(result.trim());
    } catch (e) {
      debugPrint('Error importing SVG: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _exportSvg() async {
    try {
      final provider = context.read<SvgProvider>();
      if (provider.currentSvgString == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay SVG para exportar')),
          );
        }
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/animated_svg_${DateTime.now().millisecondsSinceEpoch}.svg');
      await file.writeAsString(provider.currentSvgString!, flush: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Guardado en: ${file.path}')),
        );
      }
    } catch (e) {
      debugPrint('Error exporting SVG: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: ${e.toString()}')),
        );
      }
    }
  }
}
