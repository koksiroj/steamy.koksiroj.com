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
