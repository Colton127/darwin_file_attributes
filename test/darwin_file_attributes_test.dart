import 'dart:typed_data';

import 'package:darwin_file_attributes/darwin_file_attributes.dart';
import 'package:darwin_file_attributes/darwin_file_attributes_method_channel.dart';
import 'package:darwin_file_attributes/darwin_file_attributes_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDarwinFileAttributesPlatform
    with MockPlatformInterfaceMixin
    implements DarwinFileAttributesPlatform {
  @override
  Future<FileResourceValues> getResourceValues(String path,
      {Set<FileResourceKey>? keys}) async {
    return const FileResourceValues(
        isExcludedFromBackup: true,
        isHidden: false,
        isUserImmutable: true,
        creationDate: null);
  }

  @override
  Future<void> setResourceValues(
      String path, FileResourceValues values) async {}

  @override
  Future<Uint8List?> getExtendedAttribute(String path, String name) async {
    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<void> setExtendedAttribute(
      String path, String name, Uint8List value) async {}

  @override
  Future<void> removeExtendedAttribute(String path, String name) async {}

  @override
  Future<List<String>> listExtendedAttributes(String path) async {
    return ['com.example.test'];
  }
}

void main() {
  final DarwinFileAttributesPlatform initialPlatform =
      DarwinFileAttributesPlatform.instance;

  test('MethodChannelDarwinFileAttributes is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDarwinFileAttributes>());
  });

  group('DarwinFileAttributes convenience wrappers', () {
    late DarwinFileAttributesInterface plugin;

    setUp(() {
      plugin = DarwinFileAttributesInterface();
      DarwinFileAttributesPlatform.instance =
          MockDarwinFileAttributesPlatform();
    });

    test('getIsExcludedFromBackup', () async {
      expect(await plugin.getIsExcludedFromBackup('/test'), true);
    });

    test('getIsHidden', () async {
      expect(await plugin.getIsHidden('/test'), false);
    });

    test('getIsUserImmutable', () async {
      expect(await plugin.getIsUserImmutable('/test'), true);
    });

    test('getExtendedAttribute', () async {
      final result = await plugin.getExtendedAttribute('/test', 'com.example');
      expect(result, Uint8List.fromList([1, 2, 3]));
    });

    test('listExtendedAttributes', () async {
      final result = await plugin.listExtendedAttributes('/test');
      expect(result, ['com.example.test']);
    });
  });

  group('FileResourceValues', () {
    test('fromMap parses all fields correctly', () {
      final map = <Object?, Object?>{
        'isExcludedFromBackup': true,
        'isHidden': false,
        'isUserImmutable': true,
        'creationDate': 1700000000000,
        'contentModificationDate': 1700000001000,
        'fileProtection': 'complete',
        'isUbiquitousItem': false,
        'ubiquitousItemDownloadingStatus': 'current',
        'ubiquitousItemIsUploaded': true,
        'ubiquitousItemIsUploading': false,
      };

      final values = FileResourceValues.fromMap(map);

      expect(values.isExcludedFromBackup, true);
      expect(values.isHidden, false);
      expect(values.isUserImmutable, true);
      expect(values.creationDate,
          DateTime.fromMillisecondsSinceEpoch(1700000000000));
      expect(values.contentModificationDate,
          DateTime.fromMillisecondsSinceEpoch(1700000001000));
      expect(values.fileProtection, FileProtectionType.complete);
      expect(values.isUbiquitousItem, false);
      expect(values.ubiquitousItemDownloadingStatus,
          UbiquitousItemDownloadingStatus.current);
      expect(values.ubiquitousItemIsUploaded, true);
      expect(values.ubiquitousItemIsUploading, false);
    });

    test('toMap includes only non-null writable fields', () {
      final values = FileResourceValues(
        isExcludedFromBackup: true,
        isHidden: null,
        creationDate: DateTime.fromMillisecondsSinceEpoch(1700000000000),
        fileProtection: FileProtectionType.complete,
        isUbiquitousItem: true, // read-only — must not appear in toMap
      );

      final map = values.toMap();

      expect(map['isExcludedFromBackup'], true);
      expect(map.containsKey('isHidden'), false);
      expect(map['creationDate'], 1700000000000);
      expect(map['fileProtection'], 'complete');
      expect(map.containsKey('isUbiquitousItem'), false);
    });

    test('fromMap handles empty map gracefully', () {
      final values = FileResourceValues.fromMap(<Object?, Object?>{});

      expect(values.isExcludedFromBackup, isNull);
      expect(values.isHidden, isNull);
      expect(values.creationDate, isNull);
      expect(values.fileProtection, isNull);
    });

    test('fromMap ignores unknown fileProtection values', () {
      final values = FileResourceValues.fromMap(
          <Object?, Object?>{'fileProtection': 'unknownValue'});
      expect(values.fileProtection, isNull);
    });

    test('toString includes only non-null fields', () {
      const values = FileResourceValues(isHidden: true);
      expect(values.toString(), contains('isHidden: true'));
      expect(values.toString(), isNot(contains('isExcludedFromBackup')));
    });
  });
}
