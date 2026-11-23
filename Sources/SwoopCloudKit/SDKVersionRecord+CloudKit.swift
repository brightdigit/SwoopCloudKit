//
// SDKVersionRecord+CloudKit.swift
// Copyright (c) 2026 BrightDigit.
//

#if canImport(CloudKit)
  internal import SwoopKit
  internal import CloudKit
  internal import Foundation

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
