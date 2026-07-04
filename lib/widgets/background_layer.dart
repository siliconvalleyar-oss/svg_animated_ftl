import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/svg_provider.dart';

class BackgroundLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SvgProvider>(
      builder: (context, provider, _) {
        final images = provider.activeWorkspace.backgroundImages;
        if (images.isEmpty) return const SizedBox.shrink();

        return Stack(
          children: images
              .where((img) => !img.hidden)
              .map((img) => Positioned(
                    left: img.x,
                    top: img.y,
                    child: Opacity(
                      opacity: img.opacity,
                      child: Image.file(
                        File(img.path),
                        width: img.width,
                        height: img.height,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}
