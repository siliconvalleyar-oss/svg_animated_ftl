import 'dart:math';
import 'package:flutter/material.dart';
import '../models/animation_config.dart';

class AnimationEngine {
  static Widget buildAnimation({
    required String presetId,
    required Widget child,
    required Animation<double> animation,
    required AnimationConfig config,
  }) {
    try {
      switch (presetId) {
        case 'rotate':
          return _buildRotate(child, animation);
        case 'wheel':
          return _buildWheel(child, animation);
        case 'pulse':
          return _buildPulse(child, animation);
        case 'bounce':
          return _buildBounce(child, animation, config.directionAngle);
        case 'gravity':
          return _buildGravity(child, animation, config.directionAngle);
        case 'slide':
          return _buildSlide(child, animation, config.directionAngle);
        case 'oval':
          return _buildOval(child, animation, config.ovalRx, config.ovalRy);
        case 'fade':
          return _buildFade(child, animation);
        case 'shake':
          return _buildShake(child, animation, config.directionAngle);
        case 'float':
          return _buildFloat(child, animation, config.directionAngle);
        case 'levitate':
          return _buildLevitate(child, animation, config.directionAngle);
        case 'projectile':
          return _buildProjectile(child, animation, config);
        case 'radiate':
          return _buildRadiate(child, animation, config.arcRx, config.arcRy, config.directionAngle);
        case 'spin':
          return _buildSpin(child, animation);
        case 'glow':
          return _buildGlow(child, animation);
        case 'wave-sine':
          return _buildWaveSine(child, animation, config.directionAngle);
        case 'wave-square':
          return _buildWaveSquare(child, animation, config.directionAngle);
        case 'wave-triangle':
          return _buildWaveTriangle(child, animation, config.directionAngle);
        case 'pendulum':
          return _buildPendulum(child, animation);
        case 'freefall':
          return _buildFreefall(child, animation);
        case 'elastic-bounce':
          return _buildElasticBounce(child, animation);
        case 'spring':
          return _buildSpring(child, animation);
        case 'draw':
          return _buildDraw(child, animation);
        case 'opacity-anim':
          return _buildOpacityAnim(child, animation);
        default:
          return child;
      }
    } catch (e) {
      debugPrint('Error building animation $presetId: $e');
      return child;
    }
  }

