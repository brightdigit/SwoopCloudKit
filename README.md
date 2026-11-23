# SwoopCloudKit

A read-only reader for the public CloudKit database of `iCloud.com.brightdigit.Bushel`, using native `CloudKit.framework`. It maps `CKRecord`s onto the record models from SwoopKit. Bushel and Stewed share it.

[SwoopMistKit](https://github.com/brightdigit/BushelCloud) writes the database. This package only queries it, and it needs no API token or server-to-server key: it uses the app's iCloud entitlement.

## What it reads

- `RestoreImage`, through `CloudKitRestoreImageService` (one page, for Bushel's catalog).
- `SDKVersion` and `XcodeVersion`, through `CloudKitReleaseCatalog`: every page, mapped to SwoopKit's `SDKVersionRecord` and `XcodeVersionRecord`. Records that don't map are returned as skips instead of failing the fetch. Both types grant `READ` only to `_icloud`, so `accountStatus()` must be `.available`.

A development-signed build reads the container's Development environment; a Developer ID or App Store build reads Production.

## Release-data snapshot and cache file

These build everywhere: they're outside `#if canImport(CloudKit)`.

- `ReleaseDataSnapshot`: `SDKVersion`, `XcodeVersion` and `SimulatorRuntime` records with the `fetchedAt` date of the fetch. JSON with ISO 8601 dates; a file without `simulatorRuntimes` decodes with none. `init(json:)` reads one, such as an app's bundled snapshot.
- `ReleaseDataCacheFile`: a disk cache's contents, the snapshot plus `formatVersion` (currently 1). `decode(_:)` checks the version before decoding records and throws a typed `ReleaseDataCacheError`. Where the file lives is up to the app.
- `CloudKitReleaseCatalog.fetchSnapshot(now:)` fetches `SDKVersion` and `XcodeVersion` into a snapshot. It doesn't fetch `SimulatorRuntime` records yet.
- `JSONDecoder.iso8601`, `JSONDecoder.decodeValue(_:from:)` (typed throws), `JSONEncoder.iso8601PrettySorted` and `JSONEncoder.encodeAsserting(_:)`, the coders the files use.

Moved from Stewed's StewedKit (Stewed #124). The JSON is unchanged: `Tests/SwoopCloudKitTests/Resources/release-data/cache-format-1.json` was written by Stewed's code before the move, and the tests check that it decodes and re-encodes to the same bytes.

Tests (`swift test`) cover the `CKRecord` mappings with hand-built records, and the snapshot and cache file with the JSON fixtures in `Tests/SwoopCloudKitTests/Resources/release-data/` (copies of Stewed's `docs/fixtures/release-data/`). They never open a `CKContainer`, which traps without the iCloud entitlement.

Seeded from Bushel's `BushelCloudKitDebug` module (`v3.0.0-alpha.3`, `46b6240`): the `RestoreImage` query, the account-status check, the `RestoreImageRecord` mapping and the `CKRecord` value helpers. The SwiftUI debug window and the `ImageMetadata` derivation stayed in Bushel, because they depend on Bushel's app modules.

## Branches

- `simulator`: Stewed's working branch. It depends on BushelKit by path (`../BushelKit`), as a sibling subrepo.
- `main`: depends on BushelKit by URL.
