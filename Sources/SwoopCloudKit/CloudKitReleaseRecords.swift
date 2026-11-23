//
// CloudKitReleaseRecords.swift
// Copyright (c) 2026 BrightDigit.
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
