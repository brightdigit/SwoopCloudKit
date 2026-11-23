//
// SimulatorRuntimeRecordCloudKitTests.swift
// Copyright (c) 2026 BrightDigit.
//

#if canImport(CloudKit)
  internal import SwoopKit
  internal import CloudKit
  internal import Foundation
  internal import Testing

  @testable internal import SwoopCloudKit

  @Suite("SimulatorRuntime CKRecord mapping")
  internal struct SimulatorRuntimeRecordCloudKitTests {
    /// A record shaped like SwoopMistKit's `toCloudKitFields()` output.
    private static func record(
      _ fields: [String: any CKRecordValueProtocol]
    ) -> CKRecord {
      let record = CKRecord(
        recordType: "SimulatorRuntime",
        recordID: CKRecord.ID(recordName: "SimulatorRuntime-iOS-24B91016s")
      )
      for (key, value) in fields {
        record[key] = value
      }
      return record
    }

    /// iPhone Duo's 27.2 final, from Apple's simulator index.
    private static func duoFinal() -> CKRecord {
      record([
        "platform": "iOS",
        "version": "27.2",
        "buildNumber": "24B91016s",
        "isPrerelease": 0 as NSNumber,
        "releaseLabel": "Final",
        "sdkBuildNumbersText": "24B113,24B8118",
      ])
    }

    @Test("A final with SDK builds maps every field")
    internal func duoFinal() throws {
      let mapped = try SimulatorRuntimeRecord(cloudKitRecord: Self.duoFinal())
      #expect(
        mapped
          == SimulatorRuntimeRecord(
            platform: .iOS,
            version: "27.2",
            buildNumber: "24B91016s",
            releaseLabel: .final,
            sdkBuildNumbers: ["24B113", "24B8118"]
          )
      )
    }

    @Test(
      "Labels keep their numbers",
      arguments: [
        ("Beta 4", SimulatorRuntimeRecord.ReleaseLabel.beta(4)),
        ("RC 1", .releaseCandidate(1)),
        ("RC 2", .releaseCandidate(2)),
      ]
    )
    internal func labels(text: String, label: SimulatorRuntimeRecord.ReleaseLabel) throws {
      let record = Self.duoFinal()
      record["releaseLabel"] = text
      let mapped = try SimulatorRuntimeRecord(cloudKitRecord: record)
      #expect(mapped.releaseLabel == label)
      #expect(mapped.isPrerelease)
    }

    @Test("A runtime with no SDK mapping has no SDK builds")
    internal func noSDKBuilds() throws {
      let record = Self.duoFinal()
      record["sdkBuildNumbersText"] = nil
      #expect(try SimulatorRuntimeRecord(cloudKitRecord: record).sdkBuildNumbers.isEmpty)
    }

    @Test(
      "SDK build text maps to a list: empty, one and several builds",
      arguments: [
        ("", [String]()),
        ("24B113", ["24B113"]),
        ("24B113,24B8118", ["24B113", "24B8118"]),
        (" 24B113 , ,24B8118,", ["24B113", "24B8118"]),
      ]
    )
    internal func sdkBuildText(text: String, builds: [String]) throws {
      let record = Self.duoFinal()
      record["sdkBuildNumbersText"] = text
      #expect(try SimulatorRuntimeRecord(cloudKitRecord: record).sdkBuildNumbers == builds)
    }

    @Test(
      "A missing required field throws",
      arguments: ["platform", "version", "buildNumber", "releaseLabel"]
    )
    internal func missingField(field: String) {
      let record = Self.duoFinal()
      record[field] = nil
      #expect(throws: CloudKitRecordMappingError.missingField(field)) {
        try SimulatorRuntimeRecord(cloudKitRecord: record)
      }
    }

    @Test("An unknown platform throws")
    internal func unknownPlatform() {
      let record = Self.duoFinal()
      record["platform"] = "carOS"
      #expect(throws: CloudKitRecordMappingError.invalidPlatform("carOS")) {
        try SimulatorRuntimeRecord(cloudKitRecord: record)
      }
    }

    @Test("An unknown label throws instead of guessing")
    internal func unknownLabel() {
      let record = Self.duoFinal()
      record["releaseLabel"] = "Golden Master"
      #expect(throws: CloudKitRecordMappingError.invalidReleaseLabel("Golden Master")) {
        try SimulatorRuntimeRecord(cloudKitRecord: record)
      }
    }
  }
#endif
