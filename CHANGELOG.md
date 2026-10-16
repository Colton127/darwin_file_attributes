## 1.0.1

* Added Swift Package Manager support for iOS and macOS. CocoaPods remains
  supported; the podspecs now point at the Swift package sources. Swift Package
  Manager builds require Flutter 3.44 or later, which vends the Flutter
  framework as the `FlutterFramework` Swift package.
* The privacy manifest (`PrivacyInfo.xcprivacy`) is now bundled by both build
  systems, and declares `NSPrivacyAccessedAPICategoryFileTimestamp` (reasons
  `0A2A.1` and `C617.1`) for the `creationDate` / `contentModificationDate`
  resource keys.
* Raised the macOS podspec deployment target to 10.14
* Fixed the macOS plugin failing to compile against its 10.14 deployment
  target. The `fileProtection` resource key relies on macOS 11.0 APIs and is
  now only read on macOS 11.0 or later; on older versions it is omitted.

## 1.0.0

* Initial release
