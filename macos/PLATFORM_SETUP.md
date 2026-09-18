# macOS platform folder — needs to be generated on a Mac

Same reasoning as `ios/PLATFORM_SETUP.md`: the macOS platform's
`Runner.xcodeproj/project.pbxproj` is an Xcode-managed indexed project file
that's unsafe to hand-write, and Xcode itself only runs on macOS.

## To add real macOS desktop support

On a Mac, with Flutter and Xcode installed, run this from the project root:

```bash
flutter create --platforms=macos .
```

This generates `macos/Runner.xcodeproj`, `macos/Runner.xcworkspace`,
`macos/Podfile`, `macos/Runner/AppDelegate.swift`,
`macos/Runner/MainFlutterWindow.swift`, `Info.plist`, and entitlements —
without touching your existing `lib/`, `android/`, `web/`, `linux/`, or
`windows/` folders.
