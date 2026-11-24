# ``SwoopCloudKit``

Read Apple release data from the public CloudKit database with native CloudKit, and
keep it as a snapshot or cache file.

## Overview

SwoopMistKit syncs Apple's SDK, Xcode, simulator runtime and macOS restore image
releases into the public database of the `iCloud.com.brightdigit.Swoop` container.
SwoopCloudKit is the read side: it queries that database with `CloudKit.framework`
and maps each `CKRecord` onto the shared record models from SwoopKit, such as
`SDKVersionRecord`, `XcodeVersionRecord` and `SimulatorRuntimeRecord`.

It never writes, and it needs no API token or server-to-server key. Reads go through
the app's iCloud entitlement and the user's iCloud account, so nothing secret ships in
the app.

```swift
import SwoopCloudKit

let catalog = CloudKitReleaseCatalog()
guard try await catalog.accountStatus() == .available else {
  // Ask the user to sign in to iCloud, or keep using cached data.
  return
}
let snapshot = try await catalog.fetchSnapshot(now: .now)
let cacheData = ReleaseDataCacheFile.encode(snapshot)
```

The package has two halves:

- **CloudKit readers.** ``CloudKitReleaseCatalog`` reads the `SDKVersion`,
  `XcodeVersion` and `SimulatorRuntime` record types, and
  ``CloudKitRestoreImageService`` lists `RestoreImage` records. They compile only where
  CloudKit is available. See <doc:ReadingReleaseData>.
- **Release data on disk.** ``ReleaseDataSnapshot`` and ``ReleaseDataCacheFile`` turn
  fetched records into stable JSON and back, for a disk cache or a snapshot bundled in
  an app. They depend only on Foundation and SwoopKit, so they build on every platform
  SwoopKit does, Linux included. See <doc:CachingReleaseData>.

## Topics

### Essentials

- <doc:ReadingReleaseData>
- <doc:CachingReleaseData>

### Reading release records

- ``CloudKitReleaseCatalog``
- ``CloudKitReleaseRecords``
- ``CloudKitRecordSkip``
- ``CloudKitRecordMappingError``

### Checking the iCloud account

- ``CloudKitAccountStatus``

### Handling CloudKit failures

- ``CloudKitCatalogError``

### Snapshots and cache files

- ``ReleaseDataSnapshot``
- ``ReleaseDataCacheFile``
- ``ReleaseDataCacheError``

### Listing macOS restore images

- ``CloudKitRestoreImageService``
- ``CloudKitRestoreImageFetch``
- ``CloudKitRestoreImage``
- ``CloudKitRestoreImageSkip``
- ``CloudKitRestoreImageMappingError``

### JSON coding

- ``Foundation/JSONDecoder/iso8601``
- ``Foundation/JSONDecoder/decodeValue(_:from:)``
- ``Foundation/JSONEncoder/iso8601PrettySorted``
- ``Foundation/JSONEncoder/encodeAsserting(_:)``
