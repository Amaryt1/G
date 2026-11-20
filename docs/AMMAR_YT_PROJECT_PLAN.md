# AMMAR YT GTA V — Project Roadmap

> Independent iPhone/iPad IPA project based on the public GTA5Port v1.5.2 source. Not affiliated with Rockstar Games, Take-Two, or Five Star Port. This repository contains no licensed game data.

## Baseline (do not skip)

- Upstream: `kevinerikjs/gta5-ios-port`
- Base commit: `9357c182b5cddd58e16dee684ea07ebc18a97a5d` (v1.5.2)
- Development branch: `feature/ammar-yt-foundation`
- Target: iOS/iPadOS 16.0+; native iOS app/IPA, **not** a macOS game. The Apple Silicon Mac is the build machine.
- Source locations: `app/project.yml` (XcodeGen), `app/App` (UIKit/Swift), `app/Source` (engine host and Metal), `app/Scripts` (code generation), `build_ipa.sh` (IPA build).
- Upstream engine input: pinned Web build `8b0b5899ed`; `game.wasm`, `shaders/index.json`, shader packs and `data/manifest.json` must pass `check_game_files.py`.
- Do not replace or modify `main` until changes are reviewed and tested.

## Milestones and gates

### M0 — Environment and game input verification [BLOCKED on local licensed inputs]

- [ ] Confirm Apple Silicon (`uname -m`), Xcode (`xcodebuild -version`), XcodeGen (`xcodegen --version`) and available disk space on the user's MacBook M4.
- [ ] Supply matching game inputs that the developer has legal permission to use; keep them outside GitHub.
- [ ] Pass `python3 app/Scripts/check_game_files.py --mirror /path/to/game-folder`.
- [ ] Record all build tool versions and exact failure logs without exposing private information or any game data.
- Exit criteria: **Game files OK.** and agreed right to use the required inputs.

### M1 — Build and install the UNMODIFIED upstream baseline [NOT STARTED]

- [ ] From a clean clone of the base commit, run `./build_ipa.sh --mirror /path/to/game-folder --free`.
- [ ] Confirm `GTA5Port.ipa` is generated with a valid `Payload/*.app`.
- [ ] Sign the app using a permitted Apple team/profile; check device provisioning and memory entitlements.
- [ ] Install on iPhone and iPad using Xcode or a suitable IPA signer.
- [ ] Launch, detect locally supplied game data, play Sandbox and Story, test save/reopen, inspect logs and note crashes.
- Exit criteria: baseline installed and launched; any failures documented and reproducible. Never label the baseline stable before real-device checks.

### M2 — Identity, privacy and independence [NOT STARTED]

- [ ] Define brand: `AMMAR YT GTA V`; design original icon and backgrounds.
- [ ] Change display name, bundle identifier, and version in **`app/project.yml` and `app/App/Info.plist`** without changing project identity unintentionally.
- [ ] Audit and disable/replace original project connections: `Analytics.swift`, `LogUploader.swift`, `UpdateCheck.swift`, `Theme.telegramURL`, `ModsViewController` external links, and any other hardcoded host references.
- [ ] Preserve credits/license notices and privacy transparency; never include developer secrets.
- [ ] Confirm whether keeping a separate bundle identifier requires users to reimport their own game data and saves.
- Exit criteria: fresh install launches; no unexpected requests to the original developer's services.

### M3 — Data manager [NOT STARTED]

- [ ] Preserve existing local data, archive import, remote archive download, and resume behavior.
- [ ] Design an optional remotely configurable URL for **authorized user-provided** data sources. No copyrighted game data hosted in this repository.
- [ ] Authenticate downloaded configuration and verify content identity (SHA-256 where available); allow manual URL override.
- [ ] Reject incompatible game builds and fail safely on expired URLs, insufficient storage, changes of archive version, and interrupted downloads.
- [ ] Test real-device local install, resume/restart, integrity validation and low-storage recovery.
- Exit criteria: the app never combines different archives or reports unverified data as complete.

### M4 — Safe mod installer [NOT STARTED]

- [ ] Keep support for verified mod types and explicit compatibility warnings.
- [ ] Make replacing a mod transactional: stage -> validate -> swap, with rollback on failure.
- [ ] Add safe mode without mods, crash recovery, mod enable/disable and a visible reason when a file is unsupported.
- [ ] Test replacement cars, add-on cars, player models, OIV/ASI compatibility independently, offline and after restart.
- Exit criteria: failed installation does not destroy previously working mod files or saves.

### M5 — AMMAR MOD MENU and vehicles [NOT STARTED]

- [ ] Create an original branded mod/cheat UI using the existing engine-supported commands.
- [ ] Add verified custom vehicle asset workflow: Blender -> Sollumz -> correctly packed Legacy-compatible assets.
- [ ] Begin with one replacement vehicle; test texture, wheels, collision, LOD, memory and frame pacing before add-on packaging.
- [ ] Avoid claiming all PC script mods or enhanced-edition assets work.
- Exit criteria: reproducible on-device tests with clean restart and save compatibility.

### M6 — Performance, updates, beta QA [NOT STARTED]

- [ ] Measure actual FPS, memory usage, thermal state, load time, shader compilation, app crashes and cold-launch behavior.
- [ ] Check on both available iOS devices; test alternative signing profiles and entitlement behavior.
- [ ] Verify update handling does not corrupt saves or installed user data; use independent and authorized distribution only.
- Exit criteria: documented beta checklist passes, with unresolved limitations listed transparently.

## Working rules

1. One small change per branch/PR, with scope, verification evidence, and rollback plan.
2. Never commit **game archives, generated engine code, shaders derived from the game, game assets, signed or unsigned IPA builds containing copyrighted code, Apple provisioning profiles, private keys, or credentials**.
3. The upstream MIT license only covers the source written for that port, not GTA V itself or separate third-party code/licenses.
4. Keep the Mac as the build/development environment, but the iPhone/iPad as the primary runtime targets.
5. When no compatible and authorized `game.wasm` and shaders are available, stop at static code review and tests; do not claim a successful playable build.
6. Keep Feather, Mstoda, AMARYT STORE and their deployment systems completely separate from this repository.

## Current state (2026-11-20)

- Repo `Amaryt1/G` is an existing public fork, not an empty repository.
- `main` still equals upstream v1.5.2 base commit.
- No local Mac build, IPA generation, signing, or iPhone runtime test has been observed in this chat.
- Immediate next milestone: **M0** and then a clean **M1** baseline build.
