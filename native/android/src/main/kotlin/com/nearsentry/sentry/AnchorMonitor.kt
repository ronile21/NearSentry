package com.nearsentry.sentry

interface AnchorMonitor {
    suspend fun start()
    suspend fun stop()
}
