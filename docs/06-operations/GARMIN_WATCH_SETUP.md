# Garmin Fenix 7X Setup

## Components

NearSentry version `v0.0.0.1` contains both sides:

- Android: `GarminWatchMessenger`
- Garmin: `watch/garmin/`

Shared Connect IQ application ID:

`d3bc778912b844e69b096a9e1a3e8b42`

## Prerequisites

Install Garmin Connect IQ SDK Manager on Windows, download an SDK, and set it as current.

The build script reads:

`%APPDATA%\Garmin\ConnectIQ\current-sdk.cfg`

A Garmin developer signing key is also required. With the Garmin Monkey C VS Code extension installed, use **Ctrl+Shift+P → Monkey C: Generate a Developer Key** and save it as:

`watch\garmin\developer_key.der`

The build script can also use an existing key referenced by the `CIQ_DEVELOPER_KEY` environment variable. Keys are intentionally ignored by Git.

Connect IQ SDK 9.2.0 on Windows may place `monkeyc.bat` directly in the SDK root rather than under `bin\`; the NearSentry build script supports both layouts.

## Build

From repository root:

```bat
git checkout v0.0.0.1
git pull --ff-only origin v0.0.0.1
GARMIN_BUILD_WATCH.BAT
```

Expected output:

`watch\garmin\build\NearSentry-fenix7x.prg`

## Install on the Fenix 7X

Connect the Fenix 7X to the computer by USB.

Use Garmin's normal sideload path for a Connect IQ PRG and copy:

`NearSentry-fenix7x.prg`

to:

`GARMIN\APPS\`

Safely disconnect the watch. NearSentry should appear in the Apps list.

## Pair with Android

1. Keep Garmin Connect installed and the Fenix connected.
2. Install the latest NearSentry Android build.
3. In NearSentry, enroll the Fenix as the trusted Garmin device.
4. Open Diagnostics.
5. Press **Test watch alarm** while the watch is connected.
6. The Android diagnostics field `Watch app status` should no longer report `watch:not_installed`.
7. Arm phone protection and verify that the watch receives `ARMED`.

## Separation test

For immediate NearSentry-controlled watch vibration, keep the NearSentry watch app active, arm the phone, and then move the watch/phone apart.

The watch independently checks Garmin's `phoneConnected` state and applies the synchronized grace interval.

## Platform limitation

Garmin Connect IQ does not allow `Toybox.Attention.vibrate()` or `playTone()` in a background process. A background app also has no immediate phone-disconnect callback. The implemented background fallback therefore uses Garmin's minimum five-minute temporal event plus `requestApplicationWake()`.

For immediate watch attention while NearSentry is not foreground, Garmin's native Phone Connectivity Alert should also be enabled on the watch. Exact settings-menu wording can vary by firmware.
