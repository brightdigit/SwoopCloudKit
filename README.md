# SwoopCloudKit

[![SwiftPM](https://img.shields.io/badge/SPM-macOS%20%7C%20Linux%20(snapshots)-success?logo=swift)](https://swift.org)
[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSwoopCloudKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/SwoopCloudKit)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSwoopCloudKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/SwoopCloudKit)
[![License](https://img.shields.io/github/license/brightdigit/SwoopCloudKit)](LICENSE)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/SwoopCloudKit/SwoopCloudKit.yml?label=actions&logo=github)](https://github.com/brightdigit/SwoopCloudKit/actions)
[![Documentation](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/brightdigit/SwoopCloudKit/documentation)

A read-only reader for the public CloudKit database of `iCloud.com.brightdigit.Bushel`, using native `CloudKit.framework`. It maps `CKRecord`s onto the record models from [SwoopKit](https://github.com/brightdigit/SwoopKit). Bushel and Stewed share it.

[SwoopMistKit](https://github.com/brightdigit/SwoopMistKit) writes the database. This package only queries it, and it needs no API token or server-to-server key: it uses the app's iCloud entitlement.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [What it reads](#what-it-reads)
- [Release-data snapshot and cache file](#release-data-snapshot-and-cache-file)
- [Documentation](#documentation)
- [Development](#development)
- [Branches](#branches)
- [License](#license)

## Requirements

- Swift 6.4 (Xcode 27) or later.
- macOS 14 or later for the CloudKit readers, with the iCloud (CloudKit) capability and the `iCloud.com.brightdigit.Bushel` container in the app's entitlements, and a signed-in iCloud account at run time.
- The snapshot, cache file and JSON helpers also build on Linux.

## Installation

```swift
dependencies: [
  .package(url: "https://github.com/brightdigit/SwoopCloudKit.git", branch: "main")
],
targets: [
  .target(
    name: "MyApp",
    dependencies: [.product(name: "SwoopCloudKit", package: "SwoopCloudKit")]
  )
]
```

## Usage

```swift
import SwoopCloudKit

let catalog = CloudKitReleaseCatalog()
guard try await catalog.accountStatus() == .available else {
  // Ask the user to sign in to iCloud, or keep using cached data.
  return
}
let snapshot = try await catalog.fetchSnapshot(now: .now)
try ReleaseDataCacheFile.encode(snapshot).write(to: cacheURL, options: .atomic)
```

## What it reads

- `RestoreImage`, through `CloudKitRestoreImageService` (one page, for Bushel's catalog).
- `SDKVersion`, `XcodeVersion` and `SimulatorRuntime`, through `CloudKitReleaseCatalog`: every page, mapped to SwoopKit's `SDKVersionRecord`, `XcodeVersionRecord` and `SimulatorRuntimeRecord`. Records that don't map are returned as skips instead of failing the fetch. The types grant `READ` only to `_icloud`, so `accountStatus()` must be `.available`.

A development-signed build reads the container's Development environment; a Developer ID or App Store build reads Production.

## Release-data snapshot and cache file

These build everywhere: they're outside `#if canImport(CloudKit)`.

- `ReleaseDataSnapshot`: `SDKVersion`, `XcodeVersion` and `SimulatorRuntime` records with the `fetchedAt` date of the fetch. JSON with ISO 8601 dates; a file without `simulatorRuntimes` decodes with none. `init(json:)` reads one, such as an app's bundled snapshot.
- `ReleaseDataCacheFile`: a disk cache's contents, the snapshot plus `formatVersion` (currently 1). `decode(_:)` checks the version before decoding records and throws a typed `ReleaseDataCacheError`. Where the file lives is up to the app.
- `CloudKitReleaseCatalog.fetchSnapshot(now:)` fetches `SDKVersion`, `XcodeVersion` and `SimulatorRuntime` into a snapshot. An environment without the `SimulatorRuntime` record type (`CKError.unknownItem`) gives a snapshot with no runtime records instead of failing.
- `JSONDecoder.iso8601`, `JSONDecoder.decodeValue(_:from:)` (typed throws), `JSONEncoder.iso8601PrettySorted` and `JSONEncoder.encodeAsserting(_:)`, the coders the files use.

Moved from Stewed's StewedKit (Stewed #124). The JSON is unchanged: `Tests/SwoopCloudKitTests/Resources/release-data/cache-format-1.json` was written by Stewed's code before the move, and the tests check that it decodes and re-encodes to the same bytes.

Tests (`swift test`) cover the `CKRecord` mappings with hand-built records, and the snapshot and cache file with the JSON fixtures in `Tests/SwoopCloudKitTests/Resources/release-data/` (copies of Stewed's `docs/fixtures/release-data/`). They never open a `CKContainer`, which traps without the iCloud entitlement, so they need no iCloud account or network.

Seeded from Bushel's `BushelCloudKitDebug` module (`v3.0.0-alpha.3`, `46b6240`): the `RestoreImage` query, the account-status check, the `RestoreImageRecord` mapping and the `CKRecord` value helpers. The SwiftUI debug window and the `ImageMetadata` derivation stayed in Bushel, because they depend on Bushel's app modules.

## Documentation

The DocC catalog is in `Sources/SwoopCloudKit/SwoopCloudKit.docc`, with articles on reading release data from CloudKit and on caching it. Build it with `make docs` (`Scripts/docc.sh`, warnings as errors; output in `.build/docs`) or preview it with `make docs-preview`. The package doesn't depend on swift-docc-plugin, so packages that depend on SwoopCloudKit never resolve it. Swift Package Index hosts the published documentation (`.spi.yml`).

## Development

```bash
swift build
swift test
make lint      # swift-format, SwiftLint, build, headers, periphery (run `mise install` once)
make docs
```

Lint tools are pinned in `mise.toml`. See `CLAUDE.md` for the package's rules.

## Branches

- `simulator`: Stewed's working branch. It depends on SwoopKit by path (`../SwoopKit`), as a sibling subrepo. CI swaps that path for the SwoopKit repo (`.github/actions/setup-swoopkit`).
- `main`: depends on SwoopKit by URL.

## License

SwoopCloudKit is available under the MIT license. See [LICENSE](LICENSE).
