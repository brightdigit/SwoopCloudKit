//
// CloudKitRestoreImageFetch.swift
// Copyright (c) 2025 BrightDigit.
//

/// The result of one read-only query against the public CloudKit database.
public struct CloudKitRestoreImageFetch: Sendable {
  /// A description of the iCloud account status at query time.
  public let accountStatus: String

  /// The records that mapped successfully.
  public let images: [CloudKitRestoreImage]

  /// The records that could not be mapped, with reasons.
  public let skipped: [CloudKitRestoreImageSkip]

  /// Whether CloudKit returned a cursor, meaning more records are available.
  public let hasMoreResults: Bool

  /// Creates a fetch result.
  ///
  /// - Parameters:
  ///   - accountStatus: The iCloud account status description.
  ///   - images: The successfully mapped records.
  ///   - skipped: The records that failed to map.
  ///   - hasMoreResults: Whether more records remain server side.
  public init(
    accountStatus: String,
    images: [CloudKitRestoreImage],
    skipped: [CloudKitRestoreImageSkip],
    hasMoreResults: Bool
  ) {
    self.accountStatus = accountStatus
    self.images = images
    self.skipped = skipped
    self.hasMoreResults = hasMoreResults
  }
}
