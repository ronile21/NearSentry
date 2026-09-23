using Toybox.Background as Background;
using Toybox.System as System;
using Toybox.Time as Time;

(:background)
module NearSentryBackgroundPolicy {
    const WATCHDOG_SECONDS = 5 * 60;

    function sync(armed) as Void {
        registerPhoneMessages();
        if (armed == true) {
            ensureWatchdog();
        } else {
            stopWatchdog();
        }
    }

    function registerPhoneMessages() as Void {
        try {
            Background.registerForPhoneAppMessageEvent();
        } catch (error) {
            System.println("NearSentry background message registration failed: " + error);
        }
    }

    function ensureWatchdog() as Void {
        try {
            Background.registerForTemporalEvent(
                new Time.Duration(WATCHDOG_SECONDS)
            );
        } catch (error) {
            System.println("NearSentry temporal watchdog registration failed: " + error);
        }
    }

    function stopWatchdog() as Void {
        try {
            Background.deleteTemporalEvent();
        } catch (error) {
            System.println("NearSentry temporal watchdog deletion failed: " + error);
        }
    }
}
