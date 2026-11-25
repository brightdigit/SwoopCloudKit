//
//  Platform.swift
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

internal import Foundation
internal import Testing

/// Platform detection for SwoopCloudKit's tests.
///
/// Suites that need the CloudKit framework take
/// `.enabled(if: Platform.isCloudKitAvailable)`, and their files stay inside
/// `#if canImport(CloudKit)` so they compile where CloudKit doesn't exist.
internal enum Platform {
  /// True where the CloudKit framework exists: macOS, iOS, watchOS, tvOS,
  /// visionOS and Mac Catalyst. False on Linux, where only the release-data
  /// snapshot, the cache file and the JSON helpers build.
  internal static let isCloudKitAvailable: Bool = {
    #if canImport(CloudKit)
      return true
    #else
      return false
    #endif
  }()
}
