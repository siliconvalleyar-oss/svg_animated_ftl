import 'package:flutter/material.dart';
import '../core/constants.dart';

class EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 80,
            color: AppColors.textDim,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin SVG cargado',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textDim,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Importa un SVG o selecciona una forma',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}
