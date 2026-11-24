//
//  CloudKitRestoreImage.swift
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
