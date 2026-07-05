import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  static const _boxName = 'svg_settings';
  static const _exportPathKey = 'export_path';
  static const _defaultPath = '/sdcard/Pictures/svg_animated_ftl';

  String _exportPath = _defaultPath;
  String get exportPath => _exportPath;

  Future<void> init() async {
    try {
      final box = await Hive.openBox(_boxName);
      _exportPath = box.get(_exportPathKey, defaultValue: _defaultPath);
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
}
