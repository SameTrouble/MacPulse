# MacPulse

A macOS menu bar system monitor (CPU / Memory / GPU / CPU Temperature / GPU Temperature). Runs purely in the menu bar with no Dock icon.

## Status

In development (scaffold stage).

## Development

- Dependencies: Xcode, [XcodeGen](https://github.com/yonaskolb/XcodeGen), [SwiftLint](https://github.com/realm/SwiftLint)
- Generate project: `xcodegen generate`
- Build: `xcodebuild -project MacPulse.xcodeproj -scheme MacPulse build`
- Test: `xcodebuild -project MacPulse.xcodeproj -scheme MacPulse test`
- Lint: `swiftlint lint`

## License

MIT (see [LICENSE](LICENSE))
