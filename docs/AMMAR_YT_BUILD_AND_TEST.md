# AMMAR YT GTA V — MacBook M4 setup and iPhone/iPad baseline test

**Goal:** create and test an iPhone/iPad **IPA** from the existing fork, without modifying the original upstream runtime first. The MacBook M4 is only the build machine.

## 1. Clone and select branch

1. In GitHub Desktop: File → Clone Repository → select `Amaryt1/G`.
2. Select the branch `feature/ammar-yt-foundation` in GitHub Desktop.
3. Open the local repository in Terminal (`Repository → Open in Terminal`, or open its folder).

Do **not** copy GTA V game archives, game shader files, signing credentials, or private assets into the Git checkout.

## 2. Preflight Mac environment

Run from the repository root:

```bash
uname -m
xcode-select -p
xcodebuild -version
python3 --version
xcodegen --version
df -h .
git rev-parse --short HEAD
```

Expected CPU architecture: `arm64`. Install XcodeGen only if needed:

```bash
brew install xcodegen
```

The underlying project expects a fully installed Xcode and uses Python, XcodeGen, clang/Metal and pinned build-time tools.

## 3. Obtain and verify compatible, authorized inputs (mandatory)

The `--mirror` folder must contain:

```text
/path/to/game-folder/
  data/
    manifest.json
    common/
    x64/
  b/
    8b0b5899ed/
      game.wasm
      shaders/
        index.json
        ... shader packs
```

The `game.wasm` SHA-256 and shader index SHA-256 are pinned in `app/Scripts/check_game_files.py`. No ordinary GTA V PC installation automatically supplies this WebAssembly build.

Do not upload the data or generated derivatives to GitHub or distribute copies without a license granting those rights. If these inputs are not available with appropriate permission, **do not bypass the digest checks** and do not claim this version can be built and played.

Run:

```bash
python3 app/Scripts/check_game_files.py --mirror "/path/to/game-folder"
```

Expected success message: `Game files OK.`

## 4. Build unchanged IPA first

```bash
./build_ipa.sh --mirror "/path/to/game-folder" --free
```

The baseline script generates `GTA5Port.ipa` at the repository root; it is not immediately installable until an appropriate signature is applied. Build output can be diagnosed in `app/Build/xcodebuild.log`. A preparation/build failure is NOT a completed build.

If you use Xcode directly after preparation, open the generated `app/PlayGTA5Native.xcodeproj`. Choose the iPhone or iPad under Devices, use your Apple signing Team, and set a unique bundle identifier if required. For persistent changes to project configuration use `app/project.yml` (the Xcode project is generated, and local project edits may be overwritten).

A certificate for one device does not necessarily provision another. Elevated-memory entitlements must be present in the actual granted signature/profile, not merely in an entitlement file.

## 5. Initial device test matrix

Check each on the **iPhone and iPad**, logging actual device model and iOS version without personal identifiers.

| Test | iPhone | iPad |
|---|---|---|
| IPA installs with proper profile | Not tested | Not tested |
| First launch shows home and game-file UI | Not tested | Not tested |
| Detects files the user supplied in the app folder | Not tested | Not tested |
| Offline Sandbox launches and driving works | Not tested | Not tested |
| Story Mode starts, saves, and resumes correctly | Not tested | Not tested |
| Controls: movement, camera, vehicle, pause | Not tested | Not tested |
| App force-quit and cold restart preserve data | Not tested | Not tested |
| Download interruption/resume with authorized test archive | Not tested | Not tested |
| Baseline launch without mods | Not tested | Not tested |
| Device thermals, crashes, app logs | Not tested | Not tested |

For each failure, record: observed action, expected result, actual result, device/iOS version, and sanitized `xcodebuild.log` or app's Share log.

## 6. First real source changes — only after M0 and M1

1. Original app identity and bundle ID.
2. Disconnect original analytics, update and log-upload endpoints.
3. Run smoke tests again on both devices.
4. Then implement **AMMAR DATA MANAGER**, transactional mods, custom cars and mod menu in isolated PRs.

## Release safety

The current GitHub fork is **public**. The source code may be visible to anyone; avoid pushing private credentials or proprietary game files. GitHub Actions and Releases are not authorized storage for unlicensed game content or derived engine binaries. Preserve attribution and all third-party licenses.
