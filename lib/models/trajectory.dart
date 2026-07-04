class Trajectory {
  String name;
  List<TrajectoryPoint> points;

  Trajectory({required this.name, List<TrajectoryPoint>? points})
      : points = points ?? [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'points': points.map((e) => e.toJson()).toList(),
  };

  factory Trajectory.fromJson(Map<String, dynamic> json) {
    return Trajectory(
      name: json['name'],
      points: (json['points'] as List?)
          ?.map((e) => TrajectoryPoint.fromJson(e)).toList() ?? [],
    );
  }
}

class TrajectoryPoint {
  double x;
  double y;

  TrajectoryPoint({required this.x, required this.y});

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory TrajectoryPoint.fromJson(Map<String, dynamic> json) {
    return TrajectoryPoint(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
    );
  }
}
