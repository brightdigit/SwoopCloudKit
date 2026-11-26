# Caching Release Data

Keep fetched release data as JSON, in a disk cache or a snapshot bundled with an app.

## Overview

Release data changes rarely, and an app should stay useful offline or signed out of
iCloud. SwoopCloudKit gives you two JSON formats for that. Both build on every platform
SwoopKit does, without CloudKit, so a command-line tool on Linux can read and write
them too.

- ``ReleaseDataSnapshot``: the `SDKVersion`, `XcodeVersion` and `SimulatorRuntime`
  records with ``ReleaseDataSnapshot/fetchedAt``, the date they were fetched from
  CloudKit. Use it for a snapshot bundled in an app.
- ``ReleaseDataCacheFile``: a snapshot plus a `formatVersion`, for a disk cache that an
  older or newer build might find.

Neither type reads or writes files. Where the file lives, and when it's read or
written, is up to the app.

### Write and read a cache file

``ReleaseDataCacheFile/encode(_:)`` turns a snapshot into the cache file's JSON, and
``ReleaseDataCacheFile/decode(_:)`` turns it back:

```swift
let snapshot = try await CloudKitReleaseCatalog().fetchSnapshot(now: .now)
try ReleaseDataCacheFile.encode(snapshot).write(to: cacheURL, options: .atomic)

// On a later launch:
do {
  let cached = try ReleaseDataCacheFile.decode(Data(contentsOf: cacheURL))
  // Use cached.sdkVersions, cached.xcodeVersions, cached.simulatorRuntimes.
} catch {
  // Ignore the cache; the next fetch replaces it.
}
```

``ReleaseDataCacheFile/decode(_:)`` reads the `formatVersion` before it decodes any
records. A file from another format throws
``ReleaseDataCacheError/unsupportedFormatVersion(_:)``, and a file that isn't a cache
file throws ``ReleaseDataCacheError/unreadable(_:)``. Treat either as "no cache": the
next successful fetch overwrites it. ``ReleaseDataCacheError/fileFailed(_:)`` is there
for the app's own file reads and writes.

Bump ``ReleaseDataCacheFile/currentFormatVersion`` only when the layout changes in a
way an older build can't read. Adding a field that decodes as empty when missing, as
`simulatorRuntimes` did, isn't such a change.

### Bundle a snapshot

A snapshot bundled in the app gives a fresh install release data before its first
fetch. Read it with ``ReleaseDataSnapshot/init(json:)``:

```swift
if let url = Bundle.main.url(
  forResource: "release-data-snapshot",
  withExtension: "json"
) {
  let bundled = try ReleaseDataSnapshot(json: Data(contentsOf: url))
}
```

Write one with the same encoder the cache file uses,
``Foundation/JSONEncoder/iso8601PrettySorted``, so the file is stable and diffable
between exports.

### Choose the newer data

When an app has both a cache and a bundled snapshot, compare their
``ReleaseDataSnapshot/fetchedAt`` dates and start from the later one. Always use
`fetchedAt`, never a file's modification date: copying or installing a file changes its
modification date, not the age of its records.

### The JSON

A snapshot is one object: `fetchedAt`, `sdkVersions`, `xcodeVersions` and
`simulatorRuntimes`, with the SwoopKit records' own `Codable` field names. A cache file
adds `formatVersion`. Dates are ISO 8601 in whole seconds, keys are sorted, and the
output is pretty-printed. A file written before `simulatorRuntimes` existed decodes
with no runtime records.

The coders are public so other tools can match the format:

- ``Foundation/JSONEncoder/iso8601PrettySorted`` and
  ``Foundation/JSONDecoder/iso8601`` return a new, configured coder on every call.
- ``Foundation/JSONDecoder/decodeValue(_:from:)`` decodes with a typed
  `DecodingError`.
- ``Foundation/JSONEncoder/encodeAsserting(_:)`` encodes a value whose type can't fail
  to encode, and asserts if it does.
