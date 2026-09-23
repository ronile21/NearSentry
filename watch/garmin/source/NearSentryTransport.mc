using Toybox.Background as Background;
using Toybox.Communications as Communications;
using Toybox.System as System;

class NearSentryTransmitListener extends Communications.ConnectionListener {
    var _label;

    function initialize(label) {
        Communications.ConnectionListener.initialize();
        _label = label;
    }

    function onComplete() as Void {
        System.println("NearSentry transmit complete: " + _label);
    }

    function onError() as Void {
        System.println("NearSentry transmit error: " + _label);
    }
}

(:background)
class NearSentryBackgroundTransmitListener extends Communications.ConnectionListener {
    var _exitData;
    var _label;

    function initialize(exitData, label) {
        Communications.ConnectionListener.initialize();
        _exitData = exitData;
        _label = label;
    }

    function onComplete() as Void {
        System.println("NearSentry background transmit complete: " + _label);
        Background.exit(_exitData);
    }

    function onError() as Void {
        System.println("NearSentry background transmit error: " + _label);
        Background.exit(_exitData);
    }
}

module NearSentryTransport {
    function ackPayload(command, status) {
        var deviceSettings = System.getDeviceSettings();
        return {
            "type" => "ACK",
            "protocol" => 1,
            "command" => command,
            "status" => status,
            "armed" => NearSentryState.isArmed(),
            "serviceEnabled" => NearSentryState.isServiceEnabled(),
            "tonesOn" => deviceSettings.tonesOn,
            "vibrateOn" => deviceSettings.vibrateOn,
            "phoneConnected" => deviceSettings.phoneConnected
        };
    }

    function sendAck(command, status) as Void {
        try {
            Communications.transmit(
                ackPayload(command, status),
                {},
                new NearSentryTransmitListener(command)
            );
        } catch (error) {
            System.println("NearSentry ACK transmit failed: " + error);
        }
    }

    (:background)
    function sendBackgroundAck(command, status, exitData) as Void {
        try {
            Communications.transmit(
                ackPayload(command, status),
                {},
                new NearSentryBackgroundTransmitListener(exitData, command)
            );
        } catch (error) {
            System.println("NearSentry background ACK transmit failed: " + error);
            Background.exit(exitData);
        }
    }
}
