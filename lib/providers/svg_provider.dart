import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/animation_config.dart';
import '../models/workspace.dart';
import '../models/group.dart';
import '../models/trajectory.dart';

class SvgProvider extends ChangeNotifier {
  static const _boxName = 'svg_animator';
  static const _workspacesKey = 'workspaces';

  final _uuid = const Uuid();
  List<Workspace> _workspaces = [];
  int _activeWorkspaceIndex = 0;
  bool _animationPlaying = true;

  Workspace get activeWorkspace => _workspaces[_activeWorkspaceIndex];
  List<Workspace> get workspaces => _workspaces;
  int get activeWorkspaceIndex => _activeWorkspaceIndex;
  bool get animationPlaying => _animationPlaying;
  String? get currentSvgString => activeWorkspace.originalSvgString;
  Map<int, AnimationConfig> get elementAnimations => activeWorkspace.elementAnimations;

  Future<void> init() async {
    try {
      await _loadWorkspaces();
      if (_workspaces.isEmpty) {
        _workspaces.add(Workspace(
          id: _generateId(),
          name: 'Espacio 1',
        ));
      }
      // Load example SVG if no SVG is loaded
      if (activeWorkspace.originalSvgString == null) {
        try {
          final exampleSvg = await rootBundle.loadString('assets/example.svg');
          activeWorkspace.originalSvgString = exampleSvg;
        } catch (e) {
          debugPrint('Could not load example SVG: $e');
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing: $e');
      _workspaces = [Workspace(id: _generateId(), name: 'Espacio 1')];
      notifyListeners();
    }
  }

  void addWorkspace() {
    try {
      _saveActiveWorkspace();
      final ws = Workspace(
        id: _generateId(),
        name: 'Espacio ${_workspaces.length + 1}',
      );
      _workspaces.add(ws);
      _activeWorkspaceIndex = _workspaces.length - 1;
      _saveWorkspaces();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding workspace: $e');
    }
  }

  void switchWorkspace(int index) {
    if (index == _activeWorkspaceIndex) return;
    if (index < 0 || index >= _workspaces.length) return;
    try {
      _saveActiveWorkspace();
      _activeWorkspaceIndex = index;
      notifyListeners();
    } catch (e) {
      debugPrint('Error switching workspace: $e');
    }
  }

  void removeWorkspace(int index) {
    if (_workspaces.length <= 1) return;
    if (index < 0 || index >= _workspaces.length) return;
    try {
      _workspaces.removeAt(index);
      if (_activeWorkspaceIndex >= _workspaces.length) {
        _activeWorkspaceIndex = _workspaces.length - 1;
      }
      _saveWorkspaces();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing workspace: $e');
    }
  }

  void renameWorkspace(String name) {
    activeWorkspace.name = name;
    _saveWorkspaces();
    notifyListeners();
  }

  Future<void> loadSvgString(String svgString, {bool createNewWorkspace = true}) async {
    try {
      if (createNewWorkspace) {
        _saveActiveWorkspace();
        if (activeWorkspace.originalSvgString == null) {
          // Reutilizar workspace vacío
        } else {
          final ws = Workspace(id: _generateId(), name: 'Espacio ${_workspaces.length + 1}');
          _workspaces.add(ws);
          _activeWorkspaceIndex = _workspaces.length - 1;
        }
      }

      activeWorkspace.originalSvgString = svgString;
      _resetAnimationState();
      _saveActiveWorkspace();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading SVG: $e');
    }
  }

  Future<void> loadSvgFile(File file) async {
    try {
      if (!await file.exists()) {
        debugPrint('File does not exist');
        return;
      }
      final content = await file.readAsString();
      if (content.isEmpty) {
        debugPrint('File is empty');
        return;
      }
      await loadSvgString(content);
    } catch (e) {
      debugPrint('Error loading file: $e');
    }
  }

  void togglePreset(String presetId) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;

      _pushHistory();
      final cfg = _getConfigForIndex(index);

      if (cfg.presetId == presetId) {
        if (cfg.extraPresets.isNotEmpty) {
          cfg.presetId = cfg.extraPresets.removeAt(0);
        } else {
          cfg.presetId = null;
        }
      } else if (cfg.extraPresets.contains(presetId)) {
        cfg.extraPresets.remove(presetId);
      } else {
        if (cfg.presetId != null) {
          if (!cfg.extraPresets.contains(cfg.presetId!)) {
            cfg.extraPresets.add(cfg.presetId!);
          }
        }
        cfg.presetId = presetId;
      }

      activeWorkspace.elementAnimations[index] = cfg;
      _syncGroupIfNeeded(index, cfg);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling preset: $e');
    }
  }

