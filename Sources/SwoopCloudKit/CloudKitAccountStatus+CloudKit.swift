//
//  CloudKitAccountStatus+CloudKit.swift
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

  extension CloudKitAccountStatus {
    /// Each `CKAccountStatus` and its counterpart.
    internal static let byCloudKitStatus: [CKAccountStatus: Self] = [
      .available: .available,
      .noAccount: .noAccount,
      .restricted: .restricted,
      .temporarilyUnavailable: .temporarilyUnavailable,
      .couldNotDetermine: .couldNotDetermine,
    ]

    /// Maps CloudKit's status.
    ///
    /// A status added in a later SDK reads as ``couldNotDetermine``, which
    /// callers retry.
    ///
    /// - Parameter status: The status from `CKContainer.accountStatus()`.
    internal init(_ status: CKAccountStatus) {
      self = Self.byCloudKitStatus[status] ?? .couldNotDetermine
    }
  }

  extension CloudKitCatalogError {
    /// Wraps whatever CloudKit threw, keeping its `CKError.Code`.
    ///
    /// - Parameters:
    ///   - operation: What was being done.
    ///   - error: The error CloudKit threw.
    internal init(operation: String, error: any Error) {
      self.init(
        operation: operation,
        ckErrorCode: (error as? CKError)?.code.rawValue,
        message: error.localizedDescription
      )
    }
  }
#endif
