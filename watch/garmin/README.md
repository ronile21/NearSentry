# NearSentry Garmin Watch App

Target: Garmin Fenix 7X (`fenix7x`).

Connect IQ application ID:

`d3bc778912b844e69b096a9e1a3e8b42`

This ID is also compiled into the Android Garmin messenger and must remain identical.

## Behavior

The watch app stores the phone's ARMED/DISARMED state and synchronizes the configured grace interval.

While the NearSentry watch app is in the foreground, it polls Garmin's `System.getDeviceSettings().phoneConnected` state once per second. If the phone stays disconnected longer than the synchronized grace period, it starts a repeating vibration/tone alarm.

The app also receives these phone commands:

- `ARMED`
- `DISARMED`
- `ALARM`
- `ALARM_STOP`
- `TEST_ALARM`

A Connect IQ background service registers for phone-app messages. When armed it also registers Garmin's minimum periodic background check (five minutes). If that background check sees the phone disconnected, it requests an application wake and marks an alarm pending.

## Garmin platform limitation

Connect IQ does not allow `Toybox.Attention.vibrate()` or `playTone()` from a background process. There is also no immediate background event for a phone-disconnect transition.

Consequently:

- immediate NearSentry-controlled watch vibration is available while the watch app is active;
- background phone messages can request an application wake;
- an armed background fallback can detect disconnection on Garmin's minimum five-minute temporal interval and request a wake;
- the Garmin system's own Phone Connectivity Alert remains the only platform-level immediate background disconnect alert when the NearSentry device app is not active.

This limitation is a Garmin runtime constraint, not a NearSentry state-machine decision.

## Build

From the repository root:

```bat
GARMIN_BUILD_WATCH.BAT
```

The build output is:

`watch\garmin\build\NearSentry-fenix7x.prg`

A developer signing key is required. The build script first looks for `watch\garmin\developer_key.der`, then for the optional `CIQ_DEVELOPER_KEY` environment variable. If no key is available, use VS Code → Command Palette → **Monkey C: Generate a Developer Key** and save it as `watch\garmin\developer_key.der`. Developer keys are ignored by Git.

The script supports both Connect IQ SDK layouts where `monkeyc.bat` is located in the SDK root (including SDK 9.2.0 on Windows) and older layouts where it is under `bin\`.

## Sideload

Connect the Fenix 7X to the computer and copy the generated PRG to:

`GARMIN\APPS\`

Then disconnect the watch safely and launch NearSentry from the watch's Apps list.
