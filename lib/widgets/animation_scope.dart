import 'package:flutter/material.dart';

class AnimationScope extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AnimationScope({super.key, required this.child, this.duration = const Duration(seconds: 4)});

  static AnimationController? of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_AnimationScopeInherited>();
    return inherited?.controller;
  }

  @override
  State<AnimationScope> createState() => _AnimationScopeState();
}

class _AnimationScopeState extends State<AnimationScope> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void didUpdateWidget(AnimationScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _controller.repeat();
    }
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
