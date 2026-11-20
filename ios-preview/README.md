# AMMAR YT GTA V — iPhone/iPad UI preview

This folder is an **independent, buildable iOS interface preview (v0.3.1)** inside the `Amaryt1/G` repository. It lets you see and test the proposed Arabic visual identity on an iPhone/iPad **without game data**.

**Important:** This preview is *not* the real GTA V engine. It does not play GTA V, download or unpack game archives, install mods, or bypass any license or signing restrictions. It only demonstrates the planned launcher UI. The upstream native game source remains under `app/`.

## Included and testable

- Branded dark interface: home, data, mods/cars and about/settings.
- Working navigation between sections.
- In preview the main action opens the Data setup tab instead of showing a misleading fake game launch. Native Play enters the original app shell and delegates missing-data prompting to the existing port.
- Local-only saving of an HTTPS data-source link (no download), with basic URL validation.
- iOS Files picker with **read-only inspection** of chosen data folders, archives and test mod files.
- Shows file name, type and actual size; computes **SHA-256 for small test files up to 8 MiB**.
- A selected folder is checked for three basic layout markers (`data/manifest.json`, `b/8b0b5899ed/game.wasm`, `b/8b0b5899ed/shaders/index.json`). This does **not** prove data compatibility or game build readiness.
- No file copying, extraction, download, mod installation or execution; no data is uploaded.
- No telemetry, update checks, or network requests.
- iOS 16+ target for both iPhone and iPad.

## One-command build on MacBook M4

Open **GitHub Desktop → Repository → Open in Terminal**. Check out `feature/ammar-yt-v031-native-entry` and fetch/pull it first.

Run:

```bash
bash ios-preview/build_preview_ipa.sh
```

The script installs nothing and does not need game files. It generates `ios-preview/AMMARYTGTAUIPreview.xcodeproj` and builds:

```text
ios-preview/Build/AMMAR-YT-GTA-V-Preview.ipa
```

This IPA has **not been signed for your device**. You must sign it with your own valid Apple development profile or compatible sideloading tool. An iPad-only certificate/profile may not be valid for your iPhone.

### Easier on-device debug/install with Xcode

After running the script, open `ios-preview/AMMARYTGTAUIPreview.xcodeproj` in Xcode, choose your iPhone/iPad destination, set **Signing & Capabilities → Team** to your own Apple team, and change the bundle identifier if Xcode requests a unique one. Press **Run**. This path can install the development app without manually exporting an IPA.

### How this fits the future game app

The original game is a separate runtime target in `app/`. Since v0.3.0 the **same SwiftUI launcher source** is compiled in that native target via `AMMAR_NATIVE`. Its Play action is bound by `NativePortViewController` to the actual engine boot, with real data, mods and settings controls. The standalone preview target remains deliberately isolated: it cannot start GTA V or install game files. After obtaining authorized, matching `game.wasm` and shaders, we will build and verify the original game target, then transfer validated UI changes and functionality into it. We will not publish proprietary game code, game files, keys or signed app packages.

## Troubleshooting

- `command not found: xcodegen`: install with `brew install xcodegen`.
- `xcodebuild` fails: inspect `ios-preview/Build/xcodebuild.log` and share a screenshot of the **error lines**, not private signing information.
- Simulator or Xcode shows `No such module 'UIKit'`: open the generated **.xcodeproj**, not an individual Swift file, and choose an iOS target instead of **My Mac**.
- Do not merge this branch into `main` before reviewing and testing. Keep `Feather`, `Mstoda` and store code outside this repository.


## Preview v0.3.1 test checklist

1. Build with `bash ios-preview/build_preview_ipa.sh` or run the generated `.xcodeproj` on the iPhone Simulator.
2. Open **الداتا**, save a valid `https://` URL, switch tabs, and return. The saved URL should remain. Try an invalid URL and confirm rejection.
3. Open **الداتا → اختيار أرشيف أو مجلد** and select a small ZIP test file. The name, size and SHA-256 should appear (SHA-256 only for files up to 8 MiB).
4. Select a directory. The view should report whether the three minimum game-folder layout markers are present; it must not say the engine is valid from path presence alone.
5. Open **المودات → اختيار ZIP / OIV / ملف مود**, pick a small test archive, and confirm read-only inspection. Nothing should be installed.
6. Press **فتح إعدادات اللعبة** in the engine-free simulator preview; the Data tab should open directly without a fake Play confirmation.
7. Test on a physical iPhone/iPad with an actual provisioned Apple profile before calling it device-tested.

The game engine under `app/` is not part of this preview build. Never upload copyrighted game content or signing credentials to GitHub.

### v0.3.1 — No-Terminal simulator test

1. In **GitHub Desktop**, Fetch/Pull branch `feature/ammar-yt-v031-native-entry`.
2. Open the previously generated `AMMARYTGTAUIPreview.xcodeproj` in Xcode and press **Command + R**.
3. Check the Home and Settings tabs both display **v0.3.1**, even when the generated Xcode Info.plist is still on an older setting.
4. Choose Story or Sandbox. The engine-free preview shows **فتح إعدادات اللعبة** and enters the Data tab, with no “نسخة معاينة فقط” alert. It does not pretend to boot the GTA game.
5. All previously available data and mod file inspections should still work.
6. For real engine boot testing, use the separate native target only once the permitted matching engine and shaders exist and the native game build succeeds.

### Native entry without downloaded data (v0.3.1)

The **full native game application** can show its original file setup before playable game data has been installed. With a compiled native engine on iPhone, tapping **تشغيل اللعبة** in the shared AMMAR launcher reveals the existing original GTA port shell and forwards to its **unchanged** `startEngine()` preflight. When no usable local folder or reachable asset server is present, that existing handler calls `showGameFiles()`, and the original `GameFilesViewController` presents its add-game guide on first run. Downloads and missing-file messages remain implemented by the original project.

**This does not mean GTA V's 3D world can run without data.** Both the matching engine/shaders at build time and compatible game files at runtime are still necessary for actual gameplay. The separate `ios-preview/` target deliberately has no engine.
