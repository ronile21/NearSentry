using Toybox.Attention as Attention;
using Toybox.System as System;
using Toybox.Timer as Timer;
using Toybox.WatchUi as WatchUi;

class NearSentryController {
    var _view;
    var _connectionTimer;
    var _alarmTimer;
    var _disconnectedAt;
    var _alarmActive;

    function initialize(view) {
        _view = view;
        _connectionTimer = new Timer.Timer();
        _alarmTimer = new Timer.Timer();
        _disconnectedAt = null;
        _alarmActive = false;

        _connectionTimer.start(method(:pollConnection), 1000, true);
        restoreState();
    }

    function shutdown() as Void {
        try {
            _connectionTimer.stop();
        } catch (error) {
        }
        try {
            _alarmTimer.stop();
        } catch (error) {
        }
    }

    function restoreState() as Void {
        var connected = System.getDeviceSettings().phoneConnected;
        _view.setPhoneConnected(connected);
        _view.setArmed(NearSentryState.isArmed());
        _view.setLastCommand(NearSentryState.getLastCommand());

        if (NearSentryState.isAlarmPending()) {
            startAlarm(NearSentryState.getLastReason());
        } else if (NearSentryState.isArmed() && !connected) {
            _disconnectedAt = System.getTimer();
        } else {
            stopAlarm(false);
        }
        WatchUi.requestUpdate();
    }

    function handlePhoneMessage(data) as Void {
        var command = NearSentryState.commandFrom(data);
        if (command == null) {
            return;
        }

        NearSentryState.setLastCommand(command);
        NearSentryState.setGraceMs(NearSentryState.graceFrom(data));
        _view.setLastCommand(command);

        if (command == "ARMED") {
            NearSentryState.setArmed(true);
            NearSentryState.setAlarmPending(false);
            _view.setArmed(true);
            _disconnectedAt = null;
            stopAlarm(false);
        } else if (command == "DISARMED" || command == "ALARM_STOP") {
            NearSentryState.setArmed(false);
            NearSentryState.setAlarmPending(false);
            _view.setArmed(false);
            _disconnectedAt = null;
            stopAlarm(true);
        } else if (command == "ALARM" || command == "TEST_ALARM") {
            NearSentryState.setAlarmPending(true);
            var reason = NearSentryState.reasonFrom(data);
            NearSentryState.setLastReason(
                reason.length() > 0 ? reason : "phone_alarm"
            );
            startAlarm(NearSentryState.getLastReason());
        }

        WatchUi.requestUpdate();
    }

    function onPhoneConnectedChanged(connected) as Void {
        _view.setPhoneConnected(connected);

        if (!NearSentryState.isArmed() || _alarmActive) {
            WatchUi.requestUpdate();
            return;
        }

        if (connected) {
            _disconnectedAt = null;
        } else if (_disconnectedAt == null) {
            _disconnectedAt = System.getTimer();
        }

        WatchUi.requestUpdate();
    }

    function pollConnection() as Void {
        var connected = System.getDeviceSettings().phoneConnected;
        _view.setPhoneConnected(connected);

        if (!NearSentryState.isArmed() || _alarmActive) {
            if (!NearSentryState.isArmed()) {
                _disconnectedAt = null;
            }
            WatchUi.requestUpdate();
            return;
        }

        if (connected) {
            _disconnectedAt = null;
            WatchUi.requestUpdate();
            return;
        }

        if (_disconnectedAt == null) {
            _disconnectedAt = System.getTimer();
            WatchUi.requestUpdate();
            return;
        }

        var elapsed = System.getTimer() - _disconnectedAt;
        if (elapsed >= NearSentryState.getGraceMs()) {
            NearSentryState.setAlarmPending(true);
            NearSentryState.setLastReason("foreground_phone_disconnected");
            startAlarm("foreground_phone_disconnected");
        }

        WatchUi.requestUpdate();
    }

    function startAlarm(reason) as Void {
        if (_alarmActive) {
            return;
        }

        _alarmActive = true;
        _view.setAlarm(true, reason);
        pulseAlarm();

        try {
            _alarmTimer.start(method(:pulseAlarm), 6000, true);
        } catch (error) {
            System.println("NearSentry alarm timer failed: " + error);
        }

        WatchUi.requestUpdate();
    }

    function stopAlarm(clearPending) as Void {
        if (_alarmActive) {
            try {
                _alarmTimer.stop();
            } catch (error) {
            }
        }

        _alarmActive = false;
        if (clearPending) {
            NearSentryState.setAlarmPending(false);
        }
        _view.setAlarm(false, "");
        WatchUi.requestUpdate();
    }

    function pulseAlarm() as Void {
        if (!_alarmActive) {
            return;
        }

        try {
            if (Attention has :vibrate) {
                Attention.vibrate([
                    new Attention.VibeProfile(100, 900),
                    new Attention.VibeProfile(0, 180),
                    new Attention.VibeProfile(100, 900),
                    new Attention.VibeProfile(0, 180),
                    new Attention.VibeProfile(100, 900),
                    new Attention.VibeProfile(0, 180),
                    new Attention.VibeProfile(100, 900)
                ]);
            }

            if (Attention has :playTone) {
                // Use Garmin's built-in attention tones rather than a custom
                // ToneProfile. These are supported by the fenix 7X family and
                // are more noticeable than a single TONE_ALARM pulse.
                Attention.playTone(Attention.TONE_CANARY);
                Attention.playTone(Attention.TONE_LOUD_BEEP);
                Attention.playTone(Attention.TONE_CANARY);
            }

            if (Attention has :backlight) {
                Attention.backlight(true);
            }
        } catch (error) {
            System.println("NearSentry attention failed: " + error);
        }
    }
}
