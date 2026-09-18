# iOS platform folder — needs to be generated on a Mac

This folder is intentionally minimal. Unlike `android/`, `linux/`, and
`windows/` (which are plain Gradle/CMake text files I could safely hand-write
and verify), the iOS platform folder's core file is `Runner.xcodeproj/project.pbxproj`
— Xcode's internal project index. It's an indexed, cross-referenced format
(unique object IDs linking build phases, targets, and file references) that
Xcode itself generates and maintains. A single mistake in it — a wrong ID, a
missing reference — produces a project that fails to open, and Xcode's error
messages for a malformed `.pbxproj` are not easy to debug or fix by hand.

There's also a practical point: **Xcode only runs on macOS**, so an iOS build
isn't something you can act on directly from Windows/Linux anyway.

## To add real iOS support

On a Mac, with Flutter and Xcode installed, run this from the project root:

```bash
flutter create --platforms=ios .
```

This generates `ios/Runner.xcodeproj`, `ios/Runner.xcworkspace`,
`ios/Podfile`, `ios/Runner/AppDelegate.swift`, `Info.plist`, and the asset
catalogs — safely, using the real Flutter tooling — without touching your
existing `lib/`, `android/`, `web/`, `linux/`, or `windows/` folders.

After that, update `ios/Runner/Info.plist`:
- `CFBundleDisplayName` → `Disha Saathi`
- Bundle Identifier (in Xcode → Signing & Capabilities) → `com.aialchemists.dishaSaathi`
  (to match the Android `applicationId`/`namespace` used in this project)
