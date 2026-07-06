import 'dart:ui' show Offset;
import 'animation_config.dart';
import 'group.dart';
import 'trajectory.dart';
import 'background_image.dart';

class Workspace {
  final String id;
  String name;
  String? originalSvgString;
  Map<int, AnimationConfig> elementAnimations;
  Map<String, Group> elementGroups;
  Map<int, Offset> elementOffsets;
  int? selectedElementIndex;
  List<int> selectedGroupElements;
  bool isMultiSelectMode;
  String? selectedGroupId;
  int nextGroupId;
  Map<String, Trajectory> trajectories;
  int nextTrajId;
  bool isTrajectoryMode;
  String? selectedTrajectoryId;
  List<BackgroundImage> backgroundImages;
  double zoomLevel;
  bool isPiecesMode;
  int piecesSelectedIndex;
  bool boundaryActive;
  List<Map<String, dynamic>> undoStack;
  int undoIndex;

  Workspace({
    required this.id,
    required this.name,
    this.originalSvgString,
    Map<int, AnimationConfig>? elementAnimations,
    Map<String, Group>? elementGroups,
    this.selectedElementIndex,
    List<int>? selectedGroupElements,
    this.isMultiSelectMode = false,
    this.selectedGroupId,
    this.nextGroupId = 1,
    Map<int, Offset>? elementOffsets,
    Map<String, Trajectory>? trajectories,
    this.nextTrajId = 1,
    this.isTrajectoryMode = false,
    this.selectedTrajectoryId,
    List<BackgroundImage>? backgroundImages,
    this.zoomLevel = 1.0,
    this.isPiecesMode = false,
    this.piecesSelectedIndex = -1,
    this.boundaryActive = false,
    List<Map<String, dynamic>>? undoStack,
    this.undoIndex = -1,
  })  : elementAnimations = elementAnimations ?? {},
        elementGroups = elementGroups ?? {},
        elementOffsets = elementOffsets ?? {},
        selectedGroupElements = selectedGroupElements ?? [],
        trajectories = trajectories ?? {},
        backgroundImages = backgroundImages ?? [],
        undoStack = undoStack ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'originalSvgString': originalSvgString,
    'elementAnimations': elementAnimations.map((k, v) => MapEntry(k.toString(), v.toJson())),
    'elementGroups': elementGroups.map((k, v) => MapEntry(k, v.toJson())),
    'elementOffsets': elementOffsets.map((k, v) => MapEntry(k.toString(), {'dx': v.dx, 'dy': v.dy})),
    'selectedElementIndex': selectedElementIndex,
    'selectedGroupElements': selectedGroupElements,
    'isMultiSelectMode': isMultiSelectMode,
    'selectedGroupId': selectedGroupId,
    'nextGroupId': nextGroupId,
    'trajectories': trajectories.map((k, v) => MapEntry(k, v.toJson())),
    'nextTrajId': nextTrajId,
    'isTrajectoryMode': isTrajectoryMode,
    'selectedTrajectoryId': selectedTrajectoryId,
    'backgroundImages': backgroundImages.map((e) => e.toJson()).toList(),
    'zoomLevel': zoomLevel,
    'isPiecesMode': isPiecesMode,
    'piecesSelectedIndex': piecesSelectedIndex,
    'boundaryActive': boundaryActive,
    'undoStack': undoStack,
    'undoIndex': undoIndex,
  };

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      name: json['name'],
      originalSvgString: json['originalSvgString'],
      elementAnimations: (json['elementAnimations'] as Map?)
              ?.cast<String, dynamic>()
              .map((k, v) => MapEntry(int.parse(k), AnimationConfig.fromJson(v))) ?? {},
      elementGroups: (json['elementGroups'] as Map?)
              ?.cast<String, dynamic>()
              .map((k, v) => MapEntry(k, Group.fromJson(v))) ?? {},
      selectedElementIndex: json['selectedElementIndex'],
      selectedGroupElements: List<int>.from(json['selectedGroupElements'] ?? []),
      isMultiSelectMode: json['isMultiSelectMode'] ?? false,
      selectedGroupId: json['selectedGroupId'],
      nextGroupId: json['nextGroupId'] ?? 1,
      elementOffsets: (json['elementOffsets'] as Map?)
              ?.cast<String, dynamic>()
              .map((k, v) => MapEntry(int.parse(k), Offset((v['dx'] as num).toDouble(), (v['dy'] as num).toDouble()))) ?? {},
      trajectories: (json['trajectories'] as Map?)
              ?.cast<String, dynamic>()
              .map((k, v) => MapEntry(k, Trajectory.fromJson(v))) ?? {},
      nextTrajId: json['nextTrajId'] ?? 1,
      isTrajectoryMode: json['isTrajectoryMode'] ?? false,
      selectedTrajectoryId: json['selectedTrajectoryId'],
      backgroundImages: (json['backgroundImages'] as List?)
          ?.map((e) => BackgroundImage.fromJson(e)).toList() ?? [],
      zoomLevel: (json['zoomLevel'] ?? 1.0).toDouble(),
      isPiecesMode: json['isPiecesMode'] ?? false,
      piecesSelectedIndex: json['piecesSelectedIndex'] ?? -1,
      boundaryActive: json['boundaryActive'] ?? false,
      undoStack: List<Map<String, dynamic>>.from(json['undoStack'] ?? []),
      undoIndex: json['undoIndex'] ?? -1,
    );
  }
}
