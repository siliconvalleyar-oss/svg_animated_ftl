import 'package:hive/hive.dart';

part 'animation_config.g.dart';

@HiveType(typeId: 0)
class AnimationConfig extends HiveObject {
  @HiveField(0)
  String? presetId;

  @HiveField(1)
  double speed;

  @HiveField(2)
  double delay;

  @HiveField(3)
  String iter;

  @HiveField(4)
  String dir;

  @HiveField(5)
  double ovalRx;

  @HiveField(6)
  double ovalRy;

  @HiveField(7)
  double ovalAngle;

  @HiveField(8)
  double arcRx;

  @HiveField(9)
  double arcRy;

  @HiveField(10)
  double directionAngle;

  @HiveField(11)
  double? pivotX;

  @HiveField(12)
  double? pivotY;

  @HiveField(13)
  List<String> extraPresets;

  @HiveField(14)
  String? trajectoryId;

  @HiveField(15)
  double opacity;

  @HiveField(16)
  double initialVelocity;

  @HiveField(17)
  double launchAngle;

  @HiveField(18)
  double gravity;

  AnimationConfig({
    this.presetId,
    this.speed = 1.0,
    this.delay = 0.0,
    this.iter = 'infinite',
    this.dir = 'normal',
    this.ovalRx = 80.0,
    this.ovalRy = 40.0,
    this.ovalAngle = 0.0,
    this.arcRx = 80.0,
    this.arcRy = 80.0,
    this.directionAngle = 0.0,
    this.pivotX,
    this.pivotY,
    List<String>? extraPresets,
    this.trajectoryId,
    this.opacity = 1.0,
    this.initialVelocity = 100.0,
    this.launchAngle = 45.0,
    this.gravity = 9.8,
  }) : extraPresets = extraPresets ?? [];

  AnimationConfig copyWith({
    String? presetId,
    double? speed,
    double? delay,
    String? iter,
    String? dir,
    double? ovalRx,
    double? ovalRy,
    double? ovalAngle,
    double? arcRx,
    double? arcRy,
    double? directionAngle,
    double? pivotX,
    double? pivotY,
    List<String>? extraPresets,
    String? trajectoryId,
    double? opacity,
    double? initialVelocity,
    double? launchAngle,
    double? gravity,
  }) {
    return AnimationConfig(
      presetId: presetId ?? this.presetId,
      speed: speed ?? this.speed,
      delay: delay ?? this.delay,
      iter: iter ?? this.iter,
      dir: dir ?? this.dir,
      ovalRx: ovalRx ?? this.ovalRx,
      ovalRy: ovalRy ?? this.ovalRy,
      ovalAngle: ovalAngle ?? this.ovalAngle,
      arcRx: arcRx ?? this.arcRx,
      arcRy: arcRy ?? this.arcRy,
      directionAngle: directionAngle ?? this.directionAngle,
      pivotX: pivotX ?? this.pivotX,
      pivotY: pivotY ?? this.pivotY,
      extraPresets: extraPresets ?? List.from(this.extraPresets),
      trajectoryId: trajectoryId ?? this.trajectoryId,
      opacity: opacity ?? this.opacity,
      initialVelocity: initialVelocity ?? this.initialVelocity,
      launchAngle: launchAngle ?? this.launchAngle,
      gravity: gravity ?? this.gravity,
    );
  }

  Map<String, dynamic> toJson() => {
    'presetId': presetId,
    'speed': speed,
    'delay': delay,
    'iter': iter,
    'dir': dir,
    'ovalRx': ovalRx,
    'ovalRy': ovalRy,
    'ovalAngle': ovalAngle,
    'arcRx': arcRx,
    'arcRy': arcRy,
    'directionAngle': directionAngle,
    'pivotX': pivotX,
    'pivotY': pivotY,
    'extraPresets': extraPresets,
    'trajectoryId': trajectoryId,
    'opacity': opacity,
    'initialVelocity': initialVelocity,
    'launchAngle': launchAngle,
    'gravity': gravity,
  };

  factory AnimationConfig.fromJson(Map<String, dynamic> json) {
    return AnimationConfig(
      presetId: json['presetId'],
      speed: (json['speed'] ?? 1.0).toDouble(),
      delay: (json['delay'] ?? 0.0).toDouble(),
      iter: json['iter'] ?? 'infinite',
      dir: json['dir'] ?? 'normal',
      ovalRx: (json['ovalRx'] ?? 80.0).toDouble(),
      ovalRy: (json['ovalRy'] ?? 40.0).toDouble(),
      ovalAngle: (json['ovalAngle'] ?? 0.0).toDouble(),
      arcRx: (json['arcRx'] ?? 80.0).toDouble(),
      arcRy: (json['arcRy'] ?? 80.0).toDouble(),
      directionAngle: (json['directionAngle'] ?? 0.0).toDouble(),
      pivotX: json['pivotX']?.toDouble(),
      pivotY: json['pivotY']?.toDouble(),
      extraPresets: List<String>.from(json['extraPresets'] ?? []),
      trajectoryId: json['trajectoryId'],
      opacity: (json['opacity'] ?? 1.0).toDouble(),
      initialVelocity: (json['initialVelocity'] ?? 100.0).toDouble(),
      launchAngle: (json['launchAngle'] ?? 45.0).toDouble(),
      gravity: (json['gravity'] ?? 9.8).toDouble(),
    );
  }
}
