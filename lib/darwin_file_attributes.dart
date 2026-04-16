import 'dart:typed_data';

import 'darwin_file_attributes_platform_interface.dart';
import 'src/file_protection_type.dart';
import 'src/file_resource_key.dart';
import 'src/file_resource_values.dart';
import 'src/ubiquitous_item_downloading_status.dart';

export 'src/exceptions.dart';
export 'src/file_protection_type.dart';
export 'src/file_resource_key.dart';
export 'src/file_resource_values.dart';
export 'src/ubiquitous_item_downloading_status.dart';

// ignore: non_constant_identifier_names
/// Global singleton to access [DarwinFileAttributesInterface].
// ignore: non_constant_identifier_names
final DarwinFileAttributesInterface DarwinFileAttributes =
    const DarwinFileAttributesInterface();

/// A Flutter plugin for reading and writing Darwin (iOS / macOS) file-system
/// attributes via Apple's `URLResourceValues` API and POSIX extended
/// attributes (`xattr`).
///
/// **All methods require the target file or directory to already exist on
/// disk.** A [FileNotFoundException] is thrown if the path does not point to
/// an existing file-system entity.
///
/// ### Quick start
///
/// ```dart
///
/// // Exclude a file from iCloud / Finder backups
/// await DarwinFileAttributes.setIsExcludedFromBackup('/path/to/file', true);
///
/// // Read several resource values at once
/// final values = await DarwinFileAttributes.getResourceValues(
///   '/path/to/file',
///   keys: const {FileResourceKey.isHidden, FileResourceKey.creationDate},
/// );
/// print(values.isHidden);
/// print(values.creationDate);
/// ```
class DarwinFileAttributesInterface {
  const DarwinFileAttributesInterface();

  // ---------------------------------------------------------------------------
  // Bulk operations
  // ---------------------------------------------------------------------------

