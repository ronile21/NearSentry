package com.nearsentry.sentry

data class AnchorDescriptor(
    val id: String,
    val name: String,
    val status: String,
)

enum class AnchorStatus {
    PRESENT,
    ABSENT,
    UNKNOWN,
}

data class AnchorObservation(
    val anchorId: String,
    val monotonicTimestampMs: Long,
    val status: AnchorStatus,
    val source: String,
    val rssi: Int? = null,
    val confidence: String,
    val diagnosticReason: String,
)

interface AnchorMonitor {
    fun start(
        enrolledAnchorId: String?,
        listener: (AnchorObservation) -> Unit,
    )

    fun stop()

    fun availableAnchors(): List<AnchorDescriptor>
}
