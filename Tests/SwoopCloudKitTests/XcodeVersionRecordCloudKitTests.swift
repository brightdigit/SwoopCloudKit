//
//  XcodeVersionRecordCloudKitTests.swift
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

  @Suite("XcodeVersion CKRecord mapping", .enabled(if: Platform.isCloudKitAvailable))
  internal struct XcodeVersionRecordCloudKitTests {
    private static let releaseDate = Date(timeIntervalSince1970: 1_780_000_000)
    private static let downloadURL = "https://developer.apple.com/download/Xcode_27.2.xip"

    private static func record() -> CKRecord {
      let record = CKRecord(
        recordType: "XcodeVersion",
        recordID: CKRecord.ID(recordName: "XcodeVersion-27B52")
      )
      record["version"] = "27.2"
      record["buildNumber"] = "27B52"
      record["releaseDate"] = releaseDate as NSDate
      return record
    }

    @Test("Every field maps, references become record names")
    internal func fullRecord() throws {
      let record = Self.record()
      record["isPrerelease"] = 0 as NSNumber
      record["downloadURL"] = Self.downloadURL
      record["fileSize"] = 12_345_678_901 as NSNumber
      record["minimumMacOS"] = CKRecord.Reference(
        recordID: CKRecord.ID(recordName: "RestoreImage-25A100"),
        action: .none
      )
      record["includedSwiftVersion"] = CKRecord.Reference(
        recordID: CKRecord.ID(recordName: "SwiftVersion-6.4"),
        action: .none
      )
      record["sdkVersions"] = #"{"iOS":"27.2"}"#
      record["notes"] = "Release"

      let mapped = try XcodeVersionRecord(cloudKitRecord: record)
      #expect(mapped.version == "27.2")
      #expect(mapped.buildNumber == "27B52")
      #expect(mapped.releaseDate == Self.releaseDate)
      #expect(mapped.isPrerelease == false)
      #expect(
        mapped.downloadURL == URL(string: Self.downloadURL)
      )
      #expect(mapped.fileSize == 12_345_678_901)
      #expect(mapped.minimumMacOS == "RestoreImage-25A100")
      #expect(mapped.includedSwiftVersion == "SwiftVersion-6.4")
      #expect(mapped.sdkVersions == #"{"iOS":"27.2"}"#)
      #expect(mapped.notes == "Release")
    }

    @Test("Only the required fields: optionals are nil and it's a final")
    internal func minimalRecord() throws {
      let mapped = try XcodeVersionRecord(cloudKitRecord: Self.record())
      #expect(mapped.isPrerelease == false)
      #expect(mapped.downloadURL == nil)
      #expect(mapped.fileSize == nil)
      #expect(mapped.minimumMacOS == nil)
      #expect(mapped.includedSwiftVersion == nil)
      #expect(mapped.sdkVersions == nil)
      #expect(mapped.notes == nil)
      #expect(mapped.prereleaseLabel == nil)
    }

    @Test("isPrerelease 1 is a prerelease")
    internal func prerelease() throws {
      let record = Self.record()
      record["isPrerelease"] = 1 as NSNumber
      #expect(try XcodeVersionRecord(cloudKitRecord: record).isPrerelease)
    }

    @Test("prereleaseLabel maps; a prerelease without it has no label")
    internal func prereleaseLabel() throws {
      let record = Self.record()
      record["isPrerelease"] = 1 as NSNumber
      #expect(try XcodeVersionRecord(cloudKitRecord: record).prereleaseLabel == nil)

      record["prereleaseLabel"] = "Beta 3"
      #expect(try XcodeVersionRecord(cloudKitRecord: record).prereleaseLabel == "Beta 3")
    }

    @Test(
      "A missing required field throws",
      arguments: ["version", "buildNumber", "releaseDate"]
    )
    internal func missingField(field: String) {
      let record = Self.record()
      record[field] = nil
      #expect(throws: CloudKitRecordMappingError.missingField(field)) {
        try XcodeVersionRecord(cloudKitRecord: record)
      }
    }
  }
#endif
