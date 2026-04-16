import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'darwin_file_attributes_platform_interface.dart';
import 'src/exceptions.dart';
import 'src/file_resource_key.dart';
import 'src/file_resource_values.dart';

/// An implementation of [DarwinFileAttributesPlatform] that uses method channels.
class MethodChannelDarwinFileAttributes extends DarwinFileAttributesPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('darwin_file_attributes');

  /// Wraps a platform call, converting `FILE_NOT_FOUND` errors into
  /// [FileNotFoundException].
  Future<T> _call<T>(String path, Future<T> Function() fn) async {
    try {
      return await fn();
    } on PlatformException catch (e) {
      if (e.code == 'FILE_NOT_FOUND') {
        throw FileNotFoundException(
            path, e.message ?? 'File or directory not found');
      }
      rethrow;
    }
  }

  @override
  Future<FileResourceValues> getResourceValues(String path,
      {Set<FileResourceKey>? keys}) {
    final effectiveKeys = keys ?? FileResourceKey.values.toSet();
    return _call(path, () async {
      final result = await methodChannel
          .invokeMethod<Map<Object?, Object?>>('getResourceValues', {
        'path': path,
        'keys': effectiveKeys.map((k) => k.name).toList(),
      });
      return FileResourceValues.fromMap(result ?? {});
    });
  }

  @override
  Future<void> setResourceValues(String path, FileResourceValues values) {
    return _call(path, () async {
      await methodChannel.invokeMethod<void>(
          'setResourceValues', {'path': path, 'values': values.toMap()});
    });
  }

  @override
  Future<Uint8List?> getExtendedAttribute(String path, String name) {
    return _call(path, () async {
      return await methodChannel
          .invokeMethod<Uint8List>('getXattr', {'path': path, 'name': name});
    });
  }

  @override
  Future<void> setExtendedAttribute(String path, String name, Uint8List value) {
    return _call(path, () async {
      await methodChannel.invokeMethod<void>(
          'setXattr', {'path': path, 'name': name, 'value': value});
    });
  }

  @override
  Future<void> removeExtendedAttribute(String path, String name) {
    return _call(path, () async {
      await methodChannel
          .invokeMethod<void>('removeXattr', {'path': path, 'name': name});
    });
  }

  @override
  Future<List<String>> listExtendedAttributes(String path) {
    return _call(path, () async {
      final result = await methodChannel
          .invokeListMethod<String>('listXattr', {'path': path});
      return result ?? [];
    });
  }
}
