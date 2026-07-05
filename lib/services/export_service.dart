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

      String keyframesAll = '';
      String elementStyles = '';

      // Add data-anim-index attributes to elements
      final animTags = ['circle', 'rect', 'ellipse', 'path', 'line', 'polyline', 'polygon', 'g', 'text'];
      int elemIndex = 0;
      for (final child in svg.childElements) {
        if (animTags.contains(child.name.local)) {
          child.setAttribute('data-anim-index', elemIndex.toString());
          elemIndex++;
        }
      }

      elementAnimations.forEach((index, config) {
        if (config.presetId == null) return;

        final keyframes = _generateKeyframes(index, config, trajectories);
        keyframesAll += '$keyframes\n\n';

        elementStyles += _generateElementStyle(index, config);
      });

      if (keyframesAll.isEmpty && elementStyles.isEmpty) {
        return originalSvg;
      }

      final styleContent = '$keyframesAll\n$elementStyles';

      final styleElement = XmlElement(
        XmlName('style'),
        [],
        [XmlText(styleContent)],
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
        return '@keyframes svgRotate_$index {\n  from { transform: rotate(0deg); }\n  to { transform: rotate(360deg); }\n}';
      case 'wheel':
        return '@keyframes svgWheel_$index {\n  0% { transform: rotate(0deg); }\n  25% { transform: rotate(90deg); }\n  50% { transform: rotate(180deg); }\n  75% { transform: rotate(270deg); }\n  100% { transform: rotate(360deg); }\n}';
      case 'pulse':
        return '@keyframes svgPulse_$index {\n  0%, 100% { transform: scale(1); }\n  50% { transform: scale(1.15); }\n}';
      case 'bounce':
        if (config.directionAngle != 0) {
          return _generateDirectionalKeyframes('bounce', index, config);
        }
        return '@keyframes svgBounce_$index {\n  0%, 100% { transform: translateY(0); }\n  50% { transform: translateY(-20px); }\n}';
      case 'gravity':
        return '@keyframes svgGravity_$index {\n  0% { transform: translateY(-30px); }\n  100% { transform: translateY(0); }\n}';
      case 'slide':
        if (config.directionAngle != 0) {
          return _generateDirectionalKeyframes('slide', index, config);
        }
        return '@keyframes svgSlide_$index {\n  0%, 100% { transform: translateX(0); }\n  50% { transform: translateX(80px); }\n}';
      case 'oval':
        return '@keyframes svgOval_$index {\n  0% { transform: translate(0, 0); }\n  25% { transform: translate(${config.ovalRx}px, 0); }\n  50% { transform: translate(0, 0); }\n  75% { transform: translate(0, ${config.ovalRy}px); }\n  100% { transform: translate(0, 0); }\n}';
      case 'fade':
        return '@keyframes svgFade_$index {\n  0%, 100% { opacity: 1; }\n  50% { opacity: 0.15; }\n}';
      case 'shake':
        return '@keyframes svgShake_$index {\n  0%, 100% { transform: translateX(0); }\n  25% { transform: translateX(-8px); }\n  75% { transform: translateX(8px); }\n}';
      case 'float':
        return '@keyframes svgFloat_$index {\n  0%, 100% { transform: translateY(0); }\n  50% { transform: translateY(-15px); }\n}';
      case 'levitate':
        return '@keyframes svgLevitate_$index {\n  0%, 100% { transform: translateY(0) scale(1); }\n  50% { transform: translateY(-15px) scale(1.05); }\n}';
      case 'spin':
        return '@keyframes svgSpin_$index {\n  0% { transform: rotate(0deg) scale(0.85); }\n  100% { transform: rotate(360deg) scale(0.85); }\n}';
      case 'glow':
        return '@keyframes svgGlow_$index {\n  0%, 100% { filter: drop-shadow(0 0 0px rgba(255, 200, 0, 0)); }\n  50% { filter: drop-shadow(0 0 15px rgba(255, 200, 0, 0.8)); }\n}';
      case 'wave-sine':
        if (config.directionAngle != 0) {
          return _generateDirectionalKeyframes('wave-sine', index, config);
        }
        return '@keyframes svgWaveSine_$index {\n  0%, 100% { transform: translateX(0); }\n  25% { transform: translateX(40px); }\n  50% { transform: translateX(0); }\n  75% { transform: translateX(-40px); }\n}';
      case 'wave-square':
        if (config.directionAngle != 0) {
          return _generateDirectionalKeyframes('wave-square', index, config);
        }
        return '@keyframes svgWaveSquare_$index {\n  0%, 49.9% { transform: translateX(-40px); }\n  50%, 100% { transform: translateX(40px); }\n}';
      case 'wave-triangle':
        if (config.directionAngle != 0) {
          return _generateDirectionalKeyframes('wave-triangle', index, config);
        }
        return '@keyframes svgWaveTriangle_$index {\n  0% { transform: translateX(-40px); }\n  50% { transform: translateX(40px); }\n  100% { transform: translateX(-40px); }\n}';
      case 'draw':
        return '@keyframes svgDraw_$index {\n  0% { clip-path: inset(0 100% 0 0); }\n  100% { clip-path: inset(0 0% 0 0); }\n}';
      case 'pendulum':
        return '@keyframes svgPendulum_$index {\n  0%, 100% { transform: rotate(-28.6deg); }\n  50% { transform: rotate(28.6deg); }\n}';
      case 'freefall':
        return '@keyframes svgFreefall_$index {\n  0% { transform: translateY(0); }\n  100% { transform: translateY(196px); }\n}';
      case 'elastic-bounce':
        return '@keyframes svgElasticBounce_$index {\n  0%, 100% { transform: translateY(0); }\n  50% { transform: translateY(-40px); }\n}';
      case 'spring':
        return '@keyframes svgSpring_$index {\n  0%, 100% { transform: translateX(0) scale(1); }\n  25% { transform: translateX(30px) scale(1.1); }\n  75% { transform: translateX(-30px) scale(0.9); }\n}';
      case 'opacity-anim':
        return '@keyframes svgOpacityAnim_$index {\n  0%, 100% { opacity: 1; }\n  50% { opacity: 0.2; }\n}';
      case 'radiate':
        if (config.directionAngle != 0) {
          return _generateDirectionalKeyframes('radiate', index, config);
        }
        return '@keyframes svgRadiate_$index {\n  0%, 100% { transform: translate(0, 0); }\n  25% { transform: translate(${config.arcRx}px, 0); }\n  75% { transform: translate(-${config.arcRx}px, 0); }\n}';
      case 'projectile':
        final rad = config.launchAngle * pi / 180;
        final v0 = config.initialVelocity;
        final g = config.gravity;
        final range = (v0 * v0 * sin(2 * rad) / g).clamp(10.0, 500.0);
        final height = (v0 * v0 * sin(rad) * sin(rad) / (2 * g)).clamp(10.0, 300.0);
        return '@keyframes svgProjectile_$index {\n  0% { transform: translate(0, 0); }\n  50% { transform: translate(${range / 2}px, -${height}px); }\n  100% { transform: translate(${range}px, 0); }\n}';
      default:
        return '';
    }
  }

  static String _generateDirectionalKeyframes(String presetId, int index, AnimationConfig config) {
    final rad = config.directionAngle * pi / 180;
    final sinA = sin(rad);
    final cosA = cos(rad);

    switch (presetId) {
      case 'bounce':
        return '@keyframes bounce_$index {\n  0%, 100% { transform: translate(0, 0); }\n  50% { transform: translate(${sinA * 20}px, ${-cosA * 20}px); }\n}';
      case 'slide':
        return '@keyframes slide_$index {\n  0%, 100% { transform: translate(0, 0); }\n  50% { transform: translate(${sinA * 80}px, ${-cosA * 80}px); }\n}';
      case 'wave-sine':
        return '@keyframes waveSine_$index {\n  0%, 100% { transform: translate(0, 0); }\n  25% { transform: translate(${sinA * 40}px, ${-cosA * 40}px); }\n  50% { transform: translate(0, 0); }\n  75% { transform: translate(${-sinA * 40}px, ${cosA * 40}px); }\n}';
      case 'wave-square':
        return '@keyframes waveSquare_$index {\n  0%, 49.9% { transform: translate(${-sinA * 40}px, ${cosA * 40}px); }\n  50%, 100% { transform: translate(${sinA * 40}px, ${-cosA * 40}px); }\n}';
      case 'wave-triangle':
        return '@keyframes waveTriangle_$index {\n  0% { transform: translate(${-sinA * 40}px, ${cosA * 40}px); }\n  50% { transform: translate(${sinA * 40}px, ${-cosA * 40}px); }\n  100% { transform: translate(${-sinA * 40}px, ${cosA * 40}px); }\n}';
      case 'radiate':
        return '@keyframes radiate_$index {\n  0%, 100% { transform: translate(0, 0); }\n  25% { transform: translate(${sinA * config.arcRx}px, ${-cosA * config.arcRx}px); }\n  75% { transform: translate(${-sinA * config.arcRx}px, ${cosA * config.arcRx}px); }\n}';
      case 'shake':
        return '@keyframes shake_$index {\n  0%, 100% { transform: translate(0, 0); }\n  25% { transform: translate(${sinA * -8}px, ${cosA * 8}px); }\n  75% { transform: translate(${sinA * 8}px, ${-cosA * 8}px); }\n}';
      case 'float':
        return '@keyframes float_$index {\n  0%, 100% { transform: translate(0, 0); }\n  50% { transform: translate(${sinA * -15}px, ${cosA * 15}px); }\n}';
      case 'levitate':
        return '@keyframes levitate_$index {\n  0%, 100% { transform: translate(0, 0) scale(1); }\n  50% { transform: translate(${sinA * -15}px, ${cosA * 15}px) scale(1.05); }\n}';
      default:
        return '';
    }
  }

  static String _generateElementStyle(int index, AnimationConfig config) {
    String animName;
    switch (config.presetId) {
      case 'rotate':
        animName = 'svgRotate_$index';
        break;
      case 'wheel':
        animName = 'svgWheel_$index';
        break;
      case 'pulse':
        animName = 'svgPulse_$index';
        break;
      case 'bounce':
        animName = config.directionAngle != 0 ? 'bounce_$index' : 'svgBounce_$index';
        break;
      case 'gravity':
        animName = 'svgGravity_$index';
        break;
      case 'slide':
        animName = config.directionAngle != 0 ? 'slide_$index' : 'svgSlide_$index';
        break;
      case 'oval':
        animName = 'svgOval_$index';
        break;
      case 'fade':
        animName = 'svgFade_$index';
        break;
      case 'shake':
        animName = config.directionAngle != 0 ? 'shake_$index' : 'svgShake_$index';
        break;
      case 'float':
        animName = config.directionAngle != 0 ? 'float_$index' : 'svgFloat_$index';
        break;
      case 'levitate':
        animName = config.directionAngle != 0 ? 'levitate_$index' : 'svgLevitate_$index';
        break;
      case 'spin':
        animName = 'svgSpin_$index';
        break;
      case 'glow':
        animName = 'svgGlow_$index';
        break;
      case 'wave-sine':
        animName = config.directionAngle != 0 ? 'waveSine_$index' : 'svgWaveSine_$index';
        break;
      case 'wave-square':
        animName = config.directionAngle != 0 ? 'waveSquare_$index' : 'svgWaveSquare_$index';
        break;
      case 'wave-triangle':
        animName = config.directionAngle != 0 ? 'waveTriangle_$index' : 'svgWaveTriangle_$index';
        break;
      case 'draw':
        animName = 'svgDraw_$index';
        break;
      case 'pendulum':
        animName = 'svgPendulum_$index';
        break;
      case 'freefall':
        animName = 'svgFreefall_$index';
        break;
      case 'elastic-bounce':
        animName = 'svgElasticBounce_$index';
        break;
      case 'spring':
        animName = 'svgSpring_$index';
        break;
      case 'opacity-anim':
        animName = 'svgOpacityAnim_$index';
        break;
      case 'radiate':
        animName = config.directionAngle != 0 ? 'radiate_$index' : 'svgRadiate_$index';
        break;
      case 'projectile':
        animName = 'svgProjectile_$index';
        break;
      default:
        return '';
    }

    final iteration = config.iter == 'infinite' ? 'infinite' : config.iter;
    final easing = _mapEasing(config.presetId!);

    return '[data-anim-index="$index"] {\n  animation: $animName ${config.speed}s $easing $iteration ${config.delay}s ${config.dir};\n  transform-origin: center;\n  transform-box: fill-box;\n}\n';
  }

  static String _mapEasing(String presetId) {
    switch (presetId) {
      case 'rotate':
      case 'wheel':
      case 'oval':
        return 'linear';
      case 'pulse':
      case 'fade':
      case 'bounce':
      case 'slide':
      case 'shake':
      case 'float':
      case 'levitate':
      case 'wave-sine':
      case 'wave-triangle':
      case 'radiate':
      case 'elastic-bounce':
      case 'spring':
      case 'opacity-anim':
        return 'ease-in-out';
      case 'gravity':
      case 'freefall':
        return 'ease-in';
      case 'glow':
      case 'spin':
      case 'pendulum':
        return 'linear';
      case 'wave-square':
        return 'steps(2, end)';
      case 'draw':
        return 'ease-in-out';
      default:
        return 'linear';
    }
  }
}
