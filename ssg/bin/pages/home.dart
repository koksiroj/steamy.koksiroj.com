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
  final dirsGames = language.directory.listSync().whereType<Directory>().toList();
  dirsGames.sort((dirA, dirB) {
    final fileTitleA = File(p.join(dirA.path, "title.txt"));
    final String titleA = fileTitleA.readAsStringSync().trim();
    final fileTitleB = File(p.join(dirB.path, "title.txt"));
    final String titleB = fileTitleB.readAsStringSync().trim();

    final fileLinkA = File(p.join(dirA.path, "link.txt"));
    final fileLinkB = File(p.join(dirB.path, "link.txt"));

    // If they're both the same "level", aka both are links or neither are links
    if ((fileLinkA.existsSync() && fileLinkB.existsSync()) ||
        (!fileLinkA.existsSync() && !fileLinkB.existsSync())) {
      return titleA.compareTo(titleB);
    } else {
      // They're not the same level, so the one that is a link should be prioritised
      if (fileLinkA.existsSync()) return -1;
      if (fileLinkB.existsSync()) return 1;
    }
    return 0;
  });
  return Body(
    header: Header(children: []),
    main: Main(
      children: [
        UnorderedList(
          classes: ["games"],
          items: dirsGames.map((dir) {
            final fileTitle = File(p.join(dir.path, "title.txt"));
            final String title = fileTitle.readAsStringSync().trim();

            final fileLink = File(p.join(dir.path, "link.txt"));
            final String link;
            if (fileLink.existsSync()) {
              link = fileLink.readAsStringSync().trim();
              final uri = Uri.parse(link); //verify that it's an actual proper link
              if (uri.authority != "store.steampowered.com") {
                throw Exception("The URL in `${fileLink.path} is not a valid `store.steampowered.com` URL!");
              }
            } else {
              link = p.basename(dir.path);
            }
            return _gameCard(title: title, link: link, dir: dir);
          }),
        ),
      ],
    ),
    footer: Footer(children: []),
  );
}

ListItem _gameCard({
  required String title,
  required String link,
  required Directory dir,
}) {
  final fileTags = File(p.join(dir.path, "tags.txt"));
  final String tags = fileTags.readAsStringSync().trim();
  final fileReleaseDate = File(p.join(dir.path, "release_date.txt"));
  final String releaseDate = fileReleaseDate.readAsStringSync().trim();
  return ListItem(
    children: [
      A(
        href: link,
        classes: ["game-card"],
        children: [
          Image(src: "${p.basename(dir.path)}/store_capsule_small.jpg", alt: ""),
          Div(
            classes: ["game-content"],
            children: [
              Div(
                classes: ["game-content-column", "game-info"],
                children: [
                  H3.text(title),
                  P.text(tags),
                  P.text(releaseDate),
                ],
              ),
              Div(
                classes: ["game-content-column", "game-price"],
                children: [
                  P.text("12,34€"),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
