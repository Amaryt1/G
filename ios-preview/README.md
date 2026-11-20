# AMMAR YT GTA V — iPhone/iPad UI preview

This folder is an **independent, buildable iOS interface preview (v0.2.0)** inside the `Amaryt1/G` repository. It lets you see and test the proposed Arabic visual identity on an iPhone/iPad **without game data**.

**Important:** This preview is *not* the real GTA V engine. It does not play GTA V, download or unpack game archives, install mods, or bypass any license or signing restrictions. It only demonstrates the planned launcher UI. The upstream native game source remains under `app/`.

## Included and testable

- Branded dark interface: home, data, mods/cars and about/settings.
- Working navigation between sections.
- Play button explains why the actual game is not yet available.
- Local-only saving of an HTTPS data-source link (no download), with basic URL validation.
- iOS Files picker with **read-only inspection** of chosen data folders, archives and test mod files.
- Shows file name, type and actual size; computes **SHA-256 for small test files up to 8 MiB**.
- A selected folder is checked for three basic layout markers (`data/manifest.json`, `b/8b0b5899ed/game.wasm`, `b/8b0b5899ed/shaders/index.json`). This does **not** prove data compatibility or game build readiness.
- No file copying, extraction, download, mod installation or execution; no data is uploaded.
- No telemetry, update checks, or network requests.
- iOS 16+ target for both iPhone and iPad.

## One-command build on MacBook M4

Open **GitHub Desktop → Repository → Open in Terminal**. Check out `feature/ammar-yt-ui-preview` and fetch/pull it first.

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

The original app in `app/` is a separate runtime target. This preview is deliberately isolated: it is not yet linked to `GameInstallManager`, `GameFolder`, or any game renderer. After obtaining authorized, matching `game.wasm` and shaders, we will build and verify the original game target, then transfer validated UI changes and functionality into it. We will not publish proprietary game code, game files, keys or signed app packages.

## Troubleshooting

- `command not found: xcodegen`: install with `brew install xcodegen`.
- `xcodebuild` fails: inspect `ios-preview/Build/xcodebuild.log` and share a screenshot of the **error lines**, not private signing information.
- Simulator or Xcode shows `No such module 'UIKit'`: open the generated **.xcodeproj**, not an individual Swift file, and choose an iOS target instead of **My Mac**.
- Do not merge this branch into `main` before reviewing and testing. Keep `Feather`, `Mstoda` and store code outside this repository.


## Preview v0.2.0 test checklist

1. Build with `bash ios-preview/build_preview_ipa.sh` or run the generated `.xcodeproj` on the iPhone Simulator.
2. Open **الداتا**, save a valid `https://` URL, switch tabs, and return. The saved URL should remain. Try an invalid URL and confirm rejection.
3. Open **الداتا → اختيار أرشيف أو مجلد** and select a small ZIP test file. The name, size and SHA-256 should appear (SHA-256 only for files up to 8 MiB).
4. Select a directory. The view should report whether the three minimum game-folder layout markers are present; it must not say the engine is valid from path presence alone.
5. Open **المودات → اختيار ZIP / OIV / ملف مود**, pick a small test archive, and confirm read-only inspection. Nothing should be installed.
6. Press **تشغيل اللعبة** and verify the honest `UI-only` alert still appears.
7. Test on a physical iPhone/iPad with an actual provisioned Apple profile before calling it device-tested.

The game engine under `app/` is not part of this preview build. Never upload copyrighted game content or signing credentials to GitHub.
