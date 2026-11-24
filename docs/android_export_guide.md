# Echo Loop — Android Export and Release Guide

**Engine:** Godot 4.7.2 stable  
**Renderer:** GL Compatibility  
**Target:** Android landscape  
**Release phase:** Sprint 05  
**Final APK acceptance:** Pending

## 1. Development Environment

Requirements:
- Godot 4.7.2 stable.
- Matching Godot export templates.
- Android SDK and JDK configured locally.
- Android Debug Bridge (ADB) when needed.
- An approved Android package identifier.
- A physical Android device for final verification.

Android SDK and Java SDK paths are machine-specific and must not be committed to the repository.

## 2. Application Configuration

The current source includes:
- Application name and custom branding.
- Echo Loop launcher icon.
- Echo Loop boot splash.
- Dark navy splash background.
- Two-second minimum splash duration.
- GL Compatibility rendering.
- A 1280 x 720 logical viewport.
- Landscape-oriented UI design.
- Custom Android Back navigation.
- Main Menu Sound ON/OFF preference.

Branding assets:
- `res://assets/branding/echo_loop_icon.png`
- `res://assets/branding/echo_loop_splash.png`

Verify the final Android export preset independently from the PC project settings.

## 3. Export Preparation

1. Update the source to the approved release commit.
2. Confirm that the working tree contains no unintended changes.
3. Open `project.godot` using Godot 4.7.2 stable.
4. Allow resource imports to finish.
5. Run F5 and the relevant F6 regression tests.
6. Open Project > Export.
7. Review the Android export preset.
8. Confirm package identifier, version, architectures, and landscape orientation.
9. Verify icon, splash, and renderer compatibility.
10. Verify the export templates, SDK, and JDK.
11. Export the APK outside the repository.

Do not export a final submission APK until final level and visual changes have passed integration tests.

## 4. Signing and Security

Debug builds may use local debug signing.

Release builds require an approved signing method and a safely stored release keystore when applicable.

Never commit:
- Keystores
- Signing passwords
- Private keys
- Credentials
- APK or AAB files
- `.godot/` caches
- Private device information

The current repository policy excludes `export_presets.cfg`; local machines must configure the necessary export preset independently.

Check Git status and staged changes before each release-related commit.

## 5. Release Artifact Identity

For every candidate, record:

| Field | Required Value |
|---|---|
| Source commit | Full Git SHA |
| APK file | Exact filename |
| APK hash | SHA-256 |
| Godot version | Exact engine version |
| Package identifier | Actual Android package |
| Application version | Version name and code |
| Device | Manufacturer and model |
| Android version | OS/API level |
| Tester | Person who performed the test |
| Date | Actual execution date |
| Result | PASS, FAIL, BLOCKED, or NOT RUN |
| Evidence | Screenshot, log, or video reference |

A result from a previous APK cannot automatically be reused as final acceptance evidence after packaged code, levels, or assets change.

## 6. Physical Android Test Procedure

1. Install the exact candidate APK on a real Android device.
2. Verify the launcher icon and application name.
3. Launch the application without internet access.
4. Confirm landscape orientation and readable layout.
5. Test Main Menu and Tutorial.
6. Test Level Select and locked levels.
7. Complete Level 01 through Level 05.
8. Verify the 12-tick limit, blocked movement, and WAIT.
9. Verify creation and deterministic replay of up to two Echoes.
10. Verify switch and door behavior.
11. Verify Pause, Resume, Restart, and Level Complete.
12. Verify Android Back in each applicable screen.
13. Verify Sound ON/OFF and retained preference.
14. Close and reopen the application; verify unlocked progress.
15. Background and resume the application.
16. Record errors, device metadata, and supporting evidence.

Different screen aspect ratios should be tested when suitable devices are available. Untested combinations must remain documented as NOT RUN.

## 7. Recommended QA Ownership

- Leader: export configuration, final build identity, Back navigation, release approval.
- TV2: actor controls, replay, animation, and responsiveness.
- TV3: level solutions, puzzle placement, switch/door behavior.
- TV4: HUD layout, touch targets, tutorial, and navigation.
- TV5: aggregate QA matrix, known issues, final report, release checklist.

One tester may help another owner execute device tests, but the report must identify the person and actual device used.

## 8. Relevant Documentation

- `docs/module_contract.md`
- `tests/android_actor_qa.md`
- `tests/android_levels_qa.md`
- `tests/android_ui_qa.md`
- `tests/ui_device_matrix.md`
- `tests/android_test_matrix.md`
- `tests/final_qa_report.md`
- `tests/release_checklist.md`
- `docs/known_issues.md`
- `docs/user_guide_vi.md`

Reports must be reconciled to the final source commit and APK hash.

## 9. Verification Status

| Check | Current Status |
|---|---|
| Android foundation and branding | Implemented |
| Previous Debug APK preparation | Leader reported |
| PC Sound Settings F5 | PASS, Leader reported |
| PC Back/Escape F5 | PASS, Leader reported |
| Final level and visual polish | Planned |
| Final APK export | NOT RUN |
| Final APK physical-device regression | NOT RUN |
| Final release QA approval | BLOCKED |

Previous Android reports may be used as historical evidence but must not be presented as verified final-build results without matching source and APK identities.

## 10. Final Release Gate

The Leader may approve the release only when:
- Source and documentation are synchronized.
- Relevant F6 and F5 checks pass.
- The final APK is installed and tested on physical Android hardware.
- All five levels have valid, verified solutions.
- UI, Back, audio, save, and offline requirements pass.
- No unresolved blocker remains.
- The final QA matrix and checklist are complete.
- The source SHA, APK SHA-256, and release artifact match.

Until these conditions are satisfied, Sprint 05 final release acceptance remains pending.
