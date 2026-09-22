using Toybox.Application as Application;
using Toybox.Background as Background;
using Toybox.Communications as Communications;
using Toybox.System as System;
using Toybox.Time as Time;
using Toybox.WatchUi as WatchUi;

(:background)
class NearSentryWatchApp extends Application.AppBase {
    var _view;
    var _controller;
    var _pendingData;

    function initialize() {
        Application.AppBase.initialize();
        _view = null;
        _controller = null;
        _pendingData = null;
    }

    function onStart(state) {
        registerBackgroundEvents();
    }

    function onStop(state) {
        if (_controller != null) {
            _controller.shutdown();
        }

        try {
            Communications.registerForPhoneAppMessages(null);
        } catch (error) {
        }
    }

    function getInitialView() {
        _view = new NearSentryView();
        _controller = new NearSentryController(_view);

        try {
            Communications.registerForPhoneAppMessages(
                method(:onForegroundPhoneMessage)
            );
        } catch (error) {
            System.println("NearSentry phone message registration failed: " + error);
        }

        if (_pendingData != null) {
            _controller.handlePhoneMessage(_pendingData);
            _pendingData = null;
        } else if (NearSentryState.isAlarmPending()) {
            _controller.restoreState();
        }

        return [_view];
    }

    function getServiceDelegate() {
        return [new NearSentryServiceDelegate()];
    }

    function onForegroundPhoneMessage(msg) {
        if (_controller != null) {
            _controller.handlePhoneMessage(msg.data);
        }
    }

    function onBackgroundData(data) {
        if (data == null) {
            return;
        }

        if (_controller != null) {
            _controller.handlePhoneMessage(data);
        } else {
            _pendingData = data;
        }
    }

    function onStorageChanged() {
        if (_controller != null) {
            _controller.restoreState();
        }
    }

    function onDeviceSettingChanged(aSymbol, aValue) {
        if (aSymbol == :phoneConnected && _controller != null) {
            _controller.onPhoneConnectedChanged(aValue);
        }
    }

    function onAppInstall() {
        registerBackgroundEvents();
    }

    function onAppUpdate() {
        registerBackgroundEvents();
    }

    function registerBackgroundEvents() {
        try {
            Background.registerForPhoneAppMessageEvent();

            if (NearSentryState.isArmed()) {
                Background.registerForTemporalEvent(new Time.Duration(5 * 60));
            }
        } catch (error) {
            System.println("NearSentry background registration failed: " + error);
        }
    }
}
