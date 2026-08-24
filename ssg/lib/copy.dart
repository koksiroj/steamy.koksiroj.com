import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/constants.dart";

void copy(String source, String targetInBuild) {
  final dirTarget = Directory(p.joinAll([dirBuild.path, ...targetInBuild.split("/")]))..createSync();
  for (final FileSystemEntity fse in Directory(source).listSync(recursive: true)) {
    final String copyTo = p.join(dirTarget.path, p.relative(fse.path, from: source));
    switch (fse) {
      case File():
        fse.copySync(copyTo);
      case Directory():
        Directory(copyTo).createSync(recursive: true);
    }
  }
}
