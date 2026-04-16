import 'dart:io';

/// Exception thrown when a file or directory does not exist at the given path.
///
/// All [DarwinFileAttributes] methods require the target file or directory to
/// already exist on disk. If the path does not point to an existing file-system
/// entity, this exception is thrown.
class FileNotFoundException implements IOException {
  /// The path that could not be found.
  final String path;

  /// A human-readable description of the error.
  final String message;

  /// Creates a [FileNotFoundException] for [path].
  const FileNotFoundException(this.path,
      [this.message = 'File or directory not found']);

  @override
  String toString() => 'FileNotFoundException: $message (path: $path)';
}
