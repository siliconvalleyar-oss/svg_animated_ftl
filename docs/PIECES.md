# Modo Piezas

El modo piezas permite interactuar con elementos individuales dentro de un SVG directamente en la pantalla táctil del dispositivo móvil.

## Activar

1. Cargar un SVG (importar desde dispositivo o usar forma predefinida)
2. Navegar al panel "Piezas"
3. Tocar el botón "Activar modo piezas"
4. El modo se activa y las animaciones se pausan

## Funcionamiento

### Seleccionar elemento
- **Tocar** cualquier elemento del SVG en el área de previsualización
- El elemento seleccionado se resalta con un borde punteado violeta y drop-shadow

### Mover elemento
- **Arrastrar** el elemento seleccionado con un dedo
- El movimiento se escala automáticamente al espacio de coordenadas del SVG
- Se aplica `Transform.translate()` al widget del elemento

### Multi-selección
- **Long-press** en un elemento para activar multi-selección
- Tocar otros elementos para agregar/quitar de la selección
- Botón "Crear grupo" aparece cuando hay ≥2 elementos seleccionados

### Deseleccionar
- Tocar fuera de cualquier elemento
- Presionar el botón "Deseleccionar" en el panel

## Panel de elementos

El panel muestra una lista de todos los elementos del SVG:

- **Miniatura** (40x40px) del elemento con viewBox escalado
- **Nombre**: tag del elemento + índice (ej: "path 3")
- **Animación**: nombre de la animación asignada (o "—")
- **Indicador de grupo**: badge coloreado si pertenece a un grupo
- **Botón de visibilidad**: mostrar/ocultar elemento

## Comportamiento

- Las animaciones se pausan automáticamente al entrar al modo piezas (`AnimationController.stop()`)
- Las animaciones se reanudan al salir del modo (`AnimationController.repeat()`)
- Los movimientos se aplican via `Transform.translate()` en el widget
- Los movimientos son relativos a la posición original del elemento
- El estado se guarda por workspace

## Implementación en Flutter

```dart
class PiecesOverlay extends StatefulWidget {
  final List<SvgElement> elements;
  final bool isActive;
  final VoidCallback onToggle;
  
  @override
  _PiecesOverlayState createState() => _PiecesOverlayState();
}

class _PiecesOverlayState extends State<PiecesOverlay> {
  Map<int, Offset> _offsets = {}; // offset por índice de elemento
  
  void _onPanUpdate(DragUpdateDetails details, int index) {
    setState(() {
      _offsets[index] = (_offsets[index] ?? Offset.zero) + details.delta;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.elements.asMap().entries.map((entry) {
        final i = entry.key;
        final el = entry.value;
        final offset = _offsets[i] ?? Offset.zero;
        
        return Positioned(
          left: el.x + offset.dx,
          top: el.y + offset.dy,
          child: GestureDetector(
            onPanUpdate: (d) => _onPanUpdate(d, i),
            child: CustomPaint(
              painter: SvgElementPainter(el),
              child: SizedBox(width: el.width, height: el.height),
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

## Limitaciones

- Los movimientos no se guardan al exportar (solo afectan el preview)
- Para exportar con posiciones personalizadas, editar el SVG externamente
- Los elementos de tipo `g` (grupo SVG) se tratan como una sola unidad
