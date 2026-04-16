/// The iCloud (ubiquitous item) download status of a file.
///
/// Corresponds to Apple's `URLUbiquitousItemDownloadingStatus` values.
enum UbiquitousItemDownloadingStatus {
  /// The item has not been downloaded yet.
  notDownloaded,

  /// The item has been downloaded but may not be the most recent version.
  downloaded,

  /// The local copy is the most current version available.
  current,
}
