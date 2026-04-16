import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:darwin_file_attributes/darwin_file_attributes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _output = 'Tap the button to run the demo.';

  Future<void> _runDemo() async {
    final buf = StringBuffer();

    try {
      // Create a temporary file to work with.
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/darwin_attrs_demo.txt');
      await file.writeAsString('hello world');
      final path = file.path;
      buf.writeln('File: $path\n');

      // --- Backup exclusion ---
      await DarwinFileAttributes.setIsExcludedFromBackup(path, true);
      final excluded = await DarwinFileAttributes.getIsExcludedFromBackup(path);
      buf.writeln('isExcludedFromBackup: $excluded');

      // --- Visibility ---
      final hidden = await DarwinFileAttributes.getIsHidden(path);
      buf.writeln('isHidden: $hidden');

      // --- Dates ---
      final created = await DarwinFileAttributes.getCreationDate(path);
      buf.writeln('creationDate: $created');
      final modified = await DarwinFileAttributes.getContentModificationDate(
        path,
      );
      buf.writeln('contentModificationDate: $modified');

      // --- Extended attributes ---
      await DarwinFileAttributes.setExtendedAttribute(
        path,
        'com.example.demo',
        Uint8List.fromList(utf8.encode('demo-value')),
      );
      final xattrData = await DarwinFileAttributes.getExtendedAttribute(
        path,
        'com.example.demo',
      );
      if (xattrData != null) {
        buf.writeln('xattr com.example.demo: ${utf8.decode(xattrData)}');
      }
      final names = await DarwinFileAttributes.listExtendedAttributes(path);
      buf.writeln('xattr names: $names');

      // --- Bulk read ---
      final values = await DarwinFileAttributes.getResourceValues(
        path,
        keys: {
          FileResourceKey.isExcludedFromBackup,
          FileResourceKey.isHidden,
          FileResourceKey.isUserImmutable,
        },
      );
      buf.writeln('\nBulk read: $values');

      // Cleanup
      await DarwinFileAttributes.removeExtendedAttribute(
        path,
        'com.example.demo',
      );
      await file.delete();
    } on FileNotFoundException catch (e) {
      buf.writeln('FileNotFoundException: $e');
    } on PlatformException catch (e) {
      buf.writeln('PlatformException: ${e.message}');
    }

    if (!mounted) return;
    setState(() => _output = buf.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('darwin_file_attributes demo')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(_output, style: const TextStyle(fontFamily: 'monospace')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _runDemo,
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}
