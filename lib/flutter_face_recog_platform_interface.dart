import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:typed_data';

import 'flutter_face_recog_method_channel.dart';

abstract class FlutterFaceRecogPlatform extends PlatformInterface {
  /// Constructs a FlutterFaceRecogPlatform.
  FlutterFaceRecogPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterFaceRecogPlatform _instance = MethodChannelFlutterFaceRecog();

  /// The default instance of [FlutterFaceRecogPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterFaceRecog].
  static FlutterFaceRecogPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterFaceRecogPlatform] when
  /// they register themselves.
  static set instance(FlutterFaceRecogPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool?> registerFace(String name, Uint8List image) {
    throw UnimplementedError('registerFace() has not been implemented.');
  }

  Future<String?> recognizeFace(Uint8List image) {
    throw UnimplementedError('recognizeFace() has not been implemented.');
  }

  Future<bool?> clearRegisteredFaces() {
    throw UnimplementedError(
        'clearRegisteredFaces() has not been implemented.');
  }
}
