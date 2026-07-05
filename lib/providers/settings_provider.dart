import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  static const _boxName = 'svg_settings';
  static const _exportPathKey = 'export_path';
  static const _dimOpacityKey = 'dim_opacity';
  static const _defaultSpeedKey = 'default_speed';
  static const _selectedOpacityKey = 'selected_opacity';
  static const _defaultPath = '/sdcard/Pictures/svg_animated_ftl';
  static const double _defaultDimOpacity = 0.4;
  static const double _defaultSelectedOpacity = 1.0;
  static const double _initialSpeed = 30.0;

  String _exportPath = _defaultPath;
  double _dimOpacity = _defaultDimOpacity;
  double _selectedOpacity = _defaultSelectedOpacity;
  double _speed = _initialSpeed;

  String get exportPath => _exportPath;
  double get dimOpacity => _dimOpacity;
  double get selectedOpacity => _selectedOpacity;
  double get defaultSpeed => _speed;

  Future<void> init() async {
    try {
      final box = await Hive.openBox(_boxName);
      _exportPath = box.get(_exportPathKey, defaultValue: _defaultPath);
      _dimOpacity = (box.get(_dimOpacityKey, defaultValue: _defaultDimOpacity)).toDouble();
      _selectedOpacity = (box.get(_selectedOpacityKey, defaultValue: _defaultSelectedOpacity)).toDouble();
      _speed = (box.get(_defaultSpeedKey, defaultValue: _initialSpeed)).toDouble();
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

  Future<void> setSelectedOpacity(double opacity) async {
    try {
      _selectedOpacity = opacity.clamp(0.0, 1.0);
      final box = await Hive.openBox(_boxName);
      await box.put(_selectedOpacityKey, _selectedOpacity);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving selected opacity: $e');
    }
  }

  Future<void> setDefaultSpeed(double speed) async {
    try {
      _speed = speed.clamp(0.5, 60.0);
      final box = await Hive.openBox(_boxName);
      await box.put(_defaultSpeedKey, _speed);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving default speed: $e');
    }
  }
}
