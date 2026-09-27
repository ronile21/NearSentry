using Toybox.Graphics as Graphics;
using Toybox.System as System;
using Toybox.WatchUi as WatchUi;

class NearSentryView extends WatchUi.View {
    var _armed;
    var _alarm;
    var _alarmMuted;
    var _phoneConnected;
    var _reason;
    var _lastCommand;

    var _systemLeft;
    var _systemTop;
    var _systemRight;
    var _systemBottom;
    var _muteLeft;
    var _muteTop;
    var _muteRight;
    var _muteBottom;

    function initialize() {
        WatchUi.View.initialize();
        _armed = false;
        _alarm = false;
        _alarmMuted = false;
        _phoneConnected = System.getDeviceSettings().phoneConnected;
        _reason = "";
        _lastCommand = "NONE";

        _systemLeft = 0;
        _systemTop = 0;
        _systemRight = 0;
        _systemBottom = 0;
        _muteLeft = 0;
        _muteTop = 0;
        _muteRight = 0;
        _muteBottom = 0;
    }

    function setArmed(value) { _armed = value == true; }

    function setAlarm(value, reason) {
        _alarm = value == true;
        _reason = reason;
    }

    function setAlarmMuted(value) { _alarmMuted = value == true; }
    function setPhoneConnected(value) { _phoneConnected = value == true; }

    function setLastCommand(value) {
        _lastCommand = value == null ? "NONE" : value.toString();
    }

    function actionAt(x, y) {
        if (inside(x, y, _systemLeft, _systemTop, _systemRight, _systemBottom)) {
            return "SYSTEM_TOGGLE";
        }

        if (_alarm &&
            inside(x, y, _muteLeft, _muteTop, _muteRight, _muteBottom)) {
            return "MUTE_TOGGLE";
        }

        return null;
    }

    function inside(x, y, left, top, right, bottom) {
        return x >= left && x <= right && y >= top && y <= bottom;
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;

        _systemLeft = 55;
        _systemRight = width - 55;
        _systemTop = height - 100;
        _systemBottom = _systemTop + 38;

        _muteLeft = 85;
        _muteRight = width - 85;
        _muteTop = height - 55;
        _muteBottom = _muteTop + 30;

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

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 14, Graphics.FONT_SMALL, "NearSentry V2",
            Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(statusColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 48, Graphics.FONT_LARGE, statusText,
            Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(
            _phoneConnected ? Graphics.COLOR_GREEN : Graphics.COLOR_RED,
            Graphics.COLOR_TRANSPARENT
        );
        dc.drawText(
            cx, 96, Graphics.FONT_SMALL,
            _phoneConnected ? "PHONE CONNECTED" : "PHONE DISCONNECTED",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 128, Graphics.FONT_XTINY,
            "Last: " + _lastCommand, Graphics.TEXT_JUSTIFY_CENTER);

        if (_alarm && _reason.length() > 0) {
            dc.drawText(cx, 148, Graphics.FONT_XTINY, _reason,
                Graphics.TEXT_JUSTIFY_CENTER);
        }

        var switchColor = _armed ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
        dc.setColor(switchColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(
            _systemLeft,
            _systemTop,
            _systemRight - _systemLeft,
            _systemBottom - _systemTop
        );
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            _systemTop + 8,
            Graphics.FONT_SMALL,
            _armed ? "SYSTEM: ON" : "SYSTEM: OFF",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        if (_alarm) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(
                _muteLeft,
                _muteTop,
                _muteRight - _muteLeft,
                _muteBottom - _muteTop
            );
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                cx,
                _muteTop + 5,
                Graphics.FONT_XTINY,
                _alarmMuted ? "UNMUTE" : "MUTE",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                cx,
                height - 50,
                Graphics.FONT_XTINY,
                "Tap switch or START/STOP",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }
}
