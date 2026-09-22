package com.nearsentry.app

import android.Manifest
import android.app.NotificationManager
import android.bluetooth.BluetoothAdapter
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.activity.result.contract.ActivityResultContracts
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import com.nearsentry.sentry.SentryRuntime
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private lateinit var runtime: SentryRuntime
    private var pendingPermissionResult: MethodChannel.Result? = null

    private val permissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) {
            pendingPermissionResult?.success(true)
            pendingPermissionResult = null
            runtime.publishSnapshot()
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        runtime = SentryRuntime.get(applicationContext)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CONTROL_CHANNEL,
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "getCurrentSnapshot" -> result.success(runtime.snapshot())
                    "getSettings" -> result.success(runtime.settings())
                    "getRecentTelemetry" -> result.success(runtime.telemetry())
                    "getAvailableAnchors" -> result.success(runtime.availableAnchors())
                    "pingWatch" -> {
                        runtime.pingWatch()
                        result.success(null)
                    }
                    "testWatchAlarm" -> {
                        runtime.testWatchAlarm()
                        result.success(null)
                    }
                    "stopWatchAlarm" -> {
                        runtime.stopWatchAlarm()
                        result.success(null)
                    }
                    "enrollAnchor" -> {
                        runtime.enrollAnchor(call.argument<String>("id").orEmpty())
                        result.success(null)
                    }
                    "arm" -> {
                        runtime.arm()
                        result.success(null)
                    }
                    "disarm" -> {
                        runtime.disarm("user")
                        result.success(null)
                    }
                    "requestAuthenticatedDismissal" -> authenticateDismissal(result)
                    "updateSettings" -> {
                        @Suppress("UNCHECKED_CAST")
                        runtime.updateSettings(call.arguments as? Map<String, Any?> ?: emptyMap())
                        result.success(null)
                    }
                    "requestPrerequisiteAction" ->
                        handlePrerequisiteAction(call.argument<String>("id").orEmpty(), result)
                    "simulate" -> {
                        runtime.simulate(call.argument<String>("action").orEmpty())
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                result.error("NEARSENTRY_ERROR", error.message, null)
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL,
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                runtime.setEventSink { event -> runOnUiThread { events?.success(event) } }
                runtime.publishSnapshot()
            }

            override fun onCancel(arguments: Any?) {
                runtime.setEventSink(null)
            }
        })
    }

    override fun onResume() {
        super.onResume()
        if (::runtime.isInitialized) {
            runtime.publishSnapshot()
        }
    }

    private fun authenticateDismissal(result: MethodChannel.Result) {
        if (runtime.snapshot()["state"] != "alarm") {
            result.success(false)
            return
        }

        val authenticators =
            BiometricManager.Authenticators.BIOMETRIC_STRONG or
                BiometricManager.Authenticators.DEVICE_CREDENTIAL
        val manager = BiometricManager.from(this)
        if (manager.canAuthenticate(authenticators) != BiometricManager.BIOMETRIC_SUCCESS) {
            result.error(
                "AUTH_UNAVAILABLE",
                "Strong biometric or device credential authentication is unavailable.",
                null,
            )
            return
        }

        val prompt = BiometricPrompt(
            this,
            ContextCompat.getMainExecutor(this),
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(
                    authenticationResult: BiometricPrompt.AuthenticationResult,
                ) {
                    runtime.authenticatedDismissal()
                    result.success(true)
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    result.success(false)
                }
            },
        )

        prompt.authenticate(
            BiometricPrompt.PromptInfo.Builder()
                .setTitle("Dismiss NearSentry alarm")
                .setSubtitle("Confirm that the phone is back under your control")
                .setAllowedAuthenticators(authenticators)
                .build(),
        )
    }

    private fun handlePrerequisiteAction(id: String, result: MethodChannel.Result) {
        when (id) {
            "bluetoothPermission", "notificationPermission" -> {
                val permissions = mutableListOf<String>()
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    permissions += Manifest.permission.BLUETOOTH_CONNECT
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    permissions += Manifest.permission.POST_NOTIFICATIONS
                }
                if (permissions.isEmpty()) {
                    result.success(true)
                } else {
                    pendingPermissionResult = result
                    permissionLauncher.launch(permissions.toTypedArray())
                }
            }

            "bluetoothEnabled" -> {
                startActivity(Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE))
                result.success(true)
            }

            "batteryOptimization" -> {
                startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                result.success(true)
            }

            "notifications" -> {
                val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                }
                startActivity(intent)
                result.success(true)
            }

            "fullScreenIntent" -> {
                if (Build.VERSION.SDK_INT >= 34) {
                    startActivity(
                        Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT).apply {
                            data = Uri.parse("package:$packageName")
                        },
                    )
                }
                result.success(true)
            }

            else -> result.success(false)
        }
    }

    companion object {
        private const val CONTROL_CHANNEL = "nearsentry/control"
        private const val EVENT_CHANNEL = "nearsentry/events"
    }
}
