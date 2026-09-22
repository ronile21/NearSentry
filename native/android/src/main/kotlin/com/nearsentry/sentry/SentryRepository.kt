package com.nearsentry.sentry

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID

data class SentrySettings(
    val onboardingComplete: Boolean,
    val graceSeconds: Int,
    val soundEnabled: Boolean,
    val vibrationEnabled: Boolean,
    val telemetryRetention: Int,
    val simulationMode: Boolean,
)

data class TelemetryRecord(
    val eventId: String = UUID.randomUUID().toString(),
    val wallTimestamp: String,
    val monotonicMs: Long,
    val previousState: String,
    val nextState: String,
    val trigger: String,
    val source: String,
    val detail: String,
    val anchorId: String?,
    val rssi: Int?,
    val confidence: String?,
    val runtimeGeneration: Int,
    val appVersion: String = "0.1.0.0",
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "eventId" to eventId,
        "wallTimestamp" to wallTimestamp,
        "monotonicMs" to monotonicMs,
        "previousState" to previousState,
        "nextState" to nextState,
        "trigger" to trigger,
        "source" to source,
        "detail" to detail,
        "anchorId" to anchorId,
        "rssi" to rssi,
        "confidence" to confidence,
        "runtimeGeneration" to runtimeGeneration,
        "appVersion" to appVersion,
    )
}

class SentryRepository(context: Context) {
    private val preferences =
        context.applicationContext.getSharedPreferences("nearsentry", Context.MODE_PRIVATE)

    fun settings(): SentrySettings = SentrySettings(
        onboardingComplete = preferences.getBoolean("onboardingComplete", false),
        graceSeconds = preferences.getInt("graceSeconds", 3).coerceIn(1, 15),
        soundEnabled = preferences.getBoolean("soundEnabled", true),
        vibrationEnabled = preferences.getBoolean("vibrationEnabled", true),
        telemetryRetention =
            preferences.getInt("telemetryRetention", 250).coerceIn(50, 1000),
        simulationMode = preferences.getBoolean("simulationMode", false),
    )

    fun saveSettings(settings: SentrySettings) {
        preferences.edit()
            .putBoolean("onboardingComplete", settings.onboardingComplete)
            .putInt("graceSeconds", settings.graceSeconds.coerceIn(1, 15))
            .putBoolean("soundEnabled", settings.soundEnabled)
            .putBoolean("vibrationEnabled", settings.vibrationEnabled)
            .putInt("telemetryRetention", settings.telemetryRetention.coerceIn(50, 1000))
            .putBoolean("simulationMode", settings.simulationMode)
            .putInt("schemaVersion", 1)
            .apply()
        trimTelemetry(settings.telemetryRetention)
    }

    fun saveAnchor(id: String, name: String) {
        preferences.edit()
            .putString("anchorId", id)
            .putString("anchorName", name)
            .apply()
    }

    fun anchorId(): String? = preferences.getString("anchorId", null)
    fun anchorName(): String? = preferences.getString("anchorName", null)

    fun setArmedIntended(value: Boolean) {
        preferences.edit().putBoolean("armedIntended", value).apply()
    }

    fun armedIntended(): Boolean = preferences.getBoolean("armedIntended", false)

    fun nextRuntimeGeneration(): Int {
        val next = preferences.getInt("runtimeGeneration", 0) + 1
        preferences.edit().putInt("runtimeGeneration", next).apply()
        return next
    }

    fun runtimeGeneration(): Int = preferences.getInt("runtimeGeneration", 0)

    fun appendTelemetry(record: TelemetryRecord) {
        val array = readTelemetryArray()
        array.put(JSONObject(record.toMap()))
        val max = settings().telemetryRetention
        val trimmed = JSONArray()
        val start = (array.length() - max).coerceAtLeast(0)
        for (index in start until array.length()) {
            trimmed.put(array.get(index))
        }
        preferences.edit().putString("telemetry", trimmed.toString()).apply()
    }

    fun telemetry(): List<Map<String, Any?>> {
        val array = readTelemetryArray()
        val result = ArrayList<Map<String, Any?>>(array.length())
        for (index in array.length() - 1 downTo 0) {
            val item = array.optJSONObject(index) ?: continue
            result += item.keys().asSequence().associateWith { key ->
                if (item.isNull(key)) null else item.opt(key)
            }
        }
        return result
    }

    private fun trimTelemetry(max: Int) {
        val array = readTelemetryArray()
        if (array.length() <= max) return
        val trimmed = JSONArray()
        for (index in array.length() - max until array.length()) {
            trimmed.put(array.get(index))
        }
        preferences.edit().putString("telemetry", trimmed.toString()).apply()
    }

    private fun readTelemetryArray(): JSONArray {
        val raw = preferences.getString("telemetry", null) ?: return JSONArray()
        return try {
            JSONArray(raw)
        } catch (_: Exception) {
            preferences.edit().remove("telemetry").apply()
            JSONArray()
        }
    }
}
