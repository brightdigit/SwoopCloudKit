//
// CloudKitRestoreImageMappingError.swift
// Copyright (c) 2025 BrightDigit.
//

/// A failure encountered while mapping a `CKRecord` to a `RestoreImageRecord`.
public enum CloudKitRestoreImageMappingError: Error, Sendable {
  /// A field required by `RestoreImageRecord` was absent from the record.
  case missingField(String)

  /// The `downloadURL` field was present but not a parseable URL.
  ///
  /// - Note: `downloadURL` is a `STRING` in `schema.ckdb`, not a `CKAsset`.
  case invalidDownloadURL(String)

  /// A short explanation suitable for display.
  public var reason: String {
    switch self {
    case .missingField(let field):
      "missing field \"\(field)\""

    case .invalidDownloadURL(let value):
      "downloadURL is not a valid URL: \"\(value)\""
    }
  }
}
