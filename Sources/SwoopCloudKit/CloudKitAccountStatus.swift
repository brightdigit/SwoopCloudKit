//
//  CloudKitAccountStatus.swift
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
