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

  String? optional(String key) {
    return _keys[key];
  }

  LinkedHashMap<String, String> getWithPrefix(String prefix) {
    final LinkedHashMap<String, String> result = LinkedHashMap<String, String>();
    _keys.forEach((String key, String value) {
      if (key.startsWith(prefix)) {
        result[key.replaceFirst(prefix, "")] = value;
      }
    });
    return result;
  }

  @override
  String toString({bool showKeys = true}) {
    if (showKeys) {
      return "KeyValueFile(file: `${_file.path}`, keys: $_keys)";
    } else {
      return "KeyValueFile(file: `${_file.path}`)";
    }
  }
}
