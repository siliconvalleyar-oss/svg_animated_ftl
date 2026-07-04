import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/svg_provider.dart';
import '../core/constants.dart';

class PiecesOverlay extends StatefulWidget {
  @override
  State<PiecesOverlay> createState() => _PiecesOverlayState();
}

class _PiecesOverlayState extends State<PiecesOverlay> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTap: () => provider.clearSelection(),
          child: Container(
            color: Colors.transparent,
            child: const Center(
              child: Text(
                'Modo Piezas Activo',
                style: TextStyle(color: AppColors.accent, fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }
}
