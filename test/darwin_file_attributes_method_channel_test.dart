import 'package:darwin_file_attributes/darwin_file_attributes.dart';
import 'package:darwin_file_attributes/darwin_file_attributes_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelDarwinFileAttributes platform =
      MethodChannelDarwinFileAttributes();
  const MethodChannel channel = MethodChannel('darwin_file_attributes');

  // ---------------------------------------------------------------------------
  // getResourceValues
  // ---------------------------------------------------------------------------

  group('getResourceValues', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'getResourceValues') {
          return <String, dynamic>{
            'isExcludedFromBackup': true,
            'isHidden': false
          };
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('returns FileResourceValues from channel response', () async {
      final values = await platform.getResourceValues('/test');
      expect(values.isExcludedFromBackup, true);
      expect(values.isHidden, false);
    });
  });

  // ---------------------------------------------------------------------------
  // setResourceValues
  // ---------------------------------------------------------------------------

  group('setResourceValues', () {
    late Map<String, dynamic> capturedValues;

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'setResourceValues') {
          capturedValues =
              Map<String, dynamic>.from(call.arguments['values'] as Map);
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('sends non-null values to channel', () async {
      await platform.setResourceValues(
          '/test',
          const FileResourceValues(
              isExcludedFromBackup: true, isHidden: false));
      expect(capturedValues['isExcludedFromBackup'], true);
      expect(capturedValues['isHidden'], false);
    });
  });

  // ---------------------------------------------------------------------------
  // Extended attributes
  // ---------------------------------------------------------------------------

  group('extended attributes', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        switch (call.method) {
          case 'getXattr':
            return Uint8List.fromList([72, 101, 108, 108, 111]);
          case 'setXattr':
            return null;
          case 'removeXattr':
            return null;
          case 'listXattr':
            return <String>['com.example.test', 'com.example.other'];
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('getExtendedAttribute returns data', () async {
      final data =
          await platform.getExtendedAttribute('/test', 'com.example.test');
      expect(data, Uint8List.fromList([72, 101, 108, 108, 111]));
    });

    test('listExtendedAttributes returns names', () async {
      final names = await platform.listExtendedAttributes('/test');
      expect(names, ['com.example.test', 'com.example.other']);
    });
  });

  // ---------------------------------------------------------------------------
  // Error handling
  // ---------------------------------------------------------------------------

  group('error handling', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        throw PlatformException(
            code: 'FILE_NOT_FOUND',
            message: 'No file or directory at path: /nonexistent');
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('getResourceValues throws FileNotFoundException', () async {
      expect(() => platform.getResourceValues('/nonexistent'),
          throwsA(isA<FileNotFoundException>()));
    });

    test('setResourceValues throws FileNotFoundException', () async {
      expect(
          () => platform.setResourceValues(
              '/nonexistent', const FileResourceValues(isHidden: true)),
          throwsA(isA<FileNotFoundException>()));
    });

    test('getExtendedAttribute throws FileNotFoundException', () async {
      expect(() => platform.getExtendedAttribute('/nonexistent', 'com.example'),
          throwsA(isA<FileNotFoundException>()));
    });

    test('listExtendedAttributes throws FileNotFoundException', () async {
      expect(() => platform.listExtendedAttributes('/nonexistent'),
          throwsA(isA<FileNotFoundException>()));
    });
  });
}
