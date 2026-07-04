import 'package:xml/xml.dart';

class SvgElement {
  final int index;
  final String tag;
  final XmlElement element;

  SvgElement({
    required this.index,
    required this.tag,
    required this.element,
  });
}
