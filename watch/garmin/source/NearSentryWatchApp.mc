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

    function onStart(state) as Void {
        registerBackgroundEvents();
    }

    function onStop(state) as Void {
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

    function onForegroundPhoneMessage(msg as Communications.PhoneAppMessage) as Void {
        var command = NearSentryState.commandFrom(msg.data);
        if (_controller != null) {
            _controller.handlePhoneMessage(msg.data);
        }
        if (command != null) {
            NearSentryTransport.sendAck(command, "foreground_received");
        }
    }

    function onBackgroundData(data) as Void {
        if (data == null) {
            return;
        }

        if (_controller != null) {
            _controller.handlePhoneMessage(data);
        } else {
            _pendingData = data;
        }
    }

    function onStorageChanged() as Void {
        if (_controller != null) {
            _controller.restoreState();
        }
    }

    function onDeviceSettingChanged(aSymbol, aValue) as Void {
        if (aSymbol == :phoneConnected && _controller != null) {
            _controller.onPhoneConnectedChanged(aValue);
        }
    }

    function onAppInstall() as Void {
        registerBackgroundEvents();
    }

    function onAppUpdate() as Void {
        registerBackgroundEvents();
    }

    function registerBackgroundEvents() as Void {
        try {
            Background.registerForPhoneAppMessageEvent();

            if (NearSentryState.isServiceEnabled() &&
                NearSentryState.isArmed()
            ) {
                Background.registerForTemporalEvent(new Time.Duration(5 * 60));
            }
        } catch (error) {
            System.println("NearSentry background registration failed: " + error);
        }
    }
}
