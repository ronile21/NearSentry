using Toybox.Lang as Lang;
using Toybox.WatchUi as WatchUi;

class NearSentryInputDelegate extends WatchUi.InputDelegate {
    var _controller;

    function initialize(controller) {
        WatchUi.InputDelegate.initialize();
        _controller = controller;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            _controller.toggleProtection();
            return true;
        }

        if (key == WatchUi.KEY_DOWN && _controller.isAlarmActive()) {
            _controller.toggleAlarmMute();
            return true;
        }

        return false;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Lang.Boolean {
        var point = clickEvent.getCoordinates();
        return _controller.handleTap(point[0], point[1]);
    }
}
