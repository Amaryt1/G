# AMMAR YT GTA V — Native launcher integration

## What is now real vs what is still a preview

The `ios-preview/` target is a **UI-only demonstration**. Its Play button intentionally cannot launch GTA V.

The existing **real game application** is the separate `app/` target, assembled by `app/Scripts/prepare.py` and built by `build_ipa.sh` only after the required authorized, compatible Web build `8b0b5899ed` files are supplied. This branch modifies **that native app**, without substituting a fake gameplay flow.

### Wiring inside the native app

| Launcher control | Existing real implementation |
|---|---|
| Play | `HomeView.playButton` → `NativePortViewController.startEngine()` → actual engine boot |
| Story / Sandbox | `GameSettings.shared.gameMode` / `PGSetStartMode(...)` |
| Data shortcut and game files card | `NativePortViewController.showGameFiles()` → `GameFilesViewController` → `GameInstallManager` / `GameInstaller` |
| Mods / vehicles shortcut | `showInstalledMods()` → `ModsViewController` → `ModInstaller` |
| Settings shortcut | `showSettings()` → `SettingsHomeViewController` |
| Graphics | Existing `GameSettings` and `GraphicsConfiguration` |
| Cheats | Existing `NativeCheats`, only while the real game is running |

The new shortcuts do not duplicate engine logic. Game-file download, archive unpack, verification, installed-mod toggles, and uninstall operations remain implemented in the existing native controllers. Normal mode and game-data checks still gate Play. The first mode selection defaults to **Story**; it can be changed to Sandbox before launch. If files are missing, the user needs to add them in the real data screen.

### Brand and privacy

- The native app's opening screen now uses the AMMAR navy/cyan identity, with no upstream cover art as its background.
- The actual home screen has visible **الداتا / المودات / الإعدادات** shortcuts.
- The original Telegram shortcut and automatic upstream update request have been removed from the native home/startup path.
- Native `PG_NO_STATS` condition already prevents original anonymous statistics in our build configuration.
- The default log upload path no longer sends logs to the upstream server. Explicit **localhost-only** `PG_LOG_ENDPOINT` is allowed for local tests; users can share logs locally instead.
- A local in-app mod guide replaces the previous upstream Mods URL.

### Important remaining limitations

- **No real playable IPA can be produced or verified without the matching legally usable `game.wasm`, shader packs, and game data.** Do not fake or skip their hashes.
- The SwiftUI preview currently installed on the iPhone simulator still uses its own UI-only `ios-preview` target. Changes in `app/` **will not** appear there. This is deliberate isolation until the game engine can be built.
- The native changes in this branch have received static review but have **not** been compiled with Xcode or exercised on a physical device yet. Expect to run a complete native baseline build and QA as soon as valid game inputs exist.
- The app currently uses the upstream runtime's mod compatibility restrictions, startup safety and local Files container behavior; no promise is made that every PC mod or unsupported game archive works.
- The optional external-file server URL remains user-managed. HTTPS is recommended; the existing runtime still supports HTTP for local networks.

## On-device verification plan

1. Build the real native target from a clean checkout after running the upstream input checker with authorized game files.
2. Confirm launch screen reads **AMMAR YT GTA V** and uses the dark-blue/cyan theme.
3. Open **الداتا** and verify local import, URL download, archive extraction, resume and integrity check.
4. Open **المودات**, import a known compatible legal test mod, toggle it on/off, relaunch and verify changes.
5. Select Story then Play and verify actual engine launches on a physical iPhone; repeat with Sandbox.
6. Check that no upstream `fivestarport.site` analytics, log upload or update endpoint is contacted in the default build.
7. Check accessibility, navigation dismissal, memory and thermal behavior, then test signing on the actual phone/iPad certificate.

The existing, successfully tested `ios-preview/` target is retained to avoid losing the UI work. Do not delete it or claim it launches the game.
