# AMMAR YT GTA V — Real one-app iOS integration (v0.3.2)

**Development branch:** `feature/ammar-yt-v032-native-app`  
**Status:** source integration complete for native launcher and orientation flow; real engine build and on-device gameplay **NOT VERIFIED** because the required game build input was not supplied. Keep this branch unmerged until Xcode and device QA.

## Product architecture

The final installed application is **one** iOS application, with a single `@main AppDelegate`, one scene and one binary (`PlayGTA5Native`):

```text
app/PlayGTA5Native.xcodeproj  (generated from app/project.yml)
  -> NativePortViewController (actual renderer, game engine bridge, audio, controls)
    -> UIHostingController<PreviewRoot> (AMMAR SwiftUI launcher)
       -> Play: selects Story/Sandbox, uses original startEngine()
       -> Data: original GameFilesViewController and in-app download/setup
       -> Mods: original ModsViewController and ModInstaller
       -> Settings: original SettingsHomeViewController
    -> original PGStartEngine(...) when validated game inputs are ready
    -> hide launcher on WORLD_READY/first native frame
```

The `ios-preview/` Xcode scheme is only for visually testing the same launcher source. It has **no GTA engine**; pressing its button is **not evidence that GTA V works**.

The native app ships with native engine code and shader assets compiled **at build time** from a legally usable matching WebAssembly build, and can receive its large gameplay data via the original in-app file manager after installation. The game data does not have to be hardcoded into the IPA, but the engine input and compiled shaders **must** be available at build time. Do not confuse the two roles.

### v0.3.2 behavior

1. First launch of the actual game app shows the AMMAR navy/cyan launcher, with a visible `v0.3.2` in Home and Settings.
2. Data, Mods and Settings open the original native managers, not the standalone preview screens.
3. Pressing **تشغيل اللعبة** selects Story or Sandbox and delegates to the unchanged `startEngine` routine.
4. If files are missing or the server does not answer, the original `GameFilesViewController` and its first-run add-data guide are shown; the AMMAR launcher remains underneath.
5. If a candidate game folder is no longer readable, the launcher directs the user to the real Game Files manager.
6. If preflight succeeds, the app requests iOS landscape orientation and waits until the actual window is wider than it is tall; only then does it start the Metal game boot. The port's original `PGStartEngine` remains the final entry point.
7. The AMMAR launcher hides only on the native engine's `WORLD_READY` or first-frame event. If the engine stops, the original error panel remains visible.

The new orientation transition is code-reviewed and syntax-checked but **untested on device**, so treat it as a candidate implementation rather than guaranteed runtime behavior.

## Mandatory external build inputs

The original code repository does **not** include the GTA V engine or game world. The native build scripts demand these files from your own authorized compatible game build:

- `data/manifest.json`
- `b/8b0b5899ed/game.wasm`
- `b/8b0b5899ed/shaders/index.json`
- all shader packs enumerated in that shader index

The original `app/Scripts/check_game_files.py` compares SHA-256 for the WASM engine and shader index. It refuses missing, different or incomplete builds. `app/Scripts/prepare.py` translates the exact matching WebAssembly engine into native C/ARM64 and converts those shaders into a compiled Metal library, then uses XcodeGen to produce `PlayGTA5Native.xcodeproj`.

**Do not bypass these hashes or upload licensed GTA engine/assets to a public GitHub repository.** Files from a Steam/Epic/Rockstar PC installation or Xbox release alone do not automatically satisfy this specific Web-build format.

The repository's `build_ipa.sh` creates an ad-hoc-signed/unsigned-for-distribution build of the native app when those same inputs exist. The recipient must sign it using a valid Apple account/provisioning profile and add compatible gameplay files or a working game server in the original Game Files screen.

## No manual Terminal commands: use Script Editor/Finder once

The source contains a macOS GUI bootstrap:

`tools/AMMAR_Native_Setup.applescript`

1. Open the `G` folder through **GitHub Desktop → Repository → Show in Finder**.
2. Open `tools/AMMAR_Native_Setup.applescript` using **Script Editor**, and click the **Run** button in that app.
3. Select your cloned **G** repository folder and the folder containing your authorized matching Web game build (`data/` and `b/`).
4. Choose **تجهيز Xcode** to generate the real `app/PlayGTA5Native.xcodeproj`, including iPhone and Simulator SDK dependencies, or **بناء IPA** to produce an unsigned IPA using the existing native build script.
5. When the first option finishes, the script opens **PlayGTA5Native** in Xcode. Choose the correct `PlayGTA5Native` scheme and your real iPhone or simulator, set **Signing & Capabilities** for a real device, then use **Command + R**.
6. When the second option finishes, Finder reveals `AMMAR-YT-GTA-V.ipa`. **Signing is still required before installation on iPhone**.

The script shows the end of the error log on failure. Complete diagnostics remain in `app/Build/AMMAR-native-setup.log`. It downloads only build-tool dependencies referenced by the existing scripts; it does **not** find, download or redistribute the GTA engine or game data.

**Until the matching legal game build is available, the real Xcode project cannot be fully generated or built.** Existing `ios-preview` working screenshots prove only the interface.

## Native quality checks

- [x] Same shared SwiftUI launcher compiled in the native XcodeGen target under `AMMAR_NATIVE`, preserving the original native `@main`.
- [x] Real data/mod/settings callbacks target existing native screens.
- [x] Native Play routes to original `startEngine`/`PGStartEngine`, preserving file/server checks.
- [x] Missing game data opens the original in-app setup; no fake driving scene.
- [x] Visible `v0.3.2` and both project versions align.
- [x] CI compiles the stand-alone SwiftUI preview, syntax-checks the native launcher, tests version parity, and syntax-checks the Finder/Script Editor setup tool.
- [ ] Full native iPhone/simulator compilation **with real Web engine and shaders**.
- [ ] First-frame runtime validation on a physical iPhone.
- [ ] Portrait -> landscape transition on an actual device.
- [ ] Download/resume, game-data verification, safe mod import, graphics, audio, input, saves and thermal test.
- [ ] Confirm no residual requests to original developer endpoints at runtime before any public distribution.
- [ ] Review GTA V asset, game code and trademark rights before distributing an IPA or files.

## Related upstream/alternatives review

- `kevinerikjs/gta5-ios-port` upstream release v1.5.2 provides this code architecture and the built-in data manager. Its README explicitly says it has **no game files or game code**; this fork does not add those.
- Other iOS GTA V recompilation projects may use an entirely different base (for example Xbox 360 TU27) and have different licenses; they are not plug-in replacement engines for this WASM-to-ARM64 project.
- A public prebuilt `.ipa` does not automatically provide editable, authorized native engine source compatible with our Xcode project.

There is **no safe, truthful shortcut** from the interface-only preview to a playable GTA V native IPA without supplying and validating the matching engine/shader inputs. This is the remaining concrete blocker, not a missing Play button.
