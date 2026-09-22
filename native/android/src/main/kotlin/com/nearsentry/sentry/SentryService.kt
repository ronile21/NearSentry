package com.nearsentry.sentry

import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat

class SentryService : Service() {
    private lateinit var runtime: SentryRuntime

    override fun onCreate() {
        super.onCreate()
        runtime = SentryRuntime.get(applicationContext)

        val notification = NotificationCompat.Builder(
            this,
            AlarmController.MONITORING_CHANNEL,
        )
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .setContentTitle("NearSentry protection active")
            .setContentText("Monitoring your trusted device")
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()

        ServiceCompat.startForeground(
            this,
            AlarmController.MONITORING_NOTIFICATION_ID,
            notification,
            ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE,
        )
        runtime.onServiceStarted()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        runtime.startMonitoringIfArmed()
        return START_STICKY
    }

    override fun onDestroy() {
        runtime.onServiceStopped()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
