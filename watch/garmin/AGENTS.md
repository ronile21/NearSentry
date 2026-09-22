# Garmin Watch Agent Contract

Scope: `watch/garmin/`.

- Target the Fenix 7X Connect IQ product ID `fenix7x` unless the human explicitly expands support.
- Keep the Connect IQ application ID synchronized with `GarminWatchMessenger.WATCH_APP_ID`.
- Do not claim `Toybox.Attention` works in background context.
- Do not reduce Garmin's temporal-event minimum below platform limits.
- The foreground watch app may independently evaluate `phoneConnected`; the Android phone remains the authoritative protected-device enforcement runtime.
- Never add a cloud/backend dependency for watch signaling without an explicit ADR.
- Changes to the phone/watch command protocol must update Android, watch code, docs, and diagnostics together.
- A successful source review is not a successful `monkeyc` build or physical Fenix validation.
