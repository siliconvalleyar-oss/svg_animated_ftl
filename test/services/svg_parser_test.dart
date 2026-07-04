import 'package:flutter_test/flutter_test.dart';
import 'package:svg_animated_ftl/services/svg_parser.dart';
import 'package:svg_animated_ftl/models/svg_element.dart';

void main() {
  group('SvgParser', () {
    test('parse valid SVG with circle element', () {
      const svg = '<svg viewBox="0 0 200 200">'
          '<circle cx="100" cy="100" r="70"/>'
          '</svg>';

      final result = SvgParser.parse(svg);

      expect(result.isSuccess, isTrue);
      expect(result.error, isNull);
      expect(result.elements.length, equals(1));
      expect(result.elements[0].tag, equals('circle'));
      expect(result.elements[0].index, equals(0));
      expect(result.viewBoxWidth, equals(200.0));
      expect(result.viewBoxHeight, equals(200.0));
    });

    test('parse SVG with multiple element types', () {
      const svg = '<svg viewBox="0 0 400 300">'
          '<rect x="10" y="10" width="100" height="50"/>'
          '<circle cx="50" cy="50" r="40"/>'
          '<path d="M10 10L50 50"/>'
          '<ellipse cx="100" cy="100" rx="50" ry="30"/>'
          '</svg>';

      final result = SvgParser.parse(svg);

      expect(result.isSuccess, isTrue);
      expect(result.elements.length, equals(4));
      expect(result.elements[0].tag, equals('rect'));
      expect(result.elements[1].tag, equals('circle'));
      expect(result.elements[2].tag, equals('path'));
      expect(result.elements[3].tag, equals('ellipse'));
      expect(result.viewBoxWidth, equals(400.0));
      expect(result.viewBoxHeight, equals(300.0));
    });

    test('parse SVG with custom viewBox', () {
      const svg = '<svg viewBox="-50 -50 300 150">'
          '<rect x="0" y="0" width="100" height="50"/>'
          '</svg>';

      final result = SvgParser.parse(svg);

      expect(result.isSuccess, isTrue);
      expect(result.viewBoxWidth, equals(300.0));
      expect(result.viewBoxHeight, equals(150.0));
    });

    test('parse SVG with line, polyline, polygon elements', () {
      const svg = '<svg viewBox="0 0 200 200">'
          '<line x1="10" y1="10" x2="100" y2="100"/>'
          '<polyline points="10,10 50,50 100,10"/>'
          '<polygon points="10,10 50,50 100,10"/>'
          '</svg>';

      final result = SvgParser.parse(svg);

      expect(result.isSuccess, isTrue);
      expect(result.elements.length, equals(3));
      expect(result.elements[0].tag, equals('line'));
      expect(result.elements[1].tag, equals('polyline'));
      expect(result.elements[2].tag, equals('polygon'));
    });

    test('parse SVG with g (group) and text elements', () {
      const svg = '<svg viewBox="0 0 200 200">'
          '<g>'
          '<circle cx="100" cy="100" r="50"/>'
          '</g>'
          '<text x="50" y="50">Hello</text>'
          '</svg>';

      final result = SvgParser.parse(svg);

      expect(result.isSuccess, isTrue);
      expect(result.elements.length, equals(2));
      expect(result.elements[0].tag, equals('g'));
      expect(result.elements[1].tag, equals('text'));
    });

    test('return error for invalid SVG string', () {
      const svg = 'not an svg';

      final result = SvgParser.parse(svg);

      expect(result.isSuccess, isFalse);
      expect(result.error, isNotNull);
      expect(result.error, contains('Error al parsear SVG'));
    });

    test('return error for empty SVG string', () {
      const svg = '';

      final result = SvgParser.parse(svg);

      expect(result.isSuccess, isFalse);
      expect(result.error, isNotNull);
    });

    test('return error for non-svg root element', () {
      const svg = '<html><body></body></html>';

      final result = SvgParser.parse(svg);

      expect(result.isSuccess, isFalse);
      expect(result.error, contains('No se encontró un elemento SVG válido'));
    });

    test('return empty elements for SVG with no animatable tags', () {
      const svg = '<svg viewBox="0 0 200 200">'
          '<defs>'
          '<linearGradient id="grad"/>'
          '</defs>'
          '</svg>';

      final result = SvgParser.parse(svg);

      expect(result.isSuccess, isTrue);
      expect(result.elements, isEmpty);
    });

    test('use default viewBox when viewBox is missing', () {
      const svg = '<svg><circle cx="100" cy="100" r="70"/></svg>';

      final result = SvgParser.parse(svg);

      expect(result.isSuccess, isTrue);
      expect(result.viewBoxWidth, equals(200.0));
      expect(result.viewBoxHeight, equals(200.0));
    });

    test('use default viewBox when viewBox is malformed', () {
      const svg = '<svg viewBox="invalid"><circle cx="100" cy="100" r="70"/></svg>';

      final result = SvgParser.parse(svg);

      expect(result.isSuccess, isTrue);
      expect(result.viewBoxWidth, equals(200.0));
      expect(result.viewBoxHeight, equals(200.0));
    });

    test('assign sequential indices to elements', () {
      const svg = '<svg viewBox="0 0 200 200">'
          '<circle cx="50" cy="50" r="30"/>'
          '<rect x="10" y="10" width="50" height="50"/>'
          '<path d="M10 10L50 50"/>'
          '<ellipse cx="100" cy="100" rx="30" ry="20"/>'
          '</svg>';

      final result = SvgParser.parse(svg);

      expect(result.isSuccess, isTrue);
      expect(result.elements.length, equals(4));
      for (int i = 0; i < result.elements.length; i++) {
        expect(result.elements[i].index, equals(i));
      }
    });

    test('element contains the original XmlElement', () {
      const svg = '<svg viewBox="0 0 200 200">'
          '<circle cx="100" cy="100" r="70" fill="red"/>'
          '</svg>';

      final result = SvgParser.parse(svg);
      final element = result.elements[0];

      expect(element.element.getAttribute('cx'), equals('100'));
      expect(element.element.getAttribute('cy'), equals('100'));
      expect(element.element.getAttribute('r'), equals('70'));
      expect(element.element.getAttribute('fill'), equals('red'));
    });

    test('skip non-animated elements like defs, style, metadata', () {
      const svg = '<svg viewBox="0 0 200 200">'
          '<defs><linearGradient id="g"/></defs>'
          '<style>circle { fill: red; }</style>'
          '<metadata><rdf/></metadata>'
          '<circle cx="100" cy="100" r="70"/>'
          '</svg>';

      final result = SvgParser.parse(svg);

      expect(result.isSuccess, isTrue);
      expect(result.elements.length, equals(1));
      expect(result.elements[0].tag, equals('circle'));
    });
  });
}
