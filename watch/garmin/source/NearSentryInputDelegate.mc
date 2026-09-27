using Toybox.Lang as Lang;
using Toybox.WatchUi as WatchUi;

class NearSentryInputDelegate extends WatchUi.BehaviorDelegate {
    var _controller;

    function initialize(controller) {
        WatchUi.BehaviorDelegate.initialize();
        _controller = controller;
    }

    function onSelect() as Lang.Boolean {
        _controller.toggleProtection();
        return true;
    }

    function onNextPage() as Lang.Boolean {
        if (_controller.isAlarmActive()) {
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
