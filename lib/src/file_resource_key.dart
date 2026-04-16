/// Keys identifying specific file-system resource properties.
///
/// Pass a set of these keys to
/// [DarwinFileAttributes.getResourceValues] to request only the attributes you
/// need. Fetching fewer keys is more efficient than requesting all values.
enum FileResourceKey {
  /// Whether the file is excluded from backups (iCloud, iTunes, Finder).
  ///
  /// Available on **iOS and macOS**. Writable.
  isExcludedFromBackup,

  /// Whether the file is hidden in Finder / Files.
  ///
  /// Available on **iOS and macOS**. Writable.
  isHidden,

  /// Whether the file is locked by the user (user-immutable flag).
  ///
  /// **macOS only.** Returns `null` on iOS. Writable on macOS.
  isUserImmutable,

  /// The file's creation date.
  ///
  /// Available on **iOS and macOS**. Writable.
  creationDate,

  /// The file's last content-modification date.
  ///
  /// Available on **iOS and macOS**. Writable.
  contentModificationDate,

  /// The file's iOS Data Protection class.
  ///
  /// **iOS only.** Returns `null` on macOS. Writable on iOS.
  fileProtection,

  /// Whether the file is a ubiquitous item (managed by iCloud).
  ///
  /// Available on **iOS and macOS**. **Read-only.**
  isUbiquitousItem,

  /// The current download status of a ubiquitous (iCloud) item.
  ///
  /// Available on **iOS and macOS**. **Read-only.**
  ubiquitousItemDownloadingStatus,

  /// Whether the ubiquitous item has been uploaded to iCloud.
  ///
  /// Available on **iOS and macOS**. **Read-only.**
  ubiquitousItemIsUploaded,

  /// Whether the ubiquitous item is currently being uploaded to iCloud.
  ///
  /// Available on **iOS and macOS**. **Read-only.**
  ubiquitousItemIsUploading,
}