  void updateAnimationSpeed(double speed) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.speed = speed;
      _syncGroupValue(index, 'speed', speed);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating speed: $e');
    }
  }

  void updateAnimationDelay(double delay) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.delay = delay;
      _syncGroupValue(index, 'delay', delay);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating delay: $e');
    }
  }

  void updateAnimationIteration(String iter) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.iter = iter;
      _syncGroupValue(index, 'iter', iter);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating iteration: $e');
    }
  }

  void updateAnimationDirection(String dir) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.dir = dir;
      _syncGroupValue(index, 'dir', dir);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating direction: $e');
    }
  }

  void updateDirectionAngle(double angle) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.directionAngle = angle;
      _syncGroupValue(index, 'directionAngle', angle);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating angle: $e');
    }
  }

  void updateOvalRx(double rx) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.ovalRx = rx;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating ovalRx: $e');
    }
  }

  void updateOvalRy(double ry) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.ovalRy = ry;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating ovalRy: $e');
    }
  }

  void updateArcRx(double rx) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.arcRx = rx;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating arcRx: $e');
    }
  }

  void updateArcRy(double ry) {
    try {
      final index = activeWorkspace.selectedElementIndex;
      if (index == null) return;
      final cfg = _getConfigForIndex(index);
      cfg.arcRy = ry;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating arcRy: $e');
    }
  }

  void selectElement(int index) {
    activeWorkspace.selectedElementIndex = index;
    notifyListeners();
  }

  void clearSelection() {
    activeWorkspace.selectedElementIndex = null;
    notifyListeners();
  }

  void togglePiecesMode() {
    activeWorkspace.isPiecesMode = !activeWorkspace.isPiecesMode;
    if (!activeWorkspace.isPiecesMode) {
      activeWorkspace.piecesSelectedIndex = -1;
    }
    notifyListeners();
  }

  void moveElement(int index, double dx, double dy) {
    notifyListeners();
  }

  void createGroup(List<int> indices, String name) {
    try {
      if (indices.length < 2) return;
      _pushHistory();

      final color = _getNextGroupColor(activeWorkspace.nextGroupId);
      final groupId = 'g${activeWorkspace.nextGroupId++}';

      final templateConfig = elementAnimations[indices.first] ?? AnimationConfig();

      final group = Group(
        name: name,
        color: color,
        elements: List.from(indices),
        config: AnimationConfig.fromJson(templateConfig.toJson()),
      );

      activeWorkspace.elementGroups[groupId] = group;

      for (final idx in indices) {
        activeWorkspace.elementAnimations[idx] = AnimationConfig.fromJson(templateConfig.toJson());
      }

      activeWorkspace.selectedGroupElements = [];
      activeWorkspace.isMultiSelectMode = false;
      activeWorkspace.selectedGroupId = groupId;

      _saveActiveWorkspace();
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating group: $e');
    }
  }

  void deleteGroup(String groupId) {
    try {
      _pushHistory();
      activeWorkspace.elementGroups.remove(groupId);
      if (activeWorkspace.selectedGroupId == groupId) {
        activeWorkspace.selectedGroupId = null;
      }
      _saveActiveWorkspace();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting group: $e');
    }
  }

  String addTrajectory(String name) {
    try {
      final id = 'traj_${activeWorkspace.nextTrajId++}';
      final trajectory = Trajectory(
        name: name,
        points: [
          TrajectoryPoint(x: 30, y: 100),
          TrajectoryPoint(x: 55, y: 60),
          TrajectoryPoint(x: 100, y: 40),
          TrajectoryPoint(x: 145, y: 60),
          TrajectoryPoint(x: 170, y: 100),
        ],
      );
      activeWorkspace.trajectories[id] = trajectory;
      activeWorkspace.selectedTrajectoryId = id;
      activeWorkspace.isTrajectoryMode = true;
      _pushHistory();
      notifyListeners();
      return id;
    } catch (e) {
      debugPrint('Error adding trajectory: $e');
      return '';
    }
  }

  void deleteTrajectory(String id) {
    try {
      _pushHistory();
      activeWorkspace.trajectories.remove(id);
      if (activeWorkspace.selectedTrajectoryId == id) {
        activeWorkspace.selectedTrajectoryId = null;
        activeWorkspace.isTrajectoryMode = false;
      }
      for (final entry in activeWorkspace.elementAnimations.entries) {
        if (entry.value.trajectoryId == id) {
          entry.value.trajectoryId = null;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting trajectory: $e');
    }
  }

  void _pushHistory() {
    try {
      final ws = activeWorkspace;
      if (ws.undoIndex < ws.undoStack.length - 1) {
        ws.undoStack = ws.undoStack.sublist(0, ws.undoIndex + 1);
      }
      ws.undoStack.add({
        'animations': ws.elementAnimations.map((k, v) => MapEntry(k, v.toJson())),
        'groups': ws.elementGroups.map((k, v) => MapEntry(k, v.toJson())),
      });
      if (ws.undoStack.length > 50) {
        ws.undoStack.removeAt(0);
      }
      ws.undoIndex = ws.undoStack.length - 1;
    } catch (e) {
      debugPrint('Error pushing history: $e');
    }
  }

  void undo() {
    try {
      final ws = activeWorkspace;
      if (ws.undoIndex <= 0) return;
      ws.undoIndex--;
      _restoreHistory(ws.undoStack[ws.undoIndex]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error undoing: $e');
    }
  }

  void redo() {
    try {
      final ws = activeWorkspace;
      if (ws.undoIndex >= ws.undoStack.length - 1) return;
      ws.undoIndex++;
      _restoreHistory(ws.undoStack[ws.undoIndex]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error redoing: $e');
    }
  }

  void _restoreHistory(Map<String, dynamic> state) {
    try {
      final ws = activeWorkspace;
      ws.elementAnimations = (state['animations'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(int.parse(k), AnimationConfig.fromJson(v))) ?? {};
      ws.elementGroups = (state['groups'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, Group.fromJson(v))) ?? {};
    } catch (e) {
      debugPrint('Error restoring history: $e');
    }
  }

  bool get canUndo => activeWorkspace.undoIndex > 0;
  bool get canRedo => activeWorkspace.undoIndex < activeWorkspace.undoStack.length - 1;

  void togglePlayPause() {
    _animationPlaying = !_animationPlaying;
    notifyListeners();
  }

  void setZoom(double level) {
    activeWorkspace.zoomLevel = level.clamp(0.2, 5.0);
    notifyListeners();
  }

  AnimationConfig _getConfigForIndex(int index) {
    return activeWorkspace.elementAnimations[index] ?? AnimationConfig();
  }

  void _syncGroupValue(int index, String key, dynamic value) {
    final groupId = activeWorkspace.elementGroups.keys.firstWhere(
      (gid) => activeWorkspace.elementGroups[gid]!.elements.contains(index),
      orElse: () => '',
    );
    if (groupId.isEmpty) return;

    final group = activeWorkspace.elementGroups[groupId]!;
    switch (key) {
      case 'speed': group.config.speed = value; break;
      case 'delay': group.config.delay = value; break;
      case 'iter': group.config.iter = value; break;
      case 'dir': group.config.dir = value; break;
      case 'directionAngle': group.config.directionAngle = value; break;
    }

    for (final idx in group.elements) {
      if (activeWorkspace.elementAnimations.containsKey(idx)) {
        switch (key) {
          case 'speed': activeWorkspace.elementAnimations[idx]!.speed = value; break;
          case 'delay': activeWorkspace.elementAnimations[idx]!.delay = value; break;
          case 'iter': activeWorkspace.elementAnimations[idx]!.iter = value; break;
          case 'dir': activeWorkspace.elementAnimations[idx]!.dir = value; break;
          case 'directionAngle': activeWorkspace.elementAnimations[idx]!.directionAngle = value; break;
        }
      }
    }
  }

  void _syncGroupIfNeeded(int index, AnimationConfig config) {
    final groupId = activeWorkspace.elementGroups.keys.firstWhere(
      (gid) => activeWorkspace.elementGroups[gid]!.elements.contains(index),
      orElse: () => '',
    );
    if (groupId.isEmpty) return;

    final group = activeWorkspace.elementGroups[groupId]!;
    group.config = AnimationConfig.fromJson(config.toJson());

    for (final idx in group.elements) {
      activeWorkspace.elementAnimations[idx] = AnimationConfig.fromJson(config.toJson());
    }
  }

  void _resetAnimationState() {
    activeWorkspace.elementAnimations = {};
    activeWorkspace.elementGroups = {};
    activeWorkspace.selectedElementIndex = null;
    activeWorkspace.selectedGroupElements = [];
    activeWorkspace.selectedGroupId = null;
    activeWorkspace.isMultiSelectMode = false;
    activeWorkspace.nextGroupId = 1;
    activeWorkspace.trajectories = {};
    activeWorkspace.nextTrajId = 1;
    activeWorkspace.isTrajectoryMode = false;
    activeWorkspace.selectedTrajectoryId = null;
    activeWorkspace.undoStack = [];
    activeWorkspace.undoIndex = -1;
  }

  void _saveActiveWorkspace() {
    _saveWorkspaces();
  }

  Future<void> _loadWorkspaces() async {
    try {
      final box = await Hive.openBox(_boxName);
      final data = box.get(_workspacesKey);
      if (data != null) {
        final list = List<Map<String, dynamic>>.from(data);
        _workspaces = list.map((e) => Workspace.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading workspaces: $e');
    }
  }

  Future<void> _saveWorkspaces() async {
    try {
      final box = await Hive.openBox(_boxName);
      final data = _workspaces.map((e) => e.toJson()).toList();
      await box.put(_workspacesKey, data);
    } catch (e) {
      debugPrint('Error saving workspaces: $e');
    }
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 8)}';
  }

  String _getNextGroupColor(int groupId) {
    const colors = ['#6c5ce7', '#e74c3c', '#2ecc71', '#f39c12', '#1abc9c', '#9b59b6', '#3498db', '#e67e22'];
    return colors[(groupId - 1) % colors.length];
  }
}
