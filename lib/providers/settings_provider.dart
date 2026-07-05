import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  static const _boxName = 'svg_settings';
  static const _exportPathKey = 'export_path';
  static const _dimOpacityKey = 'dim_opacity';
  static const _defaultPath = '/sdcard/Pictures/svg_animated_ftl';
  static const double _defaultDimOpacity = 0.5;

  String _exportPath = _defaultPath;
  double _dimOpacity = _defaultDimOpacity;

  String get exportPath => _exportPath;
  double get dimOpacity => _dimOpacity;

  Future<void> init() async {
    try {
      final box = await Hive.openBox(_boxName);
      _exportPath = box.get(_exportPathKey, defaultValue: _defaultPath);
      _dimOpacity = (box.get(_dimOpacityKey, defaultValue: _defaultDimOpacity)).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setExportPath(String path) async {
    try {
      _exportPath = path;
      final box = await Hive.openBox(_boxName);
      await box.put(_exportPathKey, path);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving export path: $e');
    }
  }

  Future<void> setDimOpacity(double opacity) async {
    try {
      _dimOpacity = opacity.clamp(0.0, 1.0);
      final box = await Hive.openBox(_boxName);
      await box.put(_dimOpacityKey, _dimOpacity);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving dim opacity: $e');
    }
  }
}
