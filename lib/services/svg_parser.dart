import 'package:xml/xml.dart';
import '../models/svg_element.dart';

class SvgParseResult {
  final bool isSuccess;
  final String? error;
  final List<SvgElement> elements;
  final double viewBoxWidth;
  final double viewBoxHeight;

  SvgParseResult._({
    required this.isSuccess,
    this.error,
    List<SvgElement>? elements,
    this.viewBoxWidth = 200,
    this.viewBoxHeight = 200,
  }) : elements = elements ?? [];

  factory SvgParseResult.success({
    required List<SvgElement> elements,
    required double viewBoxWidth,
    required double viewBoxHeight,
  }) {
    return SvgParseResult._(
      isSuccess: true,
      elements: elements,
      viewBoxWidth: viewBoxWidth,
      viewBoxHeight: viewBoxHeight,
    );
  }

  factory SvgParseResult.error(String error) {
    return SvgParseResult._(
      isSuccess: false,
      error: error,
    );
  }
}

class SvgParser {
  static const animatedTags = ['circle', 'rect', 'ellipse', 'path', 'line', 'polyline', 'polygon', 'g', 'text'];

  static SvgParseResult parse(String svgString) {
    try {
      final doc = XmlDocument.parse(svgString);
      final svg = doc.rootElement;

      if (svg.name.local != 'svg') {
        return SvgParseResult.error('No se encontró un elemento SVG válido');
      }

      final elements = <SvgElement>[];
      int index = 0;

      for (final child in svg.childElements) {
        if (animatedTags.contains(child.name.local)) {
          elements.add(SvgElement(
            index: index,
            tag: child.name.local,
            element: child,
          ));
          index++;
        }
      }

      final viewBox = svg.getAttribute('viewBox') ?? '0 0 200 200';
      final parts = viewBox.split(RegExp(r'[\s,]+'));
      final vbWidth = parts.length >= 3 ? (double.tryParse(parts[2]) ?? 200.0) : 200.0;
      final vbHeight = parts.length >= 4 ? (double.tryParse(parts[3]) ?? 200.0) : 200.0;

      return SvgParseResult.success(
        elements: elements,
        viewBoxWidth: vbWidth,
        viewBoxHeight: vbHeight,
      );
    } catch (e) {
      return SvgParseResult.error('Error al parsear SVG: ${e.toString()}');
    }
  }
}
