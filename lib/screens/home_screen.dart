import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/svg_provider.dart';
import '../providers/settings_provider.dart';
import '../core/constants.dart';
import '../widgets/svg_preview.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/panel_slider.dart';
import '../widgets/animation_grid.dart';
import '../widgets/controls_panel.dart';
import '../widgets/elements_list.dart';
import '../services/export_service.dart';

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
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return Column(
            children: [
              Expanded(child: SvgPreview(dimOpacity: settings.dimOpacity, selectedOpacity: settings.selectedOpacity)),
              if (_selectedPanel >= 0) _buildPanel(),
            ],
          );
        },
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
        PopupMenuButton<String>(
          icon: const Icon(Icons.file_upload_outlined),
          onSelected: (value) {
            if (value == 'import') {
              _importSvgFromString();
            } else if (value == 'import_folder') {
              final settings = context.read<SettingsProvider>();
              _importFromFolder(settings.exportPath);
            } else if (value == 'export') {
              _exportSvg();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'import_folder', child: ListTile(leading: Icon(Icons.folder_open), title: Text('Cargar desde carpeta'))),
            const PopupMenuItem(value: 'import', child: ListTile(leading: Icon(Icons.upload_file), title: Text('Pegar código SVG'))),
            const PopupMenuItem(value: 'export', child: ListTile(leading: Icon(Icons.save_alt), title: Text('Exportar SVG'))),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showSettings,
        ),
      ],
    );
  }

  Widget _buildPanel() {
    switch (_selectedPanel) {
      case 0:
        return PanelSlider(child: _buildMovePanel());
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
        return PanelSlider(child: _buildPiecesPanel());
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMovePanel() {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        final hasSelection = provider.activeWorkspace.selectedGroupElements.isNotEmpty;
        final step = 5.0;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                hasSelection
                    ? 'Mover piezas seleccionadas (${provider.activeWorkspace.selectedGroupElements.length})'
                    : 'Selecciona piezas para mover',
                style: const TextStyle(fontSize: 13, color: AppColors.text),
              ),
            ),
            if (hasSelection) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left column
                  Column(
                    children: [
                      const SizedBox(height: 36),
                      _dirButton(Icons.arrow_back, () => provider.moveSelectedElements(-step, 0)),
                    ],
                  ),
                  // Center column: up, reset, down
                  Column(
                    children: [
                      _dirButton(Icons.arrow_upward, () => provider.moveSelectedElements(0, -step)),
                      const SizedBox(height: 4),
                      _dirButton(Icons.center_focus_strong, provider.resetElementOffsets,
                          color: AppColors.danger),
                      const SizedBox(height: 4),
                      _dirButton(Icons.arrow_downward, () => provider.moveSelectedElements(0, step)),
                    ],
                  ),
                  // Right column
                  Column(
                    children: [
                      const SizedBox(height: 36),
                      _dirButton(Icons.arrow_forward, () => provider.moveSelectedElements(step, 0)),
                    ],
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _dirButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 22, color: color ?? AppColors.textDim),
      ),
    );
  }

  Widget _buildPiecesPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Consumer<SvgProvider>(
            builder: (context, provider, _) {
              return ElevatedButton.icon(
                onPressed: () => provider.togglePiecesMode(),
                icon: Icon(
                  provider.activeWorkspace.isPiecesMode ? Icons.grid_off : Icons.grid_view,
                  size: 18,
                ),
                label: Text(
                  provider.activeWorkspace.isPiecesMode ? 'Desactivar piezas' : 'Activar piezas',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: provider.activeWorkspace.isPiecesMode ? AppColors.danger : AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minimumSize: const Size(double.infinity, 40),
                ),
              );
            },
          ),
        ),
        Expanded(child: ElementsList()),
      ],
    );
  }

  void _showSettings() {
    final settings = context.read<SettingsProvider>();
    final provider = context.read<SvgProvider>();
    final pathController = TextEditingController(text: settings.exportPath);
    final nameController = TextEditingController(text: provider.activeWorkspace.name);
    double tempDimOpacity = settings.dimOpacity;
    double tempSelectedOpacity = settings.selectedOpacity;
    double tempSpeed = settings.defaultSpeed;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface2,
            title: const Text('Configuración', style: TextStyle(color: AppColors.text)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ruta de exportación/importación:', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: pathController,
                    style: const TextStyle(color: AppColors.text, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: '/sdcard/Pictures/svg_animated_ftl',
                      hintStyle: const TextStyle(color: AppColors.textDim),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.restore, size: 18),
                        onPressed: () {
                          pathController.text = '/sdcard/Pictures/svg_animated_ftl';
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Nombre del espacio:', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: AppColors.text, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Workspace',
                      hintStyle: TextStyle(color: AppColors.textDim),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Velocidad por defecto:', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: tempSpeed,
                          min: 0.5,
                          max: 60.0,
                          divisions: 120,
                          activeColor: AppColors.accent,
                          onChanged: (v) {
                            setDialogState(() => tempSpeed = v);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          '${tempSpeed.toStringAsFixed(1)}s',
                          style: const TextStyle(fontSize: 11, color: AppColors.text),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Opacidad de piezas no seleccionadas:', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: tempDimOpacity,
                          min: 0.0,
                          max: 1.0,
                          divisions: 20,
                          activeColor: AppColors.accent,
                          onChanged: (v) {
                            setDialogState(() => tempDimOpacity = v);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${(tempDimOpacity * 100).toInt()}%',
                          style: const TextStyle(fontSize: 11, color: AppColors.text),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Opacidad de piezas seleccionadas:', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: tempSelectedOpacity,
                          min: 0.0,
                          max: 1.0,
                          divisions: 20,
                          activeColor: AppColors.accent,
                          onChanged: (v) {
                            setDialogState(() => tempSelectedOpacity = v);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${(tempSelectedOpacity * 100).toInt()}%',
                          style: const TextStyle(fontSize: 11, color: AppColors.text),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  final path = pathController.text.trim();
                  if (path.isNotEmpty) {
                    final dir = Directory(path);
                    if (!await dir.exists()) {
                      await dir.create(recursive: true);
                    }
                    await settings.setExportPath(path);
                  }
                  final name = nameController.text.trim();
                  if (name.isNotEmpty && name != provider.activeWorkspace.name) {
                    provider.renameWorkspace(name);
                  }
                  await settings.setDimOpacity(tempDimOpacity);
                  await settings.setSelectedOpacity(tempSelectedOpacity);
                  await settings.setDefaultSpeed(tempSpeed);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Configuración guardada')),
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Guardar', style: TextStyle(color: AppColors.accent)),
              ),
            ],
          );
        },
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

  Future<void> _importFromFolder(String folderPath) async {
    try {
      final dir = Directory(folderPath);
      if (!await dir.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Carpeta no encontrada: $folderPath')),
          );
        }
        return;
      }

      final svgFiles = await dir
          .list()
          .where((f) => f.path.endsWith('.svg'))
          .toList();

      if (svgFiles.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay archivos SVG en la carpeta')),
          );
        }
        return;
      }

      final selectedFile = await showDialog<String>(
        context: context,
        builder: (context) => SimpleDialog(
          backgroundColor: AppColors.surface2,
          title: const Text('Seleccionar SVG', style: TextStyle(color: AppColors.text)),
          children: svgFiles.map((f) {
            final name = f.path.split('/').last;
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, f.path),
              child: Text(name, style: const TextStyle(color: AppColors.text)),
            );
          }).toList(),
        ),
      );

      if (selectedFile == null) return;

      final file = File(selectedFile);
      if (!await file.exists()) return;

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
      debugPrint('Error importing from folder: $e');
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
      final settings = context.read<SettingsProvider>();

      if (provider.currentSvgString == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay SVG para exportar')),
          );
        }
        return;
      }

      final dir = Directory(settings.exportPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final animatedSvg = await ExportService.generateAnimatedSvg(
        originalSvg: provider.currentSvgString!,
        elementAnimations: provider.elementAnimations,
        trajectories: provider.activeWorkspace.trajectories,
      );

      final file = File('${settings.exportPath}/animated_svg_${DateTime.now().millisecondsSinceEpoch}.svg');
      await file.writeAsString(animatedSvg, flush: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Guardado: ${file.path}')),
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
