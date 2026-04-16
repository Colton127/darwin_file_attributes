import 'file_protection_type.dart';
import 'ubiquitous_item_downloading_status.dart';

/// A collection of file-system resource values.
///
/// All fields are nullable. When returned by
/// `DarwinFileAttributes.getResourceValues`, a `null` value means the
/// property was not requested, not available on the current platform, or not
/// applicable to the file.
///
/// When passed to `DarwinFileAttributes.setResourceValues`, only non-null
/// fields are written. Read-only fields are silently ignored by the native
/// layer.
class FileResourceValues {
  /// Whether the file is excluded from backups (iCloud, iTunes, Finder).
  ///
  /// Available on **iOS and macOS**.
  final bool? isExcludedFromBackup;

  /// Whether the file is hidden in Finder / Files.
  ///
  /// Available on **iOS and macOS**.
  final bool? isHidden;

  /// Whether the file is locked by the user (user-immutable flag).
  ///
  /// **macOS only.** Always `null` on iOS.
  final bool? isUserImmutable;

  /// The file's creation date.
  ///
  /// Available on **iOS and macOS**.
  final DateTime? creationDate;

  /// The file's last content-modification date.
  ///
  /// Available on **iOS and macOS**.
  final DateTime? contentModificationDate;

  /// The file's iOS Data Protection class.
  ///
  /// **iOS only.** Always `null` on macOS.
  final FileProtectionType? fileProtection;

  /// Whether the file is a ubiquitous item (managed by iCloud).
  ///
  /// Available on **iOS and macOS**. **Read-only** — ignored by
  /// `DarwinFileAttributes.setResourceValues`.
  final bool? isUbiquitousItem;

  /// The current download status of a ubiquitous (iCloud) item.
  ///
  /// Available on **iOS and macOS**. **Read-only** — ignored by
  /// `DarwinFileAttributes.setResourceValues`.
  final UbiquitousItemDownloadingStatus? ubiquitousItemDownloadingStatus;

  /// Whether the ubiquitous item has been uploaded to iCloud.
  ///
  /// Available on **iOS and macOS**. **Read-only** — ignored by
  /// `DarwinFileAttributes.setResourceValues`.
  final bool? ubiquitousItemIsUploaded;

  /// Whether the ubiquitous item is currently being uploaded to iCloud.
  ///
  /// Available on **iOS and macOS**. **Read-only** — ignored by
  /// `DarwinFileAttributes.setResourceValues`.
  final bool? ubiquitousItemIsUploading;

  /// Creates a [FileResourceValues] instance with the given properties.
  const FileResourceValues({
    this.isExcludedFromBackup,
    this.isHidden,
    this.isUserImmutable,
    this.creationDate,
    this.contentModificationDate,
    this.fileProtection,
    this.isUbiquitousItem,
    this.ubiquitousItemDownloadingStatus,
    this.ubiquitousItemIsUploaded,
    this.ubiquitousItemIsUploading,
  });

  /// Creates a [FileResourceValues] from a platform channel response map.
  factory FileResourceValues.fromMap(Map<Object?, Object?> map) {
    return FileResourceValues(
      isExcludedFromBackup: map['isExcludedFromBackup'] as bool?,
      isHidden: map['isHidden'] as bool?,
      isUserImmutable: map['isUserImmutable'] as bool?,
      creationDate: _dateFromMillis(map['creationDate']),
      contentModificationDate: _dateFromMillis(map['contentModificationDate']),
      fileProtection:
          _fileProtectionFromString(map['fileProtection'] as String?),
      isUbiquitousItem: map['isUbiquitousItem'] as bool?,
      ubiquitousItemDownloadingStatus: _downloadStatusFromString(
          map['ubiquitousItemDownloadingStatus'] as String?),
      ubiquitousItemIsUploaded: map['ubiquitousItemIsUploaded'] as bool?,
      ubiquitousItemIsUploading: map['ubiquitousItemIsUploading'] as bool?,
    );
  }

  /// Converts the writable, non-null fields to a map for the platform channel.
  ///
  /// Read-only fields ([isUbiquitousItem], [ubiquitousItemDownloadingStatus],
  /// [ubiquitousItemIsUploaded], [ubiquitousItemIsUploading]) are intentionally
  /// excluded.
  Map<String, Object> toMap() {
    final map = <String, Object>{};
    if (isExcludedFromBackup != null) {
      map['isExcludedFromBackup'] = isExcludedFromBackup!;
    }
    if (isHidden != null) map['isHidden'] = isHidden!;
    if (isUserImmutable != null) map['isUserImmutable'] = isUserImmutable!;
    if (creationDate != null) {
      map['creationDate'] = creationDate!.millisecondsSinceEpoch;
    }
    if (contentModificationDate != null) {
      map['contentModificationDate'] =
          contentModificationDate!.millisecondsSinceEpoch;
    }
    if (fileProtection != null) map['fileProtection'] = fileProtection!.name;
    return map;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static DateTime? _dateFromMillis(Object? value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  static FileProtectionType? _fileProtectionFromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'none':
        return FileProtectionType.none;
      case 'complete':
        return FileProtectionType.complete;
      case 'completeUnlessOpen':
        return FileProtectionType.completeUnlessOpen;
      case 'completeUntilFirstUserAuthentication':
        return FileProtectionType.completeUntilFirstUserAuthentication;
      default:
        return null;
    }
  }

  static UbiquitousItemDownloadingStatus? _downloadStatusFromString(
      String? value) {
    if (value == null) return null;
    switch (value) {
      case 'notDownloaded':
        return UbiquitousItemDownloadingStatus.notDownloaded;
      case 'downloaded':
        return UbiquitousItemDownloadingStatus.downloaded;
      case 'current':
        return UbiquitousItemDownloadingStatus.current;
      default:
        return null;
    }
  }

  @override
  String toString() {
    final fields = <String>[];
    if (isExcludedFromBackup != null) {
      fields.add('isExcludedFromBackup: $isExcludedFromBackup');
    }
    if (isHidden != null) fields.add('isHidden: $isHidden');
    if (isUserImmutable != null) {
      fields.add('isUserImmutable: $isUserImmutable');
    }
    if (creationDate != null) fields.add('creationDate: $creationDate');
    if (contentModificationDate != null) {
      fields.add('contentModificationDate: $contentModificationDate');
    }
    if (fileProtection != null) fields.add('fileProtection: $fileProtection');
    if (isUbiquitousItem != null) {
      fields.add('isUbiquitousItem: $isUbiquitousItem');
    }
    if (ubiquitousItemDownloadingStatus != null) {
      fields.add(
          'ubiquitousItemDownloadingStatus: $ubiquitousItemDownloadingStatus');
    }
    if (ubiquitousItemIsUploaded != null) {
      fields.add('ubiquitousItemIsUploaded: $ubiquitousItemIsUploaded');
    }
    if (ubiquitousItemIsUploading != null) {
      fields.add('ubiquitousItemIsUploading: $ubiquitousItemIsUploading');
    }
    return 'FileResourceValues(${fields.join(', ')})';
  }
}
