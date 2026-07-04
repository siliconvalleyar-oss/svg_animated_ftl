# Instalación

## Requisitos

- Flutter SDK 3.0 o superior
- Dart SDK 3.0 o superior
- Android Studio / VS Code con plugin Flutter
- Dispositivo Android (5.0+ / API 21+) o iOS (12.0+)

## Plataformas soportadas

- Android (5.0+ / API 21+)
- iOS (12.0+)

## Instalación de Flutter

### Windows / Mac / Linux
1. Descargar Flutter SDK desde https://flutter.dev
2. Extraer y agregar al PATH
3. Ejecutar `flutter doctor` para verificar instalación
4. Instalar Android Studio o VS Code con plugin Flutter

### Verificar instalación
```bash
flutter doctor
```

## Configurar el proyecto

### Clonar el repositorio
```bash
git clone https://github.com/usuario/svg_animated_ftl.git
cd svg_animated_ftl
```

### Instalar dependencias
```bash
flutter pub get
```

### Configurar plataformas
```bash
# Android
flutter create --platforms android .

# iOS
flutter create --platforms ios .
```

## Ejecutar la app

### En emulador Android
```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en emulador
flutter run
```

### En dispositivo físico Android
1. Activar "Depuración USB" en ajustes del dispositivo
2. Conectar por USB
3. Ejecutar:
```bash
flutter run
```

### En simulador iOS (requiere Mac)
```bash
# Abrir simulador
open -a Simulator

# Ejecutar
flutter run
```

### En dispositivo físico iOS (requiere Mac + Xcode)
1. Abrir `ios/Runner.xcworkspace` en Xcode
2. Configurar equipo de desarrollo
3. Ejecutar desde Xcode o `flutter run`

## Build release

### Android APK
```bash
flutter build apk --release
```
El APK se genera en `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (para Play Store)
```bash
flutter build appbundle --release
```
Se genera en `build/app/outputs/bundle/release/app-release.aab`

### iOS (requiere Mac + certificado Apple)
```bash
flutter build ios --release
```

## Sin servidor

A diferencia de la versión web, la versión Flutter NO requiere:
- Python
- Servidor local
- Abrir navegador
- Ningún proceso adicional

La app es un ejecutable nativo que se instala directamente en el dispositivo.

## Estructura de archivos en el dispositivo

```
/data/data/com.ejemplo.svganimator/
├── app_flutter/
│   ├── files/
│   │   ├── sample.svg          # SVG de ejemplo
│   │   └── ...
│   └── ...
├── shared_prefs/
│   └── config.xml              # Configuración guardada
└── databases/
    └── ...
```

## Solución de problemas

### Error: "Flutter SDK not found"
```bash
# Verificar que Flutter está en el PATH
flutter doctor

# Si no se encuentra, agregar al PATH manualmente
export PATH="$PATH:/ruta/a/flutter/bin"
```

### Error: "No devices found"
```bash
# Listar dispositivos
flutter devices

# Reiniciar adb (Android)
adb kill-server
adb start-server
```

### Error: "pub get failed"
```bash
# Limpiar caché
flutter clean
flutter pub get
```

### Error en iOS: "CocoaPods not installed"
```bash
sudo gem install cocoapods
cd ios && pod install && cd ..
```
