//
//  CloudKitReleaseRecords.swift
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

/// Every record of one type read from the public database: the ones that
/// mapped onto their SwoopKit model, and the ones that didn't.
public struct CloudKitReleaseRecords<Record: Sendable>: Sendable {
  /// The records that mapped successfully, newest release first.
  public let records: [Record]

  /// The records that could not be mapped or fetched, with reasons.
  public let skipped: [CloudKitRecordSkip]

  /// Creates a result.
  ///
  /// - Parameters:
  ///   - records: The successfully mapped records.
  ///   - skipped: The records that were skipped.
  public init(records: [Record], skipped: [CloudKitRecordSkip]) {
    self.records = records
    self.skipped = skipped
  }
}
