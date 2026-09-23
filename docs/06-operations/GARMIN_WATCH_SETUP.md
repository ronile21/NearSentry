# Garmin Fenix 7X Setup

## Components

NearSentry version `v0.0.0.1` contains both sides:

- Android: `GarminWatchMessenger`
- Garmin: `watch/garmin/`

Shared Connect IQ application ID:

`d3bc778912b844e69b096a9e1a3e8b42`

## Build

From repository root:

```bat
git checkout v0.0.0.1
git pull --ff-only origin v0.0.0.1
GARMIN_BUILD_WATCH.BAT
```

Expected output:

`watch\garmin\build\NearSentry-fenix7x.prg`

## Install

Connect the Fenix 7X by USB and copy the PRG to:

`GARMIN\APPS\`

Safely disconnect the watch and open NearSentry.

The current build uses `BOOT-2` as its startup marker.

## Pair with Android

1. Keep Garmin Connect installed and the Fenix connected.
2. Install the current NearSentry Android build.
3. Enroll the Fenix as the trusted Garmin anchor.
4. Verify Android Diagnostics can PING the watch.

## Physical controls

- Top-right **START/STOP**: START when disarmed; STOP when armed.
- Bottom-left **DOWN**: MUTE/UNMUTE while ALARM is active.

START is rejected when the watch already reports PHONE DISCONNECTED.

During ALARM, START/STOP cannot disarm. DOWN only mutes the watch output; Android remains alarming until authenticated dismissal.

## Battery model

The one-second connection poll runs only while the NearSentry watch UI is active.

While armed in background:
- phone-app messages are event-driven
- a five-minute temporal watchdog is registered

When stopped, the temporal watchdog is removed.

Connect IQ does not provide an unrestricted one-second background watch-app daemon.

For immediate system-level background separation notification, also enable Garmin's native phone connectivity alert.

See `docs/01-design/GARMIN_WATCH_RUNTIME.md` for the code-level design and validation sequence.
