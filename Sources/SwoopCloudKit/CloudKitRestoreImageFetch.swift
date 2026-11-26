//
//  CloudKitRestoreImageFetch.swift
//  SwoopCloudKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
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
