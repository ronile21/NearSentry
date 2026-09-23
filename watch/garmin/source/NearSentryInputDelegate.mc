using Toybox.WatchUi as WatchUi;

class NearSentryInputDelegate extends WatchUi.BehaviorDelegate {
    var _controller;

    function initialize(controller) {
        WatchUi.BehaviorDelegate.initialize();
        _controller = controller;
    }

    function onSelect() as Boolean {
        _controller.toggleProtection();
        return true;
    }

    function onNextPage() as Boolean {
        if (_controller.isAlarmActive()) {
            _controller.toggleAlarmMute();
            return true;
        }
        return false;
    }
}
