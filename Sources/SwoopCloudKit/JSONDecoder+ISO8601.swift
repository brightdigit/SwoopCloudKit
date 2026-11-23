//
// JSONDecoder+ISO8601.swift
// Copyright (c) 2026 BrightDigit.
//

public import Foundation

extension JSONDecoder {
  /// ISO 8601 dates, matching ``Foundation/JSONEncoder/iso8601PrettySorted``.
  ///
  /// Each call returns a new decoder, so callers can't change one
  /// another's settings.
  public static var iso8601: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }
}
