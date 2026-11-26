//
//  ReleaseDataCacheError.swift
//  SwoopCloudKit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
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
    case (.unsupportedFormatVersion(let left), .unsupportedFormatVersion(let right)):
      left == right

    case (.unreadable(let left), .unreadable(let right)):
      String(describing: left) == String(describing: right)

    case (.fileFailed(let left), .fileFailed(let right)):
      left == right

    default:
      false
    }
  }
}
