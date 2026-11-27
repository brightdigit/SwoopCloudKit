# Reading Release Data from CloudKit

Check the iCloud account, then fetch every release record with native CloudKit.

## Overview

``CloudKitReleaseCatalog`` reads three record types from the **public** database of
``CloudKitReleaseCatalog/defaultContainerIdentifier``:

| Record type | Model | Fetch |
|---|---|---|
| `SDKVersion` | `SDKVersionRecord` | ``CloudKitReleaseCatalog/fetchSDKVersions()`` |
| `XcodeVersion` | `XcodeVersionRecord` | ``CloudKitReleaseCatalog/fetchXcodeVersions()`` |
| `SimulatorRuntime` | `SimulatorRuntimeRecord` | ``CloudKitReleaseCatalog/fetchSimulatorRuntimes()`` |

SwoopMistKit's sync writes these records. SwoopCloudKit only queries them.

### Set up the app

The reader uses `CloudKit.framework`, not CloudKit Web Services, so the app needs:

- The iCloud capability with CloudKit, and the container in its entitlements. Opening a
  `CKContainer` without the entitlement traps, so a test target or a command-line tool
  without one must never call the fetch methods. Creating a ``CloudKitReleaseCatalog``
  is safe: it doesn't touch CloudKit until you call a method.
- No token or key. The record types grant `READ` only to `_icloud` (signed-in users),
  so access comes from the user's iCloud account, never from a credential shipped in
  the app.

The CloudKit environment follows the app's signing: a development-signed build reads
Development, and a Developer ID or App Store build reads Production.

### Check the account first

Because the record types grant `READ` only to `_icloud`, a fetch works only when
``CloudKitReleaseCatalog/accountStatus()`` returns ``CloudKitAccountStatus/available``.
The other cases mean different things to the user:

- ``CloudKitAccountStatus/noAccount`` and ``CloudKitAccountStatus/restricted``: the
  user can fix it in System Settings.
- ``CloudKitAccountStatus/temporarilyUnavailable``: signed in, but the account needs
  attention, such as signing in again.
- ``CloudKitAccountStatus/couldNotDetermine``, or a thrown ``CloudKitCatalogError``:
  usually no network. Don't present this as a sign-in problem. Check again later, for
  example when the network comes back or the account changes (`CKAccountChanged`),
  rather than polling.

``CloudKitAccountStatus`` mirrors `CKAccountStatus`, so code that decides what to show
doesn't need to import CloudKit. A status that a later SDK adds reads as
``CloudKitAccountStatus/couldNotDetermine``.

### Fetch every record

Each fetch method pages through all results, following CloudKit's query cursor with
the largest page size CloudKit allows, and returns a ``CloudKitReleaseRecords`` value:

```swift
let catalog = CloudKitReleaseCatalog()
let sdks = try await catalog.fetchSDKVersions()
for skip in sdks.skipped {
  print("Skipped \(skip.id): \(skip.reason)")
}
let iOSSDKs = sdks.records.filter { $0.platform == .iOS }
```

`SDKVersion` and `XcodeVersion` records come back newest release first, sorted on
`releaseDate`. `SimulatorRuntime` records have no release date, so they come back in
no particular order: sort them by platform, version and `ReleaseLabel` yourself.

Nothing is filtered. For example, macOS `SDKVersion` records are included even though
no macOS simulator runtime exists; drop what your app doesn't use.

### Skipped records versus failures

A record that comes back but doesn't map, because a required field is missing or a
value is unknown, doesn't fail the fetch. It's listed in
``CloudKitReleaseRecords/skipped`` as a ``CloudKitRecordSkip`` with a readable reason
from ``CloudKitRecordMappingError``, and the other records are still usable. Surface
skips in logs or diagnostics: they're how schema drift between the writer and the
reader shows up.

A failure of the query itself (no network, a missing entitlement, a permission error)
throws ``CloudKitCatalogError``. Its ``CloudKitCatalogError/operation`` names the
record type being queried (or `"accountStatus"`), and
``CloudKitCatalogError/ckErrorCode`` keeps the `CKError.Code` raw value when CloudKit
reported one.

### Fetch everything as a snapshot

``CloudKitReleaseCatalog/fetchSnapshot(now:)`` fetches `SDKVersion`, then
`XcodeVersion`, then `SimulatorRuntime`, and returns a `ReleaseDataSnapshot` stamped
with the date you pass. Skipped records are left out of the snapshot.

One failure is tolerated: if the environment's schema has no `SimulatorRuntime` record
type yet, CloudKit answers that query with `CKError.unknownItem`
(``CloudKitCatalogError/isUnknownRecordType``). The snapshot then has no runtime
records, and the failure is logged. Any other failure of any query throws.

To keep the snapshot on disk, see <doc:CachingReleaseData>.

### Restore images

Bushel lists macOS restore images from the same database with
``CloudKitRestoreImageService``. Unlike the release catalog, it reads a single page
(``CloudKitRestoreImageService/fetchRestoreImages(limit:)``) and reports whether more
records remain in ``CloudKitRestoreImageFetch/hasMoreResults``. It only lists: nothing
in this package downloads or verifies an image.
