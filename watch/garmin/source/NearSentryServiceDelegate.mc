using Toybox.Background as Background;
using Toybox.Communications as Communications;
using Toybox.System as System;

(:background)
class NearSentryServiceDelegate extends System.ServiceDelegate {
    function initialize() {
        System.ServiceDelegate.initialize();
    }

    function onPhoneAppMessage(msg as Communications.PhoneAppMessage) as Void {
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
            NearSentryState.setAlarmMuted(false);
            NearSentryState.setLastReason("phone_armed");
            NearSentryBackgroundPolicy.sync(true);
        } else if (command == "DISARMED" || command == "ALARM_STOP") {
            NearSentryState.setArmed(false);
            NearSentryState.setAlarmPending(false);
            NearSentryState.setAlarmMuted(false);
            NearSentryState.setLastReason("phone_disarmed");
            NearSentryBackgroundPolicy.sync(false);
        } else if (command == "ALARM" || command == "TEST_ALARM") {
            NearSentryState.setAlarmPending(true);
            NearSentryState.setAlarmMuted(false);
            NearSentryState.setLastReason(
                NearSentryState.reasonFrom(data).length() > 0
                    ? NearSentryState.reasonFrom(data)
                    : "phone_alarm"
            );
            requestWake("NearSentry alarm - open app");
        }

        NearSentryTransport.sendBackgroundAck(
            command, "background_received", data
        );
    }

    function onTemporalEvent() as Void {
        if (!NearSentryState.isArmed()) {
            NearSentryBackgroundPolicy.sync(false);
            Background.exit(null);
            return;
        }

        var connected = System.getDeviceSettings().phoneConnected;
        if (!connected) {
            NearSentryState.setAlarmPending(true);
            NearSentryState.setAlarmMuted(false);
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

    function requestWake(message) as Void {
        try {
            Background.requestApplicationWake(message);
        } catch (error) {
            System.println("NearSentry wake request failed: " + error);
        }
    }
}
