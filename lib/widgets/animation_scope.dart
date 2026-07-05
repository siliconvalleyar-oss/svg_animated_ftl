import 'package:flutter/material.dart';

/// A scope that hosts an [AnimationController] and exposes it to descendants
/// via [InheritedWidget].
///
/// This separates the controller lifecycle from the presentation widgets,
/// so widgets like [SvgPreview] don't need [SingleTickerProviderStateMixin].
class AnimationScope extends StatefulWidget {
  final Widget child;

  const AnimationScope({super.key, required this.child});

  /// Retrieve the [AnimationController] from the nearest [AnimationScope]
  /// ancestor. Returns `null` if no [AnimationScope] is found.
  static AnimationController? of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_AnimationScopeInherited>();
    return inherited?.controller;
  }

  @override
  State<AnimationScope> createState() => _AnimationScopeState();
}

class _AnimationScopeState extends State<AnimationScope> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimationScopeInherited(
      controller: _controller,
      child: widget.child,
    );
  }
}

class _AnimationScopeInherited extends InheritedWidget {
  final AnimationController controller;

  const _AnimationScopeInherited({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(_AnimationScopeInherited oldWidget) {
    return controller != oldWidget.controller;
  }
}
