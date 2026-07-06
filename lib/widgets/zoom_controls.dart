import 'package:flutter/material.dart';
import '../core/constants.dart';

class ZoomControls extends StatelessWidget {
  final TransformationController? controller;
  final Size viewportSize;

  const ZoomControls({Key? key, this.controller, this.viewportSize = Size.zero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          icon: Icons.add,
          onTap: () => _zoom(1.03),
        ),
        const SizedBox(height: 4),
        _buildButton(
          icon: Icons.remove,
          onTap: () => _zoom(0.97),
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
    );
  }

  void _zoom(double factor) {
    if (controller == null || viewportSize == Size.zero) return;
    final matrix = controller!.value.clone();
    final cx = viewportSize.width / 2;
    final cy = viewportSize.height / 2;
    final translateCenter = Matrix4.translationValues(cx, cy, 0);
    final translateBack = Matrix4.translationValues(-cx, -cy, 0);
    final scaleMatrix = Matrix4.diagonal3Values(factor, factor, 1.0);
    controller!.value = translateCenter * scaleMatrix * translateBack * matrix;
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
