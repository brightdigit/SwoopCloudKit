//
// CloudKitCatalogError.swift
// Copyright (c) 2026 BrightDigit.
//

/// A failure from CloudKit itself while reading the public database, such as
/// no network, a missing entitlement, or a permission error.
public struct CloudKitCatalogError: Error, Sendable, Equatable {
  /// What was being done: `"accountStatus"`, or the record type queried.
  public let operation: String

  /// The `CKError.Code` raw value, when CloudKit reported one.
  public let ckErrorCode: Int?

  /// The underlying error's localized description.
  public let message: String

  /// Creates an error.
  ///
  /// - Parameters:
  ///   - operation: What was being done.
  ///   - ckErrorCode: The `CKError.Code` raw value, if any.
  ///   - message: The underlying error's description.
  public init(operation: String, ckErrorCode: Int?, message: String) {
    self.operation = operation
    self.ckErrorCode = ckErrorCode
    self.message = message
  }
}
