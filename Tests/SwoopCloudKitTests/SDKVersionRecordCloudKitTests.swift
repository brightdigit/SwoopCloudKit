//
// SDKVersionRecordCloudKitTests.swift
// Copyright (c) 2026 BrightDigit.
//

#if canImport(CloudKit)
  internal import SwoopKit
  internal import CloudKit
  internal import Foundation
  internal import Testing

  @testable internal import SwoopCloudKit

  @Suite("SDKVersion CKRecord mapping")
  internal struct SDKVersionRecordCloudKitTests {
    private static let releaseDate = Date(timeIntervalSince1970: 1_780_000_000)
    private static let supersededAt = Date(timeIntervalSince1970: 1_790_000_000)

    /// A record shaped like SwoopMistKit's `toCloudKitFields()` output.
    private static func record(
      _ fields: [String: any CKRecordValueProtocol]
    ) -> CKRecord {
      let record = CKRecord(
        recordType: "SDKVersion",
        recordID: CKRecord.ID(recordName: "SDKVersion-iOS-24A5318c")
      )
      for (key, value) in fields {
        record[key] = value
      }
      return record
    }

    private static func reference(_ name: String) -> CKRecord.Reference {
      CKRecord.Reference(recordID: CKRecord.ID(recordName: name), action: .none)
    }

    private static func superseded() -> CKRecord {
      record([
        "platform": "iOS",
        "version": "27.0",
        "buildNumber": "24A5318c",
        "isPrerelease": 1 as NSNumber,
        "prereleaseLabel": "Beta 5",
        "releaseDate": releaseDate as NSDate,
        "xcodeVersion": reference("XcodeVersion-27A5318c"),
        "supersededBy": reference("SDKVersion-iOS-24A340"),
        "supersededAt": supersededAt as NSDate,
      ])
    }

    @Test("A superseded beta maps every field")
    internal func supersededBeta() throws {
      let mapped = try SDKVersionRecord(cloudKitRecord: Self.superseded())
      #expect(
        mapped
          == SDKVersionRecord(
            platform: .iOS,
            version: "27.0",
            buildNumber: "24A5318c",
            isPrerelease: true,
            prereleaseLabel: "Beta 5",
            releaseDate: Self.releaseDate,
            xcodeVersion: "XcodeVersion-27A5318c",
            supersededBy: "SDKVersion-iOS-24A340",
            supersededAt: Self.supersededAt
          )
      )
    }

    @Test("A final with only the required fields has no prerelease data")
    internal func minimalFinal() throws {
      let mapped = try SDKVersionRecord(
        cloudKitRecord: Self.record([
          "platform": "visionOS",
          "version": "27.2",
          "buildNumber": "24N120",
          "releaseDate": Self.releaseDate as NSDate,
        ])
      )
      #expect(mapped.platform == .visionOS)
      #expect(mapped.isPrerelease == false)
      #expect(mapped.prereleaseLabel == nil)
      #expect(mapped.xcodeVersion == nil)
      #expect(mapped.supersededBy == nil)
      #expect(mapped.supersededAt == nil)
    }

    @Test("isPrerelease is an INT64: 0 is false", arguments: [0, 1])
    internal func prereleaseFlag(value: Int) throws {
      let record = Self.superseded()
      record["isPrerelease"] = value as NSNumber
      #expect(try SDKVersionRecord(cloudKitRecord: record).isPrerelease == (value != 0))
    }

    @Test(
      "A missing required field throws",
      arguments: ["platform", "version", "buildNumber", "releaseDate"]
    )
    internal func missingField(field: String) {
      let record = Self.superseded()
      record[field] = nil
      #expect(throws: CloudKitRecordMappingError.missingField(field)) {
        try SDKVersionRecord(cloudKitRecord: record)
      }
    }

    @Test("An unknown platform throws")
    internal func unknownPlatform() {
      let record = Self.superseded()
      record["platform"] = "carOS"
      #expect(throws: CloudKitRecordMappingError.invalidPlatform("carOS")) {
        try SDKVersionRecord(cloudKitRecord: record)
      }
    }

    @Test("A reference stored as a string is ignored, not misread")
    internal func referenceAsString() throws {
      let record = Self.superseded()
      record["xcodeVersion"] = "XcodeVersion-27A5318c"
      #expect(try SDKVersionRecord(cloudKitRecord: record).xcodeVersion == nil)
    }
  }
#endif
