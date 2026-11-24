# Sprint 05 — UI Device Matrix

Issue: #29
Owner: TV4 — UI/Tutorial
Reviewer: Leader
Status: PENDING ANDROID VERIFICATION

## Tested baseline

Godot 4.7.2 stable
HUD PR #52 merge: 3ed2800f392fb9ee1f01a06f1677c3fc11700165

## Device and resolution matrix

| Device | Android | Resolution | Orientation | UI result | Evidence |
|---|---|---|---|---|---|
| Godot PC editor | N/A | 1280x720 design viewport | Landscape | Visual reviewed | Leader screenshot |
| Physical Android device 1 | PENDING | PENDING | Landscape | NOT RUN | PENDING |
| Additional aspect ratio | PENDING | PENDING | Landscape | NOT RUN | PENDING |

## UI verification criteria

- All seven HUD controls are visible and accessible.
- D-pad does not cover important puzzle objects.
- LEVEL, TICK, LOOP and ECHO labels remain readable.
- Touch target boundaries match visible buttons.
- Rapid touches do not cause unintended extra ticks.
- Pause overlay does not allow background gameplay input.
- Tutorial and Level Select remain readable.
- No clipping at screen edges or system navigation areas.
- UI remains usable at the actual device aspect ratio.

## Final candidate metadata

Full source commit SHA: PENDING
APK SHA-256: PENDING
APK version: PENDING
Android device model: PENDING
Android OS: PENDING
Tester: PENDING
Test date: PENDING

## Result policy

Only tests actually executed may be marked PASS.
Editor preview is not equivalent to physical Android testing.
All Android acceptance results must reference the APK tested.
