package com.nearsentry.sentry

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.Ringtone
import android.media.RingtoneManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.core.app.NotificationCompat

class AlarmController(
    private val context: Context,
) {
    private val notificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    private var ringtone: Ringtone? = null
    private var active = false

    init {
        createChannels()
    }

    @Synchronized
    fun start(settings: SentrySettings) {
        if (active) return
        active = true

        val fullScreenIntent = PendingIntent.getActivity(
            context,
            1001,
            Intent(context, AlarmActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val notification = NotificationCompat.Builder(context, ALARM_CHANNEL)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle("NearSentry separation alarm")
            .setContentText("Your trusted device is no longer nearby.")
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setOngoing(true)
            .setAutoCancel(false)
            .setFullScreenIntent(fullScreenIntent, true)
            .setContentIntent(fullScreenIntent)
            .build()

        notificationManager.notify(ALARM_NOTIFICATION_ID, notification)

        if (settings.soundEnabled) {
            val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            ringtone = RingtoneManager.getRingtone(context, uri)?.apply {
                audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
                if (Build.VERSION.SDK_INT >= 28) {
                    isLooping = true
                }
                play()
            }
        }

        if (settings.vibrationEnabled) {
            val effect = VibrationEffect.createWaveform(
                longArrayOf(0, 700, 250, 700, 250),
                1,
            )
            vibrator()?.vibrate(effect)
        }
    }

    @Synchronized
    fun stop() {
        if (!active) return
        active = false
        ringtone?.stop()
        ringtone = null
        vibrator()?.cancel()
        notificationManager.cancel(ALARM_NOTIFICATION_ID)
    }

    fun isActive(): Boolean = active

    private fun vibrator(): Vibrator? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager)
                .defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }
    }

    private fun createChannels() {
        notificationManager.createNotificationChannel(
            NotificationChannel(
                ALARM_CHANNEL,
                "NearSentry alarms",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Security separation alarms"
                setSound(null, null)
                enableVibration(false)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            },
        )
        notificationManager.createNotificationChannel(
            NotificationChannel(
                MONITORING_CHANNEL,
                "NearSentry protection",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Persistent protection status while NearSentry is armed"
                setSound(null, null)
            },
        )
    }

    companion object {
        const val ALARM_CHANNEL = "nearsentry_alarm_v1"
        const val MONITORING_CHANNEL = "nearsentry_monitoring_v1"
        const val ALARM_NOTIFICATION_ID = 4102
        const val MONITORING_NOTIFICATION_ID = 4101
    }
}
