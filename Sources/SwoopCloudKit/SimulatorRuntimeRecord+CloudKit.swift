//
// SimulatorRuntimeRecord+CloudKit.swift
// Copyright (c) 2026 BrightDigit.
//

#if canImport(CloudKit)
  internal import SwoopKit
  internal import CloudKit
  internal import Foundation

  extension SimulatorRuntimeRecord {
    /// Maps a public-database `SimulatorRuntime` record onto the shared model.
    ///
    /// The mirror of SwoopMistKit's `SimulatorRuntimeRecord.from(recordInfo:)`:
    /// `releaseLabel` is text ("Beta 4", "RC 1", "Final"), and the SDK builds are
    /// one comma-separated `STRING` in `sdkBuildNumbersText` that's absent when the
    /// index maps no SDK. `isPrerelease` is stored too, but the label already says it.
    ///
    /// The SDK builds aren't a `LIST<STRING>` because SwoopMistKit's writer, MistKit,
    /// can't decode that type in responses (brightdigit/MistKit#509).
    /// TODO: Read a `LIST<STRING>` again once SwoopMistKit switches back.
    ///
    /// - Parameter cloudKitRecord: The record returned by `CKQuery`.
    /// - Throws: ``CloudKitRecordMappingError`` when `platform`, `version`,
    ///   `buildNumber` or `releaseLabel` is missing, or the platform or label
    ///   is unknown.
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
      guard let labelValue = cloudKitRecord["releaseLabel"] as? String else {
        throw .missingField("releaseLabel")
      }
      guard let releaseLabel = ReleaseLabel(labelValue) else {
        throw .invalidReleaseLabel(labelValue)
      }
      self.init(
        platform: platform,
        version: version,
        buildNumber: buildNumber,
        releaseLabel: releaseLabel,
        sdkBuildNumbers: Self.sdkBuildNumbers(
          fromText: cloudKitRecord[Self.sdkBuildNumbersFieldName] as? String
        )
      )
    }

    /// The field that holds the SDK builds as comma-separated text (MistKit#509).
    internal static let sdkBuildNumbersFieldName = "sdkBuildNumbersText"

    /// Splits `sdkBuildNumbersText`; a missing or empty value is `[]`.
    internal static func sdkBuildNumbers(fromText text: String?) -> [String] {
      guard let text else {
        return []
      }
      return text.split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty }
    }
  }
#endif
