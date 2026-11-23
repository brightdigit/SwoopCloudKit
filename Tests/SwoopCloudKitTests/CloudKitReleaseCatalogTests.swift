//
// CloudKitReleaseCatalogTests.swift
// Copyright (c) 2026 BrightDigit.
//

#if canImport(CloudKit)
  internal import SwoopKit
  internal import CloudKit
  internal import Foundation
  internal import Testing

  @testable internal import SwoopCloudKit

  /// Covers what can be tested without a container: never open a `CKContainer`
  /// here, because without the iCloud entitlement it traps.
  @Suite("CloudKitReleaseCatalog without a container")
  internal struct CloudKitReleaseCatalogTests {
    private struct PageFailure: LocalizedError {
      var errorDescription: String? { "zone busy" }
    }

    private static func xcodeRecord(_ name: String, version: String?) -> CKRecord {
      let record = CKRecord(
        recordType: "XcodeVersion",
        recordID: CKRecord.ID(recordName: name)
      )
      record["version"] = version
      record["buildNumber"] = "27B52"
      record["releaseDate"] = Date(timeIntervalSince1970: 1_780_000_000) as NSDate
      return record
    }

    @Test("Each CKAccountStatus maps to its counterpart")
    internal func accountStatuses() {
      let expected: [(CKAccountStatus, CloudKitAccountStatus)] = [
        (.available, .available),
        (.noAccount, .noAccount),
        (.restricted, .restricted),
        (.temporarilyUnavailable, .temporarilyUnavailable),
        (.couldNotDetermine, .couldNotDetermine),
      ]
      for (status, mapped) in expected {
        #expect(CloudKitAccountStatus(status) == mapped)
      }
      let mappedCases = Set(CloudKitAccountStatus.byCloudKitStatus.values)
      #expect(mappedCases == Set(CloudKitAccountStatus.allCases))
    }

    @Test("A status from a later SDK reads as could not determine")
    internal func unknownStatus() throws {
      let future = try #require(CKAccountStatus(rawValue: 99))
      #expect(CloudKitAccountStatus(future) == .couldNotDetermine)
    }

    @Test("A page keeps mapped records in order and skips the rest with reasons")
    internal func partition() {
      let good = Self.xcodeRecord("XcodeVersion-27B52", version: "27.2")
      let bad = Self.xcodeRecord("XcodeVersion-bad", version: nil)
      let failedID = CKRecord.ID(recordName: "XcodeVersion-failed")
      let page: [(CKRecord.ID, Result<CKRecord, any Error>)] = [
        (good.recordID, .success(good)),
        (bad.recordID, .success(bad)),
        (failedID, .failure(PageFailure())),
      ]
      let transform: CloudKitRecordTransform<XcodeVersionRecord> = {
        record throws(CloudKitRecordMappingError) in
        try XcodeVersionRecord(cloudKitRecord: record)
      }

      let result = CloudKitReleaseCatalog.partition(page, using: transform)

      #expect(result.records.map(\.version) == ["27.2"])
      #expect(
        result.skipped == [
          CloudKitRecordSkip(id: "XcodeVersion-bad", reason: "missing field \"version\""),
          CloudKitRecordSkip(id: "XcodeVersion-failed", reason: "zone busy"),
        ]
      )
    }

    @Test("A CloudKit error keeps its code and message")
    internal func catalogError() {
      let error = CloudKitCatalogError(
        operation: "XcodeVersion",
        error: CKError(.notAuthenticated)
      )
      #expect(error.operation == "XcodeVersion")
      #expect(error.ckErrorCode == CKError.Code.notAuthenticated.rawValue)
      #expect(!error.message.isEmpty)
    }
  }
#endif
