//
//  SDKVersionRecord+CloudKit.swift
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

  extension SDKVersionRecord {
    /// Maps a public-database `SDKVersion` record onto the shared model.
    ///
    /// The mirror of SwoopMistKit's `SDKVersionRecord.from(recordInfo:)`:
    /// `isPrerelease` is an `INT64`, and `xcodeVersion` and `supersededBy` are
    /// `REFERENCE`s whose record names become the model's strings.
    ///
    /// - Parameter cloudKitRecord: The record returned by `CKQuery`.
    /// - Throws: ``CloudKitRecordMappingError`` when `platform`, `version`,
    ///   `buildNumber` or `releaseDate` is missing, or the platform is unknown.
    internal init(cloudKitRecord: CKRecord) throws(CloudKitRecordMappingError) {
      guard let platformValue = cloudKitRecord["platform"] as? String else {
        throw .missingField("platform")
      }
      guard let platform = Platform(rawValue: platformValue) else {
        throw .invalidPlatform(platformValue)
      }
      guard let version = cloudKitRecord["version"] as? String else {
        throw .missingField("version")
      }
      guard let buildNumber = cloudKitRecord["buildNumber"] as? String else {
        throw .missingField("buildNumber")
      }
      guard let releaseDate = cloudKitRecord["releaseDate"] as? Date else {
        throw .missingField("releaseDate")
      }
      self.init(
        platform: platform,
        version: version,
        buildNumber: buildNumber,
        isPrerelease: cloudKitRecord.booleanValue(forKey: "isPrerelease") ?? false,
        prereleaseLabel: cloudKitRecord["prereleaseLabel"] as? String,
        releaseDate: releaseDate,
        xcodeVersion: cloudKitRecord.referenceName(forKey: "xcodeVersion"),
        supersededBy: cloudKitRecord.referenceName(forKey: "supersededBy"),
        supersededAt: cloudKitRecord["supersededAt"] as? Date
      )
    }
  }
#endif
