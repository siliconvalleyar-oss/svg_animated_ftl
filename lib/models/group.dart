import 'animation_config.dart';

class Group {
  String name;
  String color;
  List<int> elements;
  AnimationConfig config;

  Group({
    required this.name,
    required this.color,
    List<int>? elements,
    AnimationConfig? config,
  })  : elements = elements ?? [],
        config = config ?? AnimationConfig();

  Map<String, dynamic> toJson() => {
    'name': name,
    'color': color,
    'elements': elements,
    'config': config.toJson(),
  };

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      name: json['name'],
      color: json['color'],
      elements: List<int>.from(json['elements'] ?? []),
      config: AnimationConfig.fromJson(json['config'] ?? {}),
    );
  }
}
