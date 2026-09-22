# Hardware Validation Matrix

Record evidence per row before declaring a combination supported.

| Phone | Android | Garmin | Firmware | Garmin Connect | Scenario | Result | Notes |
|---|---|---|---|---|---|---|---|
| TBD | TBD | TBD | TBD | TBD | normal disconnect/reconnect | UNVERIFIED | |
| TBD | TBD | TBD | TBD | TBD | screen off 30 min | UNVERIFIED | |
| TBD | TBD | TBD | TBD | TBD | Flutter UI killed | UNVERIFIED | |
| TBD | TBD | TBD | TBD | TBD | Bluetooth toggle | UNVERIFIED | |
| TBD | TBD | TBD | TBD | TBD | watch reboot | UNVERIFIED | |
| TBD | TBD | TBD | TBD | TBD | battery saver | UNVERIFIED | |
| TBD | TBD | TBD | TBD | TBD | overnight soak | UNVERIFIED | |
| TBD | TBD | Fenix 7X | TBD | TBD | watch app foreground separation alarm | UNVERIFIED | Build/install and physical vibration/tone test required |
| TBD | TBD | Fenix 7X | TBD | TBD | Android -> watch TEST_ALARM | UNVERIFIED | Requires sideloaded watch PRG |
| TBD | TBD | Fenix 7X | TBD | TBD | watch background phone message | UNVERIFIED | Validate wake request behavior |
| TBD | TBD | Fenix 7X | TBD | TBD | watch background disconnect fallback | UNVERIFIED | Garmin temporal minimum is five minutes |

## Measurements

For each supported combination capture:
- median / p95 separation detection latency
- false alarms per hour
- missed separation count
- reconnect/recovery latency
- service restart count
- battery delta over controlled duration


## Garmin watch-specific acceptance

Record:
- whether `ARMED` is received after phone protection reaches PROTECTED
- whether foreground `phoneConnected=false` is observed on separation
- elapsed time from disconnect to watch vibration versus configured grace
- whether `TEST_ALARM` opens/prompts the watch app and vibrates
- whether `ALARM_STOP` stops the repeating foreground alarm
- exact behavior of `Background.requestApplicationWake()` on the tested firmware
- whether Garmin's native Phone Connectivity Alert is enabled for immediate system-level background notification
