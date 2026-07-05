import 'dart:math';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import '../models/animation_config.dart';
import '../models/trajectory.dart';

class ExportService {
  static Future<String> generateAnimatedSvg({
    required String originalSvg,
    required Map<int, AnimationConfig> elementAnimations,
    required Map<String, Trajectory> trajectories,
  }) async {
    try {
      final doc = XmlDocument.parse(originalSvg);
      final svg = doc.rootElement;

      svg.removeAttribute('class');

      String embeddedStyle = '';
      String elementStyles = '';

      elementAnimations.forEach((index, config) {
        if (config.presetId == null) return;

        final keyframes = _generateKeyframes(index, config, trajectories);
        embeddedStyle += '$keyframes\n';

        elementStyles += _generateElementStyle(index, config);
      });

      final styleElement = XmlElement(
        XmlName('style'),
        [],
        [XmlText('$embeddedStyle\n$elementStyles')],
      );
      svg.children.insert(0, styleElement);

      return '<?xml version="1.0" encoding="UTF-8"?>\n${doc.toXmlString(pretty: true, indent: '  ')}';
    } catch (e) {
      debugPrint('Error generating SVG: $e');
      return originalSvg;
    }
  }

  static String _generateKeyframes(int index, AnimationConfig config, Map<String, Trajectory> trajectories) {
    switch (config.presetId) {
      case 'rotate':
        return '@keyframes svgRotate_$index { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }';
      case 'wheel':
        return '@keyframes svgWheel_$index { 0% { transform: rotate(0deg); } 25% { transform: rotate(90deg); } 50% { transform: rotate(180deg); } 75% { transform: rotate(270deg); } 100% { transform: rotate(360deg); } }';
      case 'pulse':
        return '@keyframes svgPulse_$index { 0%,100% { transform: scale(1); } 50% { transform: scale(1.15); } }';
      case 'bounce':
        if (config.directionAngle != 0) {
          return _generateDirectionalKeyframes('bounce', index, config);
        }
        return '@keyframes svgBounce_$index { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-20px); } }';
      case 'gravity':
        return '@keyframes svgGravity_$index { 0% { transform: translateY(-30px); } 100% { transform: translateY(0); } }';
      case 'slide':
        if (config.directionAngle != 0) {
          return _generateDirectionalKeyframes('slide', index, config);
        }
        return '@keyframes svgSlide_$index { 0%,100% { transform: translateX(0); } 50% { transform: translateX(80px); } }';
      case 'oval':
        return '@keyframes svgOval_$index { 0% { transform: translate(0,0); } 25% { transform: translate(${config.ovalRx}px,0); } 50% { transform: translate(0,0); } 75% { transform: translate(0,${config.ovalRy}px); } 100% { transform: translate(0,0); } }';
      case 'fade':
        return '@keyframes svgFade_$index { 0%,100% { opacity: 1; } 50% { opacity: 0.15; } }';
      case 'shake':
        return '@keyframes svgShake_$index { 0%,100% { transform: translateX(0); } 25% { transform: translateX(-8px); } 75% { transform: translateX(8px); } }';
      case 'float':
        return '@keyframes svgFloat_$index { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-15px); } }';
      case 'levitate':
        return '@keyframes svgLevitate_$index { 0%,100% { transform: translateY(0) scale(1); } 50% { transform: translateY(-15px) scale(1.05); } }';
      case 'spin':
        return '@keyframes svgSpin_$index { 0% { transform: rotate(0deg) scale(0.85); } 100% { transform: rotate(360deg) scale(0.85); } }';
      case 'glow':
        return '@keyframes svgGlow_$index { 0%,100% { filter: drop-shadow(0 0 0px amber); } 50% { filter: drop-shadow(0 0 15px amber); } }';
      case 'wave-sine':
        return '@keyframes svgWaveSine_$index { 0%,100% { transform: translateX(0); } 25% { transform: translateX(40px); } 50% { transform: translateX(0); } 75% { transform: translateX(-40px); } }';
      case 'wave-square':
        return '@keyframes svgWaveSquare_$index { 0%,49.9% { transform: translateX(-40px); } 50%,100% { transform: translateX(40px); } }';
      case 'draw':
        return '@keyframes svgDraw_$index { 0% { clip-path: inset(0 100% 0 0); } 100% { clip-path: inset(0 0% 0 0); } }';
      case 'wave-triangle':
        return '@keyframes svgWaveTriangle_$index { 0% { transform: translateX(-40px); } 50% { transform: translateX(40px); } 100% { transform: translateX(-40px); } }';
      default:
        return '';
    }
  }

  static String _generateDirectionalKeyframes(String presetId, int index, AnimationConfig config) {
    final rad = config.directionAngle * pi / 180;
    final cosA = cos(rad);
    final sinA = sin(rad);

    switch (presetId) {
      case 'bounce':
        return '@keyframes bounce_${index}_${config.directionAngle.toInt()} { 0%,100% { transform: translate(0,0); } 50% { transform: translate(${sinA * 20}px, ${-cosA * 20}px); } }';
      case 'slide':
        return '@keyframes slide_${index}_${config.directionAngle.toInt()} { 0%,100% { transform: translate(0,0); } 50% { transform: translate(${sinA * 80}px, ${-cosA * 80}px); } }';
      default:
        return '';
    }
  }

  static String _generateElementStyle(int index, AnimationConfig config) {
    final animName = config.presetId == 'rotate' ? 'svgRotate_$index' :
                     config.presetId == 'pulse' ? 'svgPulse_$index' :
                     config.presetId == 'bounce' && config.directionAngle != 0 ? 'bounce_${index}_${config.directionAngle.toInt()}' :
                     'svg${config.presetId!.capitalize()}_$index';

    return '[data-anim-index="$index"] { animation: $animName ${config.speed}s ${config.dir}; animation-delay: ${config.delay}s; }';
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
