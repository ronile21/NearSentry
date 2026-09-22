# Bluetooth / Garmin Agent

## Scope

Own feasibility and implementation of trusted-anchor observation, initially Garmin.

Relevant files:
- Bluetooth/Garmin design documents
- native anchor adapters
- hardware integration tests

## Responsibilities

- identify observable signals available to a normal Android application
- distinguish Android Bluetooth APIs from Garmin Connect/Connect IQ capabilities
- normalize observations into present/absent/unknown + evidence
- measure reconnection/disconnection behavior
- document watch/phone/firmware compatibility

## Critical rules

- paired is not equivalent to observable connection
- RSSI is not distance
- do not assume Garmin Connect exposes its connection to NearSentry
- do not declare a watch-side alarm path until demonstrated

## Evidence required

Real-device evidence is mandatory before promoting a candidate mechanism to production design.
