# AMMAR YT GTA V — iPhone/iPad UI preview

This folder is an **independent, buildable iOS interface preview** inside the `Amaryt1/G` repository. It lets you see and test the proposed Arabic visual identity on an iPhone/iPad **without game data**.

**Important:** This preview is *not* the real GTA V engine. It does not play GTA V, download or unpack game archives, install mods, or bypass any license or signing restrictions. It only demonstrates the planned launcher UI. The upstream native game source remains under `app/`.

## Included and testable

- Branded dark interface: home, data, mods/cars and about/settings.
- Working navigation between sections.
- Play button explains why the actual game is not yet available.
- Local-only saving of an HTTPS data-source link (no download), with basic URL validation.
- iOS file picker to display the selected archive/folder name (no import/extraction).
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
