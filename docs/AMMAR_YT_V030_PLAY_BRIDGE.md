# AMMAR YT GTA V v0.3.0 — Shared launcher and real-engine Play bridge

**Status:** Source integration committed. The existing iPhone Simulator preview has been independently launched as v0.2.0. **v0.3.0 preview must still be compiled and tested.** The actual game engine cannot be verified without authorized, version-matching build inputs.

## Single screen, two distinct builds

- **Preview:** `ios-preview/AMMARYTGTAUIPreview.xcodeproj`. Uses the exact SwiftUI launcher in `ios-preview/Sources/AMMARGTAVPreviewApp.swift`, with `AMMAR_NATIVE` undefined; it shows branding, tabs, local read-only file checks and a truthful Play warning. No engine, no fake success.
- **Native engine build:** `app/project.yml` includes the same SwiftUI file and defines `AMMAR_NATIVE`. The native app keeps its existing `@main AppDelegate`, `NativePortViewController`, Metal renderer and native game engine; the preview's `@main` is excluded by conditional compilation.

## Real native launch flow

1. On native app startup, `NativePortViewController` constructs `AMMARLauncherBridge` and shows a `UIHostingController<PreviewRoot>` above its existing home screen.
2. The player chooses `القصة` or `التجوال الحر` and taps `تشغيل اللعبة`.
3. `startFromAMMARLauncher(mode:)` checks whether a data install is running, selects `GameSettings.shared.gameMode`, and checks whether a local game folder or a valid server address exists.
4. Without data, it **opens the actual `GameFilesViewController`** instead of pretending the game started.
5. With a candidate source and readiness gate, it calls the original `startEngine()`. That function verifies the asset manifest and server/local access, configures the renderer and mods, then invokes **`PGStartEngine`**.
6. The SwiftUI launcher remains visible during startup and hides once the engine reports `WORLD_READY` or its first frame, revealing the game. This must be verified on real hardware.
7. The Data and Mods tabs in the native app open real `GameFilesViewController`/`ModsViewController`. The Settings tab opens `SettingsHomeViewController`. Their preview counterparts remain safe and isolated.

## Versioning rule — mandatory for future changes

The user requested **a visible version change in every new test release**. From v0.3.0 onward:

1. Bump `AMMARBuild.version` in the shared SwiftUI source — this is the version shown in **Home and Settings** even if the developer has not regenerated their local XcodeGen project.
2. Bump `CFBundleShortVersionString` and `CFBundleVersion` in `ios-preview/project.yml`.
3. Bump `CFBundleShortVersionString` and `CFBundleVersion` in `app/project.yml`.
4. Keep displayed and spec versions equal; the GitHub Actions preview build checks these values.
5. Do not merge a new visible feature without incrementing the preview version.

## Testing with GitHub Desktop and Xcode, no Terminal required

- Select `feature/ammar-yt-v030-play-bridge` in GitHub Desktop, Fetch origin and Pull origin.
- Open the previously generated **preview** `ios-preview/AMMARYTGTAUIPreview.xcodeproj` in Xcode, choose the iPhone Simulator and press **Command + R**.
- Confirm v0.3.0 appears on **Home** and **Settings**; choose Story or Sandbox; tap Play in preview and verify it does not falsely launch GTA V, and that the alert's Data button opens the data tab.
- Verify the original read-only file and mod inspections still work.
- For a real native-game build, follow `docs/AMMAR_YT_BUILD_AND_TEST.md` after obtaining legally usable matching Web engine, shaders and game data. Merely pressing Run in the preview scheme will never run GTA V.

## Known limitations / necessary future tests

- No full-native build was possible in this development session: the mandatory `8b0b5899ed` engine and shaders are absent.
- The game target is still **landscape only**. The SwiftUI launcher adapts by scrolling in landscape, but the final portrait-to-landscape transition has not been implemented/tested.
- A syntactically valid server URL does not guarantee a working source; the existing native `startEngine` server connection check remains responsible for validating accessibility before gameplay.
- The original native engine and asset preparation must compile and work on a physical iPhone/iPad before claiming gameplay is available.
- The preview's data and mods inspection do not install anything, by design.
- All proprietary game binaries/assets stay outside GitHub.

## Troubleshooting

The user should **not** need Terminal for normal preview code changes. Pull in GitHub Desktop, press Command + R in Xcode, and share any compiler errors. If native Xcode project generation requires game data, do not bypass the game's cryptographic checks or pretend that the standalone preview can start the engine.
