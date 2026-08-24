import "package:ssg/constants.dart";
import "package:ssg/copy.dart";
import "package:ssg/log.dart";

import "pages/404.dart";
import "pages/language_select.dart";

Future<void> main(List<String> arguments) async {
  if (dirBuild.existsSync()) {
    dirBuild.deleteSync(recursive: true);
  }
  dirBuild.createSync();

  log.info("Starting generation...");

  copy("ssg/copy", "");
  copy("ssg/styles", "styles");

  await createLanguageSelectPage();
  await create404();

  log.info("Done with generation!");
}
