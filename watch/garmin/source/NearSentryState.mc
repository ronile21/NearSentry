using Toybox.Application.Storage as Storage;
using Toybox.Lang as Lang;

(:background)
module NearSentryState {
    const KEY_ARMED = "armed";
    const KEY_ALARM_PENDING = "alarmPending";
    const KEY_LAST_COMMAND = "lastCommand";
    const KEY_LAST_REASON = "lastReason";
    const KEY_GRACE_MS = "graceMs";
    const KEY_SERVICE_ENABLED = "serviceEnabled";

    function isArmed() {
        return Storage.getValue(KEY_ARMED) == true;
    }

    function isServiceEnabled() {
        var value = Storage.getValue(KEY_SERVICE_ENABLED);
        return value == null ? true : value == true;
    }

    function setServiceEnabled(value) {
        Storage.setValue(KEY_SERVICE_ENABLED, value == true);
        if (value != true) {
            setArmed(false);
            setAlarmPending(false);
        }
    }

    function setArmed(value) {
        Storage.setValue(KEY_ARMED, value == true);
    }

    function isAlarmPending() {
        return Storage.getValue(KEY_ALARM_PENDING) == true;
    }

    function setAlarmPending(value) {
        Storage.setValue(KEY_ALARM_PENDING, value == true);
    }

    function setLastCommand(command) {
        Storage.setValue(KEY_LAST_COMMAND, command);
    }

    function getLastCommand() {
        var value = Storage.getValue(KEY_LAST_COMMAND);
        return value == null ? "NONE" : value.toString();
    }

    function setLastReason(reason) {
        Storage.setValue(KEY_LAST_REASON, reason);
    }

    function getLastReason() {
        var value = Storage.getValue(KEY_LAST_REASON);
        return value == null ? "" : value.toString();
    }

    function setGraceMs(value) {
        if (value != null && value instanceof Lang.Number) {
            var bounded = value;
            if (bounded < 1000) {
                bounded = 1000;
            }
            if (bounded > 15000) {
                bounded = 15000;
            }
            Storage.setValue(KEY_GRACE_MS, bounded);
        }
    }

    function getGraceMs() {
        var value = Storage.getValue(KEY_GRACE_MS);
        if (value != null && value instanceof Lang.Number) {
            return value;
        }
        return 3000;
    }

    function commandFrom(data) {
        if (!(data instanceof Lang.Dictionary)) {
            return null;
        }
        var command = data["command"];
        return command == null ? null : command.toString();
    }

    function graceFrom(data) {
        if (!(data instanceof Lang.Dictionary)) {
            return null;
        }
        return data["graceMs"];
    }

    function reasonFrom(data) {
        if (!(data instanceof Lang.Dictionary)) {
            return "";
        }
        var reason = data["reason"];
        return reason == null ? "" : reason.toString();
    }
}
