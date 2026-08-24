import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/head.dart";
import "package:ssg/constants.dart";
import "package:ssg/languages.dart";
import "package:techs_html_bindings/elements.dart";

void createHomePages() {
  for (final Language language in languages) {
    _createHomePage(language);
  }
}

void _createHomePage(Language language) {
  final String indexHTML = HTML(
    lang: language.code,
    head: generateHead(
      title: "Steamy Store",
      description: "",
      extraStyles: ["home"],
    ),
    body: _generateBody(language),
  ).build();

  final Directory dirBuildLanguage = Directory(p.join(dirBuild.path, language.code))..createSync();
  File(p.join(dirBuildLanguage.path, "index.html")).writeAsStringSync(indexHTML);
}

Body _generateBody(Language language) {
  final dirsGames = language.directory.listSync().whereType<Directory>();
  return Body(
    header: Header(children: []),
    main: Main(
      children: [
        UnorderedList(
          classes: ["games"],
          items: dirsGames.map((dir) {
            final fileTitle = File(p.join(dir.path, "title.txt"));
            final String title = fileTitle.readAsStringSync().trim();
            return ListItem(children: [A.text(title, href: p.basename(dir.path))]);
          }),
        ),
      ],
    ),
    footer: Footer(children: []),
  );
}
