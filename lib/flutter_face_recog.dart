import 'dart:typed_data';

import 'flutter_face_recog_platform_interface.dart';

class FlutterFaceRecog {
  Future<String?> getPlatformVersion() {
    return FlutterFaceRecogPlatform.instance.getPlatformVersion();
  }

  Future<bool?> registerFace(String name, Uint8List image) {
    return FlutterFaceRecogPlatform.instance.registerFace(name, image);
  }

  Future<String?> recognizeFace(Uint8List image) {
    return FlutterFaceRecogPlatform.instance.recognizeFace(image);
  }

  Future<bool?> clearRegisteredFaces() {
    return FlutterFaceRecogPlatform.instance.clearRegisteredFaces();
  }
}