  /// Reads the requested file resource values for the item at [path].
  ///
  /// If [keys] is omitted every supported resource key is fetched.
  /// Requesting only the keys you need is more efficient.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<FileResourceValues> getResourceValues(String path,
      {Set<FileResourceKey>? keys}) {
    return DarwinFileAttributesPlatform.instance
        .getResourceValues(path, keys: keys);
  }

  /// Writes the non-null fields of [values] to the item at [path].
  ///
  /// Read-only fields (e.g. [FileResourceValues.isUbiquitousItem]) are
  /// silently ignored by the native layer.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<void> setResourceValues(String path, FileResourceValues values) {
    return DarwinFileAttributesPlatform.instance
        .setResourceValues(path, values);
  }

  // ---------------------------------------------------------------------------
  // Convenience — Backup exclusion
  // ---------------------------------------------------------------------------

  /// Returns whether the item at [path] is excluded from backups
  /// (iCloud, iTunes, Finder), or `null` if the value is unavailable.
  ///
  /// Available on **iOS and macOS**.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<bool?> getIsExcludedFromBackup(String path) async {
    final v = await getResourceValues(path,
        keys: const {FileResourceKey.isExcludedFromBackup});
    return v.isExcludedFromBackup;
  }

  /// Sets whether the item at [path] should be excluded from backups.
  ///
  /// Available on **iOS and macOS**.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<void> setIsExcludedFromBackup(String path, bool excluded) {
    return setResourceValues(
        path, FileResourceValues(isExcludedFromBackup: excluded));
  }

  // ---------------------------------------------------------------------------
  // Convenience — Visibility
  // ---------------------------------------------------------------------------

  /// Returns whether the item at [path] is hidden, or `null` if unavailable.
  ///
  /// Available on **iOS and macOS**.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<bool?> getIsHidden(String path) async {
    final v =
        await getResourceValues(path, keys: const {FileResourceKey.isHidden});
    return v.isHidden;
  }

  /// Sets whether the item at [path] should be hidden.
  ///
  /// Available on **iOS and macOS**.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<void> setIsHidden(String path, bool hidden) {
    return setResourceValues(path, FileResourceValues(isHidden: hidden));
  }

  // ---------------------------------------------------------------------------
  // Convenience — User immutable (file lock)
  // ---------------------------------------------------------------------------

  /// Returns whether the item at [path] is locked (user-immutable), or `null`
  /// if unavailable.
  ///
  /// **macOS only.** Returns `null` on iOS.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<bool?> getIsUserImmutable(String path) async {
    final v = await getResourceValues(path,
        keys: const {FileResourceKey.isUserImmutable});
    return v.isUserImmutable;
  }

  /// Sets whether the item at [path] should be locked (user-immutable).
  ///
  /// **macOS only.** Has no effect on iOS.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<void> setIsUserImmutable(String path, bool immutable) {
    return setResourceValues(
        path, FileResourceValues(isUserImmutable: immutable));
  }

  // ---------------------------------------------------------------------------
  // Convenience — Dates
  // ---------------------------------------------------------------------------

  /// Returns the creation date of the item at [path], or `null` if
  /// unavailable.
  ///
  /// Available on **iOS and macOS**.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<DateTime?> getCreationDate(String path) async {
    final v = await getResourceValues(path,
        keys: const {FileResourceKey.creationDate});
    return v.creationDate;
  }

  /// Sets the creation date of the item at [path].
  ///
  /// Available on **iOS and macOS**.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<void> setCreationDate(String path, DateTime date) {
    return setResourceValues(path, FileResourceValues(creationDate: date));
  }

  /// Returns the last content-modification date of the item at [path], or
  /// `null` if unavailable.
  ///
  /// Available on **iOS and macOS**.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<DateTime?> getContentModificationDate(String path) async {
    final v = await getResourceValues(path,
        keys: const {FileResourceKey.contentModificationDate});
    return v.contentModificationDate;
  }

  /// Sets the last content-modification date of the item at [path].
  ///
  /// Available on **iOS and macOS**.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<void> setContentModificationDate(String path, DateTime date) {
    return setResourceValues(
        path, FileResourceValues(contentModificationDate: date));
  }

  // ---------------------------------------------------------------------------
  // Convenience — File protection (iOS only)
  // ---------------------------------------------------------------------------

  /// Returns the iOS Data Protection class of the item at [path], or `null`
  /// if unavailable.
  ///
  /// **iOS only.** Always returns `null` on macOS.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<FileProtectionType?> getFileProtection(String path) async {
    final v = await getResourceValues(path,
        keys: const {FileResourceKey.fileProtection});
    return v.fileProtection;
  }

  /// Sets the iOS Data Protection class of the item at [path].
  ///
  /// **iOS only.** Has no effect on macOS.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<void> setFileProtection(String path, FileProtectionType type) {
    return setResourceValues(path, FileResourceValues(fileProtection: type));
  }

  // ---------------------------------------------------------------------------
  // Convenience — Ubiquitous (iCloud) items   (read-only)
  // ---------------------------------------------------------------------------

  /// Returns whether the item at [path] is a ubiquitous (iCloud-managed)
  /// item, or `null` if unavailable.
  ///
  /// Available on **iOS and macOS**. **Read-only.**
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<bool?> getIsUbiquitousItem(String path) async {
    final v = await getResourceValues(path,
        keys: const {FileResourceKey.isUbiquitousItem});
    return v.isUbiquitousItem;
  }

  /// Returns the download status of the ubiquitous (iCloud) item at [path],
  /// or `null` if the item is not ubiquitous or the value is unavailable.
  ///
  /// Available on **iOS and macOS**. **Read-only.**
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<UbiquitousItemDownloadingStatus?> getUbiquitousItemDownloadingStatus(
      String path) async {
    final v = await getResourceValues(path,
        keys: const {FileResourceKey.ubiquitousItemDownloadingStatus});
    return v.ubiquitousItemDownloadingStatus;
  }

  /// Returns whether the ubiquitous item at [path] has been uploaded to
  /// iCloud, or `null` if the item is not ubiquitous.
  ///
  /// Available on **iOS and macOS**. **Read-only.**
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<bool?> getUbiquitousItemIsUploaded(String path) async {
    final v = await getResourceValues(path,
        keys: const {FileResourceKey.ubiquitousItemIsUploaded});
    return v.ubiquitousItemIsUploaded;
  }

  /// Returns whether the ubiquitous item at [path] is currently being
  /// uploaded to iCloud, or `null` if the item is not ubiquitous.
  ///
  /// Available on **iOS and macOS**. **Read-only.**
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<bool?> getUbiquitousItemIsUploading(String path) async {
    final v = await getResourceValues(path,
        keys: const {FileResourceKey.ubiquitousItemIsUploading});
    return v.ubiquitousItemIsUploading;
  }

  // ---------------------------------------------------------------------------
  // Extended attributes (xattr)
  // ---------------------------------------------------------------------------

  /// Reads the extended attribute [name] from the item at [path].
  ///
  /// Returns `null` if the attribute does not exist on the item.
  ///
  /// Available on **iOS and macOS**.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<Uint8List?> getExtendedAttribute(String path, String name) {
    return DarwinFileAttributesPlatform.instance
        .getExtendedAttribute(path, name);
  }

  /// Sets (or overwrites) the extended attribute [name] on the item at
  /// [path] with the given byte [value].
  ///
  /// Available on **iOS and macOS**.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<void> setExtendedAttribute(String path, String name, Uint8List value) {
    return DarwinFileAttributesPlatform.instance
        .setExtendedAttribute(path, name, value);
  }

  /// Removes the extended attribute [name] from the item at [path].
  ///
  /// Does nothing if the attribute does not exist.
  ///
  /// Available on **iOS and macOS**.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<void> removeExtendedAttribute(String path, String name) {
    return DarwinFileAttributesPlatform.instance
        .removeExtendedAttribute(path, name);
  }

  /// Lists all extended attribute names on the item at [path].
  ///
  /// Returns an empty list if there are no extended attributes.
  ///
  /// Available on **iOS and macOS**.
  ///
  /// The file or directory at [path] **must exist**; throws
  /// [FileNotFoundException] otherwise.
  Future<List<String>> listExtendedAttributes(String path) {
    return DarwinFileAttributesPlatform.instance.listExtendedAttributes(path);
  }
}