  static Widget _buildRotate(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: animation.value * 2 * pi,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget _buildWheel(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = (animation.value * 4).floorToDouble() * pi / 2;
        return Transform.rotate(angle: angle, child: child);
      },
      child: child,
    );
  }

  static Widget _buildPulse(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = 1.0 + animation.value * 0.15;
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }

  static Widget _buildBounce(Widget child, Animation<double> animation, double angle) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rad = angle * pi / 180;
        final dx = sin(rad) * animation.value * 20;
        final dy = -cos(rad) * animation.value * 20;
        return Transform.translate(offset: Offset(dx, dy), child: child);
      },
      child: child,
    );
  }

  static Widget _buildGravity(Widget child, Animation<double> animation, double angle) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rad = angle * pi / 180;
        final dx = sin(rad) * animation.value * 30;
        final dy = -cos(rad) * animation.value * 30;
        return Transform.translate(offset: Offset(dx, dy), child: child);
      },
      child: child,
    );
  }

  static Widget _buildSlide(Widget child, Animation<double> animation, double angle) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rad = angle * pi / 180;
        final dx = sin(rad) * animation.value * 80;
        final dy = -cos(rad) * animation.value * 80;
        return Transform.translate(offset: Offset(dx, dy), child: child);
      },
      child: child,
    );
  }

  static Widget _buildOval(Widget child, Animation<double> animation, double rx, double ry) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = animation.value * 2 * pi;
        final dx = cos(angle) * rx;
        final dy = sin(angle) * ry;
        return Transform.translate(offset: Offset(dx, dy), child: child);
      },
      child: child,
    );
  }

  static Widget _buildFade(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - animation.value * 0.85,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget _buildShake(Widget child, Animation<double> animation, double angle) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rad = angle * pi / 180;
        final shake = sin(animation.value * 4 * pi) * 8;
        final dx = sin(rad) * shake;
        final dy = -cos(rad) * shake;
        return Transform.translate(offset: Offset(dx, dy), child: child);
      },
      child: child,
    );
  }

  static Widget _buildFloat(Widget child, Animation<double> animation, double angle) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rad = angle * pi / 180;
        final dx = sin(rad) * animation.value * 15;
        final dy = -cos(rad) * animation.value * 15;
        return Transform.translate(offset: Offset(dx, dy), child: child);
      },
      child: child,
    );
  }

  static Widget _buildLevitate(Widget child, Animation<double> animation, double angle) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rad = angle * pi / 180;
        final dx = sin(rad) * animation.value * 15;
        final dy = -cos(rad) * animation.value * 15;
        final scale = 1.0 + animation.value * 0.05;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: child,
    );
  }

  // Tiro Oblicuo — fórmula de física:
  // x(t) = v0 * cos(θ) * t
  // y(t) = v0 * sin(θ) * t - 0.5 * g * t²
  static Widget _buildProjectile(Widget child, Animation<double> animation, AnimationConfig config) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final v0 = config.initialVelocity;
        final theta = config.launchAngle * pi / 180;
        final g = config.gravity;
        final t = animation.value * 2.0;
        final dx = v0 * cos(theta) * t;
        final dy = -(v0 * sin(theta) * t - 0.5 * g * t * t);
        return Transform.translate(offset: Offset(dx, dy), child: child);
      },
      child: child,
    );
  }

  static Widget _buildRadiate(Widget child, Animation<double> animation, double rx, double ry, double angle) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value * pi;
        final dx = cos(t) * rx;
        final dy = -sin(t) * ry;
        final rad = angle * pi / 180;
        final rdx = dx * cos(rad) - dy * sin(rad);
        final rdy = dx * sin(rad) + dy * cos(rad);
        final glow = animation.value * 0.5;
        return Transform.translate(
          offset: Offset(rdx, rdy),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: glow),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  static Widget _buildSpin(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = animation.value * 2 * pi;
        final scale = 0.85 + animation.value * 0.15;
        return Transform.rotate(
          angle: angle,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: child,
    );
  }

  static Widget _buildGlow(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final glow = animation.value * 0.8;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: glow),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget _buildWaveSine(Widget child, Animation<double> animation, double angle) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rad = angle * pi / 180;
        final wave = sin(animation.value * 2 * pi) * 40;
        final dx = sin(rad) * wave;
        final dy = -cos(rad) * wave;
        return Transform.translate(offset: Offset(dx, dy), child: child);
      },
      child: child,
    );
  }

  static Widget _buildWaveSquare(Widget child, Animation<double> animation, double angle) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rad = angle * pi / 180;
        final wave = (animation.value * 2).floor().isOdd ? 40.0 : -40.0;
        final dx = sin(rad) * wave;
        final dy = -cos(rad) * wave;
        return Transform.translate(offset: Offset(dx, dy), child: child);
      },
      child: child,
    );
  }

  static Widget _buildWaveTriangle(Widget child, Animation<double> animation, double angle) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rad = angle * pi / 180;
        final t = animation.value * 2;
        final mod = t % 2;
        final wave = (mod < 1) ? (t % 1) * 80 - 40 : (2 - mod) * 80 - 40;
        final dx = sin(rad) * wave;
        final dy = -cos(rad) * wave;
        return Transform.translate(offset: Offset(dx, dy), child: child);
      },
      child: child,
    );
  }

  // Péndulo — θ(t) = θmax * cos(ωt), ω = sqrt(g/L)
  static Widget _buildPendulum(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = sin(animation.value * 2 * pi) * 0.5;
        return Transform.rotate(angle: angle, child: child);
      },
      child: child,
    );
  }

  // Caída Libre — y(t) = 0.5 * g * t²
  static Widget _buildFreefall(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final dy = 0.5 * 9.8 * t * t * 20;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: child,
    );
  }

  // Rebote Elástico — y(t) = |sin(πt)| * amplitude
  static Widget _buildElasticBounce(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final dy = sin((animation.value * pi).abs()) * 40;
        return Transform.translate(offset: Offset(0, -dy), child: child);
      },
      child: child,
    );
  }

  // Resorte — x(t) = A * e^(-ζωt) * cos(ωdt)
  static Widget _buildSpring(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value * 4 * pi;
        final decay = exp(-0.5 * animation.value * 3);
        final dx = decay * sin(t) * 30;
        final scale = 1.0 + decay * cos(t) * 0.1;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: child,
    );
  }

  // Dibujar — revela progresivamente de izquierda a derecha
  static Widget _buildDraw(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Opacidad — oscila entre 0.2 y 1.0
  static Widget _buildOpacityAnim(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final opacity = 0.2 + (1.0 - animation.value) * 0.8;
        return Opacity(opacity: opacity, child: child);
      },
      child: child,
    );
  }

  static bool isTranslatable(String presetId) {
    return ['slide', 'bounce', 'shake', 'float', 'gravity', 'levitate',
            'projectile', 'radiate', 'wave-sine', 'wave-square', 'wave-triangle']
        .contains(presetId);
  }

  static Duration getDuration(double speed) {
    return Duration(milliseconds: (speed * 1000).toInt());
  }

  static Curve getCurve(String easing) {
    switch (easing) {
      case 'linear':
        return Curves.linear;
      case 'ease-in':
        return Curves.easeIn;
      case 'ease-out':
        return Curves.easeOut;
      case 'easeInOut':
        return Curves.easeInOut;
      case 'bounceOut':
        return Curves.bounceOut;
      case 'elasticOut':
        return Curves.elasticOut;
      default:
        return Curves.easeInOut;
    }
  }
}
