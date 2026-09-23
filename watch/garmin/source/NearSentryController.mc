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
    var _alarmMuted;
    var _alarmPulseIndex;

    function initialize(view) {
        _view = view;
        _connectionTimer = new Timer.Timer();
        _alarmTimer = new Timer.Timer();
        _disconnectedAt = null;
        _alarmActive = false;
        _alarmMuted = false;
        _alarmPulseIndex = 0;

        _connectionTimer.start(method(:pollConnection), 1000, true);
        restoreState();
    }

    function shutdown() as Void {
        try { _connectionTimer.stop(); } catch (error) {}
        stopAlarmTimer();
    }

    function isAlarmActive() { return _alarmActive; }

    function restoreState() as Void {
        var connected = System.getDeviceSettings().phoneConnected;
        _view.setPhoneConnected(connected);
        _view.setArmed(NearSentryState.isArmed());
        _view.setLastCommand(NearSentryState.getLastCommand());

        if (NearSentryState.isAlarmPending()) {
            startAlarm(NearSentryState.getLastReason(), false);
        } else if (NearSentryState.isArmed() && !connected) {
            _disconnectedAt = System.getTimer();
            stopAlarm(false);
        } else {
            stopAlarm(false);
        }
        WatchUi.requestUpdate();
    }

    function toggleProtection() as Void {
        if (_alarmActive) {
            NearSentryState.setLastCommand("STOP_BLOCKED");
            NearSentryState.setLastReason("authenticate_on_phone");
            _view.setLastCommand("STOP_BLOCKED");
            WatchUi.requestUpdate();
            return;
        }

        if (NearSentryState.isArmed()) {
            stopLocalProtection();
        } else {
            startLocalProtection();
        }
    }

    function startLocalProtection() as Void {
        var connected = System.getDeviceSettings().phoneConnected;
        _view.setPhoneConnected(connected);

        if (!connected) {
            NearSentryState.setLastCommand("START_BLOCKED");
            NearSentryState.setLastReason("phone_disconnected");
            _view.setLastCommand("START_BLOCKED");
            _view.setArmed(false);
            WatchUi.requestUpdate();
            return;
        }

        NearSentryState.setArmed(true);
        NearSentryState.setAlarmPending(false);
        NearSentryState.setAlarmMuted(false);
        NearSentryState.setLastCommand("START");
        NearSentryState.setLastReason("watch_started");

        _view.setArmed(true);
        _view.setLastCommand("START");
        _disconnectedAt = null;
        stopAlarm(false);

        NearSentryBackgroundPolicy.sync(true);
        NearSentryTransport.sendControl("START");
        WatchUi.requestUpdate();
    }

    function stopLocalProtection() as Void {
        NearSentryState.setArmed(false);
        NearSentryState.setAlarmPending(false);
        NearSentryState.setAlarmMuted(false);
        NearSentryState.setLastCommand("STOP");
        NearSentryState.setLastReason("watch_stopped");

        _view.setArmed(false);
        _view.setLastCommand("STOP");
        _disconnectedAt = null;
        stopAlarm(true);

        NearSentryBackgroundPolicy.sync(false);
        NearSentryTransport.sendControl("STOP");
        WatchUi.requestUpdate();
    }

    function toggleAlarmMute() as Void {
        if (!_alarmActive) { return; }

        _alarmMuted = !_alarmMuted;
        NearSentryState.setAlarmMuted(_alarmMuted);
        _view.setAlarmMuted(_alarmMuted);

        if (_alarmMuted) {
            NearSentryState.setLastCommand("MUTE");
            _view.setLastCommand("MUTE");
            silenceAlarmOutput();
        } else {
            NearSentryState.setLastCommand("UNMUTE");
            _view.setLastCommand("UNMUTE");
            resumeAlarmOutput();
        }

        WatchUi.requestUpdate();
    }

    function handlePhoneMessage(data) as Void {
        var command = NearSentryState.commandFrom(data);
        if (command == null) { return; }

        NearSentryState.setLastCommand(command);
        NearSentryState.setGraceMs(NearSentryState.graceFrom(data));
        _view.setLastCommand(command);

        if (command == "ARMED") {
            NearSentryState.setArmed(true);
            NearSentryState.setAlarmPending(false);
            NearSentryState.setAlarmMuted(false);
            _view.setArmed(true);
            _disconnectedAt = null;
            stopAlarm(false);
            NearSentryBackgroundPolicy.sync(true);
        } else if (command == "DISARMED" || command == "ALARM_STOP") {
            NearSentryState.setArmed(false);
            NearSentryState.setAlarmPending(false);
            NearSentryState.setAlarmMuted(false);
            _view.setArmed(false);
            _disconnectedAt = null;
            stopAlarm(true);
            NearSentryBackgroundPolicy.sync(false);
        } else if (command == "ALARM" || command == "TEST_ALARM") {
            NearSentryState.setAlarmPending(true);
            NearSentryState.setAlarmMuted(false);
            var reason = NearSentryState.reasonFrom(data);
            NearSentryState.setLastReason(
                reason.length() > 0 ? reason : "phone_alarm"
            );
            startAlarm(NearSentryState.getLastReason(), true);
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
            if (!NearSentryState.isArmed()) { _disconnectedAt = null; }
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
            NearSentryState.setAlarmMuted(false);
            NearSentryState.setLastReason("foreground_phone_disconnected");
            startAlarm("foreground_phone_disconnected", true);
        }

        WatchUi.requestUpdate();
    }

    function startAlarm(reason, resetMute) as Void {
        if (resetMute) { NearSentryState.setAlarmMuted(false); }
        _alarmMuted = NearSentryState.isAlarmMuted();

        if (_alarmActive) {
            _view.setAlarm(true, reason);
            _view.setAlarmMuted(_alarmMuted);
            if (_alarmMuted) { silenceAlarmOutput(); }
            WatchUi.requestUpdate();
            return;
        }

        _alarmActive = true;
        _alarmPulseIndex = 0;
        _view.setAlarm(true, reason);
        _view.setAlarmMuted(_alarmMuted);

        if (!_alarmMuted) { resumeAlarmOutput(); }
        WatchUi.requestUpdate();
    }

    function stopAlarm(clearPending) as Void {
        stopAlarmTimer();
        silenceVibration();

        _alarmActive = false;
        _alarmMuted = false;
        NearSentryState.setAlarmMuted(false);

        if (clearPending) { NearSentryState.setAlarmPending(false); }

        _view.setAlarm(false, "");
        _view.setAlarmMuted(false);
        WatchUi.requestUpdate();
    }

    function resumeAlarmOutput() as Void {
        if (!_alarmActive || _alarmMuted) { return; }
        pulseAlarm();
        startAlarmTimer();
    }

    function silenceAlarmOutput() as Void {
        stopAlarmTimer();
        silenceVibration();
    }

    function startAlarmTimer() as Void {
        stopAlarmTimer();
        try {
            _alarmTimer.start(method(:pulseAlarm), 2500, true);
        } catch (error) {
            System.println("NearSentry alarm timer failed: " + error);
        }
    }

    function stopAlarmTimer() as Void {
        try { _alarmTimer.stop(); } catch (error) {}
    }

    function silenceVibration() as Void {
        try {
            if (Attention has :vibrate) {
                Attention.vibrate([new Attention.VibeProfile(0, 1)]);
            }
        } catch (error) {
            System.println("NearSentry vibration silence failed: " + error);
        }
    }

    function pulseAlarm() as Void {
        if (!_alarmActive || _alarmMuted) { return; }

        try {
            if (Attention has :vibrate) {
                Attention.vibrate([
                    new Attention.VibeProfile(100, 650),
                    new Attention.VibeProfile(0, 120),
                    new Attention.VibeProfile(100, 650)
                ]);
            }

            if (Attention has :playTone) {
                if ((_alarmPulseIndex % 2) == 0) {
                    Attention.playTone(Attention.TONE_LOUD_BEEP);
                } else {
                    Attention.playTone(Attention.TONE_CANARY);
                }
                _alarmPulseIndex += 1;
            }

            if (Attention has :backlight) { Attention.backlight(true); }
        } catch (error) {
            System.println("NearSentry attention failed: " + error);
        }
    }
}
