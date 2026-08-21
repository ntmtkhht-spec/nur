package com.munir.app

import android.content.Context
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.view.Surface
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.munir.app/qibla_heading")
            .setStreamHandler(QiblaHeadingStreamHandler(this))
    }
}

private class QiblaHeadingStreamHandler(
    private val activity: FlutterActivity,
) : EventChannel.StreamHandler, SensorEventListener {
    private val sensorManager = activity.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private var eventSink: EventChannel.EventSink? = null
    private var sensor: Sensor? = null
    private var declinationDegrees = 0.0
    private var sensorAccuracy = SensorManager.SENSOR_STATUS_UNRELIABLE

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        val values = arguments as? Map<*, *> ?: run {
            events?.error("invalid_location", "A valid Qibla location is required.", null)
            return
        }
        val latitude = (values["latitude"] as? Number)?.toDouble()
        val longitude = (values["longitude"] as? Number)?.toDouble()
        if (latitude == null || longitude == null || !latitude.isFinite() || !longitude.isFinite() ||
            latitude !in -90.0..90.0 || longitude !in -180.0..180.0) {
            events?.error("invalid_location", "A valid Qibla location is required.", null)
            return
        }

        declinationDegrees = GeomagneticField(
            latitude.toFloat(),
            longitude.toFloat(),
            0f,
            System.currentTimeMillis(),
        ).declination.toDouble()
        sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        if (sensor == null) {
            events?.error("compass_unavailable", "This device has no rotation-vector sensor.", null)
            return
        }
        eventSink = events
        sensorAccuracy = SensorManager.SENSOR_STATUS_UNRELIABLE
        sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_UI)
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        eventSink = null
        sensor = null
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type != Sensor.TYPE_ROTATION_VECTOR) return
        val rotation = FloatArray(9)
        SensorManager.getRotationMatrixFromVector(rotation, event.values)
        val adjusted = FloatArray(9)
        val (axisX, axisY) = when (displayRotation()) {
            Surface.ROTATION_90 -> SensorManager.AXIS_Y to SensorManager.AXIS_MINUS_X
            Surface.ROTATION_180 -> SensorManager.AXIS_MINUS_X to SensorManager.AXIS_MINUS_Y
            Surface.ROTATION_270 -> SensorManager.AXIS_MINUS_Y to SensorManager.AXIS_X
            else -> SensorManager.AXIS_X to SensorManager.AXIS_Y
        }
        SensorManager.remapCoordinateSystem(rotation, axisX, axisY, adjusted)
        val orientation = FloatArray(3)
        SensorManager.getOrientation(adjusted, orientation)
        val magneticHeading = normalize(Math.toDegrees(orientation[0].toDouble()))
        val accuracyDegrees = event.values.getOrNull(4)
            ?.takeIf { it >= 0f }
            ?.let { Math.toDegrees(it.toDouble()) }
            ?: accuracyFromStatus()
        eventSink?.success(
            mapOf(
                "trueHeading" to normalize(magneticHeading + declinationDegrees),
                "accuracyDegrees" to accuracyDegrees,
            ),
        )
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        sensorAccuracy = accuracy
    }

    @Suppress("DEPRECATION")
    private fun displayRotation(): Int = activity.windowManager.defaultDisplay.rotation

    private fun accuracyFromStatus(): Double = when (sensorAccuracy) {
        SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> 10.0
        SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> 20.0
        SensorManager.SENSOR_STATUS_ACCURACY_LOW -> 45.0
        else -> -1.0
    }

    private fun normalize(degrees: Double): Double = ((degrees % 360) + 360) % 360
}
