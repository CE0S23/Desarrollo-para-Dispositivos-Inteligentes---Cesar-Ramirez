# Desarrollo para Dispositivos Inteligentes — César Ramírez

Repositorio de prácticas y proyectos desarrollados durante la materia **Desarrollo para Dispositivos Inteligentes** en la Universidad Tecnológica de Querétaro (UTEQ).

---

## 🛠 Tecnologías utilizadas

- [Flutter](https://flutter.dev/) — Framework principal para el desarrollo de la aplicación móvil
- Dart — Lenguaje de programación
- Android SDK — Plataforma de despliegue

---

## 📁 Estructura del repositorio

```
/
├── practicas/          # Reportes y evidencias de cada práctica
└── app/                # Código fuente de la aplicación Flutter
```

---

## 📝 Nota sobre el historial del repositorio

Este repositorio fue creado inicialmente para almacenar únicamente los **reportes y evidencias** de cada práctica de la materia. El código fuente de la aplicación Flutter fue integrado en una etapa posterior del curso, una vez que el desarrollo de la app comenzó formalmente.

Por esta razón, el archivo `.gitignore` (configurado para Flutter) no aparece en el commit inicial del repositorio, sino a partir del commit en que se incorporó el proyecto. En ningún momento se subieron archivos de dependencias generadas (`build/`, `.dart_tool/`, `node_modules/`, etc.), credenciales ni archivos de configuración sensibles al repositorio.

---

## ⚙️ Requisitos previos

Antes de ejecutar el proyecto, asegúrate de tener instalado lo siguiente:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versión 3.x o superior)
- [Dart SDK](https://dart.dev/get-dart) (incluido con Flutter)
- [Android Studio](https://developer.android.com/studio) o [VS Code](https://code.visualstudio.com/) con las extensiones de Flutter y Dart
- Un emulador Android configurado o un dispositivo físico con depuración USB habilitada

Verifica que tu entorno esté correctamente configurado ejecutando:

```bash
flutter doctor
```

---

## 🚀 Instalación y ejecución

1. Clona el repositorio:

```bash
git clone https://github.com/CE0S23/Desarrollo-para-Dispositivos-Inteligentes---Cesar-Ramirez.git
cd Desarrollo-para-Dispositivos-Inteligentes---Cesar-Ramirez
```

2. Navega a la carpeta de la aplicación:

```bash
cd app
```

3. Instala las dependencias del proyecto:

```bash
flutter pub get
```

4. Ejecuta la aplicación en un emulador o dispositivo conectado:

```bash
flutter run
```

> Si tienes múltiples dispositivos conectados, selecciona el destino con `flutter run -d <device_id>`. Puedes ver los dispositivos disponibles con `flutter devices`.

---

## 📦 Compilar APK (opcional)

Para generar un APK de release:

```bash
flutter build apk --release
```

El archivo generado se encontrará en `build/app/outputs/flutter-apk/app-release.apk`.

---

## 👤 Autor

**César Ramírez**  
Ingeniería en Gestión de Desarrollo de Software  
Universidad Tecnológica de Querétaro — UTEQ
