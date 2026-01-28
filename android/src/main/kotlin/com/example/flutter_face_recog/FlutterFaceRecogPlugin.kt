package com.example.flutter_face_recog

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetector
import com.example.flutter_face_recog.FaceRecognizer

/** FlutterFaceRecogPlugin */
class FlutterFaceRecogPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var faceRecognizer: FaceRecognizer
    private lateinit var faceDetector: FaceDetector

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_face_recog")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        
        // Init components
        faceRecognizer = FaceRecognizer(context)
        faceDetector = FaceDetection.getClient()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "registerFace" -> {
                val name = call.argument<String>("name")
                val imageBytes = call.argument<ByteArray>("image")
                if (name != null && imageBytes != null) {
                    processImage(imageBytes, result) { bitmap ->
                        faceRecognizer.registerFace(name, bitmap)
                        result.success(true)
                    }
                } else {
                    result.error("INVALID_ARGS", "Name or Image missing", null)
                }
            }
            "recognizeFace" -> {
                val imageBytes = call.argument<ByteArray>("image")
                if (imageBytes != null) {
                    processImage(imageBytes, result) { bitmap ->
                        val name = faceRecognizer.recognizeFace(bitmap)
                        result.success(name) // Returns name or null
                    }
                } else {
                    result.error("INVALID_ARGS", "Image missing", null)
                }
            }
            "clearRegisteredFaces" -> {
                faceRecognizer.clearRegistered()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun processImage(imageBytes: ByteArray, result: Result, onSuccess: (Bitmap) -> Unit) {
        try {
            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            if (bitmap == null) {
                result.error("DECODE_ERROR", "Failed to decode bitmap", null)
                return
            }

            // 1. Detect Face using ML Kit
            val inputImage = InputImage.fromBitmap(bitmap, 0)
            faceDetector.process(inputImage)
                .addOnSuccessListener { faces ->
                    if (faces.isNotEmpty()) {
                        // Use the first face found
                        val face = faces[0]
                        val bounds = face.boundingBox
                        
                        // 2. Crop Face
                        // Ensure bounds are within bitmap dimensions
                        var x = bounds.left
                        var y = bounds.top
                        var w = bounds.width()
                        var h = bounds.height()

                        if (x < 0) x = 0
                        if (y < 0) y = 0
                        if (x + w > bitmap.width) w = bitmap.width - x
                        if (y + h > bitmap.height) h = bitmap.height - y

                        val croppedBitmap = Bitmap.createBitmap(bitmap, x, y, w, h)
                        
                        // 3. Callback for Recognition
                        onSuccess(croppedBitmap)
                    } else {
                        // No face detected
                        result.success(null) 
                    }
                }
                .addOnFailureListener { e ->
                    result.error("DETECTION_ERROR", e.message, null)
                }
        } catch (e: Exception) {
             result.error("PROCESS_ERROR", e.message, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
