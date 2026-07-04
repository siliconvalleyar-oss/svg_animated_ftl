import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/svg_provider.dart';
import '../core/constants.dart';

class ZoomControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        return Positioned(
          right: 8,
          top: 8,
          child: Column(
            children: [
              _buildButton(
                icon: Icons.zoom_in,
                onTap: () => provider.setZoom(provider.activeWorkspace.zoomLevel + 0.2),
              ),
              const SizedBox(height: 4),
              _buildButton(
                icon: Icons.zoom_out,
                onTap: () => provider.setZoom(provider.activeWorkspace.zoomLevel - 0.2),
              ),
              const SizedBox(height: 4),
              _buildButton(
                icon: Icons.center_focus_strong,
                onTap: () => provider.setZoom(1.0),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.textDim),
      ),
    );
  }
}
