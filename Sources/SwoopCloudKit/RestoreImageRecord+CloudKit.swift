//
// RestoreImageRecord+CloudKit.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(CloudKit)
  internal import SwoopKit
  internal import CloudKit
  internal import Foundation

  extension RestoreImageRecord {
    /// Maps a public-database `RestoreImage` record onto the shared model.
    ///
    /// Traps handled here, all of them driven by SwoopMistKit's `schema.ckdb`:
    /// `downloadURL` is a `STRING` rather than a `CKAsset`; `isSigned` and
    /// `isPrerelease` are `INT64`; and `releaseDate` falls back to
    /// `sourceUpdatedAt` when a source did not publish one.
    ///
    /// - Important: This is a read-only lister — nothing here downloads or
    ///   verifies an image, so `RestoreImageRecord.validate()` (hash integrity,
    ///   HTTPS `downloadURL`, non-zero `fileSize`) is not called. Anything that
    ///   graduates this path to real downloading must add that check back.
    ///
    /// - Parameter cloudKitRecord: The record returned by `CKQuery`.
    /// - Throws: ``CloudKitRestoreImageMappingError`` when a required field is
    ///   missing or malformed. Nothing is silently defaulted that the model
    ///   treats as required.
    internal init(cloudKitRecord: CKRecord) throws(CloudKitRestoreImageMappingError) {
      guard let version = cloudKitRecord["version"] as? String else {
        throw .missingField("version")
      }
      guard let buildNumber = cloudKitRecord["buildNumber"] as? String else {
        throw .missingField("buildNumber")
      }
      let sourceUpdatedAt = cloudKitRecord["sourceUpdatedAt"] as? Date
      guard let releaseDate = (cloudKitRecord["releaseDate"] as? Date) ?? sourceUpdatedAt else {
        throw .missingField("releaseDate")
      }
      guard let downloadURLString = cloudKitRecord["downloadURL"] as? String else {
        throw .missingField("downloadURL")
      }
      guard let downloadURL = URL(string: downloadURLString) else {
        throw .invalidDownloadURL(downloadURLString)
      }
      self.init(
        version: version,
        buildNumber: buildNumber,
        releaseDate: releaseDate,
        downloadURL: downloadURL,
        fileSize: cloudKitRecord.integerValue(forKey: "fileSize").map { Int($0) } ?? 0,
        sha256Hash: cloudKitRecord["sha256Hash"] as? String ?? "",
        sha1Hash: cloudKitRecord["sha1Hash"] as? String ?? "",
        isSigned: cloudKitRecord.booleanValue(forKey: "isSigned"),
        isPrerelease: cloudKitRecord.booleanValue(forKey: "isPrerelease") ?? false,
        source: cloudKitRecord["source"] as? String ?? "",
        notes: cloudKitRecord["notes"] as? String,
        sourceUpdatedAt: sourceUpdatedAt
      )
    }
  }
#endif
