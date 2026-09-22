# MVP Acceptance Criteria

## Source/software criteria

- **AC-001** Native service owns active monitoring independently of Flutter UI lifecycle.
- **AC-002** Confirmed absence from PROTECTED enters GRACE.
- **AC-003** PRESENT before the original deadline returns to PROTECTED.
- **AC-004** Repeated ABSENT does not extend the deadline.
- **AC-005** Deadline expiry enters ALARM exactly once.
- **AC-006** Anchor recovery does not silently dismiss ALARM.
- **AC-007** Production dismissal requires Android system authentication.
- **AC-008** Every accepted transition is journaled locally.
- **AC-009** Bluetooth/permission/runtime uncertainty cannot be presented as healthy PROTECTED.
- **AC-010** Simulator is visibly identified as simulated.
- **AC-011** Settings and enrolled anchor persist locally.

## Hardware/reliability criteria

Not accepted until physical-device evidence exists:

- **AC-100** Garmin status events correctly represent real separation/recovery on each supported watch.
- **AC-101** Protection survives declared Samsung/Pixel screen-off/background test matrix.
- **AC-102** Alarm behavior is confirmed on target Android versions/OEMs.
- **AC-103** Battery impact is measured in soak testing.
- **AC-104** Supported Garmin/Android compatibility matrix is based on actual devices, not assumptions.
