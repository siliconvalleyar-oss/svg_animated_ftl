# Exportar

## SVG Animado

El botón "Exportar SVG" genera un archivo `.svg` autocontenido con las animaciones CSS embebidas para cada elemento, y lo guarda en el almacenamiento del dispositivo.

## Flujo de exportación en Flutter

1. Tocar botón "Exportar" en el panel de exportación
2. Se abre el selector de ubicación del dispositivo (SAF en Android, Files app en iOS)
3. Se genera el SVG con animaciones embebidas
4. Se guarda el archivo en la ubicación seleccionada
5. Se muestra confirmación

## Qué se exporta

- El SVG original con todos sus elementos
- Un elemento `<style>` con los `@keyframes` CSS de cada animación
- Cada elemento animado lleva un atributo `data-anim-index` para selectores CSS precisos
- Animaciones independientes por pieza, cada una con su configuración individual
- Variables CSS para animaciones configurables (óvalo, arco)
- Keyframes dinámicos para animaciones con ángulo personalizado

## Estructura del SVG exportado

```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg viewBox="0 0 200 200">
  <style>
    @keyframes svgRotate {
      from { transform: rotate(0deg); }
      to { transform: rotate(360deg); }
    }
    @keyframes bounce_0_45 {
      0%,100% { transform: translate(0,0); }
      50% { transform: translate(14.14px,-14.14px); }
    }
    [data-anim-index="0"] {
      transform-origin: 100px 100px;
      transform-box: view-box;
      animation: svgRotate 2s linear infinite normal;
    }
    [data-anim-index="1"] {
      transform-origin: 50px 50px;
      transform-box: view-box;
      --arc-rx: 80px;
      animation: bounce_0_45 1.5s ease-in-out infinite normal;
    }
  </style>
  <circle data-anim-index="0" cx="100" cy="100" r="70"/>
  <path data-anim-index="1" d="M50 50L150 50L150 150Z"/>
</svg>
```

## Implementación en Flutter

```dart
class ExportService {
  static Future<String> generateAnimatedSvg({
    required String originalSvg,
    required Map<int, AnimationConfig> elementAnimations,
    required Map<String, Trajectory> trajectories,
  }) async {
    final doc = XmlDocument.parse(originalSvg);
    final svg = doc.rootElement;
    
    // Limpiar atributos de Flutter
    svg.removeAttribute('class');
    
    String embeddedStyle = '';
    String elementStyles = '';
    
    elementAnimations.forEach((index, config) {
      if (config.presetId == null) return;
      
      // Generar keyframes
      final keyframes = _generateKeyframes(index, config, trajectories);
      embeddedStyle += keyframes;
      
      // Generar estilos del elemento
      elementStyles += _generateElementStyle(index, config);
    });
    
    // Inyectar <style>
    final styleElement = XmlElement(
      XmlName('style'),
      [],
      [XmlText(embeddedStyle + '\n' + elementStyles)],
    );
    svg.children.insert(0, styleElement);
    
    return doc.toXml(pretty: true, indent: '  ');
  }
  
  static String _generateKeyframes(int index, AnimationConfig config, Map<String, Trajectory> trajectories) {
    // Implementación según el presetId
    switch (config.presetId) {
      case 'rotate':
        return '@keyframes svgRotate { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }';
      case 'bounce':
        if (config.directionAngle != 0) {
          return _generateDirectionalKeyframes('bounce', index, config);
        }
        return '@keyframes svgBounce { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-20px); } }';
      // ... otros presets
      default:
        return '';
    }
  }
}
```

## Guardado en el dispositivo

### Android (Storage Access Framework)
```dart
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['svg'],
  // Para guardar, usar SAF:
);
// O usar path_provider + permisos
```

### iOS (Files app)
```dart
final directory = await getApplicationDocumentsDirectory();
final file = File('${directory.path}/animated.svg');
await file.writeAsString(svgContent);
```

## Compatible con

- Navegadores web modernos
- Editores SVG (Inkscape, Illustrator, Figma)
- Embebido en HTML con `<img>` o `<object>`
- CSS inline en páginas web
- Cualquier app que lea SVGs

## No exporta

- Posiciones del modo piezas (solo afecta el preview)
- Imágenes de fondo de referencia
- Configuración de pivot (solo se usa en preview)
- Configuración de zoom/boundary
