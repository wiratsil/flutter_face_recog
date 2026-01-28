import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

import 'flutter_face_recog_platform_interface.dart';

/// An implementation of [FlutterFaceRecogPlatform] that uses method channels.
class MethodChannelFlutterFaceRecog extends FlutterFaceRecogPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_face_recog');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> registerFace(String name, Uint8List image) async {
    return await methodChannel.invokeMethod<bool>('registerFace', {
      'name': name,
      'image': image,
    });
  }

  @override
  Future<String?> recognizeFace(Uint8List image) async {
    return await methodChannel.invokeMethod<String>('recognizeFace', {
      'image': image,
    });
  }

  @override
  Future<bool?> clearRegisteredFaces() async {
    return await methodChannel.invokeMethod<bool>('clearRegisteredFaces');
  }
}
