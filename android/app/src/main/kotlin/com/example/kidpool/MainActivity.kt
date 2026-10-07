package com.example.kidpool

import android.net.Uri
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kidpool/face_detection")
            .setMethodCallHandler { call, result ->
                if (call.method != "detectFaces") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val path = call.argument<String>("path")
                if (path == null) {
                    result.error("bad_args", "Missing photo path", null)
                    return@setMethodCallHandler
                }
                detectFaces(path, result)
            }
    }

    /**
     * `kidpool/face_detection`: finds faces in a photo file with ML Kit
     * (on-device, no network). iOS does the same with Vision in
     * AppDelegate.swift; the Dart side decides whether a selfie passes.
     *
     * Each face is a box normalised to 0..1 (top-left origin) of the upright
     * photo, plus head yaw/roll in degrees.
     */
    private fun detectFaces(path: String, result: MethodChannel.Result) {
        val image = try {
            // Applies the photo's EXIF rotation.
            InputImage.fromFilePath(this, Uri.fromFile(File(path)))
        } catch (e: Exception) {
            result.error("detection_failed", "Couldn't read the photo: ${e.message}", null)
            return
        }
        val rotated = image.rotationDegrees == 90 || image.rotationDegrees == 270
        val width = (if (rotated) image.height else image.width).toDouble()
        val height = (if (rotated) image.width else image.height).toDouble()

        val detector = FaceDetection.getClient(
            FaceDetectorOptions.Builder()
                .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
                .build()
        )
        detector.process(image)
            .addOnSuccessListener { faces ->
                result.success(faces.map { face ->
                    val box = face.boundingBox
                    mapOf(
                        "left" to box.left / width,
                        "top" to box.top / height,
                        "width" to box.width() / width,
                        "height" to box.height() / height,
                        "yaw" to face.headEulerAngleY.toDouble(),
                        "roll" to face.headEulerAngleZ.toDouble(),
                    )
                })
            }
            .addOnFailureListener { e ->
                result.error("detection_failed", e.message, null)
            }
            .addOnCompleteListener { detector.close() }
    }
}
