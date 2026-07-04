# Animaciones

## Lista de animaciones (19 presets)

| ID | Nombre | Descripción | Tipo | Easing por defecto |
|----|--------|-------------|------|-------------------|
| `rotate` | Rotar | Rotación continua 360° | Rotación | linear |
| `wheel` | Rueda | Rotación con pasos de 90° | Rotación | linear |
| `pulse` | Pulsar | Escala 1 → 1.15 | Escala | ease-in-out |
| `bounce` | Rebotar | Translate ±20px vertical | Translación | ease-in-out |
| `gravity` | Gravedad | Caída con rebote amortiguado | Translación | cubic-bezier |
| `slide` | Deslizar | Translate ±80px horizontal | Translación | ease-in-out |
| `oval` | Óvalo | Trayectoria elíptica configurable | Translación | linear |
| `fade` | Desvanecer | Opacidad 1 → 0.15 | Opacidad | ease-in-out |
| `draw` | Dibujar | stroke-dashoffset | Trazo | ease-in-out |
| `shake` | Temblar | Vibración ±8px | Translación | ease-in-out |
| `float` | Flotar | Translate ±15px vertical | Translación | ease-in-out |
| `levitate` | Levitar | Flotación con escala sutil | Translación | ease-in-out |
| `arc` | Arco | Trayectoria de arco configurable | Translación | ease-in-out |
| `radiate` | Radiar | Arco + drop-shadow pulsante | Translación + Filtro | ease-in-out |
| `spin` | Girar | Rotación + escala 0.85 | Rotación + Escala | ease-in-out |
| `glow` | Brillar | drop-shadow pulsante | Filtro | ease-in-out |
| `wave-sine` | Senoidal | Onda sinusoidal 320px | Translación | ease-in-out |
| `wave-square` | Cuadrada | Onda cuadrada 80px | Translación | step-end |
| `wave-triangle` | Triangular | Onda triangular 80px | Translación | linear |

## Animaciones direccionables (11)

Las siguientes animaciones soportan control de dirección mediante ángulo (0-360°):

- `bounce`, `gravity`, `slide`, `shake`, `float`, `levitate`
- `arc`, `radiate`
- `wave-sine`, `wave-square`, `wave-triangle`

## Implementación en Flutter

Las animaciones se implementan usando `AnimationController` + `Tween` de Flutter, NO CSS keyframes.

### Ejemplo: Rotar
```dart
class RotateAnimation extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: animation.value * 2 * 3.14159,
          child: child,
        );
      },
      child: child,
    );
  }
}
```

### Ejemplo: Rebotar
```dart
class BounceAnimation extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final double directionAngle; // 0-360°
  
  @override
  Widget build(BuildContext context) {
    final rad = directionAngle * 3.14159 / 180;
    final dx = sin(rad) * animation.value * 20;
    final dy = -cos(rad) * animation.value * 20;
    
    return Transform.translate(
      offset: Offset(dx, dy),
      child: child,
    );
  }
}
```

### Ejemplo: Óvalo
```dart
class OvalAnimation extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final double rx, ry;
  
  @override
  Widget build(BuildContext context) {
    final angle = animation.value * 2 * 3.14159;
    final dx = cos(angle) * rx;
    final dy = sin(angle) * ry;
    
    return Transform.translate(
      offset: Offset(dx, dy),
      child: child,
    );
  }
}
```

## Easing functions (Curves de Flutter)

| Curve Flutter | Equivalente CSS | Descripción |
|---------------|----------------|-------------|
| `Curves.linear` | `linear` | Velocidad constante |
| `Curves.ease` | `ease` | Lento inicio y fin |
| `Curves.easeIn` | `ease-in` | Lento inicio |
| `Curves.easeOut` | `ease-out` | Lento fin |
| `Curves.easeInOut` | `ease-in-out` | Lento inicio y fin |
| `Curves.elasticOut` | — | Rebote elástico |
| `Curves.bounceOut` | — | Rebote |
| `Cubic(0.33, 0, 0.67, 1)` | `cubic-bezier` | Curva personalizada (gravity) |

## Combinación de animaciones

Se pueden combinar múltiples animaciones por elemento. El sistema usa una lista `extraPresets` donde se acumulan las animaciones adicionales.

## Sensibilidad de dirección

Para animaciones direccionables con ángulo ≠ 0, se calculan componentes X/Y usando trigonometría:
```dart
final rad = angle * pi / 180;
final cosA = cos(rad);
final sinA = sin(rad);
// translateX = distance * sinA
// translateY = -distance * cosA
```
