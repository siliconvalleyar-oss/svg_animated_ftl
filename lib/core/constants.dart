import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0F1117);
  static const surface = Color(0xFF1A1D27);
  static const surface2 = Color(0xFF242734);
  static const border = Color(0xFF2E3245);
  static const text = Color(0xFFE4E6F0);
  static const textDim = Color(0xFF8B8FA7);
  static const accent = Color(0xFF6C5CE7);
  static const accentHover = Color(0xFF7C6EF7);
  static const danger = Color(0xFFE74C3C);
  static const success = Color(0xFF2ECC71);

  static const groupColors = [
    '#6c5ce7', '#e74c3c', '#2ecc71', '#f39c12',
    '#1abc9c', '#9b59b6', '#3498db', '#e67e22',
  ];
}

class AnimationPresets {
  static const List<Map<String, dynamic>> presets = [
    {'name': 'Rotar', 'id': 'rotate', 'color': '#6c5ce7', 'duration': 2.0, 'easing': 'linear'},
    {'name': 'Rueda', 'id': 'wheel', 'color': '#e74c3c', 'duration': 3.0, 'easing': 'linear'},
    {'name': 'Pulsar', 'id': 'pulse', 'color': '#e67e22', 'duration': 1.5, 'easing': 'easeInOut'},
    {'name': 'Rebotar', 'id': 'bounce', 'color': '#2ecc71', 'duration': 0.8, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Gravedad', 'id': 'gravity', 'color': '#1abc9c', 'duration': 1.5, 'easing': 'easeOut', 'translatable': true},
    {'name': 'Deslizar', 'id': 'slide', 'color': '#f39c12', 'duration': 2.0, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Óvalo', 'id': 'oval', 'color': '#9b59b6', 'duration': 3.0, 'easing': 'linear'},
    {'name': 'Desvanecer', 'id': 'fade', 'color': '#e74c3c', 'duration': 2.0, 'easing': 'easeInOut'},
    {'name': 'Dibujar', 'id': 'draw', 'color': '#1abc9c', 'duration': 2.0, 'easing': 'easeInOut'},
    {'name': 'Temblar', 'id': 'shake', 'color': '#e67e22', 'duration': 0.5, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Flotar', 'id': 'float', 'color': '#9b59b6', 'duration': 3.0, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Levitar', 'id': 'levitate', 'color': '#1abc9c', 'duration': 3.5, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Tiro Oblicuo', 'id': 'projectile', 'color': '#f39c12', 'duration': 4.0, 'easing': 'linear', 'translatable': true},
    {'name': 'Radiar', 'id': 'radiate', 'color': '#e67e22', 'duration': 4.0, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Girar', 'id': 'spin', 'color': '#3498db', 'duration': 1.2, 'easing': 'easeInOut'},
    {'name': 'Brillar', 'id': 'glow', 'color': '#e74c3c', 'duration': 2.0, 'easing': 'easeInOut'},
    {'name': 'Senoidal', 'id': 'wave-sine', 'color': '#1abc9c', 'duration': 3.0, 'easing': 'easeInOut', 'translatable': true},
    {'name': 'Cuadrada', 'id': 'wave-square', 'color': '#e74c3c', 'duration': 1.5, 'easing': 'linear', 'translatable': true},
    {'name': 'Triangular', 'id': 'wave-triangle', 'color': '#9b59b6', 'duration': 2.0, 'easing': 'linear', 'translatable': true},
    {'name': 'Péndulo', 'id': 'pendulum', 'color': '#e74c3c', 'duration': 2.0, 'easing': 'easeInOut'},
    {'name': 'Caída Libre', 'id': 'freefall', 'color': '#1abc9c', 'duration': 1.5, 'easing': 'easeIn'},
    {'name': 'Rebote Elástico', 'id': 'elastic-bounce', 'color': '#f39c12', 'duration': 1.0, 'easing': 'easeOut'},
    {'name': 'Resorte', 'id': 'spring', 'color': '#9b59b6', 'duration': 2.0, 'easing': 'elasticOut'},
    {'name': 'Opacidad', 'id': 'opacity-anim', 'color': '#e74c3c', 'duration': 2.0, 'easing': 'easeInOut'},
  ];

  static const List<Map<String, dynamic>> shapes = [
    {'name': 'Círculo', 'svg': '<svg viewBox="0 0 200 200"><circle cx="100" cy="100" r="70" fill="none" stroke="#6c5ce7" stroke-width="3"/></svg>'},
    {'name': 'Cuadrado', 'svg': '<svg viewBox="0 0 200 200"><rect x="30" y="30" width="140" height="140" rx="8" fill="none" stroke="#e74c3c" stroke-width="3"/></svg>'},
    {'name': 'Triángulo', 'svg': '<svg viewBox="0 0 200 200"><polygon points="100,20 180,170 20,170" fill="none" stroke="#2ecc71" stroke-width="3"/></svg>'},
    {'name': 'Estrella', 'svg': '<svg viewBox="0 0 200 200"><polygon points="100,15 125,75 190,80 140,125 155,190 100,155 45,190 60,125 10,80 75,75" fill="none" stroke="#f39c12" stroke-width="3"/></svg>'},
    {'name': 'Corazón', 'svg': '<svg viewBox="0 0 200 200"><path d="M100 170 C60 130 20 100 20 65 C20 35 45 15 70 15 C85 15 95 25 100 35 C105 25 115 15 130 15 C155 15 180 35 180 65 C180 100 140 130 100 170Z" fill="none" stroke="#e74c3c" stroke-width="3"/></svg>'},
    {'name': 'Hexágono', 'svg': '<svg viewBox="0 0 200 200"><polygon points="100,15 175,50 175,140 100,180 25,140 25,50" fill="none" stroke="#1abc9c" stroke-width="3"/></svg>'},
    {'name': 'Rombo', 'svg': '<svg viewBox="0 0 200 200"><polygon points="100,15 185,100 100,185 15,100" fill="none" stroke="#9b59b6" stroke-width="3"/></svg>'},
    {'name': 'Cruz', 'svg': '<svg viewBox="0 0 200 200"><path d="M70 30 H130 V70 H170 V130 H130 V170 H70 V130 H30 V70 H70 Z" fill="none" stroke="#3498db" stroke-width="3"/></svg>'},
    {'name': 'Onda', 'svg': '<svg viewBox="0 0 200 200"><path d="M20 100 Q50 60 80 100 Q110 140 140 100 Q170 60 200 100" fill="none" stroke="#e67e22" stroke-width="3"/></svg>'},
    {'name': 'Flecha', 'svg': '<svg viewBox="0 0 200 200"><path d="M100 30 L170 100 L130 100 L130 170 L70 170 L70 100 L30 100 Z" fill="none" stroke="#6c5ce7" stroke-width="3"/></svg>'},
    {'name': 'Rayo', 'svg': '<svg viewBox="0 0 200 200"><polygon points="115,15 50,105 90,105 80,185 155,90 110,90" fill="none" stroke="#f1c40f" stroke-width="3"/></svg>'},
    {'name': 'Luna', 'svg': '<svg viewBox="0 0 200 200"><path d="M120 30 A65 65 0 1 0 120 170 A50 50 0 1 1 120 30" fill="none" stroke="#8e44ad" stroke-width="3"/></svg>'},
  ];
}

class AppConstants {
  static const double minZoom = 0.2;
  static const double maxZoom = 5.0;
  static const int maxUndoSteps = 50;
  static const double defaultSpeed = 4.0;
  static const double defaultDelay = 0.0;
  static const String defaultIteration = 'infinite';
  static const String defaultDirection = 'normal';
  static const double defaultOpacity = 1.0;
  static const double defaultGravity = 9.8;
  static const double defaultInitialVelocity = 100.0;
  static const double defaultLaunchAngle = 45.0;
}
