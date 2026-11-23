//
// JSONDecoder+Typed.swift
// Copyright (c) 2026 BrightDigit.
//

public import Foundation

extension JSONDecoder {
  /// `decode(_:from:)` with its error typed.
  ///
  /// `JSONDecoder` only throws `DecodingError`; anything else a value's own
  /// `init(from:)` throws is wrapped as `.dataCorrupted`.
  ///
  /// - Parameters:
  ///   - type: The type to decode.
  ///   - data: The JSON to decode.
  /// - Returns: The decoded value.
  /// - Throws: A `DecodingError` when `data` doesn't decode as `type`.
  public func decodeValue<Value: Decodable>(
    _ type: Value.Type,
    from data: Data
  ) throws(DecodingError) -> Value {
    do {
      return try decode(type, from: data)
    } catch let error as DecodingError {
      throw error
    } catch {
      throw .dataCorrupted(
        .init(codingPath: [], debugDescription: "\(error)", underlyingError: error)
      )
    }
  }
}
