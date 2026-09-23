using Toybox.Application as Application;
using Toybox.Communications as Communications;
using Toybox.System as System;

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
        registerForegroundMessages();
        NearSentryBackgroundPolicy.sync(NearSentryState.isArmed());
        NearSentryState.setLastCommand("BOOT-2");
    }

    function onStop(state) as Void {
        if (_controller != null) { _controller.shutdown(); }
        try {
            Communications.registerForPhoneAppMessages(null);
        } catch (error) {}
    }

    function getInitialView() {
        _view = new NearSentryView();
        _controller = new NearSentryController(_view);
        registerForegroundMessages();

        if (_pendingData != null) {
            _controller.handlePhoneMessage(_pendingData);
            _pendingData = null;
        } else if (NearSentryState.isAlarmPending()) {
            _controller.restoreState();
        }

        return [_view, new NearSentryInputDelegate(_controller)];
    }

    function getServiceDelegate() {
        return [new NearSentryServiceDelegate()];
    }

    function registerForegroundMessages() as Void {
        try {
            Communications.registerForPhoneAppMessages(
                method(:onForegroundPhoneMessage)
            );
            System.println("NearSentry foreground phone messaging registered");
        } catch (error) {
            System.println(
                "NearSentry foreground phone message registration failed: " +
                error
            );
        }
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
        if (data == null) { return; }
        if (_controller != null) {
            _controller.handlePhoneMessage(data);
        } else {
            _pendingData = data;
        }
    }

    function onStorageChanged() as Void {
        if (_controller != null) { _controller.restoreState(); }
    }

    function onDeviceSettingChanged(aSymbol, aValue) as Void {
        if (aSymbol == :phoneConnected && _controller != null) {
            _controller.onPhoneConnectedChanged(aValue);
        }
    }

    function onAppInstall() as Void {
        NearSentryBackgroundPolicy.sync(NearSentryState.isArmed());
    }

    function onAppUpdate() as Void {
        NearSentryBackgroundPolicy.sync(NearSentryState.isArmed());
    }
}
