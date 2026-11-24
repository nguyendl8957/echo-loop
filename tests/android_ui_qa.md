# Sprint 05 — Android HUD/UI QA

Issue: #29
Owner: TV4 — UI/Tutorial
Review support: Leader
Date: 2026-11-24
Status: PARTIAL — Android final verification pending

## Source baseline

PR #52 merged into main.
Merge commit: 3ed2800f392fb9ee1f01a06f1677c3fc11700165
Godot: 4.7.2 stable

## Completed PC checks

- HUD scene node structure: PASS — Leader visual review
- Directional buttons use arrow labels: PASS
- Seven controls have updated visual styling: PASS
- HUD independent F6 test: PASS — Leader reported
- Gameplay F5 regression: PASS — Leader reported
- Directional input, WAIT, ENDLOOP, RESTART: PASS — Leader reported
- Pause/Resume and HUD state: PASS — Leader reported
- No new debugger errors: PASS — Leader reported

These are PC results, not Android acceptance results.

## Android test cases

| ID | Test | Expected | Status |
|---|---|---|---|
| UI-01 | Install and launch APK | HUD displays correctly | NOT RUN |
| UI-02 | Four directional touch buttons | Correct input, no duplicate tick | NOT RUN |
| UI-03 | WAIT | One tick, no Player movement | NOT RUN |
| UI-04 | ENDLOOP | Correct Echo/Loop transition | NOT RUN |
| UI-05 | RESTART | Reset to Loop 1, Tick 0, Echo 0 | NOT RUN |
| UI-06 | Pause/Resume | Gameplay input locked while paused | NOT RUN |
| UI-07 | Landscape layout | No clipped buttons or labels | NOT RUN |
| UI-08 | Different device aspect ratios | HUD remains usable | NOT RUN |
| UI-09 | Rapid touch input | No unintended duplicated actions | NOT RUN |
| UI-10 | Tutorial and navigation | Text readable, buttons accessible | NOT RUN |

## Android build identity

Source commit: PENDING
APK filename: PENDING
APK SHA-256: PENDING
Package/version: PENDING
Device/Android version: PENDING
Tester: PENDING
Test date: PENDING

## Evidence

Android screenshots, videos, device metadata and results will
be added after testing the final APK candidate.

## Acceptance

Issue #29 is not complete while mandatory Android tests
remain NOT RUN or required device evidence is missing.
