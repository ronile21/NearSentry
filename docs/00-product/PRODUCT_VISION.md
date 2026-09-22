# Product Vision

## Product

NearSentry protects a phone or other mobile asset by continuously evaluating proximity to a trusted personal device.

The first product pairing is Android phone + Garmin watch.

## Problem

A stolen or forgotten phone can leave the owner's physical control before the owner notices. Existing Bluetooth-loss alerts are often delayed, passive, unreliable in the background, easy to dismiss, or tied to one vendor ecosystem.

## Product promise

NearSentry should detect meaningful separation quickly, avoid obvious false alarms, escalate aggressively when confidence is high, and remain observable enough to explain why it did or did not trigger.

## Principles

- Detection reliability before visual polish.
- Security-critical decisions live in a durable native runtime, not only in UI code.
- Every alarm has an auditable reason.
- False-positive reduction must not create long theft-detection delays.
- Device integrations are adapters; the protection engine is vendor-independent.
- Platform restrictions are treated as hard engineering constraints, not ignored.

## Initial target

Android is the first protected platform. Garmin is the first trusted anchor.

Support for iOS and other Bluetooth anchors is explicitly outside the first implementation milestone.
