# BushelCatalog

A read-only reader for the public CloudKit database of `iCloud.com.brightdigit.Bushel`, using native `CloudKit.framework`. It maps `CKRecord`s onto the BushelFoundation record models from BushelKit. Bushel and Stewed share it.

[BushelCloud](https://github.com/brightdigit/BushelCloud) writes the database. This package only queries it, and it needs no API token or server-to-server key: it uses the app's iCloud entitlement.

Seeded from Bushel's `BushelCloudKitDebug` module (`v3.0.0-alpha.3`, `46b6240`): the `RestoreImage` query, the account-status check, the `RestoreImageRecord` mapping and the `CKRecord` value helpers. The SwiftUI debug window and the `ImageMetadata` derivation stayed in Bushel, because they depend on Bushel's app modules.

## Branches

- `simulator`: Stewed's working branch. It depends on BushelKit by path (`../BushelKit`), as a sibling subrepo.
- `main`: depends on BushelKit by URL.
