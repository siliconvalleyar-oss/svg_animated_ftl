import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/home_screen.dart';

class SvgAnimatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SVG Animator',
      theme: AppTheme.darkTheme,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
