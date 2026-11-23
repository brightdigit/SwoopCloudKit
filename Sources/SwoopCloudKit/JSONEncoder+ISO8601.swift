//
// JSONEncoder+ISO8601.swift
// Copyright (c) 2026 BrightDigit.
//

public import Foundation

extension JSONEncoder {
  /// ISO 8601 dates, pretty-printed with sorted keys: stable, diffable
  /// JSON, such as a release-data cache file or snapshot.
  ///
  /// ISO 8601 keeps whole seconds only. Each call returns a new encoder,
  /// so callers can't change one another's settings.
  public static var iso8601PrettySorted: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return encoder
  }
}
