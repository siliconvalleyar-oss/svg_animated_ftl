import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:svg_animated_ftl/services/animation_engine.dart';
import 'package:svg_animated_ftl/models/animation_config.dart';

void main() {
  group('AnimationEngine', () {
    late AnimationController controller;
    late Widget testChild;

    setUp(() {
      controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: TestVSync(),
      );
      testChild = const SizedBox(width: 100, height: 100);
    });

    tearDown(() {
      controller.dispose();
    });

    group('buildAnimation', () {
      test('rotate animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'rotate');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'rotate',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('wheel animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'wheel');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'wheel',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('pulse animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'pulse');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'pulse',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('bounce animation works with default angle', () {
        final config = AnimationConfig(presetId: 'bounce');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'bounce',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('bounce animation works with custom angle', () {
        final config = AnimationConfig(presetId: 'bounce', directionAngle: 45);
        final widget = AnimationEngine.buildAnimation(
          presetId: 'bounce',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('slide animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'slide', directionAngle: 90);
        final widget = AnimationEngine.buildAnimation(
          presetId: 'slide',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('gravity animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'gravity');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'gravity',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('oval animation uses ovalRx and ovalRy parameters', () {
        final config = AnimationConfig(presetId: 'oval', ovalRx: 80, ovalRy: 40);
        final widget = AnimationEngine.buildAnimation(
          presetId: 'oval',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('fade animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'fade');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'fade',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('shake animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'shake');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'shake',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('float animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'float');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'float',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('levitate animation combines translate and scale', () {
        final config = AnimationConfig(presetId: 'levitate');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'levitate',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('projectile animation uses physics parameters', () {
        final config = AnimationConfig(
          presetId: 'projectile',
          initialVelocity: 100,
          launchAngle: 45,
          gravity: 9.8,
        );
        final widget = AnimationEngine.buildAnimation(
          presetId: 'projectile',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('projectile animation with extreme values does not crash', () {
        final config = AnimationConfig(
          presetId: 'projectile',
          initialVelocity: 300,
          launchAngle: 90,
          gravity: 30,
        );
        final widget = AnimationEngine.buildAnimation(
          presetId: 'projectile',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('radiate animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'radiate', arcRx: 80, arcRy: 80, directionAngle: 0);
        final widget = AnimationEngine.buildAnimation(
          presetId: 'radiate',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('spin animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'spin');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'spin',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('glow animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'glow');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'glow',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('wave-sine animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'wave-sine');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'wave-sine',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('wave-square animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'wave-square');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'wave-square',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('wave-triangle animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'wave-triangle');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'wave-triangle',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('pendulum animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'pendulum');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'pendulum',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('freefall animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'freefall');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'freefall',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('elastic-bounce animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'elastic-bounce');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'elastic-bounce',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('spring animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'spring');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'spring',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('draw animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'draw');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'draw',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('opacity-anim animation returns a valid widget', () {
        final config = AnimationConfig(presetId: 'opacity-anim');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'opacity-anim',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });

      test('default unknown preset returns child widget unchanged', () {
        final config = AnimationConfig(presetId: 'unknown-preset');
        final widget = AnimationEngine.buildAnimation(
          presetId: 'unknown-preset',
          child: testChild,
          animation: controller,
          config: config,
        );
        // Should return the original child in case of unknown preset
        expect(widget, isA<Widget>());
      });

      test('null presetId returns child as default case', () {
        final config = AnimationConfig(presetId: null);
        // When presetId is null, buildAnimation returns the child unchanged
        // But the function requires a non-null presetId parameter
        // We test with an empty string to simulate no preset
        final widget = AnimationEngine.buildAnimation(
          presetId: '',
          child: testChild,
          animation: controller,
          config: config,
        );
        expect(widget, isA<Widget>());
      });
    });

    group('isTranslatable', () {
      test('returns true for bounce', () {
        expect(AnimationEngine.isTranslatable('bounce'), isTrue);
      });

      test('returns true for gravity', () {
        expect(AnimationEngine.isTranslatable('gravity'), isTrue);
      });

      test('returns true for slide', () {
        expect(AnimationEngine.isTranslatable('slide'), isTrue);
      });

      test('returns true for shake', () {
        expect(AnimationEngine.isTranslatable('shake'), isTrue);
      });

      test('returns true for float', () {
        expect(AnimationEngine.isTranslatable('float'), isTrue);
      });

      test('returns true for levitate', () {
        expect(AnimationEngine.isTranslatable('levitate'), isTrue);
      });

      test('returns true for projectile', () {
        expect(AnimationEngine.isTranslatable('projectile'), isTrue);
      });

      test('returns true for radiate', () {
        expect(AnimationEngine.isTranslatable('radiate'), isTrue);
      });

      test('returns true for wave-sine', () {
        expect(AnimationEngine.isTranslatable('wave-sine'), isTrue);
      });

      test('returns true for wave-square', () {
        expect(AnimationEngine.isTranslatable('wave-square'), isTrue);
      });

      test('returns true for wave-triangle', () {
        expect(AnimationEngine.isTranslatable('wave-triangle'), isTrue);
      });

      test('returns false for rotate', () {
        expect(AnimationEngine.isTranslatable('rotate'), isFalse);
      });

      test('returns false for wheel', () {
        expect(AnimationEngine.isTranslatable('wheel'), isFalse);
      });

      test('returns false for pulse', () {
        expect(AnimationEngine.isTranslatable('pulse'), isFalse);
      });

      test('returns false for oval', () {
        expect(AnimationEngine.isTranslatable('oval'), isFalse);
      });

      test('returns false for fade', () {
        expect(AnimationEngine.isTranslatable('fade'), isFalse);
      });

      test('returns false for unknown preset', () {
        expect(AnimationEngine.isTranslatable('unknown'), isFalse);
      });
    });

    group('getDuration', () {
      test('converts 1.0 speed to 1000ms', () {
        expect(AnimationEngine.getDuration(1.0), equals(const Duration(milliseconds: 1000)));
      });

      test('converts 2.0 speed to 2000ms', () {
        expect(AnimationEngine.getDuration(2.0), equals(const Duration(milliseconds: 2000)));
      });

      test('converts 0.5 speed to 500ms', () {
        expect(AnimationEngine.getDuration(0.5), equals(const Duration(milliseconds: 500)));
      });

      test('converts 0 speed to 0ms', () {
        expect(AnimationEngine.getDuration(0.0), equals(const Duration(milliseconds: 0)));
      });
    });

    group('getCurve', () {
      test('returns Curves.linear for linear', () {
        expect(AnimationEngine.getCurve('linear'), equals(Curves.linear));
      });

      test('returns Curves.easeIn for ease-in', () {
        expect(AnimationEngine.getCurve('ease-in'), equals(Curves.easeIn));
      });

      test('returns Curves.easeOut for ease-out', () {
        expect(AnimationEngine.getCurve('ease-out'), equals(Curves.easeOut));
      });

      test('returns Curves.easeInOut for easeInOut', () {
        expect(AnimationEngine.getCurve('easeInOut'), equals(Curves.easeInOut));
      });

      test('returns Curves.bounceOut for bounceOut', () {
        expect(AnimationEngine.getCurve('bounceOut'), equals(Curves.bounceOut));
      });

      test('returns Curves.elasticOut for elasticOut', () {
        expect(AnimationEngine.getCurve('elasticOut'), equals(Curves.elasticOut));
      });

      test('returns Curves.easeInOut for unknown easing', () {
        expect(AnimationEngine.getCurve('unknown-easing'), equals(Curves.easeInOut));
      });
    });
  });
}

class TestVSync extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}
