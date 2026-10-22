//
// CloudKitRestoreImageSkip.swift
// Copyright (c) 2025 BrightDigit.
//

/// A CloudKit record that could not be turned into a `RestoreImageRecord`.
///
/// Skips are surfaced to the caller rather than swallowed, so that a
/// schema drift between the sync job and the app is visible immediately.
public struct CloudKitRestoreImageSkip: Identifiable, Sendable {
  /// The CloudKit record name that was skipped.
  public let id: String

  /// A human readable explanation of why the record was skipped.
  public let reason: String

  /// Creates a skipped record entry.
  ///
  /// - Parameters:
  ///   - id: The CloudKit record name.
  ///   - reason: Why the record could not be mapped.
  public init(id: String, reason: String) {
    self.id = id
    self.reason = reason
  }
}
