import 'package:flutter/material.dart';
import '../core/constants.dart';

class ZoomControls extends StatelessWidget {
  final TransformationController? controller;

  const ZoomControls({Key? key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportW = constraints.maxWidth;
        final viewportH = constraints.maxHeight;
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
                    final scaleMatrix = Matrix4.diagonal3Values(1.03, 1.03, 1.0);
                    controller!.value = scaleMatrix * matrix;
                  }
                },
              ),
              const SizedBox(height: 4),
              _buildButton(
                icon: Icons.remove,
                onTap: () {
                  if (controller != null) {
                    final matrix = controller!.value.clone();
                    final scaleMatrix = Matrix4.diagonal3Values(0.97, 0.97, 1.0);
                    controller!.value = scaleMatrix * matrix;
                  }
                },
              ),
              const SizedBox(height: 4),
              _buildButton(
                icon: Icons.center_focus_strong,
                onTap: () {
                  if (controller != null) {
                    final current = controller!.value.clone();
                    final scale = current.getMaxScaleOnAxis();
                    final tx = viewportW / 2 * (1 - scale);
                    final ty = viewportH / 2 * (1 - scale);
                    current.setTranslationRaw(tx, ty, 0);
                    controller!.value = current;
                  }
                },
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
