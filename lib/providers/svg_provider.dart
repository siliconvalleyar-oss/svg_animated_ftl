import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/animation_config.dart';
import '../models/workspace.dart';
import '../services/animation_service.dart';
import '../services/group_service.dart';
import '../services/trajectory_service.dart';
import '../services/history_service.dart';
import '../services/selection_service.dart';

class SvgProvider extends ChangeNotifier {
  static const _boxName = 'svg_animator';
  static const _workspacesKey = 'workspaces';

  final _uuid = const Uuid();
  final _animationService = AnimationService();
  final _groupService = GroupService();
  final _trajectoryService = TrajectoryService();
  final _historyService = HistoryService();
  final _selectionService = SelectionService();

  List<Workspace> _workspaces = [];
  int _activeWorkspaceIndex = 0;
  bool _animationPlaying = true;

  Workspace get activeWorkspace => _workspaces[_activeWorkspaceIndex];
  List<Workspace> get workspaces => _workspaces;
  int get activeWorkspaceIndex => _activeWorkspaceIndex;
  bool get animationPlaying => _animationPlaying;
  String? get currentSvgString => activeWorkspace.originalSvgString;
  Map<int, AnimationConfig> get elementAnimations => activeWorkspace.elementAnimations;

  // ============================================================
  // INITIALIZATION & PERSISTENCE
  // ============================================================

  Future<void> init() async {
    try {
      await _loadWorkspaces();
      if (_workspaces.isEmpty) {
        _workspaces.add(Workspace(id: _generateId(), name: 'Workspace'));
      }
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
      _workspaces = [Workspace(id: _generateId(), name: 'Workspace')];
      notifyListeners();
    }
  }

  // ============================================================
  // WORKSPACE MANAGEMENT
  // ============================================================

