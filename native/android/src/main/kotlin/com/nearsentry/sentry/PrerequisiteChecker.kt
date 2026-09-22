package com.nearsentry.sentry

import android.Manifest
import android.app.NotificationManager
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.PowerManager
import androidx.core.content.ContextCompat

class PrerequisiteChecker(
    private val context: Context,
) {
    fun snapshot(): List<Map<String, Any?>> {
        val bluetoothManager =
            context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val adapter: BluetoothAdapter? = bluetoothManager.adapter

        val bluetoothPermission = Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_CONNECT,
            ) == PackageManager.PERMISSION_GRANTED

        val notificationPermission =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
                ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.POST_NOTIFICATIONS,
                ) == PackageManager.PERMISSION_GRANTED

        val notificationsEnabled =
            (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .areNotificationsEnabled()

        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val ignoringBattery =
            powerManager.isIgnoringBatteryOptimizations(context.packageName)

        val fullScreenAllowed = if (Build.VERSION.SDK_INT >= 34) {
            (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .canUseFullScreenIntent()
        } else {
            true
        }

        return listOf(
            item(
                "bluetoothPermission",
                "Nearby device permission",
                bluetoothPermission,
                true,
                if (bluetoothPermission) "Granted" else "Required to observe the trusted Garmin device",
            ),
            item(
                "bluetoothEnabled",
                "Bluetooth",
                adapter?.isEnabled == true,
                true,
                if (adapter?.isEnabled == true) "Enabled" else "Bluetooth must be enabled",
            ),
            item(
                "notificationPermission",
                "Notifications",
                notificationPermission && notificationsEnabled,
                true,
                if (notificationPermission && notificationsEnabled) {
                    "Allowed"
                } else {
                    "Required for the foreground monitoring notification"
                },
            ),
            item(
                "batteryOptimization",
                "Battery optimization",
                ignoringBattery,
                false,
                if (ignoringBattery) {
                    "NearSentry is exempt"
                } else {
                    "Recommended: OEM battery policies can interrupt background monitoring"
                },
            ),
            item(
                "fullScreenIntent",
                "Full-screen alarm",
                fullScreenAllowed,
                false,
                if (fullScreenAllowed) {
                    "Allowed"
                } else {
                    "Optional; notification/audio/vibration still remain available"
                },
            ),
        )
    }

    fun requiredReady(): Boolean =
        snapshot().filter { it["required"] == true }.all { it["ready"] == true }

    private fun item(
        id: String,
        label: String,
        ready: Boolean,
        required: Boolean,
        detail: String,
    ): Map<String, Any?> = mapOf(
        "id" to id,
        "label" to label,
        "ready" to ready,
        "required" to required,
        "detail" to detail,
    )
}
