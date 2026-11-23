//
// JSONEncoder+Asserting.swift
// Copyright (c) 2026 BrightDigit.
//

public import Foundation

extension JSONEncoder {
  /// Encodes a value whose type can't fail to encode.
  ///
  /// A failure means the value's type is wrong, so it's a programming
  /// error: it asserts, and in a release build returns empty data.
  ///
  /// - Parameter value: The value to encode.
  /// - Returns: The encoded data, or empty data if encoding failed.
  public func encodeAsserting(_ value: some Encodable) -> Data {
    do {
      return try encode(value)
    } catch {
      assertionFailure("Couldn't encode \(type(of: value)): \(error)")
      return Data()
    }
  }
}
