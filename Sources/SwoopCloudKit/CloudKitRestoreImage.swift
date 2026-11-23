//
// CloudKitRestoreImage.swift
// Copyright (c) 2025 BrightDigit.
//

public import SwoopKit

/// A single `RestoreImage` record read from the public CloudKit database.
///
/// - Note: This is a read-only value. Nothing here downloads or imports the
///   image.
public struct CloudKitRestoreImage: Identifiable, Sendable {
  /// The CloudKit record name, which is `RestoreImage-{buildNumber}`.
  public let id: String

  /// The record decoded into the shared SwoopKit model.
  public let record: RestoreImageRecord

  /// Creates a fetched restore image.
  ///
  /// - Parameters:
  ///   - id: The CloudKit record name.
  ///   - record: The decoded restore image record.
  public init(id: String, record: RestoreImageRecord) {
    self.id = id
    self.record = record
  }
}
