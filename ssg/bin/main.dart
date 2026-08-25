import "package:ssg/constants.dart";
import "package:ssg/copy.dart";
import "package:ssg/log.dart";
import "package:techs_html_bindings/elements.dart";

import "pages/404.dart";
import "pages/game.dart";
import "pages/home.dart";
import "pages/language_select.dart";

Future<void> main(List<String> arguments) async {
  if (dirBuild.existsSync()) {
    dirBuild.deleteSync(recursive: true);
  }
  dirBuild.createSync();

  log.info("Starting generation...");

  copy("ssg/copy", "");
  copy("ssg/styles", "styles");

  Hn.autoLinkClass = "";
  create404();
  createLanguageSelectPage();
  createHomePages();
  await createGamesPages();

  log.info("Done with generation!");
}
