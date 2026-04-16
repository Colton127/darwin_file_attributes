import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'darwin_file_attributes_method_channel.dart';
import 'src/file_resource_key.dart';
import 'src/file_resource_values.dart';

abstract class DarwinFileAttributesPlatform extends PlatformInterface {
  /// Constructs a DarwinFileAttributesPlatform.
  DarwinFileAttributesPlatform() : super(token: _token);

  static final Object _token = Object();

  static DarwinFileAttributesPlatform _instance =
      MethodChannelDarwinFileAttributes();

  /// The default instance of [DarwinFileAttributesPlatform] to use.
  ///
  /// Defaults to [MethodChannelDarwinFileAttributes].
  static DarwinFileAttributesPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DarwinFileAttributesPlatform] when
  /// they register themselves.
  static set instance(DarwinFileAttributesPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Reads the requested resource values for the item at [path].
  ///
  /// If [keys] is `null`, all supported keys are fetched.
  Future<FileResourceValues> getResourceValues(String path,
      {Set<FileResourceKey>? keys});

  /// Writes the non-null fields of [values] to the item at [path].
  Future<void> setResourceValues(String path, FileResourceValues values);

  /// Reads the extended attribute [name] from the item at [path].
  Future<Uint8List?> getExtendedAttribute(String path, String name);

  /// Sets the extended attribute [name] on the item at [path].
  Future<void> setExtendedAttribute(String path, String name, Uint8List value);

  /// Removes the extended attribute [name] from the item at [path].
  Future<void> removeExtendedAttribute(String path, String name);

  /// Lists all extended attribute names on the item at [path].
  Future<List<String>> listExtendedAttributes(String path);
}
