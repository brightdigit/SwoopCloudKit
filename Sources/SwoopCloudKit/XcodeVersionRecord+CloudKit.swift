//
// XcodeVersionRecord+CloudKit.swift
// Copyright (c) 2026 BrightDigit.
//

#if canImport(CloudKit)
  internal import SwoopKit
  internal import CloudKit
  internal import Foundation

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
