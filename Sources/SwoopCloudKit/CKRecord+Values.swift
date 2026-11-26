//
//  CKRecord+Values.swift
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

#if canImport(CloudKit)
  internal import CloudKit
  internal import Foundation

  extension CKRecord {
    /// Reads an `INT64` field, tolerating the several numeric bridgings
    /// CloudKit can hand back for the same column.
    ///
    /// - Parameter key: The record field name.
    /// - Returns: The value as an `Int64`, or `nil` when absent or non-numeric.
    internal func integerValue(forKey key: String) -> Int64? {
      if let value = self[key] as? Int64 {
        return value
      }
      if let value = self[key] as? Int {
        return Int64(value)
      }
      if let value = self[key] as? NSNumber {
        return value.int64Value
      }
      return nil
    }

    // swiftlint:disable discouraged_optional_boolean
    /// Reads a boolean stored as `INT64`.
    ///
    /// `schema.ckdb` has no boolean type, so `isSigned` and `isPrerelease` are
    /// persisted as `INT64` and must be widened back here.
    ///
    /// - Parameter key: The record field name.
    /// - Returns: `nil` when the field is absent, which means "unknown".
    internal func booleanValue(forKey key: String) -> Bool? {
      self.integerValue(forKey: key).map { $0 != 0 }
    }
    // swiftlint:enable discouraged_optional_boolean

    /// Reads a `REFERENCE` field as the referenced record's name, which is
    /// how the SwoopKit models store references (for example
    /// `"XcodeVersion-27A5318c"`).
    ///
    /// - Parameter key: The record field name.
    /// - Returns: `nil` when the field is absent or not a reference.
    internal func referenceName(forKey key: String) -> String? {
      (self[key] as? CKRecord.Reference)?.recordID.recordName
    }
  }
#endif
