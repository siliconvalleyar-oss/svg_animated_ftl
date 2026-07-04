import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
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
                  onPressed: _importSvg,
                  icon: const Icon(Icons.upload_file, size: 20),
                  label: const Text('Importar SVG'),
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

  Future<void> _importSvg() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['svg'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El archivo no existe')),
          );
        }
        return;
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El archivo está vacío')),
          );
        }
        return;
      }

      await context.read<SvgProvider>().loadSvgString(content);
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

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar SVG Animado',
        fileName: 'animated.svg',
        type: FileType.custom,
        allowedExtensions: ['svg'],
      );

      if (result == null) return;

      final file = File(result);
      await file.writeAsString(provider.currentSvgString!, flush: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SVG exportado correctamente')),
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
