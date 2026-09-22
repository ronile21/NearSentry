using Toybox.Graphics as Graphics;
using Toybox.System as System;
using Toybox.WatchUi as WatchUi;

class NearSentryView extends WatchUi.View {
    var _armed;
    var _alarm;
    var _phoneConnected;
    var _reason;
    var _lastCommand;

    function initialize() {
        WatchUi.View.initialize();
        _armed = false;
        _alarm = false;
        _phoneConnected = System.getDeviceSettings().phoneConnected;
        _reason = "";
        _lastCommand = "NONE";
    }

    function setArmed(value) {
        _armed = value == true;
    }

    function setAlarm(value, reason) {
        _alarm = value == true;
        _reason = reason;
    }

    function setPhoneConnected(value) {
        _phoneConnected = value == true;
    }

    function setLastCommand(value) {
        _lastCommand = value == null ? "NONE" : value.toString();
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var statusColor = Graphics.COLOR_WHITE;
        var statusText = "DISARMED";

        if (_alarm) {
            statusColor = Graphics.COLOR_RED;
            statusText = "ALARM";
        } else if (_armed) {
            statusColor = Graphics.COLOR_GREEN;
            statusText = "ARMED";
        }

        dc.setColor(statusColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, 66, 38);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, 66, 27);

        dc.setColor(statusColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            48,
            Graphics.FONT_LARGE,
            "N",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            112,
            Graphics.FONT_MEDIUM,
            "NearSentry",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(statusColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            148,
            Graphics.FONT_LARGE,
            statusText,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(
            _phoneConnected ? Graphics.COLOR_GREEN : Graphics.COLOR_RED,
            Graphics.COLOR_TRANSPARENT
        );
        dc.drawText(
            cx,
            198,
            Graphics.FONT_SMALL,
            _phoneConnected ? "PHONE CONNECTED" : "PHONE DISCONNECTED",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            height - 54,
            Graphics.FONT_XTINY,
            "Last: " + _lastCommand,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        if (_alarm && _reason.length() > 0) {
            dc.drawText(
                cx,
                height - 30,
                Graphics.FONT_XTINY,
                _reason,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }
}
