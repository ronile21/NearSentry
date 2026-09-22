using Toybox.Application.Storage as Storage;
using Toybox.Background as Background;
using Toybox.System as System;
using Toybox.Time as Time;

(:background)
class NearSentryServiceDelegate extends System.ServiceDelegate {
    function initialize() {
        System.ServiceDelegate.initialize();
    }

    function onPhoneAppMessage(msg) {
        var data = msg.data;
        var command = NearSentryState.commandFrom(data);

        if (command == null) {
            Background.exit(null);
            return;
        }

        NearSentryState.setLastCommand(command);
        NearSentryState.setGraceMs(NearSentryState.graceFrom(data));

        if (command == "ARMED") {
            NearSentryState.setArmed(true);
            NearSentryState.setAlarmPending(false);
            NearSentryState.setLastReason("phone_armed");
            ensureTemporalMonitor();
        } else if (command == "DISARMED" || command == "ALARM_STOP") {
            NearSentryState.setArmed(false);
            NearSentryState.setAlarmPending(false);
            NearSentryState.setLastReason("phone_disarmed");
            stopTemporalMonitor();
        } else if (command == "ALARM" || command == "TEST_ALARM") {
            NearSentryState.setAlarmPending(true);
            NearSentryState.setLastReason(
                NearSentryState.reasonFrom(data).length() > 0
                    ? NearSentryState.reasonFrom(data)
                    : "phone_alarm"
            );
            requestWake("NearSentry alarm - open app");
        }

        Background.exit(data);
    }

    function onTemporalEvent() {
        if (!NearSentryState.isArmed()) {
            stopTemporalMonitor();
            Background.exit(null);
            return;
        }

        var connected = System.getDeviceSettings().phoneConnected;
        if (!connected) {
            NearSentryState.setAlarmPending(true);
            NearSentryState.setLastReason("background_phone_disconnected");
            requestWake("NearSentry: phone disconnected");
            Background.exit({
                "command" => "ALARM",
                "reason" => "background_phone_disconnected"
            });
            return;
        }

        Background.exit(null);
    }

    function ensureTemporalMonitor() {
        try {
            Background.registerForTemporalEvent(new Time.Duration(5 * 60));
        } catch (error) {
            System.println("NearSentry temporal monitor registration failed: " + error);
        }
    }

    function stopTemporalMonitor() {
        try {
            Background.deleteTemporalEvent();
        } catch (error) {
            System.println("NearSentry temporal monitor deletion failed: " + error);
        }
    }

    function requestWake(message) {
        try {
            Background.requestApplicationWake(message);
        } catch (error) {
            System.println("NearSentry wake request failed: " + error);
        }
    }
}
