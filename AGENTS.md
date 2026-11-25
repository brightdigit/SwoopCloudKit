# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

SwoopCloudKit is the read side of the Swoop release-data packages. It queries the **public** CloudKit database of `iCloud.com.brightdigit.Swoop` with native `CloudKit.framework` and maps each `CKRecord` onto SwoopKit's models. It has one library product and one target, `SwoopCloudKit`, and depends only on SwoopKit.

- `CloudKitReleaseCatalog` reads `SDKVersion`, `XcodeVersion` and `SimulatorRuntime` (every page; unmappable records come back as `CloudKitRecordSkip`s, not failures), checks the iCloud account (`CloudKitAccountStatus`), and builds a `ReleaseDataSnapshot` (`fetchSnapshot(now:)`).
- `CloudKitRestoreImageService` lists `RestoreImage` records for Bushel (one page).
- `ReleaseDataSnapshot`, `ReleaseDataCacheFile` and the JSON coder extensions turn release data into stable JSON for a disk cache or a bundled snapshot.

SwoopMistKit writes the database; Stewed and Bushel read it through this package.

## Rules

- **Read-only, no credentials.** Never write to CloudKit, and never add an API token, server-to-server key or MistKit dependency. Access comes from the app's iCloud entitlement and the user's iCloud account (the record types grant `READ` only to `_icloud`).
- **Never open a `CKContainer` in tests.** Without the iCloud entitlement it traps. Test mappings with hand-built `CKRecord`s and the snapshot/cache with the JSON fixtures in `Tests/SwoopCloudKitTests/Resources/release-data/`.
- **CloudKit code stays inside `#if canImport(CloudKit)`.** The snapshot, cache file and JSON helpers stay outside it, so they build on Linux.
- **Don't break the JSON.** The snapshot and cache file are persisted by apps. A new field must decode as empty or `nil` when missing, with a test that old JSON still decodes. Bump `ReleaseDataCacheFile.currentFormatVersion` only for an incompatible change.
- **Mappings mirror SwoopMistKit's writer** (`from(recordInfo:)`) and its `schema.ckdb`: booleans are `INT64`, references become record-name strings, `sdkBuildNumbersText` is comma-separated text (MistKit#509).
- **No swift-docc-plugin in `Package.swift`.** It would be resolved by every package that depends on SwoopCloudKit. Build docs with `Scripts/docc.sh`.
- Swift 6.4 (swift-tools-version 6.4), Swift 6 language mode, complete strict concurrency, `ExistentialAny` and `InternalImportsByDefault`. Every public type is `Sendable`. Use typed throws for new throwing APIs.
- Keep the platform minimums (macOS 14; iOS 18, watchOS 11, tvOS 18, visionOS 2 and Mac Catalyst 18, matching SwoopKit) unless a consumer needs them raised.
- Every public symbol has a doc comment. Add new public types to a topic group in `Sources/SwoopCloudKit/SwoopCloudKit.docc/SwoopCloudKit.md`. Link SwoopKit types in code voice (`SDKVersionRecord`), not as ``symbol links``: DocC can't resolve another module's symbols.
- One type per file; extensions go in `Type+Feature.swift`. Each source file carries the MIT header (`make headers`).

## Branches and the SwoopKit dependency

The `simulator` branch is Stewed's working branch and depends on SwoopKit's `simulator` branch by URL (`Package.resolved` pins the revision; `swift package update` moves it). `main` uses a SwoopKit version.

## Commands

```bash
swift build
swift test             # Swift Testing; never touches iCloud or the network
make lint              # Scripts/lint.sh (tools pinned in mise.toml; run `mise install` once)
make docs              # DocC with --warnings-as-errors; output in .build/docs
make docs-preview
```

`Scripts/lint.sh` formats in place outside CI, then runs swift-format and SwiftLint in strict mode, `swift build --build-tests` (locally), the header script and periphery (locally, if installed). In Claude Code web sessions (`CLAUDE_CODE_REMOTE=true`) it skips mise, SwiftLint and periphery.

There is no Xcode project or XcodeGen target; open `Package.swift` directly.

## CI

GitHub Actions workflows trigger on `pull_request` (plus `workflow_dispatch`, branch deletion for cache cleanup, and issue/review-comment events for `claude.yml`), never on `push`. PRs into `main` or a semver branch (`v1.2.3`, `1.2.3-beta.1`) add a jammy Linux lane. There is no CodeQL workflow: CodeQL can't analyze Swift 6.4 yet.

- The manifest needs Swift 6.4, so the Linux lanes use the release `swift:6.4-<os>` images (they build and test only the non-CloudKit code) and the macOS lanes use the `xcode-27` runner image with `/Applications/Xcode_27.2.app`. Every PR builds SPM on macOS and iOS; PRs into `main` or a semver branch also build macOS, watchOS, tvOS and visionOS with xcodebuild.
- The lint job is pinned to `ubuntu-24.04`: `ubuntu-latest` is Ubuntu 26.04, which lacks the `libxml2.so.2` the SwiftLint binary needs.
- The docs job builds DocC on macOS with warnings as errors.
- Swift Package Index builds the published docs on macOS (`.spi.yml`).

## Memory & Corrections Convention

`AGENTS.md` and `.agents/` are the real files. `CLAUDE.md` and `.claude` are symlinks to them, so Claude Code finds them too. Edit the real paths, and don't replace a symlink with a copy.

These two files are the source of truth for how to work in this repo. Both are committed to git.

- **`.agents/agent-notes.md`**: an append-only log of the maintainer's corrections and standing always/never directives, one line each, newest at the bottom.
- **`.agents/memory/`**: this project's memory store. One markdown file per project-scoped fact (decisions, constraints, gotchas, context not derivable from the code or git history), indexed in `.agents/memory/MEMORY.md`.

Rules:

1. Read `.agents/agent-notes.md` and `.agents/memory/MEMORY.md` before doing any work.
2. Append to them proactively, without being asked: a line in `agent-notes.md` for every correction or always/never instruction, and a memory file plus index line for every project fact worth keeping.
3. When a directive or memory is superseded or wrong, update or delete the stale entry rather than leaving both.
4. Never store project-scoped memories in a native or global memory system (such as Claude Code's `~/.claude/projects/<project>/memory/`). They belong in the repo so they're versioned and visible to every person and agent working here.
