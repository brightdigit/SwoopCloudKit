//
// CloudKitAccountStatus+CloudKit.swift
// Copyright (c) 2026 BrightDigit.
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
