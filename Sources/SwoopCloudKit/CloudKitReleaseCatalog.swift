//
//  CloudKitReleaseCatalog.swift
//  SwoopCloudKit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#if canImport(CloudKit)
  internal import CloudKit
  internal import Foundation
  public import SwoopKit

  /// Maps one queried record onto its SwoopKit model.
  internal typealias CloudKitRecordTransform<Record> =
    (CKRecord) throws(CloudKitRecordMappingError) -> Record

  /// A read-only client for the `SDKVersion`, `XcodeVersion` and
  /// `SimulatorRuntime` record types in the **public** database of
  /// `iCloud.com.brightdigit.Bushel`.
  ///
  /// The types grant `READ` only to `_icloud`, so reads need the app's iCloud
  /// entitlement and a signed-in account (``accountStatus()``). Which
  /// environment is read follows the signing: a development-signed build reads
  /// Development, a Developer ID build Production.
  ///
  /// Every query pages through all results. Records that don't map are
  /// returned in ``CloudKitReleaseRecords/skipped`` instead of failing the
  /// fetch. Nothing is filtered: callers drop what they don't use (Stewed
  /// ignores macOS SDKs).
  public struct CloudKitReleaseCatalog: Sendable {
    /// The CloudKit container SwoopMistKit's sync writes to.
    public static let defaultContainerIdentifier = "iCloud.com.brightdigit.Bushel"

    /// The `SDKVersion` record type.
    public static let sdkVersionRecordType = "SDKVersion"

    /// The `XcodeVersion` record type.
    public static let xcodeVersionRecordType = "XcodeVersion"

    /// The `SimulatorRuntime` record type.
    public static let simulatorRuntimeRecordType = "SimulatorRuntime"

    private let containerIdentifier: String

    /// Creates a catalog against a CloudKit container.
    ///
    /// Creating one doesn't touch CloudKit. The container is only opened by
    /// the methods below, and opening it without the iCloud entitlement traps.
    ///
    /// - Parameter containerIdentifier: The container to read. Defaults to
    ///   ``defaultContainerIdentifier``.
    public init(containerIdentifier: String = Self.defaultContainerIdentifier) {
      self.containerIdentifier = containerIdentifier
    }

    /// The signed-in iCloud account's status for this container.
    ///
    /// - Returns: The status. A status CloudKit adds later reads as
    ///   ``CloudKitAccountStatus/couldNotDetermine``.
    /// - Throws: ``CloudKitCatalogError`` when CloudKit can't answer, which
    ///   also happens when the container isn't assigned to the app.
    public func accountStatus()
      async throws(CloudKitCatalogError) -> CloudKitAccountStatus
    {
      let container = CKContainer(identifier: containerIdentifier)
      do {
        let status = try await container.accountStatus()
        return CloudKitAccountStatus(status)
      } catch {
        throw CloudKitCatalogError(operation: "accountStatus", error: error)
      }
    }

    /// Every `SDKVersion` record, newest release first.
    ///
    /// - Returns: The mapped records and any that were skipped.
    /// - Throws: ``CloudKitCatalogError`` when a query page fails.
    public func fetchSDKVersions()
      async throws(CloudKitCatalogError) -> CloudKitReleaseRecords<SDKVersionRecord>
    {
      let transform: CloudKitRecordTransform<SDKVersionRecord> = {
        record throws(CloudKitRecordMappingError) in
        try SDKVersionRecord(cloudKitRecord: record)
      }
      return try await fetchAll(
        recordType: Self.sdkVersionRecordType,
        sortKey: "releaseDate",
        using: transform
      )
    }

    /// Every `XcodeVersion` record, newest release first.
    ///
    /// - Returns: The mapped records and any that were skipped.
    /// - Throws: ``CloudKitCatalogError`` when a query page fails.
    public func fetchXcodeVersions()
      async throws(CloudKitCatalogError) -> CloudKitReleaseRecords<XcodeVersionRecord>
    {
      let transform: CloudKitRecordTransform<XcodeVersionRecord> = {
        record throws(CloudKitRecordMappingError) in
        try XcodeVersionRecord(cloudKitRecord: record)
      }
      return try await fetchAll(
        recordType: Self.xcodeVersionRecordType,
        sortKey: "releaseDate",
        using: transform
      )
    }

    /// Every `SimulatorRuntime` record, in no particular order.
    ///
    /// The record type has no release date to sort on; callers order runtimes
    /// by platform, version and `SimulatorRuntimeRecord.ReleaseLabel`.
    ///
    /// - Returns: The mapped records and any that were skipped.
    /// - Throws: ``CloudKitCatalogError`` when a query page fails.
    public func fetchSimulatorRuntimes()
      async throws(CloudKitCatalogError) -> CloudKitReleaseRecords<SimulatorRuntimeRecord>
    {
      let transform: CloudKitRecordTransform<SimulatorRuntimeRecord> = {
        record throws(CloudKitRecordMappingError) in
        try SimulatorRuntimeRecord(cloudKitRecord: record)
      }
      return try await fetchAll(
        recordType: Self.simulatorRuntimeRecordType,
        sortKey: nil,
        using: transform
      )
    }

    /// Queries every record of a type, following cursors until none is left.
    ///
    /// The predicate is `NSPredicate(value: true)`, which relies on the
    /// `___recordID REFERENCE QUERYABLE` index in `schema.ckdb`. The sort, if
    /// any, is newest first on a field `schema.ckdb` marks `SORTABLE`. `CKContainer`,
    /// `CKQuery` and the cursor aren't `Sendable`, so they stay in this call.
    ///
    /// - Parameters:
    ///   - recordType: The record type to query.
    ///   - sortKey: A `SORTABLE` field to sort descending on, or `nil` for none.
    ///   - transform: Maps a record onto its model.
    /// - Returns: All mapped records and skips across every page.
    /// - Throws: ``CloudKitCatalogError`` when a page fails.
    private func fetchAll<Record: Sendable>(
      recordType: String,
      sortKey: String?,
      using transform: CloudKitRecordTransform<Record>
    ) async throws(CloudKitCatalogError) -> CloudKitReleaseRecords<Record> {
      let database = CKContainer(identifier: containerIdentifier).publicCloudDatabase
      let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
      if let sortKey {
        query.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: false)]
      }

      var records: [Record] = []
      var skipped: [CloudKitRecordSkip] = []
      do {
        var page = try await database.records(
          matching: query,
          resultsLimit: CKQueryOperation.maximumResults
        )
        while true {
          let mapped = Self.partition(page.matchResults, using: transform)
          records += mapped.records
          skipped += mapped.skipped
          guard let cursor = page.queryCursor else {
            break
          }
          page = try await database.records(
            continuingMatchFrom: cursor,
            resultsLimit: CKQueryOperation.maximumResults
          )
        }
      } catch {
        throw CloudKitCatalogError(operation: recordType, error: error)
      }
      return CloudKitReleaseRecords(records: records, skipped: skipped)
    }
  }
#endif
