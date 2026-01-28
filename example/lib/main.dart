import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_recog/flutter_face_recog.dart';

List<CameraDescription> _cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    _cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterFaceRecogPlugin = FlutterFaceRecog();
  CameraController? _controller;
  String _platformVersion = 'Unknown';
  String _status = 'Idle';
  String _recognizedName = '-';
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _initCamera();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _flutterFaceRecogPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _initCamera() async {
    if (_cameras.isEmpty) return;

    // Use Front camera if available
    CameraDescription? frontCamera;
    try {
      frontCamera = _cameras
          .firstWhere((c) => c.lensDirection == CameraLensDirection.front);
    } catch (e) {
      frontCamera = _cameras.first;
    }

    _controller = CameraController(
      frontCamera ?? _cameras.first,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg, // Important for Plugin
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (e is CameraException) {
        print('Camera Access Error: ${e.code}');
      }
    }
  }

  Future<Uint8List?> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;
    try {
      // Note: for real-time, we might use startImageStream.
      // For simplicity/stability in this demo, we take a static picture.
      final XFile file = await _controller!.takePicture();
      return await file.readAsBytes();
    } catch (e) {
      print("Take Picture Error: $e");
      return null;
    }
  }

  Future<void> _registerFace() async {
    if (_nameController.text.isEmpty) {
      setState(() => _status = "Please enter name");
      return;
    }
    setState(() => _status = "Capturing...");

    final imageBytes = await _takePicture();
    if (imageBytes == null) return;

    setState(() => _status = "Registering...");

    try {
      bool? success = await _flutterFaceRecogPlugin.registerFace(
          _nameController.text, imageBytes);
      setState(() => _status = success == true
          ? "Registered: ${_nameController.text}"
          : "Registration Failed");
    } catch (e) {
      setState(() => _status = "Error: $e");
    }
  }

  Future<void> _recognizeFace() async {
    setState(() => _status = "Capturing...");
    final imageBytes = await _takePicture();
    if (imageBytes == null) return;

    setState(() => _status = "Recognizing...");
    try {
      String? name = await _flutterFaceRecogPlugin.recognizeFace(imageBytes);
      setState(() {
        _recognizedName = name ?? "Unknown";
        _status = "Done";
      });
    } catch (e) {
      setState(() => _status = "Error: $e");
    }
  }

  Future<void> _clearFaces() async {
    await _flutterFaceRecogPlugin.clearRegisteredFaces();
    setState(() {
      _status = "Cleared All Faces";
      _recognizedName = "-";
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Face Recog Example'),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 300,
              width: 300,
              child: CameraPreview(_controller!),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Status: $_status',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Recognized: $_recognizedName',
                  style: const TextStyle(fontSize: 20, color: Colors.blue)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Name to Register',
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: _registerFace,
                    child: const Text("Register Face")),
                ElevatedButton(
                    onPressed: _recognizeFace,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: const Text("Recognize")),
              ],
            ),
            ElevatedButton(
                onPressed: _clearFaces,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Clear All Data")),
          ],
        ),
      ),
    );
  }
}
