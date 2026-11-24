//
//  CloudKitReleaseCatalog+Snapshot.swift
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
  public import Foundation
  internal import os
  internal import SwoopKit

  /// Fetches every record of one type, for the snapshot.
  internal typealias CloudKitRecordsFetch<Record: Sendable> =
    @Sendable () async throws(CloudKitCatalogError) -> CloudKitReleaseRecords<Record>

  extension CloudKitReleaseCatalog {
    private static let logger = Logger(
      subsystem: "com.brightdigit.SwoopCloudKit",
      category: "CloudKitReleaseCatalog"
    )

    /// Runs the three fetches in order and builds the snapshot.
    ///
    /// Only a `SimulatorRuntime` failure for an unknown record type is
    /// tolerated; every other failure, of any query, is thrown.
    internal static func snapshot(
      now: Date,
      sdkVersions: CloudKitRecordsFetch<SDKVersionRecord>,
      xcodeVersions: CloudKitRecordsFetch<XcodeVersionRecord>,
      simulatorRuntimes: CloudKitRecordsFetch<SimulatorRuntimeRecord>
    ) async throws(CloudKitCatalogError) -> ReleaseDataSnapshot {
      let sdk = try await sdkVersions()
      let xcode = try await xcodeVersions()
      let runtimes: [SimulatorRuntimeRecord]
      do {
        runtimes = try await simulatorRuntimes().records
      } catch
        where error.isUnknownRecordType
        && error.operation == simulatorRuntimeRecordType
      {
        let message = error.message
        logger.notice(
          "No SimulatorRuntime type; no runtime records: \(message, privacy: .public)"
        )
        runtimes = []
      }
      return ReleaseDataSnapshot(
        fetchedAt: now,
        sdkVersions: sdk.records,
        xcodeVersions: xcode.records,
        simulatorRuntimes: runtimes
      )
    }

    /// Fetches `SDKVersion`, then `XcodeVersion`, then `SimulatorRuntime`,
    /// following every page, as a snapshot fetched at `now`.
    ///
    /// Records that don't map are skipped, not failures: the rest are still
    /// usable. Nothing is filtered: macOS `SDKVersion` records are kept, and
    /// callers drop what they don't use.
    ///
    /// A `SimulatorRuntime` query that fails because the environment has no
    /// such record type (``CloudKitCatalogError/isUnknownRecordType``; for
    /// example Production before its schema is deployed) gives a snapshot
    /// with no runtime records instead of failing, and is logged.
    ///
    /// - Parameter now: The snapshot's ``ReleaseDataSnapshot/fetchedAt``.
    /// - Returns: The records, as a snapshot.
    /// - Throws: ``CloudKitCatalogError`` when any other query failure
    ///   happens, including when the user isn't signed in to iCloud or is
    ///   offline.
    public func fetchSnapshot(
      now: Date
    ) async throws(CloudKitCatalogError) -> ReleaseDataSnapshot {
      let sdkVersions: CloudKitRecordsFetch<SDKVersionRecord> = {
        () async throws(CloudKitCatalogError) in
        try await self.fetchSDKVersions()
      }
      let xcodeVersions: CloudKitRecordsFetch<XcodeVersionRecord> = {
        () async throws(CloudKitCatalogError) in
        try await self.fetchXcodeVersions()
      }
      let simulatorRuntimes: CloudKitRecordsFetch<SimulatorRuntimeRecord> = {
        () async throws(CloudKitCatalogError) in
        try await self.fetchSimulatorRuntimes()
      }
      return try await Self.snapshot(
        now: now,
        sdkVersions: sdkVersions,
        xcodeVersions: xcodeVersions,
        simulatorRuntimes: simulatorRuntimes
      )
    }
  }

  extension CloudKitCatalogError {
    /// Whether CloudKit said the queried record type doesn't exist in this
    /// environment.
    ///
    /// A query for a record type the schema doesn't have fails with
    /// `CKError.unknownItem` (server message "Did not find record type:
    /// …"). A query names no record, so for a query that code means only
    /// the type is missing. ``CloudKitReleaseCatalog/accountStatus()`` errors
    /// never count.
    public var isUnknownRecordType: Bool {
      ckErrorCode == CKError.Code.unknownItem.rawValue
        && operation != "accountStatus"
    }
  }
#endif
