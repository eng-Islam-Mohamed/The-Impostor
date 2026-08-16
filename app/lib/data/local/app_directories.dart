import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppDirectories {
  AppDirectories._();

  static Future<Directory>? _documentsDirectory;

  static Future<Directory> get documents {
    return _documentsDirectory ??= getApplicationDocumentsDirectory();
  }

  static Future<File> documentsFile(
    String fileName, {
    String? overridePath,
  }) async {
    if (overridePath != null) {
      return File(overridePath);
    }
    final directory = await documents;
    final permanentFile = File(
      '${directory.path}${Platform.pathSeparator}$fileName',
    );
    if (!await permanentFile.exists()) {
      final legacyFile = File(
        '${Directory.systemTemp.path}${Platform.pathSeparator}$fileName',
      );
      try {
        if (await legacyFile.exists()) {
          await permanentFile.parent.create(recursive: true);
          await legacyFile.copy(permanentFile.path);
        }
      } catch (_) {
        // A failed cache migration must not prevent normal app startup.
      }
    }
    return permanentFile;
  }
}
