class BackgroundImage {
  String id;
  String name;
  String path;
  double x;
  double y;
  double width;
  double height;
  double opacity;
  bool hidden;
  int zIndex;

  BackgroundImage({
    required this.id,
    required this.name,
    required this.path,
    this.x = 50,
    this.y = 50,
    this.width = 400,
    this.height = 300,
    this.opacity = 0.8,
    this.hidden = false,
    this.zIndex = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'opacity': opacity,
    'hidden': hidden,
    'zIndex': zIndex,
  };

  factory BackgroundImage.fromJson(Map<String, dynamic> json) {
    return BackgroundImage(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      x: (json['x'] ?? 50).toDouble(),
      y: (json['y'] ?? 50).toDouble(),
      width: (json['width'] ?? 400).toDouble(),
      height: (json['height'] ?? 300).toDouble(),
      opacity: (json['opacity'] ?? 0.8).toDouble(),
      hidden: json['hidden'] ?? false,
      zIndex: json['zIndex'] ?? 0,
    );
  }
}
