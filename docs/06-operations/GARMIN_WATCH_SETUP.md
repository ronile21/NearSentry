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

A Garmin developer signing key is required. NearSentry currently has the developer key under:

`watch\garmin\developer_key`

The build script can also use an existing key referenced by the `CIQ_DEVELOPER_KEY` environment variable. Signing keys must not be committed or redistributed.

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

Copy:

`watch\garmin\build\NearSentry-fenix7x.prg`

to:

`GARMIN\APPS\`

Safely disconnect the watch and open NearSentry.

The current build uses `BOOT-2` as the startup marker.

## Android build

From repository root:

```bat
ANDROID_BUILD_INSTALL.BAT
```

Keep Garmin Connect installed and connected to the Fenix.

## Pair with Android

1. Install the current Android build.
2. Enroll the Fenix as the trusted Garmin anchor.
3. Open Diagnostics.
4. Press **Ping watch**.
5. Confirm the watch Last field changes to PING.

## Physical controls

The controls use Garmin behavior mappings rather than hard-coded key numbers.

- Top-right **START/STOP**: START protection while DISARMED; STOP while ARMED.
- Bottom-left **DOWN**: MUTE/UNMUTE while ALARM is active.

START is rejected when the watch already reports PHONE DISCONNECTED.

During ALARM:
- START/STOP cannot disarm protection.
- DOWN changes only watch-local alarm output.
- Android remains in ALARM until authenticated dismissal.

## MUTE semantics

MUTE keeps the watch in ALARM.

It:
- stops repeating watch sound/vibration output
- persists across closing/reopening the watch app
- does not clear pending alarm state
- does not disarm
- does not mute the Android alarm

DOWN again performs UNMUTE.

A Garmin tone that has already started is short and has no documented Connect IQ cancellation API; MUTE prevents subsequent tones.

## Separation test

For the short-grace custom watch alarm:

1. Open NearSentry on the Fenix.
2. Press START/STOP and verify ARMED.
3. Turn Bluetooth off on Android or physically separate the devices.
4. The watch foreground detector checks `phoneConnected` once per second.
5. After the configured grace period, verify ALARM + vibration + sound.
6. Press DOWN and verify WATCH MUTED.
7. Verify Android continues alarming.
8. Press DOWN again to resume watch alarm output.

## Background and battery behavior

The one-second connection poll runs only while the NearSentry watch UI is active.

While armed in background:
- phone-app messages are event-driven
- a five-minute temporal watchdog is registered

When stopped:
- the temporal watchdog is deleted

Connect IQ does not provide an unrestricted continuously running one-second watch-app background daemon. The five-minute watchdog is a fallback/recovery mechanism, not a three-second custom background alarm guarantee.

For immediate platform-level background separation notification, Garmin's native Phone Connectivity Alert should also be enabled.

## Watch-to-Android controls

START and STOP transmit best-effort CONTROL messages to Android.

Android registers a Connect IQ app-message listener while its process is alive and retries briefly during SDK startup. A fully killed Android process cannot be treated as reliably wakeable by a Connect IQ callback.

## Detailed design

See:

- `docs/01-design/GARMIN_WATCH_RUNTIME.md`
- `docs/03-decisions/ADR-0007-watch-local-controls-and-mute.md`
