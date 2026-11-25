# CI runner images (as of 2026-11-25)

- Swift 6.4 is released; Linux lanes use `swift:6.4-<os>`. The `swiftlang/swift:nightly-6.4.x` images are no longer needed.
- `runs-on: xcode-27` is a preview image with Xcode 27.0, 27.1 (default) and 27.2. Pin `/Applications/Xcode_27.2.app` (a symlink that survives image refreshes).
- `ubuntu-latest` is Ubuntu 26.04, which lacks `libxml2.so.2`, so the mise-installed SwiftLint binary can't start. Pin non-container jobs that run SwiftLint to `ubuntu-24.04`.
- CodeQL can't analyze Swift 6.4 / macOS 27, so `codeql.yml` was removed (as in SwoopKit). Re-add it once CodeQL supports Swift 6.4.
- These mirror SwoopKit's `simulator` branch and MistKit's `mistico` branch; keep the repos in step when one moves.
