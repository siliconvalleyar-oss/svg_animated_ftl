import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/svg_provider.dart';
import '../core/constants.dart';

class PiecesOverlay extends StatefulWidget {
  @override
  State<PiecesOverlay> createState() => _PiecesOverlayState();
}

class _PiecesOverlayState extends State<PiecesOverlay> {
  final Map<int, Offset> _offsets = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        if (!provider.activeWorkspace.isPiecesMode) {
          return const SizedBox.shrink();
        }

        final selected = provider.activeWorkspace.selectedGroupElements;

        return Stack(
          children: [
            // Tap to clear selection
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => provider.clearSelection(),
                child: Container(color: Colors.transparent),
              ),
            ),

            // Drag handler for selected pieces
            if (selected.isNotEmpty)
              Positioned.fill(
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      for (final idx in selected) {
                        _offsets[idx] = (_offsets[idx] ?? Offset.zero) + details.delta;
                      }
                    });
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
          ],
        );
      },
    );
  }
}
