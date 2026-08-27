import "dart:io";

import "package:path/path.dart" as p;

final class Language {
  final String code;
  final String display;
  final Directory directory;

  new({required this.code, required this.display, required this.directory});
}

final Directory _dirPages = Directory("pages");
final List<Directory> _dirsLanguages = _dirPages.listSync().whereType<Directory>().toList()
  ..sort((a, b) => a.path.compareTo(b.path));
final List<Language> languages = List.unmodifiableOf(
  _dirsLanguages.map((dir) {
    final parts = p.basename(dir.path).split(".");
    return Language(code: parts[0], display: parts[1], directory: dir);
  }),
);

class Translations {
  final File file;
  final Map<String, String> keys;

  new(this.file)
    : keys = Map.unmodifiableOf(
        Map.fromEntries(
          file
              .readAsStringSync()
              .split("\n")
              .where((str) => str.trim().isNotEmpty)
              .where((str) => !str.startsWith(RegExp(r"\s*#|//")))
              .map(
                (String line) {
                  final int colonIndex = line.indexOf(":");
                  return MapEntry(
                    line.substring(0, colonIndex).trim(),
                    line.substring(colonIndex + 1).trim(),
                  );
                },
              ),
        ),
      );

  String operator [](String key) {
    return keys[key] ??
        (throw Exception("Translation File `${file.path}` did not have a translation for `$key`!"));
  }
}
