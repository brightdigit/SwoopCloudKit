//
// CloudKitRestoreImageService.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(CloudKit)
  internal import BushelFoundation
  internal import CloudKit
  internal import Foundation

  /// A read-only client for the `RestoreImage` record type in the **public**
  /// database of `iCloud.com.brightdigit.Bushel`.
  ///
  /// Transport is native `CloudKit.framework` rather than `BushelCloud`:
  /// `BushelCloud` exists to *write* the database from CI and carries MistKit,
  /// SwiftSoup, swift-configuration and the scrapers, plus a Server-to-Server
  /// PEM credential that cannot ship in a sandboxed app.
  ///
  /// - Important: This service only lists. It never downloads or imports.
  public struct CloudKitRestoreImageService: Sendable {
    /// The CloudKit container backing Bushel's published catalog.
    public static let defaultContainerIdentifier = "iCloud.com.brightdigit.Bushel"

    /// The record type populated by BushelCloud's sync.
    public static let recordType = "RestoreImage"

    private let containerIdentifier: String

    /// Creates a service against a CloudKit container.
    ///
    /// - Parameter containerIdentifier: The container to query. Defaults to
    ///   ``defaultContainerIdentifier``.
    public init(containerIdentifier: String = Self.defaultContainerIdentifier) {
      self.containerIdentifier = containerIdentifier
    }

    private static func partition(
      _ matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)]
    ) -> ([CloudKitRestoreImage], [CloudKitRestoreImageSkip]) {
      var images: [CloudKitRestoreImage] = []
      var skipped: [CloudKitRestoreImageSkip] = []
      for (recordID, result) in matchResults {
        switch result {
        case .success(let ckRecord):
          // Typed-throws: `error` in the catch is `CloudKitRestoreImageMappingError`
          // only because `RestoreImageRecord(cloudKitRecord:)` is the sole throwing
          // call in this `do`. Do not add a second thrower or reach for `as?`.
          do {
            let record = try RestoreImageRecord(cloudKitRecord: ckRecord)
            images.append(
              CloudKitRestoreImage(id: recordID.recordName, record: record)
            )
          } catch {
            skipped.append(
              CloudKitRestoreImageSkip(id: recordID.recordName, reason: error.reason)
            )
          }

        case .failure(let error):
          skipped.append(
            CloudKitRestoreImageSkip(
              id: recordID.recordName,
              reason: error.localizedDescription
            )
          )
        }
      }
      return (images, skipped)
    }

    private static func description(of accountStatus: CKAccountStatus) -> String {
      switch accountStatus {
      case .available:
        "available"

      case .noAccount:
        "no iCloud account"

      case .restricted:
        "restricted"

      case .couldNotDetermine:
        "could not determine"

      case .temporarilyUnavailable:
        "temporarily unavailable"

      default:
        "unknown"
      }
    }

    /// Describes the iCloud account status, keeping any error text.
    ///
    /// A failure here is diagnostic information in its own right — it is what
    /// separates "no iCloud account" from a container or entitlement
    /// misconfiguration — so it is reported rather than collapsed into the
    /// same `"unknown"` bucket as a genuinely unrecognized status.
    ///
    /// Takes the container *identifier* rather than a `CKContainer` so that the
    /// `async let` in ``fetchRestoreImages(limit:)`` captures nothing but a
    /// `String`; neither `CKContainer` nor `CKQuery` is `Sendable`.
    ///
    /// - Parameter identifier: The container to ask.
    /// - Returns: A human readable status description.
    private static func accountStatusDescription(
      ofContainerWithIdentifier identifier: String
    ) async -> String {
      do {
        let status = try await CKContainer(identifier: identifier).accountStatus()
        return Self.description(of: status)
      } catch {
        return "could not determine (\(error.localizedDescription))"
      }
    }

    /// Queries the public database for restore images, newest first.
    ///
    /// The predicate is `NSPredicate(value: true)`, which relies on the
    /// `___recordID REFERENCE QUERYABLE` index in `schema.ckdb`. Sorting uses
    /// `releaseDate`, one of the few `SORTABLE` columns.
    ///
    /// - Parameter limit: The maximum number of records to request.
    /// - Returns: The mapped records plus any that were skipped.
    /// - Throws: Any error raised by CloudKit itself.
    public nonisolated func fetchRestoreImages(
      limit: Int = 100
    ) async throws -> CloudKitRestoreImageFetch {
      // The query does not depend on the account status — that is display only
      // — so the status round trip is started first and overlaps the query
      // rather than running back to back with it.
      async let accountStatusDescription = Self.accountStatusDescription(
        ofContainerWithIdentifier: self.containerIdentifier
      )

      let container = CKContainer(identifier: self.containerIdentifier)
      let query = CKQuery(recordType: Self.recordType, predicate: NSPredicate(value: true))
      query.sortDescriptors = [NSSortDescriptor(key: "releaseDate", ascending: false)]
      let (matchResults, cursor) = try await container.publicCloudDatabase.records(
        matching: query,
        resultsLimit: limit
      )
      let (images, skipped) = Self.partition(matchResults)
      return CloudKitRestoreImageFetch(
        accountStatus: await accountStatusDescription,
        images: images,
        skipped: skipped,
        hasMoreResults: cursor != nil
      )
    }
  }
#endif
