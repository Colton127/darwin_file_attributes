# darwin_file_attributes

A Flutter plugin for reading and writing Darwin (iOS / macOS) file-system
attributes via Apple's `URLResourceValues` API and POSIX extended attributes
(`xattr`).

| Platform | Supported |
|----------|-----------|
| iOS      | 12.0+     |
| macOS    | 10.14+    |

## Quick Start

```dart
import 'package:darwin_file_attributes/darwin_file_attributes.dart';

// Exclude a file from iCloud / Finder backups
await DarwinFileAttributes.setIsExcludedFromBackup('/path/to/file', true);

// Read multiple resource values at once
final values = await DarwinFileAttributes.getResourceValues(
  '/path/to/file',
  keys: {FileResourceKey.isHidden, FileResourceKey.creationDate},
);
print(values.isHidden);       // bool?
print(values.creationDate);   // DateTime?
```

> **Important:** All methods require the target file or directory to already
> exist on disk. A `FileNotFoundException` is thrown if the path does not point
> to an existing file-system entity.

## API Reference

### Bulk Operations

Read or write several resource values in a single platform call.

```dart
// Read specific keys
final values = await DarwinFileAttributes.getResourceValues(
  path,
  keys: {FileResourceKey.isHidden, FileResourceKey.isExcludedFromBackup},
);

// Write multiple values at once
await DarwinFileAttributes.setResourceValues(path, FileResourceValues(
  isHidden: true,
  isExcludedFromBackup: true,
));
```

### Backup Exclusion — iOS & macOS

```dart
final excluded = await DarwinFileAttributes.getIsExcludedFromBackup(path); // bool?
await DarwinFileAttributes.setIsExcludedFromBackup(path, true);
```

### Visibility — iOS & macOS

```dart
final hidden = await DarwinFileAttributes.getIsHidden(path); // bool?
await DarwinFileAttributes.setIsHidden(path, true);
```

### File Lock (User Immutable) — macOS only

```dart
final locked = await DarwinFileAttributes.getIsUserImmutable(path); // bool? (null on iOS)
await DarwinFileAttributes.setIsUserImmutable(path, true);           // no-op on iOS
```

### Timestamps — iOS & macOS

```dart
final created  = await DarwinFileAttributes.getCreationDate(path);             // DateTime?
final modified = await DarwinFileAttributes.getContentModificationDate(path);   // DateTime?

await DarwinFileAttributes.setCreationDate(path, DateTime(2025, 1, 1));
await DarwinFileAttributes.setContentModificationDate(path, DateTime(2025, 6, 15));
```

### File Protection — iOS only

```dart
final prot = await DarwinFileAttributes.getFileProtection(path); // FileProtectionType? (null on macOS)
await DarwinFileAttributes.setFileProtection(path, FileProtectionType.complete);
```

`FileProtectionType` values: `none`, `complete`, `completeUnlessOpen`,
`completeUntilFirstUserAuthentication`.

### iCloud (Ubiquitous Item) Status — iOS & macOS (read-only)

```dart
final isICloud   = await DarwinFileAttributes.getIsUbiquitousItem(path);                  // bool?
final dlStatus   = await DarwinFileAttributes.getUbiquitousItemDownloadingStatus(path);   // UbiquitousItemDownloadingStatus?
final uploaded   = await DarwinFileAttributes.getUbiquitousItemIsUploaded(path);          // bool?
final uploading  = await DarwinFileAttributes.getUbiquitousItemIsUploading(path);         // bool?
```

`UbiquitousItemDownloadingStatus` values: `notDownloaded`, `downloaded`,
`current`.

### Extended Attributes (xattr) — iOS & macOS

Arbitrary key-value byte blobs stored alongside a file.

```dart
import 'dart:typed_data';
import 'dart:convert';

// Write
await DarwinFileAttributes.setExtendedAttribute(
  path,
  'com.example.myattr',
  Uint8List.fromList(utf8.encode('hello')),
);

// Read
final data = await DarwinFileAttributes.getExtendedAttribute(path, 'com.example.myattr'); // Uint8List?

// List all attribute names
final names = await DarwinFileAttributes.listExtendedAttributes(path); // List<String>

// Remove
await DarwinFileAttributes.removeExtendedAttribute(path, 'com.example.myattr');
```

## Error Handling

| Exception               | When                                       |
|-------------------------|--------------------------------------------|
| `FileNotFoundException` | The file or directory at `path` does not exist. |
| `PlatformException`     | A system-level error (permissions, I/O, etc.). |

```dart
try {
  await attrs.setIsHidden('/nonexistent', true);
} on FileNotFoundException catch (e) {
  print(e); // FileNotFoundException: No file or directory at path: /nonexistent
}
```

## Platform-Specific Notes

| Attribute                | iOS | macOS | Notes |
|--------------------------|-----|-------|-------|
| `isExcludedFromBackup`   | R/W | R/W   |       |
| `isHidden`               | R/W | R/W   |       |
| `isUserImmutable`        | —   | R/W   | Returns `null` on iOS |
| `creationDate`           | R/W | R/W   |       |
| `contentModificationDate`| R/W | R/W   |       |
| `fileProtection`         | R/W | —     | Returns `null` on macOS |
| `isUbiquitousItem`       | R   | R     | Read-only |
| `ubiquitousItemDownloadingStatus` | R | R | Read-only |
| `ubiquitousItemIsUploaded` | R | R     | Read-only |
| `ubiquitousItemIsUploading`| R | R     | Read-only |
| Extended attributes      | R/W | R/W   | POSIX `xattr` syscalls |
