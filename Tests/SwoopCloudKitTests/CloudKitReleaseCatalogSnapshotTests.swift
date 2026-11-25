//
//  CloudKitReleaseCatalogSnapshotTests.swift
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
  internal import SwoopKit
  internal import Testing

  @testable internal import SwoopCloudKit

  /// `fetchSnapshot(now:)`'s failure rules, with fake fetches: a missing
  /// `SimulatorRuntime` record type is tolerated, nothing else is.
  @Suite("CloudKitReleaseCatalog snapshot fetch", .enabled(if: Platform.isCloudKitAvailable))
  internal struct CloudKitReleaseCatalogSnapshotTests {
    private typealias Catalog = CloudKitReleaseCatalog

    private static let now = Date(timeIntervalSince1970: 1_790_000_000)

    private static let sdk = SDKVersionRecord(
      platform: .iOS,
      version: "27.2",
      buildNumber: "24B113",
      isPrerelease: true,
      prereleaseLabel: "RC 1",
      releaseDate: Date(timeIntervalSince1970: 1_780_000_000)
    )

    private static let runtime = SimulatorRuntimeRecord(
      platform: .iOS,
      version: "27.2",
      buildNumber: "24B114",
      releaseLabel: .releaseCandidate(1),
      sdkBuildNumbers: ["24B113"]
    )

    /// What CloudKit reports for a query on a type the schema lacks.
    private static let unknownType = CloudKitCatalogError(
      operation: Catalog.simulatorRuntimeRecordType,
      ckErrorCode: CKError.Code.unknownItem.rawValue,
      message: "Did not find record type: SimulatorRuntime"
    )

    private static let sdkFetch: CloudKitRecordsFetch<SDKVersionRecord> = {
      () async throws(CloudKitCatalogError) in
      CloudKitReleaseRecords(records: [sdk], skipped: [])
    }

    private static let xcodeFetch: CloudKitRecordsFetch<XcodeVersionRecord> = {
      () async throws(CloudKitCatalogError) in
      CloudKitReleaseRecords(records: [], skipped: [])
    }

    private static func failing<Record: Sendable>(
      _ error: CloudKitCatalogError
    ) -> CloudKitRecordsFetch<Record> {
      { () async throws(CloudKitCatalogError) in throw error }
    }

    private static func snapshot(
      sdkVersions: CloudKitRecordsFetch<SDKVersionRecord> = sdkFetch,
      simulatorRuntimes: CloudKitRecordsFetch<SimulatorRuntimeRecord>
    ) async throws(CloudKitCatalogError) -> ReleaseDataSnapshot {
      try await Catalog.snapshot(
        now: now,
        sdkVersions: sdkVersions,
        xcodeVersions: xcodeFetch,
        simulatorRuntimes: simulatorRuntimes
      )
    }

    @Test("Every record type lands in the snapshot")
    internal func allTypes() async throws {
      let runtimes: CloudKitRecordsFetch<SimulatorRuntimeRecord> = {
        () async throws(CloudKitCatalogError) in
        CloudKitReleaseRecords(records: [Self.runtime], skipped: [])
      }
      let snapshot = try await Self.snapshot(simulatorRuntimes: runtimes)
      #expect(snapshot.fetchedAt == Self.now)
      #expect(snapshot.sdkVersions == [Self.sdk])
      #expect(snapshot.simulatorRuntimes == [Self.runtime])
    }

    @Test("A missing SimulatorRuntime type gives no runtimes, not a failure")
    internal func unknownRecordTypeIsTolerated() async throws {
      #expect(Self.unknownType.isUnknownRecordType)
      let snapshot = try await Self.snapshot(
        simulatorRuntimes: Self.failing(Self.unknownType)
      )
      #expect(snapshot.sdkVersions == [Self.sdk])
      #expect(snapshot.simulatorRuntimes.isEmpty)
    }

    @Test(
      "Any other SimulatorRuntime failure still fails the fetch",
      arguments: [
        CloudKitCatalogError(
          operation: Catalog.simulatorRuntimeRecordType,
          ckErrorCode: CKError.Code.networkUnavailable.rawValue,
          message: "The Internet connection appears to be offline."
        ),
        CloudKitCatalogError(
          operation: Catalog.simulatorRuntimeRecordType,
          ckErrorCode: CKError.Code.permissionFailure.rawValue,
          message: "Permission failure"
        ),
        CloudKitCatalogError(
          operation: Catalog.simulatorRuntimeRecordType,
          ckErrorCode: nil,
          message: "Did not find record type: SimulatorRuntime"
        ),
      ]
    )
    internal func otherFailuresThrow(error: CloudKitCatalogError) async {
      await #expect(throws: error) {
        try await Self.snapshot(simulatorRuntimes: Self.failing(error))
      }
    }

    @Test("A missing SDKVersion type still fails the fetch")
    internal func unknownSDKVersionTypeThrows() async {
      let error = CloudKitCatalogError(
        operation: Catalog.sdkVersionRecordType,
        ckErrorCode: CKError.Code.unknownItem.rawValue,
        message: "Did not find record type: SDKVersion"
      )
      await #expect(throws: error) {
        try await Self.snapshot(
          sdkVersions: Self.failing(error),
          simulatorRuntimes: Self.failing(Self.unknownType)
        )
      }
    }

    @Test("Account status errors are never an unknown record type")
    internal func accountStatusIsNotARecordType() {
      let error = CloudKitCatalogError(
        operation: "accountStatus",
        ckErrorCode: CKError.Code.unknownItem.rawValue,
        message: "Unknown item"
      )
      #expect(!error.isUnknownRecordType)
    }
  }
#endif
