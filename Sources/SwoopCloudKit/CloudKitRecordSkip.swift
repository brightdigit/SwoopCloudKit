//
// CloudKitRecordSkip.swift
// Copyright (c) 2026 BrightDigit.
//

/// A release record that was returned by a query but couldn't be used.
public struct CloudKitRecordSkip: Identifiable, Sendable, Equatable {
  /// The CloudKit record name that was skipped.
  public let id: String

  /// A human readable explanation of why the record was skipped.
  public let reason: String

  /// Creates a skipped record entry.
  ///
  /// - Parameters:
  ///   - id: The CloudKit record name.
  ///   - reason: Why the record could not be used.
  public init(id: String, reason: String) {
    self.id = id
    self.reason = reason
  }
}
