//
//  XcodeVersionRecord+CloudKit.swift
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

  extension XcodeVersionRecord {
    /// Maps a public-database `XcodeVersion` record onto the shared model.
    ///
    /// The mirror of SwoopMistKit's `XcodeVersionRecord.from(recordInfo:)`:
    /// `isPrerelease` is an `INT64`, `downloadURL` is a `STRING` (an
    /// unparseable one reads as `nil`, as in SwoopMistKit), and `minimumMacOS`
    /// and `includedSwiftVersion` are `REFERENCE`s whose record names become
    /// the model's strings. `prereleaseLabel` is an optional `STRING`; records
    /// synced before it existed read as `nil`.
    ///
    /// - Parameter cloudKitRecord: The record returned by `CKQuery`.
    /// - Throws: ``CloudKitRecordMappingError`` when `version`, `buildNumber`
    ///   or `releaseDate` is missing.
    internal init(cloudKitRecord: CKRecord) throws(CloudKitRecordMappingError) {
      guard let version = cloudKitRecord["version"] as? String else {
        throw .missingField("version")
      }
      guard let buildNumber = cloudKitRecord["buildNumber"] as? String else {
        throw .missingField("buildNumber")
      }
      guard let releaseDate = cloudKitRecord["releaseDate"] as? Date else {
        throw .missingField("releaseDate")
      }
      let downloadURL = (cloudKitRecord["downloadURL"] as? String)
        .flatMap(URL.init(string:))
      self.init(
        version: version,
        buildNumber: buildNumber,
        releaseDate: releaseDate,
        downloadURL: downloadURL,
        fileSize: cloudKitRecord.integerValue(forKey: "fileSize").map { Int($0) },
        isPrerelease: cloudKitRecord.booleanValue(forKey: "isPrerelease") ?? false,
        // Missing on records synced before the field existed (Production until #109).
        prereleaseLabel: cloudKitRecord["prereleaseLabel"] as? String,
        minimumMacOS: cloudKitRecord.referenceName(forKey: "minimumMacOS"),
        includedSwiftVersion: cloudKitRecord.referenceName(
          forKey: "includedSwiftVersion"
        ),
        sdkVersions: cloudKitRecord["sdkVersions"] as? String,
        notes: cloudKitRecord["notes"] as? String
      )
    }
  }
#endif
