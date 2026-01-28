# Flutter Face Recognition Plugin

A Flutter plugin for Face Detection and Recognition using **Google ML Kit** (Detection) and **TensorFlow Lite** (Recognition with MobileFaceNet).

This plugin provides a simple interface to:
1.  **Register** a face with a name.
2.  **Recognize** a face from an image.
3.  Support **Android** (iOS implementation pending).

## Features

*   **Face Detection:** Locates faces in an image (ML Kit).
*   **Face Recognition:** Extracts embeddings and compares them with registered faces (TFLite MobileFaceNet).
*   **Offline Support:** All processing happens on-device.

---

## Installation

### Method 1: Git Dependency (Recommended)
Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_face_recog:
    git:
      url: https://github.com/wiratsil/flutter_face_recog.git
```

### Method 2: Local Path
If you have the plugin source code locally:

```yaml
dependencies:
  flutter_face_recog:
    path: /path/to/flutter_face_recog
```

---

## Android Setup

### 1. Update `minSdkVersion`
Open `android/app/build.gradle` and ensure `minSdkVersion` is at least **24**:

```gradle
android {
    defaultConfig {
        minSdkVersion 24
        // ...
    }
}
```

### 2. Add Permissions
Open `android/app/src/main/AndroidManifest.xml` and add the Camera permission:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.CAMERA" />
    <application ...>
        ...
    </application>
</manifest>
```

---

## Usage

### 1. Import
```dart
import 'package:flutter_face_recog/flutter_face_recog.dart';
```

### 2. Initialize
```dart
final _flutterFaceRecogPlugin = FlutterFaceRecog();
```

### 3. Register a Face
Capture an image (using `camera` package) and pass the bytes to the plugin:

```dart
// imageBytes: Uint8List from CameraController.takePicture()
String name = "User Name";
bool? success = await _flutterFaceRecogPlugin.registerFace(name, imageBytes);

if (success == true) {
  print("Face Registered!");
}
```

### 4. Recognize a Face
```dart
// imageBytes: Uint8List from CameraController
String? name = await _flutterFaceRecogPlugin.recognizeFace(imageBytes);

if (name != null) {
  print("Recognized: $name");
} else {
  print("Unknown Face");
}
```

### 5. Clear All Data
```dart
await _flutterFaceRecogPlugin.clearRegisteredFaces();
```

---

## Example App
Check the `example` folder for a complete working demo using the `camera` package.

1.  `cd example`
2.  `flutter pub get`
3.  `flutter run`
