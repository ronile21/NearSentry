package com.nearsentry.sentry

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import androidx.core.app.NotificationCompat

class AlarmController(
    private val context: Context,
) {
    private val notificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    private val audioManager =
        context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

    private val alarmAudioAttributes =
        AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

    private val audioFocusRequest =
        AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
            .setAudioAttributes(alarmAudioAttributes)
            .setOnAudioFocusChangeListener { change ->
                Log.i(TAG, "Audio focus changed: $change")
            }
            .build()

    private var mediaPlayer: MediaPlayer? = null
    private var active = false
    private var previousAlarmVolume: Int? = null
    private var audioFocusGranted = false

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
            startAlarmAudio()
        } else {
            Log.i(TAG, "Alarm sound disabled by NearSentry settings")
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

        stopAlarmAudio()
        vibrator()?.cancel()
        notificationManager.cancel(ALARM_NOTIFICATION_ID)
    }

    fun isActive(): Boolean = active

    private fun startAlarmAudio() {
        val focusResult = audioManager.requestAudioFocus(audioFocusRequest)
        audioFocusGranted = focusResult == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        Log.i(TAG, "Audio focus request result: $focusResult")

        if (!audioManager.isVolumeFixed) {
            previousAlarmVolume =
                audioManager.getStreamVolume(AudioManager.STREAM_ALARM)
            val maxVolume =
                audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            try {
                audioManager.setStreamVolume(
                    AudioManager.STREAM_ALARM,
                    maxVolume,
                    0,
                )
                Log.i(
                    TAG,
                    "Alarm stream volume raised from $previousAlarmVolume to $maxVolume",
                )
            } catch (error: SecurityException) {
                Log.w(TAG, "Unable to raise alarm stream volume", error)
            }
        }

        val uri =
            RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

        if (uri == null) {
            Log.e(TAG, "No system alarm or notification sound URI is available")
            return
        }

        try {
            mediaPlayer?.release()
            mediaPlayer =
                MediaPlayer().apply {
                    setAudioAttributes(alarmAudioAttributes)
                    setDataSource(context, uri)
                    isLooping = true
                    setVolume(1.0f, 1.0f)
                    prepare()
                    start()
                }
            Log.i(TAG, "Alarm audio started with URI: $uri")
        } catch (error: Exception) {
            Log.e(TAG, "Failed to start alarm audio", error)
            mediaPlayer?.release()
            mediaPlayer = null
        }
    }

    private fun stopAlarmAudio() {
        try {
            mediaPlayer?.stop()
        } catch (_: IllegalStateException) {
        }
        mediaPlayer?.release()
        mediaPlayer = null

        if (audioFocusGranted) {
            audioManager.abandonAudioFocusRequest(audioFocusRequest)
            audioFocusGranted = false
        }

        val originalVolume = previousAlarmVolume
        previousAlarmVolume = null
        if (originalVolume != null && !audioManager.isVolumeFixed) {
            try {
                audioManager.setStreamVolume(
                    AudioManager.STREAM_ALARM,
                    originalVolume,
                    0,
                )
                Log.i(TAG, "Alarm stream volume restored to $originalVolume")
            } catch (error: SecurityException) {
                Log.w(TAG, "Unable to restore alarm stream volume", error)
            }
        }
    }

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
        private const val TAG = "NearSentryAlarm"
        const val ALARM_CHANNEL = "nearsentry_alarm_v1"
        const val MONITORING_CHANNEL = "nearsentry_monitoring_v1"
        const val ALARM_NOTIFICATION_ID = 4102
        const val MONITORING_NOTIFICATION_ID = 4101
    }
}
