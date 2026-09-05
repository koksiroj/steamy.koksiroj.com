import "dart:collection";
import "dart:io";

class KeyValueFile {
  final File _file;
  final LinkedHashMap<String, String> _keys;

  new(this._file)
    : _keys = LinkedHashMap.fromEntries(
        _file
            .readAsStringSync()
            .split("\n")
            .where((str) => str.trim().isNotEmpty)
            .where((str) => !str.startsWith(RegExp(r"\s*#")))
            .map(
              (String line) {
                final int colonIndex = line.indexOf(":");
                return MapEntry(
                  line.substring(0, colonIndex).trim(),
                  line.substring(colonIndex + 1).trim(),
                );
              },
            ),
      );

  String operator [](String key) {
    return _keys[key] ??
        (throw Exception(
          "Key-Value File `${_file.path}` did not have a key named `$key`!",
        ));
  }
}
