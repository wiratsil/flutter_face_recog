package com.example.flutter_face_recog

import android.content.Context
import android.content.res.AssetFileDescriptor
import android.graphics.Bitmap
import android.graphics.Matrix
import android.util.Log
import org.tensorflow.lite.Interpreter
import java.io.FileInputStream
import java.io.IOException
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel
import java.util.HashMap

class FaceRecognizer(private val context: Context) {

    private var tfLite: Interpreter? = null
    private val registered = HashMap<String, FloatArray>()
    private val INPUT_SIZE = 112
    private val OUTPUT_SIZE = 192
    private val IMAGE_MEAN = 128.0f
    private val IMAGE_STD = 128.0f

    init {
        loadModel()
    }

    private fun loadModel() {
        try {
            val modelFile = "mobile_face_net.tflite"
            val options = Interpreter.Options()
            options.setNumThreads(4)
            tfLite = Interpreter(loadModelFile(context, modelFile), options)
            Log.d("FaceRecognizer", "Model loaded successfully")
        } catch (e: Exception) {
            e.printStackTrace()
            Log.e("FaceRecognizer", "Error loading model", e)
        }
    }

    @Throws(IOException::class)
    private fun loadModelFile(context: Context, modelFile: String): MappedByteBuffer {
        val fileDescriptor = context.assets.openFd(modelFile)
        val inputStream = FileInputStream(fileDescriptor.fileDescriptor)
        val fileChannel = inputStream.channel
        val startOffset = fileDescriptor.startOffset
        val declaredLength = fileDescriptor.declaredLength
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
    }

    fun registerFace(name: String, bitmap: Bitmap) {
        val embedding = getEmbedding(bitmap)
        if (embedding != null) {
            registered[name] = embedding
        }
    }

    fun recognizeFace(bitmap: Bitmap): String? {
        val embedding = getEmbedding(bitmap) ?: return null
        return findNearest(embedding)
    }

    fun clearRegistered() {
        registered.clear()
    }

    private fun getEmbedding(bitmap: Bitmap): FloatArray? {
        if (tfLite == null) return null

        val resizedBitmap = getResizedBitmap(bitmap, INPUT_SIZE, INPUT_SIZE)
        val imgData = convertBitmapToByteBuffer(resizedBitmap)

        val inputArray = arrayOf<Any>(imgData)
        val outputMap = HashMap<Int, Any>()
        val embeddings = Array(1) { FloatArray(OUTPUT_SIZE) }
        outputMap[0] = embeddings

        tfLite?.runForMultipleInputsOutputs(inputArray, outputMap)

        return embeddings[0]
    }

    private fun findNearest(emb: FloatArray): String? {
        if (registered.isEmpty()) return null

        var bestName: String? = null
        var bestDistance = Float.MAX_VALUE

        for ((name, knownEmb) in registered) {
            var distance = 0f
            for (i in emb.indices) {
                val diff = emb[i] - knownEmb[i]
                distance += diff * diff
            }
            distance = Math.sqrt(distance.toDouble()).toFloat()

            if (distance < bestDistance) {
                bestDistance = distance
                bestName = name
            }
        }

        // Threshold logic from legacy code (distance < 1.0f)
        return if (bestDistance < 1.0f) bestName else null
    }

    private fun getResizedBitmap(bm: Bitmap, newWidth: Int, newHeight: Int): Bitmap {
        val width = bm.width
        val height = bm.height
        val scaleWidth = newWidth.toFloat() / width
        val scaleHeight = newHeight.toFloat() / height
        val matrix = Matrix()
        matrix.postScale(scaleWidth, scaleHeight)
        return Bitmap.createBitmap(bm, 0, 0, width, height, matrix, false)
    }

    private fun convertBitmapToByteBuffer(bitmap: Bitmap): ByteBuffer {
        val imgData = ByteBuffer.allocateDirect(INPUT_SIZE * INPUT_SIZE * 3 * 4)
        imgData.order(ByteOrder.nativeOrder())
        val intValues = IntArray(INPUT_SIZE * INPUT_SIZE)
        bitmap.getPixels(intValues, 0, bitmap.width, 0, 0, bitmap.width, bitmap.height)
        imgData.rewind()
        for (i in 0 until INPUT_SIZE) {
            for (j in 0 until INPUT_SIZE) {
                val pixelValue = intValues[i * INPUT_SIZE + j]
                imgData.putFloat(((pixelValue shr 16 and 0xFF) - IMAGE_MEAN) / IMAGE_STD)
                imgData.putFloat(((pixelValue shr 8 and 0xFF) - IMAGE_MEAN) / IMAGE_STD)
                imgData.putFloat(((pixelValue and 0xFF) - IMAGE_MEAN) / IMAGE_STD)
            }
        }
        return imgData
    }
}
