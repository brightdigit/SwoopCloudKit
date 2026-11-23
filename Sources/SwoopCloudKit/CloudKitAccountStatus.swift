//
// CloudKitAccountStatus.swift
// Copyright (c) 2026 BrightDigit.
//

/// The iCloud account state that decides whether the public database can be read.
///
/// Records that grant `READ` only to `_icloud` need ``available``.
///
/// This mirrors `CKAccountStatus` so callers (such as a "Sign in to iCloud"
/// gate) can tell the cases apart without importing CloudKit.
public enum CloudKitAccountStatus: String, Sendable, CaseIterable {
  /// Signed in to iCloud, with access to the container.
  case available

  /// No iCloud account is signed in on this Mac.
  case noAccount

  /// Parental controls or device management restrict iCloud.
  case restricted

  /// Signed in, but iCloud isn't usable right now, for example while the
  /// account is being verified.
  case temporarilyUnavailable

  /// CloudKit couldn't tell. Worth retrying rather than treating as signed out.
  case couldNotDetermine
}
