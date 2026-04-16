/// The iOS Data Protection class for a file.
///
/// These values correspond to Apple's `URLFileProtection` /
/// `NSFileProtection` constants.
///
/// **iOS only.** On macOS, file protection is not applicable and
/// [FileResourceValues.fileProtection] will always be `null`.
enum FileProtectionType {
  /// No special protection. The file is accessible at all times.
  none,

  /// The file is stored in an encrypted format and cannot be read from or
  /// written to while the device is locked.
  complete,

  /// The file is encrypted on disk. Already-open file handles remain valid
  /// even after the device is locked.
  completeUnlessOpen,

  /// The file is encrypted on disk and cannot be accessed until the device
  /// has been unlocked at least once after a reboot.
  completeUntilFirstUserAuthentication,
}
