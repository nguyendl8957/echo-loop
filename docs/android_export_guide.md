# Echo Loop - Android Export Guide

## 1. Environment

- Engine: Godot 4.7.2 stable
- Renderer: GL Compatibility
- Target: Android, landscape
- Android SDK and Java SDK paths are configured locally in Godot Editor Settings.
- Matching Godot export templates must be installed.

## 2. Branding

- App name: Echo Loop
- Launcher icon: res://assets/branding/echo_loop_icon.png
- Boot splash: res://assets/branding/echo_loop_splash.png
- Splash stretch mode: Keep Width
- Splash minimum display time: 2000 ms
- Splash background: dark navy

Project settings are stored in project.godot.

## 3. Android Export

1. Open the project using Godot 4.7.2.
2. Open Project > Export.
3. Add an Android preset if none exists.
4. Configure the approved Android package identifier.
5. Configure the app name, icon, architecture and landscape orientation.
6. Check Android SDK, Java SDK and export-template configuration.
7. Resolve any texture compression or export configuration errors.
8. Export a Debug APK to a folder outside the repository.
9. Install the APK on a physical Android device for verification.

## 4. Signing and Security

- Debug builds use debug signing.
- Release builds must use an approved release keystore.
- Never commit keystores, passwords, private keys or APK files.
- export_presets.cfg is currently excluded by .gitignore.
- Team members must configure their own local export preset.

## 5. Verification Status

- PC F5 splash display: PASS, reported by Leader.
- Splash minimum display time: configured to 2000 ms.
- Android APK export: NOT RUN.
- Physical Android install and launch: NOT RUN.
- Android launcher icon and app label: NOT RUN.
- Android full gameplay regression: NOT RUN.

These Android checks must be performed before the final release
acceptance of Issue #26.

## 6. Release Evidence

For each candidate APK, record:

- Source commit SHA
- APK SHA-256
- Godot version
- Android device model and OS version
- Test date and test outcomes

Keep APK artifacts outside the repository.
