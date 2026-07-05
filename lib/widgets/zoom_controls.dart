import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/svg_provider.dart';
import '../core/constants.dart';

class ZoomControls extends StatelessWidget {
  final TransformationController? controller;

  const ZoomControls({Key? key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 8,
      top: 8,
      child: Column(
        children: [
          _buildButton(
            icon: Icons.add,
            onTap: () {
              if (controller != null) {
                final matrix = controller!.value.clone();
                matrix.scale(1.3);
                controller!.value = matrix;
              }
            },
          ),
          const SizedBox(height: 4),
          _buildButton(
            icon: Icons.remove,
            onTap: () {
              if (controller != null) {
                final matrix = controller!.value.clone();
                matrix.scale(0.7);
                controller!.value = matrix;
              }
            },
          ),
          const SizedBox(height: 4),
          _buildButton(
            icon: Icons.center_focus_strong,
            onTap: () {
              if (controller != null) {
                controller!.value = Matrix4.identity();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface2.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.textDim),
      ),
    );
  }
}
