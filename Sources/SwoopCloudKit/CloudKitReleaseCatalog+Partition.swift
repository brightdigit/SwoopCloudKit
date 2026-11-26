//
//  CloudKitReleaseCatalog+Partition.swift
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

#if canImport(CloudKit)
  internal import CloudKit
  internal import Foundation

  extension CloudKitReleaseCatalog {
    /// Splits one page of query results into mapped records and skips.
    ///
    /// - Parameters:
    ///   - matchResults: One page from `records(matching:)` or
    ///     `records(continuingMatchFrom:)`.
    ///   - transform: Maps a record onto its model.
    /// - Returns: The mapped records and the skipped ones, in query order.
    internal static func partition<Record: Sendable>(
      _ matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)],
      using transform: CloudKitRecordTransform<Record>
    ) -> CloudKitReleaseRecords<Record> {
      var records: [Record] = []
      var skipped: [CloudKitRecordSkip] = []
      for (recordID, result) in matchResults {
        switch result {
        case .success(let ckRecord):
          do {
            records.append(try transform(ckRecord))
          } catch {
            skipped.append(
              CloudKitRecordSkip(id: recordID.recordName, reason: error.reason)
            )
          }

        case .failure(let error):
          skipped.append(
            CloudKitRecordSkip(
              id: recordID.recordName,
              reason: error.localizedDescription
            )
          )
        }
      }
      return CloudKitReleaseRecords(records: records, skipped: skipped)
    }
  }
#endif
