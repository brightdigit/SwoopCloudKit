//
// ReleaseDataCacheError.swift
// Copyright (c) 2026 BrightDigit.
//

public import Foundation

/// Why a release-data cache file can't be used.
public enum ReleaseDataCacheError: Error, Sendable {
  /// The file was written in another format, or has no
  /// `formatVersion` (`nil`).
  case unsupportedFormatVersion(Int?)
  /// The file isn't a cache file.
  case unreadable(DecodingError)
  /// The file couldn't be read or written.
  case fileFailed(CocoaError)
}

extension ReleaseDataCacheError: Equatable {
  /// Errors are equal when their cases and values match.
  ///
  /// Decoding errors, which aren't `Equatable`, are compared by description.
  ///
  /// - Parameters:
  ///   - lhs: An error.
  ///   - rhs: Another error.
  /// - Returns: Whether the two errors are the same case with equal values.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.unsupportedFormatVersion(left), .unsupportedFormatVersion(right)):
      left == right

    case let (.unreadable(left), .unreadable(right)):
      String(describing: left) == String(describing: right)

    case let (.fileFailed(left), .fileFailed(right)):
      left == right

    default:
      false
    }
  }
}
