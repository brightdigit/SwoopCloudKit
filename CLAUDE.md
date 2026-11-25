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
- Keep the platform minimum (macOS 14) unless a consumer needs it raised.
- Every public symbol has a doc comment. Add new public types to a topic group in `Sources/SwoopCloudKit/SwoopCloudKit.docc/SwoopCloudKit.md`. Link SwoopKit types in code voice (`SDKVersionRecord`), not as ``symbol links``: DocC can't resolve another module's symbols.
- One type per file; extensions go in `Type+Feature.swift`. Each source file carries the MIT header (`make headers`).

## Branches and the SwoopKit dependency

This package is a git subrepo inside Stewed (`Packages/SwoopCloudKit`, branch `simulator`). There it depends on SwoopKit's `simulator` branch by URL; `main` uses a SwoopKit version. `.github/actions/setup-swoopkit` used to swap a sibling path for that URL in CI and now does nothing.

## Commands

```bash
swift build
swift test             # Swift Testing; never touches iCloud or the network
make lint              # Scripts/lint.sh (tools pinned in mise.toml; run `mise install` once)
make docs              # DocC with --warnings-as-errors; output in .build/docs
make docs-preview
```

`Scripts/lint.sh` formats in place outside CI, then runs swift-format and SwiftLint in strict mode, `swift build --build-tests` (locally), the header script and periphery (locally, if installed).

## CI

GitHub Actions workflows trigger on `pull_request` (plus `workflow_dispatch`, a weekly CodeQL schedule and branch deletion for cache cleanup), never on `push`.

- The manifest needs Swift 6.4, so the Linux lane uses the `swiftlang/swift:nightly-6.4.x` image (it builds and tests only the non-CloudKit code) and the macOS lanes use the `xcode-27` runner image. macOS is the only Apple platform declared, so there are no iOS, watchOS, tvOS or visionOS lanes.
- The docs job builds DocC on macOS with warnings as errors.
- Swift Package Index builds the published docs on macOS (`.spi.yml`).
