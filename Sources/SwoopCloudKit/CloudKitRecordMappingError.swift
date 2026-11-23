//
// CloudKitRecordMappingError.swift
// Copyright (c) 2026 BrightDigit.
//

/// Why a public-database release record couldn't be mapped onto its
/// SwoopKit model.
public enum CloudKitRecordMappingError: Error, Sendable, Equatable {
  /// A field the model requires was absent, or had the wrong type.
  case missingField(String)

  /// The `platform` field held a value `SDKVersionRecord.Platform` doesn't know.
  case invalidPlatform(String)

  /// The `releaseLabel` field held text `SimulatorRuntimeRecord.ReleaseLabel`
  /// doesn't parse.
  case invalidReleaseLabel(String)

  /// A short explanation suitable for display.
  public var reason: String {
    switch self {
    case .missingField(let field):
      "missing field \"\(field)\""

    case .invalidPlatform(let value):
      "unknown platform \"\(value)\""

    case .invalidReleaseLabel(let value):
      "unknown release label \"\(value)\""
    }
  }
}
