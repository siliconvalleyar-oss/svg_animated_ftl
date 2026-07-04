# Controles

## Controles básicos

### Velocidad (Duration)
- Rango: 0.2s a 16s (configurable hasta 999s)
- Controla la duración de un ciclo de animación
- Valores menores = más rápido
- Implementado como `Slider` de Flutter

### Retraso (Delay)
- Rango: 0s a 3s
- Tiempo de espera antes de iniciar la animación
- Implementado como `Slider` de Flutter

### Repetición (Repeat)
- **Infinito**: La animación se repite indefinidamente (`Loop`)
- **Una vez**: La animación corre una sola vez (`1`)
- **3 veces**: Se repite 3 veces (`3`)
- **Random**: Genera un valor aleatorio de [1, 2, 3, 5, 10, infinite]
- **Custom**: Input numérico para valor personalizado
- Implementado como fila de `ChoiceChip` o `ToggleButtons`

### Dirección (Direction)
- **Normal**: De principio a fin (`forward`)
- **Reversa**: De fin a principio (`reverse`)
- **Alterno**: Alterna entre normal y reversa (`alternate`)
- Implementado como fila de `ChoiceChip`

## Sentido / Ángulo

- Rango: 0-360° (step 5)
- Grid de 8 botones de direcciones cardinales: → ↗ ↑ ↖ ← ↙ ↓ ↘
- Flecha visual superpuesta en el preview mostrando la dirección
- Solo aplica a animaciones de translación

### Animaciones que soportan ángulo
`slide`, `bounce`, `shake`, `float`, `gravity`, `levitate`, `arc`, `radiate`, `wave-sine`, `wave-square`, `wave-triangle`

## Controles específicos por animación

### Óvalo (solo con animación "oval")
- **Ancho (X)**: Slider 10-150px — radio horizontal
- **Alto (Y)**: Slider 10-150px — radio vertical
- **Ángulo**: Slider 0-360° — rotación de la trayectoria

### Arco (solo con "arc" o "radiate")
- **Eje X**: Slider 10-200px
- **Eje Y**: Slider 10-200px

## Controles de reproducción

- **Play**: Iniciar/reanudar animación
- **Pause**: Pausar animación
- **Stop**: Detener y resetear animación
- Implementados como `IconButton` con iconos Material

## Implementación en Flutter

### Slider personalizado
```dart
class AnimationSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String label;
  final ValueChanged<double> onChanged;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: Color(0xFF6C5CE7),
            onChanged: onChanged,
          ),
        ),
        Text('${value.toStringAsFixed(1)}s', 
             style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
```

### Toggle buttons
```dart
class DirectionToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  
  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: ['normal', 'reverse', 'alternate'].map((d) => d == selected).toList(),
      onPressed: (i) => onChanged(['normal', 'reverse', 'alternate'][i]),
      children: [
        Text('Normal'),
        Text('Reversa'),
        Text('Alterno'),
      ],
    );
  }
}
```

### Grid de direcciones cardinales
```dart
final directionPresets = [
  {'label': '→', 'angle': 0},
  {'label': '↗', 'angle': 45},
  {'label': '↑', 'angle': 90},
  {'label': '↖', 'angle': 135},
  {'label': '←', 'angle': 180},
  {'label': '↙', 'angle': 225},
  {'label': '↓', 'angle': 270},
  {'label': '↘', 'angle': 315},
];
```

## Interacciones táctiles

| Gesto | Acción |
|-------|--------|
| **Tap** | Seleccionar toggle, activar botón |
| **Drag** | Ajustar slider |
| **Long-press** | N/A (no se usa en controles) |

## Tamaño mínimo de elementos interactivos

- Botones: 44x44px (iOS HIG) / 48x48px (Material Design)
- Sliders: Altura mínima 28px
- Espaciado entre elementos: mínimo 8px