  void addWorkspace() {
    try {
      _saveActiveWorkspace();
      final ws = Workspace(id: _generateId(), name: 'Workspace ${_workspaces.length + 1}');
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
        if (activeWorkspace.originalSvgString != null) {
          final ws = Workspace(id: _generateId(), name: 'Workspace ${_workspaces.length + 1}');
          _workspaces.add(ws);
          _activeWorkspaceIndex = _workspaces.length - 1;
        }
      }
      activeWorkspace.originalSvgString = svgString;
      _animationService.resetAnimationState(activeWorkspace);
      _saveActiveWorkspace();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading SVG: $e');
    }
  }

  // ============================================================
  // ELEMENT SELECTION
  // ============================================================

  void toggleElementSelection(int index) {
    _selectionService.toggleElementSelection(activeWorkspace, index);
    notifyListeners();
  }

  void selectElement(int index) {
    _selectionService.selectElement(activeWorkspace, index);
    notifyListeners();
  }

  void clearSelection() {
    _selectionService.clearSelection(activeWorkspace);
    notifyListeners();
  }

  // ============================================================
  // ANIMATION CONTROLS
  // ============================================================

  void togglePreset(String presetId) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.togglePreset(activeWorkspace, presetId);
    notifyListeners();
  }

  void updateAnimationSpeed(double speed) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.applyToSelected(activeWorkspace, (cfg) => cfg.speed = speed);
    notifyListeners();
  }

  void updateAnimationDelay(double delay) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.applyToSelected(activeWorkspace, (cfg) => cfg.delay = delay);
    notifyListeners();
  }

  void updateAnimationIteration(String iter) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.applyToSelected(activeWorkspace, (cfg) => cfg.iter = iter);
    notifyListeners();
  }

  void updateAnimationDirection(String dir) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.applyToSelected(activeWorkspace, (cfg) => cfg.dir = dir);
    notifyListeners();
  }

  void updateDirectionAngle(double angle) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.applyToSelected(activeWorkspace, (cfg) => cfg.directionAngle = angle);
    notifyListeners();
  }

  void updateOpacity(double opacity) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.applyToSelected(activeWorkspace, (cfg) => cfg.opacity = opacity);
    notifyListeners();
  }

  void updateInitialVelocity(double velocity) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.applyToSelected(activeWorkspace, (cfg) => cfg.initialVelocity = velocity);
    notifyListeners();
  }

  void updateLaunchAngle(double angle) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.applyToSelected(activeWorkspace, (cfg) => cfg.launchAngle = angle);
    notifyListeners();
  }

  void updateGravity(double gravity) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.applyToSelected(activeWorkspace, (cfg) => cfg.gravity = gravity);
    notifyListeners();
  }

  void updateOvalRx(double rx) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.applyToSelected(activeWorkspace, (cfg) => cfg.ovalRx = rx);
    notifyListeners();
  }

  void updateOvalRy(double ry) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.applyToSelected(activeWorkspace, (cfg) => cfg.ovalRy = ry);
    notifyListeners();
  }

  void updateArcRx(double rx) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.applyToSelected(activeWorkspace, (cfg) => cfg.arcRx = rx);
    notifyListeners();
  }

  void updateArcRy(double ry) {
    _historyService.pushHistory(activeWorkspace);
    _animationService.applyToSelected(activeWorkspace, (cfg) => cfg.arcRy = ry);
    notifyListeners();
  }

  // ============================================================
  // GROUPS
  // ============================================================

  void createGroup(List<int> indices, String name) {
    _historyService.pushHistory(activeWorkspace);
    _groupService.createGroup(activeWorkspace, indices, name);
    _saveActiveWorkspace();
    notifyListeners();
  }

  void deleteGroup(String groupId) {
    _historyService.pushHistory(activeWorkspace);
    _groupService.deleteGroup(activeWorkspace, groupId);
    _saveActiveWorkspace();
    notifyListeners();
  }

  void renameGroup(String groupId, String newName) {
    _groupService.renameGroup(activeWorkspace, groupId, newName);
    _saveWorkspaces();
    notifyListeners();
  }

  // ============================================================
  // MOVE ELEMENTS
  // ============================================================

  void moveSelectedElements(double dx, double dy) {
    if (activeWorkspace.selectedGroupElements.isEmpty) return;
    _historyService.pushHistory(activeWorkspace);
    for (final index in activeWorkspace.selectedGroupElements) {
      final current = activeWorkspace.elementOffsets[index] ?? Offset.zero;
      activeWorkspace.elementOffsets[index] = current + Offset(dx, dy);
    }
    notifyListeners();
  }

  void resetElementOffsets() {
    if (activeWorkspace.elementOffsets.isEmpty) return;
    _historyService.pushHistory(activeWorkspace);
    activeWorkspace.elementOffsets.clear();
    notifyListeners();
  }

  // ============================================================
  // PIECES MODE
  // ============================================================

  void togglePiecesMode() {
    _selectionService.togglePiecesMode(activeWorkspace);
    notifyListeners();
  }

  // ============================================================
  // TRAJECTORIES
  // ============================================================

  String addTrajectory(String name) {
    _historyService.pushHistory(activeWorkspace);
    final id = _trajectoryService.addTrajectory(activeWorkspace, name);
    notifyListeners();
    return id;
  }

  void deleteTrajectory(String id) {
    _historyService.pushHistory(activeWorkspace);
    _trajectoryService.deleteTrajectory(activeWorkspace, id);
    notifyListeners();
  }

  // ============================================================
  // UNDO / REDO
  // ============================================================

  bool get canUndo => _historyService.canUndo(activeWorkspace);
  bool get canRedo => _historyService.canRedo(activeWorkspace);

  void undo() {
    if (_historyService.undo(activeWorkspace)) {
      notifyListeners();
    }
  }

  void redo() {
    if (_historyService.redo(activeWorkspace)) {
      notifyListeners();
    }
  }

  // ============================================================
  // PLAYBACK & ZOOM
  // ============================================================

  void togglePlayPause() {
    _animationPlaying = !_animationPlaying;
    notifyListeners();
  }

  void setZoom(double level) {
    activeWorkspace.zoomLevel = level.clamp(0.2, 5.0);
    notifyListeners();
  }

  // ============================================================
  // PERSISTENCE HELPERS
  // ============================================================

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
}
