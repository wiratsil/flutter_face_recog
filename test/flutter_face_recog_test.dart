import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import 'package:flutter_face_recog/flutter_face_recog.dart';
import 'package:flutter_face_recog/flutter_face_recog_platform_interface.dart';
import 'package:flutter_face_recog/flutter_face_recog_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterFaceRecogPlatform
    with MockPlatformInterfaceMixin
    implements FlutterFaceRecogPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool?> registerFace(String name, Uint8List image) =>
      Future.value(true);

  @override
  Future<String?> recognizeFace(Uint8List image) => Future.value("Mock User");

  @override
  Future<bool?> clearRegisteredFaces() => Future.value(true);
}

void main() {
  final FlutterFaceRecogPlatform initialPlatform =
      FlutterFaceRecogPlatform.instance;

  test('$MethodChannelFlutterFaceRecog is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterFaceRecog>());
  });

  test('getPlatformVersion', () async {
    FlutterFaceRecog flutterFaceRecogPlugin = FlutterFaceRecog();
    MockFlutterFaceRecogPlatform fakePlatform = MockFlutterFaceRecogPlatform();
    FlutterFaceRecogPlatform.instance = fakePlatform;

    expect(await flutterFaceRecogPlugin.getPlatformVersion(), '42');
  });
}
